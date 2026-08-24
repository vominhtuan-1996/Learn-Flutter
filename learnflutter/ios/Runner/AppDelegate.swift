import Flutter
import UIKit
import GoogleMaps
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyAZXckNX4q4JSz30_6b2BvdDMUT-JzrUNM")
    GeneratedPluginRegistrant.register(with: self)

    if let registrar = self.registrar(forPlugin: "ScannerBridge") {
      ScannerBridge.shared.register(with: registrar)
    }

    // Set delegate trước khi plugin init để foreground notifications hiển thị.
    UNUserNotificationCenter.current().delegate = self

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Cho phép show banner + sound + badge khi app đang foreground.
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
