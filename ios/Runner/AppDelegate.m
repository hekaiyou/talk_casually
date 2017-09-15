#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  // 启动图片延时: 1秒
  [NSThread sleepForTimeInterval:1];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
