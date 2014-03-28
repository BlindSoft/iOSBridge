#import <UIKit/UIKit.h>
#import "UIUnityOverlayView.h"

// UIApplicationDelegate simulation class object
@interface UIKitAppDelegate : NSObject<UIApplicationDelegate>

// UIKit root view controller
@property (nonatomic,strong) UIViewController *rootViewController;
// Unity's overlay view
@property (nonatomic,strong) UIUnityOverlayView *overlayView;
// Autostart UIKit
@property (nonatomic) BOOL autostartUIKit;

// Got message from unity
- (void)didGotMessageFromUnity: (NSString*)message;
// Level loaded
- (void)didLoadLevel: (NSString*)loadLevel;

@end
