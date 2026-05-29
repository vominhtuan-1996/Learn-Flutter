import UIKit
import ARKit
import SceneKit
import ModelIO
import MetalKit

final class ScannerViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    private let sceneView = ARSCNView(frame: .zero)
    private let statusLabel = UILabel()
    private let closeButton = UIButton(type: .system)

    private var isRunning = false

    deinit { sceneView.session.pause() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        sceneView.translatesAutoresizingMaskIntoConstraints = false
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        sceneView.debugOptions = [.showWorldOrigin]
        view.addSubview(sceneView)

        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.textColor = .white
        statusLabel.font = .systemFont(ofSize: 14, weight: .medium)
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        statusLabel.layer.cornerRadius = 8
        statusLabel.layer.masksToBounds = true
        view.addSubview(statusLabel)

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        closeButton.layer.cornerRadius = 16
        closeButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 14, bottom: 6, right: 14)
        closeButton.addTarget(self, action: #selector(onClose), for: .touchUpInside)
        view.addSubview(closeButton)

        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            statusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            statusLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 36),

            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])

        setStatus("Move device slowly to scan surroundings…")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startSession()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSession()
    }

    // MARK: - Session

    func startSession() {
        guard ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) else {
            setStatus("This device does not support LiDAR scene reconstruction.")
            return
        }
        let config = ARWorldTrackingConfiguration()
        config.sceneReconstruction = .mesh
        config.environmentTexturing = .automatic
        config.planeDetection = [.horizontal, .vertical]
        sceneView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
        isRunning = true
    }

    func stopSession() {
        sceneView.session.pause()
        isRunning = false
    }

    @objc private func onClose() { dismiss(animated: true) }

    private func setStatus(_ text: String) {
        DispatchQueue.main.async { self.statusLabel.text = " \(text) " }
    }

    // MARK: - Export

    /// Export the current mesh. `format` is "obj" or "usdz". Returns the file path via completion.
    func exportModel(format: String, completion: @escaping (Result<String, Error>) -> Void) {
        let meshAnchors = (sceneView.session.currentFrame?.anchors ?? []).compactMap { $0 as? ARMeshAnchor }
        guard !meshAnchors.isEmpty else {
            completion(.failure(ScannerError.noMesh))
            return
        }

        let fileName = "scan-\(Int(Date().timeIntervalSince1970)).\(format)"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                switch format.lowercased() {
                case "obj":
                    try ScannerExporter.writeOBJ(meshAnchors: meshAnchors, to: url)
                case "usdz":
                    try ScannerExporter.writeUSDZ(meshAnchors: meshAnchors, to: url)
                default:
                    throw ScannerError.unsupportedFormat(format)
                }
                DispatchQueue.main.async { completion(.success(url.path)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }

    // MARK: - ARSessionDelegate

    func session(_ session: ARSession, didFailWithError error: Error) {
        setStatus("Session error: \(error.localizedDescription)")
    }

    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .normal: setStatus("Tracking normal. Keep moving to capture mesh.")
        case .limited(let reason): setStatus("Tracking limited: \(reason)")
        case .notAvailable: setStatus("Tracking not available")
        }
    }
}

enum ScannerError: LocalizedError {
    case noMesh
    case unsupportedFormat(String)
    case exportFailed(String)

    var errorDescription: String? {
        switch self {
        case .noMesh: return "No mesh captured yet. Scan more of the environment first."
        case .unsupportedFormat(let f): return "Unsupported export format: \(f)"
        case .exportFailed(let m): return "Export failed: \(m)"
        }
    }
}
