import UIKit
import Flutter
import GoogleMaps
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate{
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      FirebaseApp.configure()
    if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
      }
      let controller : FlutterViewController = window.rootViewController as! FlutterViewController
      let flavorChannel = FlutterMethodChannel(name: "flavor", binaryMessenger: controller.binaryMessenger)
      flavorChannel.setMethodCallHandler({ (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
          result(Bundle.main.infoDictionary?["Flavor"])
      })
    GMSServices.provideAPIKey("AIzaSyBfGcLifwtUjNLzuCiCUbbBYcoVe6Xj4vc")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

