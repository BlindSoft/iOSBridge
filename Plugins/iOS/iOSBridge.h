#import <Foundation/Foundation.h>

// Singleton, that used to switch between UIKit and Unity.
@interface iOSBridge : NSObject

// Returns shared instance of iOSBridge singleton
+ (iOSBridge*)shared;

// Opens UIKit view and pauses Unity
- (void)openUnity;

// Opens Unity view and resumes last scene
- (void)openUIKit;

// Opens Unity view with loading scene by name.
// Unity Free will switch to previous scene and then load new scene.
// Unity Pro will start asyncronous scene load. Unity will be shown after load finished.
- (void)openUnityWithScene: (NSString*)scene;

// Sends message to Unity
- (void)sendMessageToUnity: (NSString*)message;

@end
