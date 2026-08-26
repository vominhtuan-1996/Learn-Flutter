import ActivityKit
import Foundation

/// ActivityAttributes cho delivery / progress tracking use case.
/// Static: title + subtitle (không đổi suốt vòng đời activity).
/// ContentState: status, eta, progress (update real-time).
struct LiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var status: String
        var eta: String
        /// 0.0 → 1.0
        var progress: Double
    }

    var title: String
    var subtitle: String
}
