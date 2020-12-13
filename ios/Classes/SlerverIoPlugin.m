#import "SlerverIoPlugin.h"
#if __has_include(<slerver_io/slerver_io-Swift.h>)
#import <slerver_io/slerver_io-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "slerver_io-Swift.h"
#endif

@implementation SlerverIoPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSlerverIoPlugin registerWithRegistrar:registrar];
}
@end
