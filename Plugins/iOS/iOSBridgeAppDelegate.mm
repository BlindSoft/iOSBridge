#import "iOSBridgeAppDelegate.h"
#import "UIKitAppDelegate.h"

#pragma mark Unity native plugin

extern "C" {

// Received message from Unity
// message - parameter string to be transfered to UIKit
void iOSBridgeSendMessageToUIKit( const char * message ){
    NSCAssert([[UIApplication sharedApplication].delegate isKindOfClass:[iOSBridgeAppDelegate class]], @"iOSBridge // ERROR // AppDelegate name in main.mm should be changed to iOSBridgeAppDelegate");    
    if ([[UIApplication sharedApplication].delegate isKindOfClass:[iOSBridgeAppDelegate class]]) {
        if ([(iOSBridgeAppDelegate *)[UIApplication sharedApplication].delegate respondsToSelector: @selector(messageFromUnity:)]) {
            [(iOSBridgeAppDelegate *)[UIApplication sharedApplication].delegate messageFromUnity: [NSString stringWithCString:message encoding: NSUTF8StringEncoding]];
        }
    }
}

// Open UIKit frontend and pause Unity
// data - parameter to be transfered to UIKit
void iOSBridgeFinishUnity( const char * data ) {
    NSCAssert([[UIApplication sharedApplication].delegate isKindOfClass:[iOSBridgeAppDelegate class]], @"iOSBridge // ERROR // AppDelegate name in main.mm should be changed to iOSBridgeAppDelegate");
    if ([[UIApplication sharedApplication].delegate isKindOfClass:[iOSBridgeAppDelegate class]]) {
        if ([(iOSBridgeAppDelegate *)[UIApplication sharedApplication].delegate respondsToSelector: @selector(launchFrontend)]) {
            [(iOSBridgeAppDelegate *)[UIApplication sharedApplication].delegate launchFrontend];
        }
    }
}

// Unity finished level loading
void iOSBridgeLoadLevelComplete( const char * levelName ) {
    NSCAssert([[UIApplication sharedApplication].delegate isKindOfClass:[iOSBridgeAppDelegate class]], @"iOSBridge // ERROR // AppDelegate name in main.mm should be changed to iOSBridgeAppDelegate");    
    if ([[UIApplication sharedApplication].delegate isKindOfClass:[iOSBridgeAppDelegate class]]) {
        if ([(iOSBridgeAppDelegate *)[UIApplication sharedApplication].delegate respondsToSelector: @selector(launchUnity)]) {
            [(iOSBridgeAppDelegate *)[UIApplication sharedApplication].delegate launchUnity];
        }
        if ([(iOSBridgeAppDelegate *)[UIApplication sharedApplication].delegate respondsToSelector: @selector(didLoadLevel:)]) {
            [(iOSBridgeAppDelegate *)[UIApplication sharedApplication].delegate didLoadLevel:[NSString stringWithCString:levelName encoding: NSUTF8StringEncoding]];
        }
    }
}
    
}

// Unity's pause function
void UnityPause(bool pause);

#pragma mark iOS Bridge App Delegate

// Application delegate
@interface iOSBridgeAppDelegate() {
    BOOL firstLaunch;
}

// UIApplicationDelegate simulation class object
@property (nonatomic,strong) UIKitAppDelegate *uikitDelegate;

@end

// Application delegate
@implementation iOSBridgeAppDelegate
@synthesize RootViewController = _RootViewController;

// Application initialization
- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    // Unity's initialization
    BOOL result = [super application: application didFinishLaunchingWithOptions: launchOptions];
    
    firstLaunch = YES;
    
    // Get created window
    window = [UIApplication sharedApplication].keyWindow;
    
    // Unity is initially active
    UnityActive = YES;
    // Init application delegate simulation
    self.uikitDelegate = [[UIKitAppDelegate alloc] init];
    // Call initialization method of application delegate
    if ([self.uikitDelegate respondsToSelector: @selector(application:didFinishLaunchingWithOptions:)]){
        result &= [self.uikitDelegate application: application didFinishLaunchingWithOptions: launchOptions];
    }
    
    return result;
}

// Start UIKit
- (void)launchFrontend
{
    // If Unity view is not yet set
    if (unityView == nil) {
        // Select first view
        if (window.subviews.count != 0) {
            unityView = window.subviews[0];
        }
    }
    
    if (firstLaunch) {
        firstLaunch = NO;
        if (!self.uikitDelegate.autostartUIKit) {
            [self launchUnity];
            return;
        }
    }
    
    
    // Hide unity view
    unityView.hidden = YES;
    
    // Add rootViewController.view to windows if it's not added
    if (![window.subviews containsObject: self.uikitDelegate.rootViewController.view]) {
        [window addSubview: self.uikitDelegate.rootViewController.view];
    }
    // Pause unity
    [self cleanupUnity];
    // Bring rootViewController.view to front
    [window bringSubviewToFront: self.RootViewController.view];
}

// Start Unity's current scene
- (void)launchUnity
{
    // Show unity view
    unityView.hidden = NO;
    
    // Add overlay view
    if (coverView == nil) {
        coverView = self.uikitDelegate.overlayView;
        [unityView addSubview: coverView];
    }
    // Bring Unity view to front
    [window bringSubviewToFront: unityView];
    // Cleanup UIKit if needed
	[self cleanupFrontend];
    // Resume Unity
	[self setActiveState: true];
}

// This method loads level and switched to Unity on load complete
- (void)loadLevel: (NSString*)levelName {
	[self setActiveState: true];
    UnitySendMessage("iOSBridge","LoadLevel",[levelName cStringUsingEncoding: NSUTF8StringEncoding]);
}

// This method is called when level is loaded
- (void)didLoadLevel: (NSString*)levelName {
    if ([self.uikitDelegate respondsToSelector: @selector(didLoadLevel:)]) {
        [self.uikitDelegate didLoadLevel: levelName];
    }
}

- (void)messageFromUnity: (NSString*)message {
    if ([self.uikitDelegate respondsToSelector: @selector(didGotMessageFromUnity:)]) {
        [self.uikitDelegate didGotMessageFromUnity: message];
    }
}
// This method is used to send message to Unity
- (void)messageToUnity: (NSString*)message {
    UnitySendMessage("iOSBridge","MessageFromiOS",[message cStringUsingEncoding: NSUTF8StringEncoding]);
}
// This method can be used to free some resources not used during Unity's session
- (void)cleanupFrontend
{
    
}
// This method pauses Unity
- (void)cleanupUnity {
    [self setActiveState: false];
}
// Dealloc for non-arc mode
#if !__has_feature(objc_arc)
- (void)dealloc
{
	[self cleanupFrontend];
	[super dealloc];
}
#endif
// Set Unity's Play/Resume
- (void)setActiveState: (BOOL)state {
    UnityPause(!state);
    UnityActive = state;
}

#pragma mark UIApplicationDelegate forwarded to UIKitAppDelegate

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if (UnityActive) {
        [super applicationDidBecomeActive: application];
    }
    if ([self.uikitDelegate respondsToSelector: @selector(applicationDidBecomeActive:)]) {
        [self.uikitDelegate applicationDidBecomeActive: application];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    if (UnityActive) {
        [super applicationWillResignActive: application];
    }
    if ([self.uikitDelegate respondsToSelector: @selector(applicationWillResignActive:)]) {
        [self.uikitDelegate applicationWillResignActive: application];
    }
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    if ([[self superclass] instancesRespondToSelector: @selector(applicationDidEnterBackground:)]) {
        [super applicationDidEnterBackground: application];
    }
    
    if ([self.uikitDelegate respondsToSelector: @selector(applicationDidEnterBackground:)]) {
        [self.uikitDelegate applicationDidEnterBackground: application];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    if ([[self superclass] instancesRespondToSelector: @selector(applicationWillEnterForeground:)]) {
        [super applicationWillEnterForeground: application];
    }
    if ([self.uikitDelegate respondsToSelector: @selector(applicationWillEnterForeground:)]) {
        [self.uikitDelegate applicationWillEnterForeground: application];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    if ([self.uikitDelegate respondsToSelector: @selector(applicationWillTerminate:)]) {
        [self.uikitDelegate applicationWillTerminate: application];
    }
    if ([[self superclass] instancesRespondToSelector: @selector(applicationWillTerminate:)]) {
        [super applicationWillTerminate: application];
    }
}

- (BOOL)application: (UIApplication *)application
            openURL: (NSURL *)url
  sourceApplication: (NSString *)sourceApplication
         annotation: (id)annotation {
    
    BOOL result = NO;
    if ([[self superclass] instancesRespondToSelector: @selector(application:openURL:sourceApplication:annotation:)]) {
        result |= [super application:application openURL: url sourceApplication:sourceApplication annotation:annotation];
    }
    if ([self.uikitDelegate respondsToSelector: @selector(application:openURL:sourceApplication:annotation:)]) {
        result |= [self.uikitDelegate application:application openURL: url sourceApplication:sourceApplication annotation:annotation];
    }
    
    return result;
}

- (BOOL)application: (UIApplication *)application
      handleOpenURL: (NSURL *)url {
    BOOL result = NO;
    if ([[self superclass] instancesRespondToSelector: @selector(application:handleOpenURL:)]) {
        result |= [super application: application handleOpenURL: url];
    }
    if ([self.uikitDelegate respondsToSelector: @selector(application:handleOpenURL:)]) {
        result |= [self.uikitDelegate application: application handleOpenURL: url];
    }
    return result;
}

- (void)application:(UIApplication *)application willChangeStatusBarOrientation:(UIInterfaceOrientation)newStatusBarOrientation duration:(NSTimeInterval)duration {
    if ([[self superclass] instancesRespondToSelector: @selector(application:willChangeStatusBarOrientation:duration:)]) {
        [super application:application willChangeStatusBarOrientation:newStatusBarOrientation duration:duration];
    }
    if ([self.uikitDelegate respondsToSelector: @selector(application:willChangeStatusBarOrientation:duration:)]) {
        [self.uikitDelegate application:application willChangeStatusBarOrientation:newStatusBarOrientation duration:duration];
    }
}

- (void)application:(UIApplication *)application didChangeStatusBarOrientation:(UIInterfaceOrientation)oldStatusBarOrientation {
    if ([[self superclass] instancesRespondToSelector: @selector(application:didChangeStatusBarOrientation:)]) {
        [super application:application didChangeStatusBarOrientation:oldStatusBarOrientation];
    }
    if ([self.uikitDelegate respondsToSelector: @selector(application:didChangeStatusBarOrientation:)]) {
        [self.uikitDelegate application:application didChangeStatusBarOrientation:oldStatusBarOrientation];
    }
}

- (void)application:(UIApplication *)application willChangeStatusBarFrame:(CGRect)newStatusBarFrame {
    if ([[self superclass] instancesRespondToSelector: @selector(application: willChangeStatusBarFrame:)]) {
        [super application: application willChangeStatusBarFrame: newStatusBarFrame];
    }
    if ([self.uikitDelegate respondsToSelector: @selector(application: willChangeStatusBarFrame:)]) {
        [self.uikitDelegate application: application willChangeStatusBarFrame: newStatusBarFrame];
    }
}

- (void)application:(UIApplication *)application didChangeStatusBarFrame:(CGRect)oldStatusBarFrame {
    if ([[self superclass] instancesRespondToSelector: @selector(application: didChangeStatusBarFrame:)]) {
        [super application: application didChangeStatusBarFrame: oldStatusBarFrame];
    }
    if ([self.uikitDelegate respondsToSelector: @selector(application:didChangeStatusBarFrame:)]) {
        [self.uikitDelegate application: application didChangeStatusBarFrame: oldStatusBarFrame];
    }
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    if ([[self superclass] instancesRespondToSelector: @selector( applicationDidReceiveMemoryWarning:)]) {
        [super applicationDidReceiveMemoryWarning: application];
    }
    if ([self.uikitDelegate respondsToSelector: @selector( applicationDidReceiveMemoryWarning:)]) {
        [self.uikitDelegate applicationDidReceiveMemoryWarning: application];
    }
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
    if ([[self superclass] instancesRespondToSelector: @selector(applicationSignificantTimeChange:)]) {
        [super applicationSignificantTimeChange: application];
    }
    if ([self.uikitDelegate respondsToSelector: @selector(applicationSignificantTimeChange:)]) {
        [self.uikitDelegate applicationSignificantTimeChange: application];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    if ([[self superclass] instancesRespondToSelector: @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:)]) {
        [super application: application didRegisterForRemoteNotificationsWithDeviceToken: deviceToken];
    }
    if ([self.uikitDelegate respondsToSelector: @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:)]) {
        [self.uikitDelegate application: application didRegisterForRemoteNotificationsWithDeviceToken: deviceToken];
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if ([[self superclass] instancesRespondToSelector: @selector(application:didFailToRegisterForRemoteNotificationsWithError:)]) {
        [super application: application didFailToRegisterForRemoteNotificationsWithError: error];
    }
    if ([self.uikitDelegate respondsToSelector: @selector(application:didFailToRegisterForRemoteNotificationsWithError:)]) {
        [self.uikitDelegate application: application didFailToRegisterForRemoteNotificationsWithError: error];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if ([[self superclass] instancesRespondToSelector: @selector(application:didReceiveRemoteNotification:)]) {
        [super application: application didReceiveRemoteNotification: userInfo];
    }
    if ([self.uikitDelegate respondsToSelector: @selector(application:didReceiveRemoteNotification:)]) {
        [self.uikitDelegate application: application didReceiveRemoteNotification: userInfo];
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    if ([[self superclass] instancesRespondToSelector: @selector(application:didReceiveLocalNotification:)]) {
        [super application: application didReceiveLocalNotification: notification];
    }
    if ([self.uikitDelegate respondsToSelector: @selector(application:didReceiveLocalNotification:)]) {
        [self.uikitDelegate application: application didReceiveLocalNotification: notification];
    }
    
}

- (void)applicationProtectedDataWillBecomeUnavailable:(UIApplication *)application {
    if ([[self superclass] instancesRespondToSelector: @selector(applicationProtectedDataWillBecomeUnavailable:)]) {
        [super applicationProtectedDataWillBecomeUnavailable: application];
    }
    if ([[self superclass] instancesRespondToSelector: @selector(applicationProtectedDataWillBecomeUnavailable:)]) {
        [super applicationProtectedDataWillBecomeUnavailable: application];
    }
}
@end