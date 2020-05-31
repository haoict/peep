/*
 Peep
 A tweak that allows you to hide and show your status bar by tapping on it
 Copyright (c) ConorTheDev 2020
*/
#import "peep.h"

BOOL tweakEnabled;
BOOL animationsEnabled;
BOOL firstRun;
NSDictionary *prefs;
NSMutableDictionary *ignoredSubviews;
static _UIStatusBar *globalStatusBar;

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
	if(tweakEnabled) {
		if(firstRun) {
			firstRun = false;
			for (UIView *subview in self.foregroundView.subviews) {
				if(subview.hidden) {
					ignoredSubviews[[NSValue valueWithNonretainedObject:subview]] = @(YES);
				}
			}
		}

		self.foregroundView.subviews[0].hidden = !self.foregroundView.subviews[0].hidden;
		[UIView transitionWithView:self
							duration:animationsEnabled ? 0.25 : 0
							options:UIViewAnimationOptionTransitionCrossDissolve
							animations:^{
								for (UIView *subview in self.foregroundView.subviews) {
									if(!ignoredSubviews[[NSValue valueWithNonretainedObject:subview]]) {
										subview.hidden = self.foregroundView.subviews[0].hidden;
									}
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
    CFPreferencesAppSynchronize((CFStringRef)kIdentifier);
    reloadPrefs();

    tweakEnabled = [prefs objectForKey:@"enabled"] ? [[prefs valueForKey:@"enabled"] boolValue] : TRUE;
	animationsEnabled = [prefs objectForKey:@"animations"] ? [[prefs valueForKey:@"animations"] boolValue] : TRUE;
}

%ctor {
	ignoredSubviews = [NSMutableDictionary new];
	firstRun = YES;

	updatePreferences();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)updatePreferences, CFSTR("me.conorthedev.peep.prefs/ReloadPrefs"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}