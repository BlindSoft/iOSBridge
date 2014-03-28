// This is best place to control application events
#import "UIKitAppDelegate.h"
#import "TestViewController.h"

// UIApplicationDelegate simulation class object
@implementation UIKitAppDelegate

// Tells the delegate that the launch process is almost done and the app is almost ready to run.
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.autostartUIKit = YES; // Autostart UIKit
	self.rootViewController = nil; // Add root view controller initialization
    self.overlayView = nil; // Add overlay view initialization
        
    return YES;
}

// Got message from unity
- (void)didGotMessageFromUnity: (NSString*)message {
    
}

- (void)didLoadLevel: (NSString*)loadLevel {
    
}

@end
