import Foundation
import ARKit
import ModelIO
import MetalKit
import simd

enum ScannerExporter {

    // MARK: - OBJ

    static func writeOBJ(meshAnchors: [ARMeshAnchor], to url: URL) throws {
        var text = "# Scan export (world space)\n"
        var vertexOffset: UInt32 = 0

        for anchor in meshAnchors {
            let geom = anchor.geometry
            let transform = anchor.transform

            let vCount = geom.vertices.count
            let vBase = geom.vertices.buffer.contents().advanced(by: geom.vertices.offset)
            let vStride = geom.vertices.stride

            for i in 0..<vCount {
                let ptr = vBase.advanced(by: i * vStride).assumingMemoryBound(to: SIMD3<Float>.self)
                let local = ptr.pointee
                let world = transform * SIMD4<Float>(local, 1)
                text += "v \(world.x) \(world.y) \(world.z)\n"
            }

            let faceCount = geom.faces.count
            let ipp = geom.faces.indexCountPerPrimitive
            let bpi = geom.faces.bytesPerIndex
            let fBase = geom.faces.buffer.contents()

            for f in 0..<faceCount {
                var parts = "f"
                for j in 0..<ipp {
                    let byteOffset = (f * ipp + j) * bpi
                    let idx: UInt32
                    switch bpi {
                    case 4:
                        idx = fBase.advanced(by: byteOffset).assumingMemoryBound(to: UInt32.self).pointee
                    case 2:
                        let s = fBase.advanced(by: byteOffset).assumingMemoryBound(to: UInt16.self).pointee
                        idx = UInt32(s)
                    default:
                        throw ScannerError.exportFailed("unexpected bytesPerIndex=\(bpi)")
                    }
                    parts += " \(idx + vertexOffset + 1)" // OBJ is 1-indexed
                }
                text += parts + "\n"
            }

            vertexOffset += UInt32(vCount)
        }

        try text.write(to: url, atomically: true, encoding: .utf8)
    }

    // MARK: - USDZ

    static func writeUSDZ(meshAnchors: [ARMeshAnchor], to url: URL) throws {
        guard let device = MTLCreateSystemDefaultDevice() else {
            throw ScannerError.exportFailed("no Metal device")
        }
        let allocator = MTKMeshBufferAllocator(device: device)
        let asset = MDLAsset(bufferAllocator: allocator)

        for anchor in meshAnchors {
            let mesh = try anchor.geometry.toMDLMesh(
                allocator: allocator,
                transform: anchor.transform
            )
            asset.add(mesh)
        }

        // ModelIO picks format from extension; .usdz is supported on iOS 13+.
        try asset.export(to: url)
    }
}

private extension ARMeshGeometry {
    /// Build an MDLMesh with vertices baked into world space using `transform`.
    func toMDLMesh(allocator: MTKMeshBufferAllocator, transform: simd_float4x4) throws -> MDLMesh {
        let vCount = vertices.count
        let stride = MemoryLayout<SIMD3<Float>>.stride

        // Bake world-space vertices into a fresh buffer.
        var world = [SIMD3<Float>](repeating: .zero, count: vCount)
        let vBase = vertices.buffer.contents().advanced(by: vertices.offset)
        for i in 0..<vCount {
            let p = vBase.advanced(by: i * vertices.stride)
                .assumingMemoryBound(to: SIMD3<Float>.self).pointee
            let w = transform * SIMD4<Float>(p, 1)
            world[i] = SIMD3<Float>(w.x, w.y, w.z)
        }
        let vData = Data(bytes: &world, count: stride * vCount)
        let vBuffer = allocator.newBuffer(with: vData, type: .vertex)

        // Index buffer: normalize to UInt32 for portability.
        let faceCount = faces.count
        let ipp = faces.indexCountPerPrimitive
        let indexCount = faceCount * ipp
        var idx32 = [UInt32](repeating: 0, count: indexCount)
        let fBase = faces.buffer.contents()
        for i in 0..<indexCount {
            switch faces.bytesPerIndex {
            case 4:
                idx32[i] = fBase.advanced(by: i * 4).assumingMemoryBound(to: UInt32.self).pointee
            case 2:
                idx32[i] = UInt32(fBase.advanced(by: i * 2).assumingMemoryBound(to: UInt16.self).pointee)
            default:
                throw ScannerError.exportFailed("unexpected bytesPerIndex=\(faces.bytesPerIndex)")
            }
        }
        let iData = Data(bytes: &idx32, count: indexCount * MemoryLayout<UInt32>.size)
        let iBuffer = allocator.newBuffer(with: iData, type: .index)

        let submesh = MDLSubmesh(
            indexBuffer: iBuffer,
            indexCount: indexCount,
            indexType: .uInt32,
            geometryType: .triangles,
            material: nil
        )

        let vDesc = MDLVertexDescriptor()
        vDesc.attributes[0] = MDLVertexAttribute(
            name: MDLVertexAttributePosition,
            format: .float3,
            offset: 0,
            bufferIndex: 0
        )
        vDesc.layouts[0] = MDLVertexBufferLayout(stride: stride)

        return MDLMesh(
            vertexBuffer: vBuffer,
            vertexCount: vCount,
            descriptor: vDesc,
            submeshes: [submesh]
        )
    }
}
