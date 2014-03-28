#import "iOSBridge.h"
#import "iOSBridgeAppDelegate.h"

// Singleton, that used to switch between UIKit and Unity.
@implementation iOSBridge

// Returns shared instance of iOSBridge singleton
+( iOSBridge* ) shared
{
    static iOSBridge* sBridge = nil;
    static dispatch_once_t predicate;
    dispatch_once( &predicate, ^{
        sBridge = [ [ self alloc ] init ];
    } );
    return sBridge;
}

// Opens UIKit view and pauses Unity
- (void)openUnity {
    NSCAssert([[UIApplication sharedApplication].delegate isKindOfClass:[iOSBridgeAppDelegate class]], @"iOSBridge // ERROR // AppDelegate name in main.mm should be changed to iOSBridgeAppDelegate");
    if ([[UIApplication sharedApplication].delegate isKindOfClass:[iOSBridgeAppDelegate class]]) {
        iOSBridgeAppDelegate* iosBridgeAppDelegate = (iOSBridgeAppDelegate *)[UIApplication sharedApplication].delegate;
        if ([iosBridgeAppDelegate respondsToSelector: @selector(launchUnity)]) {
          [iosBridgeAppDelegate launchUnity];
        }
    }    
}

// Opens Unity view and resumes last scene
- (void)openUIKit {
    NSCAssert([[UIApplication sharedApplication].delegate isKindOfClass:[iOSBridgeAppDelegate class]], @"iOSBridge // ERROR // AppDelegate name in main.mm should be changed to iOSBridgeAppDelegate");
    if ([[UIApplication sharedApplication].delegate isKindOfClass:[iOSBridgeAppDelegate class]]) {
        iOSBridgeAppDelegate* iosBridgeAppDelegate = (iOSBridgeAppDelegate *)[UIApplication sharedApplication].delegate;
        if ([iosBridgeAppDelegate respondsToSelector: @selector(launchFrontend)]) {
          [iosBridgeAppDelegate launchFrontend];
        }        
    }
}

// Opens Unity view with loading scene by name.
// Unity Free will switch to previous scene and then load new scene.
// Unity Pro will start asyncronous scene load. Unity will be shown after load finished.
- (void)openUnityWithScene: (NSString*)scene {
    NSCAssert([[UIApplication sharedApplication].delegate isKindOfClass:[iOSBridgeAppDelegate class]], @"iOSBridge // ERROR // AppDelegate name in main.mm should be changed to iOSBridgeAppDelegate");
    if ([[UIApplication sharedApplication].delegate isKindOfClass:[iOSBridgeAppDelegate class]]) {
        iOSBridgeAppDelegate* iosBridgeAppDelegate = (iOSBridgeAppDelegate *)[UIApplication sharedApplication].delegate;
        if ([iosBridgeAppDelegate respondsToSelector: @selector(loadLevel:)]) {
          [iosBridgeAppDelegate loadLevel: scene];
        }        
    }
}

// Sends message to Unity
- (void)sendMessageToUnity: (NSString*)message {
    NSCAssert([[UIApplication sharedApplication].delegate isKindOfClass:[iOSBridgeAppDelegate class]], @"iOSBridge // ERROR // AppDelegate name in main.mm should be changed to iOSBridgeAppDelegate");
    if ([[UIApplication sharedApplication].delegate isKindOfClass:[iOSBridgeAppDelegate class]]) {
        iOSBridgeAppDelegate* iosBridgeAppDelegate = (iOSBridgeAppDelegate *)[UIApplication sharedApplication].delegate;
        if ([iosBridgeAppDelegate respondsToSelector: @selector(messageToUnity:)]) {
          [iosBridgeAppDelegate messageToUnity: message];
        }
    }    
}

@end
