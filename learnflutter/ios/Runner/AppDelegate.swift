import ActivityKit
import Flutter
import GoogleMaps
import UIKit
import UserNotifications

// MARK: - LiveActivityAttributes
// Định nghĩa trong Runner target — trùng tên + layout với Extension, ActivityKit match theo Codable.
@available(iOS 17.0, *)
struct LiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var status: String
        var eta: String
        var progress: Double
    }
    var title: String
    var subtitle: String
}

// MARK: - AppDelegate

@main
@objc class AppDelegate: FlutterAppDelegate {

    // Lưu [String: Any] tránh @available trên stored property.
    private var liveActivities: [String: Any] = [:]

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GMSServices.provideAPIKey("AIzaSyAZXckNX4q4JSz30_6b2BvdDMUT-JzrUNM")
        GeneratedPluginRegistrant.register(with: self)

        if let registrar = self.registrar(forPlugin: "ScannerBridge") {
            ScannerBridge.shared.register(with: registrar)
        }

        UNUserNotificationCenter.current().delegate = self

        // Live Activity bridge
        if let controller = window?.rootViewController as? FlutterViewController {
            let channel = FlutterMethodChannel(
                name: "live_activity",
                binaryMessenger: controller.binaryMessenger
            )
            channel.setMethodCallHandler { [weak self] call, result in
                guard let self else { return }
                let args = call.arguments as? [String: Any]
                switch call.method {
                case "start":    self.startLiveActivity(args: args, result: result)
                case "update":   self.updateLiveActivity(args: args, result: result)
                case "end":      self.endLiveActivity(args: args, result: result)
                case "areEnabled":
                    if #available(iOS 17.0, *) {
                        result(ActivityAuthorizationInfo().areActivitiesEnabled)
                    } else {
                        result(false)
                    }
                default:
                    result(FlutterMethodNotImplemented)
                }
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // MARK: - URL Scheme (Share Extension → app)

    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        // learnflutter://shared — triggered by ShareViewController after saving to App Group
        if url.scheme == "learnflutter" && url.host == "shared" {
            return true // receive_sharing_intent handles reading the data
        }
        return super.application(app, open: url, options: options)
    }

    // MARK: - Live Activity handlers

    private func startLiveActivity(args: [String: Any]?, result: @escaping FlutterResult) {
        guard #available(iOS 17.0, *) else { result(nil); return }
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { result(nil); return }

        let attrs = LiveActivityAttributes(
            title: args?["title"] as? String ?? "",
            subtitle: args?["subtitle"] as? String ?? ""
        )
        let initialState = LiveActivityAttributes.ContentState(
            status: "Đang chuẩn bị",
            eta: "--",
            progress: 0.0
        )
        do {
            let activity = try Activity<LiveActivityAttributes>.request(
                attributes: attrs,
                content: ActivityContent(state: initialState, staleDate: nil),
                pushType: nil
            )
            liveActivities[activity.id] = activity
            result(activity.id)
        } catch {
            result(FlutterError(code: "START_FAILED", message: error.localizedDescription, details: nil))
        }
    }

    private func updateLiveActivity(args: [String: Any]?, result: @escaping FlutterResult) {
        guard #available(iOS 17.0, *) else { result(nil); return }
        guard let id = args?["id"] as? String,
              let activity = liveActivities[id] as? Activity<LiveActivityAttributes> else {
            result(nil); return
        }
        let newState = LiveActivityAttributes.ContentState(
            status: args?["status"] as? String ?? "",
            eta: args?["eta"] as? String ?? "",
            progress: args?["progress"] as? Double ?? 0.0
        )
        Task {
            await activity.update(ActivityContent(state: newState, staleDate: nil))
            result(nil)
        }
    }

    private func endLiveActivity(args: [String: Any]?, result: @escaping FlutterResult) {
        guard #available(iOS 17.0, *) else { result(nil); return }
        guard let id = args?["id"] as? String,
              let activity = liveActivities[id] as? Activity<LiveActivityAttributes> else {
            result(nil); return
        }
        Task {
            await activity.end(dismissalPolicy: .immediate)
            self.liveActivities.removeValue(forKey: id)
            result(nil)
        }
    }

    // MARK: - UNUserNotificationCenterDelegate

    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        NSLog("🟡 willPresent category='%@' title='%@'",
              notification.request.content.categoryIdentifier,
              notification.request.content.title)
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .badge, .list])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }

    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let action   = response.actionIdentifier
        let category = response.notification.request.content.categoryIdentifier
        NSLog("🟢 didReceive action='%@' category='%@'", action, category)
        completionHandler()
    }
}
