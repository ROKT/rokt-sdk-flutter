import UIKit
import Flutter
import rokt_sdk
import RoktStripePaymentExtension

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    SwiftRoktSdkPlugin.paymentExtensionFactory = { type, config in
      switch type {
      case "stripe":
        return RoktStripePaymentExtension(
          applePayMerchantId: "merchant.com.runner.rokt"
        )
      default:
        return nil
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
