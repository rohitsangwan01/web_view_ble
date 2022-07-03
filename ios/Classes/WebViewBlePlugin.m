#import "WebViewBlePlugin.h"
#if __has_include(<web_view_ble/web_view_ble-Swift.h>)
#import <web_view_ble/web_view_ble-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "web_view_ble-Swift.h"
#endif

@implementation WebViewBlePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftWebViewBlePlugin registerWithRegistrar:registrar];
}
@end
