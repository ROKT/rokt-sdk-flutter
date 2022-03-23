#import "RoktSdkPlugin.h"
#if __has_include(<rokt_sdk/rokt_sdk-Swift.h>)
#import <rokt_sdk/rokt_sdk-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "rokt_sdk-Swift.h"
#endif

@implementation RoktSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftRoktSdkPlugin registerWithRegistrar:registrar];
}
@end
