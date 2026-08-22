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

    // Register notification categories cho Content Extension
    let openAction    = UNNotificationAction(identifier: "ACTION_OPEN",    title: "Mở",     options: [.foreground])
    let dismissAction = UNNotificationAction(identifier: "ACTION_DISMISS", title: "Bỏ qua", options: [.destructive])
    let okAction      = UNNotificationAction(identifier: "ACTION_OK",      title: "OK",     options: [.destructive])
    let viewAction    = UNNotificationAction(identifier: "ACTION_VIEW",    title: "Xem ngay", options: [.foreground])

    let categories: Set<UNNotificationCategory> = [
      UNNotificationCategory(identifier: "NOTIF_INFO",    actions: [openAction, dismissAction], intentIdentifiers: [], options: []),
      UNNotificationCategory(identifier: "NOTIF_SUCCESS", actions: [okAction],                  intentIdentifiers: [], options: []),
      UNNotificationCategory(identifier: "NOTIF_WARNING", actions: [viewAction, dismissAction], intentIdentifiers: [], options: []),
      UNNotificationCategory(identifier: "NOTIF_PROMO",   actions: [viewAction, dismissAction], intentIdentifiers: [], options: []),
    ]
    UNUserNotificationCenter.current().setNotificationCategories(categories)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Cho phép show banner + sound + badge khi app đang foreground.
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .sound, .badge, .list])
    } else {
      completionHandler([.alert, .sound, .badge])
    }
  }
}
