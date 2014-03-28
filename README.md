iOS Bridge
==========

-----------------------------------------------------
    Project is closed and not supported.
-----------------------------------------------------

Description
-----------

iOS Bridge library helps to embed Unity 3D view into UIKit applications and vise versa. Create GUI with UIKit view elements. 

It works with Unity 3D Free and Pro. 

Tested on versions 3.5 - 4.1

It's possible to open UIKit view controllers from Unity. Application can open any view controller no matter it custom or one of standard:

1. GameCenter
2. In-app purchases shop
3. WebView
4. MapKit
5. Image Picker

Another way to use iOSBridge is to open 3D view. You can use iOS Bridge to create such things:

1. Animated 3D Model view with full Unity3d engine power.
2. 360-degeree panorama view
3. Augmented reality applications

Also it's easy to add UIKit view above Unity3D container to create GUI elements. Create GUI with interface builder and use it without complex GUI systems for Unity. There are some nice things:

1. Automatic HD/SD graphics selection
2. Easy localization options
3. Dynamic fonts
4. Clear layout and sizing setup
5. Simple animation

Examples
--------

Some examples available here: http://blind-soft.info/iosbridge/examples/

Features
--------

* Unity Free and Pro

  iOS Bridge works in either version of Unity without any limitations.

* ARC support

  ARC support is available for UIKit part. Full instruction is available in Documentation <http://blind-soft.info/iosbridge/documentation#ARC>

* Load Unity scenes by name

  3D view can have multiple scenes in Unity, every of them can be loaded by name. 

* Storyboard, Nib or programmatically created UI

  UIKit view controllers can be created in any way. It's possible to load it from storyboard, create separate nib-files for each view controller or create them programmatically.

* UIKit view above unity's 3D view

  Set transparent UIView with controls to create GUI for Unity 3D view. Touch interactions will be available

* AppDelegate-like interface

  Application structure will be close to ordinary iOS application with AppDelegate and View Controllers. Create UIKit root view controller and switch between UIKit and Unity with single call. 

Limitations
-----------
* Unity stays in memory

  Unity stays in memory all time. Unity engine can be paused to prevent CPU and GPU consumption, but can't be unloaded.

* Messages can be send to unity only in active state

  Unity can't respond to messages in paused state. It should be active to perform operations. 

* Not all UIAppDelegate methods supported

  There's no support of the methods:
	
  		application:shouldSaveApplicationState:
		application:shouldRestoreApplicationState:
		application:viewControllerWithRestorationIdentifierPath:coder:
		application:willEncodeRestorableStateWithCoder:
		application:didDecodeRestorableStateWithCoder:
       

Documentation
-------------

### Quick start ###

#### Unity ####

1. Install and import iOS Bridge into your Unity 3D project.
2. Open **iOSBridge scene**
3. Open **Build settings** and switch to **iOS**
4. Setup bundle id, application name
5. Add **iOSBridge scene** to be first in list.
6. This step depends on how much scenes will be
  1. **Only one scene** content can be placed to iOS Bridge scene
  2. **One or more scenes** create separate scenes and add them to build list
7. Build project

#### XCode ####

1. Open created project.
2. **Unity 3.5 - 4.1:**
  
  Open **main.mm** file and replace

        UIApplicationMain(argc, argv, nil, @"AppController");
  with

        UIApplicationMain(argc, argv, nil, @"iOSBridgeAppDelegate");    
        
  **Unity 4.2:**
  
  Open **main.mm** file and replace

        const char* AppControllerClassName = "UnityAppController";
  with

        const char* AppControllerClassName = "iOSBridgeAppDelegate"; 
    
3. Open **UIKitAppDelegate.m**
4. Place creation of root UIView controller into

        - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
        
5. Set initialized UIView controller to 
    
        self.rootViewController = nil;/* replace with your controller*/
        
6. Set cover UIView for 3D View

		self.unityOverlayView = nil;/* replace with your view*/

#### Switch from Unity to iOS and back ####

* Switch to Unity from iOS by calling
    
        [[iOSBridge shared] openUnity];
        
* Switch to Unity scene from iOS
        
        [[iOSBridge shared] openUnityWithScene: @"sceneName"];
        
* Switch to ViewController from iOS by calling

        [[iOSBridge shared] openUIKit];
        
* Send message to Unity(works only when Unity is running)
	
		[[iOSBridge shared] sendMessageToUnity: @"message"];
       
* Switch to ViewController from Unity by calling

        iOSBridge.shared.OpenUIKit( "message" );
        
* Send message to UIKit
		
		iOSBridge.shared.SendMessageToUIKit( "message" );
		
* Receive message from UIKit in iOSBridge.cs file

		iOSBridge::MessageFromiOS( string message );
		
* Receive message from Unity in UIKitAppDelegate.m

		- (void)didGotMessageFromUnity: (NSString*)message;
		
* Receive level load event in UIKitAppDelegate.m

		- (void)didLoadLevel: (NSString*)loadLevel;
        
### ARC Support ###

You can add ARC support to project with these steps:

1. Open **main.mm* and replace

        NSAutoreleasePool* pool = [NSAutoreleasePool new];
		...
		[pool release];

  with
  
        @autoreleasepool {
        ...
        }

2. Open **Build Settings** and set
   
   **Objective-C Automatic Reference Counting** to **YES**
   
3. Open **Build Phases**->**Compile Sources**

   Select all *.m/*.mm files except **UIKitAppDelegate.m**, hit **Enter** and type
   
        -fno-objc-arc
        
### Overlay UIView for Unity ###

You can create GUI with UIView overlay

1. Create your view with nib as usual
2. Open UIKitAppDelegate.m file and init your overlay view

		- (BOOL)application:(UIApplication *)application
	    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    		...
    		MyOverlayView *overlayView = [[[NSBundle mainBundle] loadNibNamed: @"MyOverlayView"
                                                                owner: self.rootViewController 
                                                              options: nil] 
                                    objectAtIndex: 0]
                                  retain];
		    self.unityOverlayView = overlayView;
    		...
    		}

Overlay view should be inherited from UIUnityOverlayView for transparent background and Unity touch support 

### UIKit interface from storyboard ###

UIKit interface can be loaded from Storyboard.

1. Create your interface in storyboard as usual.

2. Open UIKitAppDelegate.m file and init your view controller.

		- (BOOL)application:(UIApplication *)application
	    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    		...
    		UIStoryboard *storyboard = [[UIStoryboard storyboardWithName: @"Your_storyboard" 
                                                           bundle: nil] autorelease];
    		self.rootViewController = [storyboard instantiateInitialViewController] retain];
    		...
    	}

3. Navigation and Tab view controllers, as well as segues can be used as usual.

### UIKit interface from nib ###

UIKit interface can be loaded from nib

1. Create your root view controller nib as usual
2. Open UIKitAppDelegate.m file and init your view controller

		- (BOOL)application:(UIApplication *)application
	    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    		...
    		ExampleViewController *exampleController = 
        	[[[ExampleViewController alloc] initWithNibName: @"ExampleViewController"
                                                bundle: nil] retain];
    		self.rootViewController = exampleController;
    		...
    		}

### Autoload UIKit ###

UIKit can be launched after application start. 

Set autostartUIKit flag in application launch handler

	- (BOOL)application:(UIApplication *)application
        didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
            ...
                self.autostartUIKit = YES; // Autostart UIKit
            ...
            }
    
### Load level by name ###

Level can be loaded by name with command

    [[iOSBridge shared] openUnityWithScene: @"sceneName"];
    
**Unity Free** will start synchronous load scene and then switch to unity.

**Unity Pro** will start asynchronous scene load. Unity will be shown after load finished. 

Method 

		private IEnumerator LoadLevelAsync( string levelName )
		
can be used to send message with load progress.

### iOSBridge object documentation ###

#### iOSBridge class in Unity ####

##iOSBridge##

Main class, used to handle communication between Unity and UIKit

##### Methods #####

	static extern void  iOSBridgeFinishUnity (  string  data  )
	
Open UIKit frontend and pause Unity

data - parameter to be sent to UIKit

-----------------------------------------------

#### iOSBridge classes in UIKit ####

##iOSBridge##

Singleton, that used to switch between UIKit and Unity.

##### Methods #####

	+  ( iOSBridge*) )  shared

Returns shared instance of iOSBridge singleton

	-  (	 void )  openUIKit

Opens UIKit view and pauses Unity

	-  (	 void )  openUnity

Opens Unity view and resumes last scene
	
	-  (	 void )  openUnityWithScene :  ( NSString*  scene )

Opens Unity view with loading scene by name.

	- (void)sendMessageToUnity: (NSString*)message;

Sends message to Unity

##UIKitAppDelegate##

This class should be used to handle UIApplicationDelegate events. 

It hides iOSBridge and Unity code for better coding experience.

This class supports most of methods from UIApplicationDelegate protocol.

See *limitations section* for unsupported methods.

##### Methods #####

	-  (  BOOL )  application :  ( UIApplication* )  application  didFinishLaunchingWithOptions  :  ( NSDictionary* )  launchOptions 
	
Standard application initialization method. Best place to init some analytics, debug stuff. Also UIKit interface initialization should be places here.

	- (void)didGotMessageFromUnity: (NSString*)message;
	
Method is called on message from Unity

	- (void)didLoadLevel: (NSString*)loadLevel;
Method is called after level was loaded

##### Properties #####

	@property  ( nonatomic )  BOOL  autostartUIKit
	
UIKit will be launched after app start if this flag is set YES

	@property  ( nonatomic ,  strong )  UIViewController*  rootViewController

Root UIKit view controller.
	
	@property  ( nonatomic ,  strong )  UIUnityOverlayView*  unityOverlayView

Unity overlay view controller.

##UIUnityOverlayView##

UIView subclass with transparent background and Unity touch support.

This is ordinary UIView with overloaded methods 
**didMoveToSuperview** and **pointInside:withEvent:**
#####Overloaded methods#####

	- (void)didMoveToSuperview {
	
Set background color to transparent

	-  (  BOOL  )  pointInside :  ( CGPoint )  point  withEvent :  ( UIEvent* )  event 

This method walks through all subviews and call same method for each.
If there's no control at touch point, it will return NO and UIKit will pass touch event to underlying Unity view.

