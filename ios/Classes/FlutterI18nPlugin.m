#import "FlutterI18nPlugin.h"
#if __has_include(<flutter_i18n/flutter_i18n-Swift.h>)
#import <flutter_i18n/flutter_i18n-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_i18n-Swift.h"
#endif

@implementation FlutterI18nPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterI18nPlugin registerWithRegistrar:registrar];
}
@end
