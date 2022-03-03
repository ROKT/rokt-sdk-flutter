import Flutter
import UIKit
import Rokt_Widget

public class SwiftRoktSdkPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "rokt_sdk", binaryMessenger: registrar.messenger())
        let instance = SwiftRoktSdkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "initialize" {
            
            if let args = call.arguments as? Dictionary<String, Any>,
               let roktTagId = args["roktTagId"] as? String {
                Rokt.initWith(roktTagId: roktTagId)
                print(roktTagId)
                result("success")
            } else {
                result("fail")
            }
            
        }else if call.method == "execute" {
            if let args = call.arguments as? Dictionary<String, Any>,
               let viewName = args["viewName"] as? String,
               let attributes = args["attributes"] as? [String: String]{
                Rokt.execute(viewName: viewName, attributes: attributes, onLoad: {
                    // Optional callback for when the Rokt placement loads
                    print("loaded")
                }, onUnLoad: {
                    // Optional callback for when the Rokt placement unloads
                    print("unloaded")
                }, onShouldShowLoadingIndicator: {
                    // Optional callback to show a loading indicator
                }, onShouldHideLoadingIndicator: {
                    // Optional callback to hide a loading indicator
                })
                
                result("success")
            } else {
                result("fail")
            }
        }else {
            result("iOS " + UIDevice.current.systemVersion)
        }
    }
}
