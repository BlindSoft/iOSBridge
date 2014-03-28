#import "UIUnityOverlayView.h"

// UIView subclass with transparent background and Unity touch support.
// This is ordinary UIView with overloaded methods pointInside:withEvent: and didMoveToSuperview
@implementation UIUnityOverlayView

// Set background color to transparent
- (void)didMoveToSuperview {

	self.backgroundColor = [UIColor clearColor];
}

// This method walks through all subviews and call same method for each.
// If there's no control at touch point, it will return NO and UIKit will pass touch event to underlying Unity view.
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {

	for (UIView *childView in self.subviews) {
		CGPoint childPoint = [childView convertPoint: point fromView: self];
		if ([childView pointInside: childPoint withEvent: event]) {
			return YES;
		}
	}

	return NO;
}

@end