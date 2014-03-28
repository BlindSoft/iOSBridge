#ifdef UNITY_4_2_0
#import "UnityAppController.h"
#else
#import "AppController.h"
#endif

// Native code plugin
#pragma mark Unity native plugin

#ifdef __cplusplus
extern "C" {
#endif
// Received message from Unity
// message - parameter string to be transfered to UIKit
void iOSBridgeSendMessageToUIKit( const char * message );

// Unity finished level loading
void iOSBridgeLoadLevelComplete( const char * levelName );

// Open UIKit frontend and pause Unity
// data - parameter to be transfered to UIKit
void iOSBridgeFinishUnity( const char * data );
 
#ifdef __cplusplus
}
#endif

// Application delegate
#pragma mark iOS Bridge App Delegate

// Main aplication delegate, that replaces Unity's AppDelegate
// Unity >= 4.2: Replace "UnityAppController" with "iOSBridgeAppDelegate" in Classes/main.mm@??
// Unity <= 4.1: Replace "AppController" with "iOSBridgeAppDelegate" in Classes/main.mm@22
#ifdef UNITY_4_2_0
@interface iOSBridgeAppDelegate : UnityAppController
#else
@interface iOSBridgeAppDelegate : AppController
#endif
{
    // Unity's window
	UIWindow *window;
    UIView *unityView;
    UIView *coverView;
    
    BOOL UnityActive;
}

// This method switches form Unity to UIKit
- (void)launchFrontend;
// This method switches form UIKit to Unity
- (void)launchUnity;

// This method loads level and switched to Unity on load complete
- (void)loadLevel: (NSString*)levelName;
// This method called on message from Unity
- (void)messageFromUnity: (NSString*)message;
// This method is used to send message to Unity
- (void)messageToUnity: (NSString*)message;

// This method is called when level is loaded
- (void)didLoadLevel: (NSString*)levelName;

// This method can be used to free some resources not used during Unity's session
- (void)cleanupFrontend;
// This method pauses Unity
- (void)cleanupUnity;
// Set Unity's Play/Resume
- (void)setActiveState: (BOOL)state;

// UIKit Root view controller
@property (nonatomic,retain) UIViewController *RootViewController;

@end
