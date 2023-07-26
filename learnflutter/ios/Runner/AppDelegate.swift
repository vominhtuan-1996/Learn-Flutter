import UIKit
import flutter_isolate
import Flutter
import flutter_local_notifications
import workmanager
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      GeneratedPluginRegistrant.register(with: self)
//    WorkmanagerPlugin.registerTask(withIdentifier: "task-identifier")
//    application.setMinimumBackgroundFetchInterval(TimeInterval(MiniIn))
      application.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
    UNUserNotificationCenter.current().delegate = self
      WorkmanagerPlugin.setPluginRegistrantCallback { registry in
          // The following code will be called upon WorkmanagerPlugin's registration.
          // Note : all of the app's plugins may not be required in this context ;
          // instead of using GeneratedPluginRegistrant.register(with: registry),
          // you may want to register only specific plugins.
          AppDelegate.registerPlugins(with: registry)
      }
      FlutterIsolatePlugin.isolatePluginRegistrantClassName = "IsolatePluginRegistrant"
      FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
          GeneratedPluginRegistrant.register(with: registry)}
      
      WorkmanagerPlugin.registerTask(withIdentifier: "be.tramckrijte.workmanagerExample.taskId")
      WorkmanagerPlugin.registerTask(withIdentifier: "be.tramckrijte.workmanagerExample.simpleTask")
      WorkmanagerPlugin.registerTask(withIdentifier: "be.tramckrijte.workmanagerExample.rescheduledTask")
      WorkmanagerPlugin.registerTask(withIdentifier: "be.tramckrijte.workmanagerExample.failedTask")
      WorkmanagerPlugin.registerTask(withIdentifier: "be.tramckrijte.workmanagerExample.simpleDelayedTask")
      WorkmanagerPlugin.registerTask(withIdentifier: "be.tramckrijte.workmanagerExample.simplePeriodicTask")
      WorkmanagerPlugin.registerTask(withIdentifier: "be.tramckrijte.workmanagerExample.simplePeriodic1HourTask")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    static func registerPlugins(with registry: FlutterPluginRegistry) {
                GeneratedPluginRegistrant.register(with: registry)
           }
    override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                         willPresent notification: UNNotification,
                                         withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
         completionHandler(.alert) // shows banner even if app is in foreground
     }
    
}
