import SwiftUI
import MapKit
import UniformTypeIdentifiers

// MARK: - Data model
struct SharePreviewItem {
    let type: ShareItemType
    let value: String
    var coordinate: CLLocationCoordinate2D? // only for .location

    enum ShareItemType { case url, text, image, file, location }

    var icon: String {
        switch type {
        case .url:      return "link"
        case .text:     return "text.alignleft"
        case .image:    return "photo"
        case .file:     return "doc"
        case .location: return "location.fill"
        }
    }

    var typeLabel: String {
        switch type {
        case .url:      return "URL"
        case .text:     return "Text"
        case .image:    return "Hình ảnh"
        case .file:     return "File"
        case .location: return "Vị trí"
        }
    }
}

// MARK: - Parse Google Maps / Apple Maps URL → CLLocationCoordinate2D
func parseLocationURL(_ urlString: String) -> CLLocationCoordinate2D? {
    guard let url = URL(string: urlString) else { return nil }
    let host = url.host ?? ""
    var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
    let params = components?.queryItems?.reduce(into: [String: String]()) { $0[$1.name] = $1.value } ?? [:]

    if host.contains("google") {
        // ?q=lat,lng
        if let q = params["q"] {
            let parts = q.split(separator: ",")
            if parts.count >= 2, let lat = Double(parts[0].trimmingCharacters(in: .whitespaces)),
               let lng = Double(parts[1].trimmingCharacters(in: .whitespaces)) {
                return CLLocationCoordinate2D(latitude: lat, longitude: lng)
            }
        }
        // /place/.../@lat,lng,zoom
        if let match = url.path.range(of: #"@(-?\d+\.\d+),(-?\d+\.\d+)"#, options: .regularExpression) {
            let captured = String(url.path[match])
            let nums = captured.dropFirst().split(separator: ",")
            if nums.count >= 2, let lat = Double(nums[0]), let lng = Double(nums[1]) {
                return CLLocationCoordinate2D(latitude: lat, longitude: lng)
            }
        }
    }

    if host.contains("apple") {
        // ?ll=lat,lng
        if let ll = params["ll"] {
            let parts = ll.split(separator: ",")
            if parts.count >= 2, let lat = Double(parts[0]), let lng = Double(parts[1]) {
                return CLLocationCoordinate2D(latitude: lat, longitude: lng)
            }
        }
    }
    return nil
}

// MARK: - Root share view
struct ShareView: View {
    let items: [SharePreviewItem]
    let onShare: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Handle bar
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(.systemGray4))
                .frame(width: 40, height: 5)
                .padding(.top, 10)

            // Header
            HStack {
                Button("Huỷ", action: onCancel).foregroundColor(.red)
                Spacer()
                Text("Chia sẻ").font(.headline)
                Spacer()
                Button(action: onShare) {
                    Text("Gửi")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16).padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(20)
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 14)

            Divider()

            // App badge
            HStack(spacing: 12) {
                Image(systemName: "square.and.arrow.up.circle.fill")
                    .font(.system(size: 36)).foregroundColor(.blue)
                VStack(alignment: .leading, spacing: 2) {
                    Text("LearnFlutter").font(.subheadline).fontWeight(.semibold)
                    Text("Nhận nội dung được chia sẻ").font(.caption).foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal, 16).padding(.vertical, 14)

            Divider()

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                        ShareItemRow(item: item)
                    }
                }
                .padding(16)
            }

            Spacer(minLength: 0)
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Single item row
struct ShareItemRow: View {
    let item: SharePreviewItem

    var body: some View {
        if item.type == .location, let coord = item.coordinate {
            LocationRow(item: item, coordinate: coord)
        } else {
            DefaultRow(item: item)
        }
    }
}

// MARK: - Location row with MapKit preview
struct LocationRow: View {
    let item: SharePreviewItem
    let coordinate: CLLocationCoordinate2D

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Map
            Map(coordinateRegion: .constant(MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            )), annotationItems: [MapPin(coordinate: coordinate)]) { pin in
                MapMarker(coordinate: pin.coordinate, tint: .red)
            }
            .frame(height: 180)
            .cornerRadius(12, corners: [.topLeft, .topRight])
            .disabled(true) // non-interactive in extension

            // Info
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.red)
                        .frame(width: 36, height: 36)
                    Image(systemName: "location.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("VỊ TRÍ")
                        .font(.caption).fontWeight(.bold).foregroundColor(.secondary)
                    Text(String(format: "%.6f, %.6f", coordinate.latitude, coordinate.longitude))
                        .font(.subheadline)
                }
                Spacer()
            }
            .padding(12)
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Default row (url / text / image / file)
struct DefaultRow: View {
    let item: SharePreviewItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10).fill(iconBg).frame(width: 44, height: 44)
                Image(systemName: item.icon).font(.system(size: 18)).foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(item.typeLabel).font(.caption).fontWeight(.semibold).foregroundColor(.secondary)
                if item.type == .image, let uiImage = UIImage(contentsOfFile: item.value) {
                    Image(uiImage: uiImage)
                        .resizable().scaledToFill()
                        .frame(maxWidth: .infinity).frame(height: 140)
                        .clipped().cornerRadius(8)
                } else {
                    Text(item.value)
                        .font(.subheadline).foregroundColor(.primary)
                        .lineLimit(4).multilineTextAlignment(.leading)
                }
            }
            Spacer()
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private var iconBg: Color {
        switch item.type {
        case .url:      return .blue
        case .text:     return .orange
        case .image:    return .purple
        case .file:     return .green
        case .location: return .red
        }
    }
}

// MARK: - Helpers
struct MapPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
