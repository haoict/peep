/*
 Peep
 A tweak that allows you to hide and show your status bar by tapping on it
 Copyright (c) ConorTheDev 2020
*/

#import "peep.h"

%hook _UIStatusBar
-(id)initWithStyle:(long long)arg1 {
	_UIStatusBar *original = %orig;

	if(original) {
		[original setupGestureRecognizer];
	}

	return original;
}

%new 
-(void)gestureRecognizerTapped:(id)sender {
	[UIView transitionWithView:self.foregroundView
                          duration:0.25
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
							for (UIView *subview in self.foregroundView.subviews) {
								subview.hidden = !subview.hidden;
							}
						}
                        completion:^(BOOL finished){ [self setupGestureRecognizer]; }];
}

%new
-(void)setupGestureRecognizer {
	self.userInteractionEnabled = TRUE;
	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizerTapped:)];
	[self addGestureRecognizer:tapRecognizer];
}
%end