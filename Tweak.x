/*
 Peep
 A tweak that allows you to hide and show your status bar by tapping on it
 Copyright (c) ConorTheDev 2020
*/

#import "peep.h"

BOOL tweakEnabled;
NSDictionary *prefs = NULL;
_UIStatusBar *globalStatusBar = NULL;

%hook _UIStatusBar
%property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;

-(id)initWithStyle:(long long)arg1 {
	_UIStatusBar *original = %orig;

	if(original) {
		[original setupGestureRecognizer];
		globalStatusBar = original;
	}

	return original;
}

%new 
-(void)gestureRecognizerTapped:(id)sender {
	if((!tweakEnabled && self.foregroundView.subviews[0].hidden) || tweakEnabled) {
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
}

%new
-(void)setupGestureRecognizer {
	self.userInteractionEnabled = TRUE;
	self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizerTapped:)];
	[self addGestureRecognizer:self.tapRecognizer];
}
%end

/* Thanks to kritanta for helping me with this */
static void reloadPrefs() {
    if ([NSHomeDirectory()isEqualToString:@"/var/mobile"]) {
        CFArrayRef keyList = CFPreferencesCopyKeyList((CFStringRef)kIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);

        if (keyList) {
            prefs = (NSDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, (CFStringRef)kIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost));

            if (!prefs) {
                prefs = [NSDictionary new];
            }
            CFRelease(keyList);
        }
    } else {
        prefs = [NSDictionary dictionaryWithContentsOfFile:kSettingsPath];
    }
}

static void updatePreferences() {
	// Refresh dictionary
    CFPreferencesAppSynchronize((CFStringRef)kIdentifier);
    reloadPrefs();

    tweakEnabled = [prefs objectForKey:@"enabled"] ? [[prefs valueForKey:@"enabled"] boolValue] : TRUE;

	NSLog(@"[peep] Enabled: %i", tweakEnabled);

	// Update gesture recognizer
	if(globalStatusBar) {
		[globalStatusBar gestureRecognizerTapped:nil];
	}
}

%ctor {
	updatePreferences();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)updatePreferences, CFSTR("me.conorthedev.peep.prefs/ReloadPrefs"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}