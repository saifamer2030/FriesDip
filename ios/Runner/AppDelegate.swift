import UIKit
import Flutter
import Firebase
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    GMSServices.provideAPIKey("AIzaSyC33k9kkicraYbyjHQjvaQFqL7TZN7sgcY")
      if #available(iOS 10.0, *) {
          UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
      } else {
          // Fallback on earlier versions
      }
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
      override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

         Messaging.messaging().apnsToken = deviceToken
         super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
       }
  //
  //     // MARK: - UNUserNotificationCenterDelegate Method
  //    override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
  //            completionHandler([.alert])
  //        }
  //
  //    override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
  //
  //         }
  }

