/*
 Peep
 A tweak that allows you to hide and show your status bar by tapping on it
 Copyright (c) ConorTheDev 2020
*/
#import "peep.h"

BOOL tweakEnabled;
BOOL animationsEnabled;
BOOL saveRespringEnabled;
BOOL firstLayoutSubviews;
NSDictionary *prefs;

%hook _UIStatusBar
%property (nonatomic, strong) UITapGestureRecognizer *peep_tapRecognizer;
%property (nonatomic, strong) UIView *peep_fakeSubview;

-(id)initWithStyle:(long long)arg1 {		
 	self = %orig;		

  	if(self) {		
 		[self peep_setupGestureRecognizer];		
 	}

  	return self;		
}

-(void)layoutSubviews {
	%orig;
	if(self.foregroundView && saveRespringEnabled && firstLayoutSubviews) {
		self.foregroundView.hidden = [[NSUserDefaults standardUserDefaults] boolForKey:@"peep_statusbar"];
		firstLayoutSubviews = NO;
	}
}

%new 
-(void)peep_gestureRecognizerTapped:(id)sender {
	if(tweakEnabled) {
		[UIView transitionWithView:self
			duration:animationsEnabled ? 0.25 : 0
			options:UIViewAnimationOptionTransitionCrossDissolve
			animations:^{
				self.foregroundView.hidden = !self.foregroundView.hidden;
			}
			completion:^(BOOL finished){ [self peep_setupGestureRecognizer]; }];
		
		if(saveRespringEnabled) {
			[[NSUserDefaults standardUserDefaults] setBool:self.foregroundView.hidden forKey:@"peep_statusbar"];
			[[NSUserDefaults standardUserDefaults] synchronize];
		}
	}
}

%new
-(void)peep_setupGestureRecognizer {
	self.userInteractionEnabled = YES;

	self.peep_tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(peep_gestureRecognizerTapped:)];
	[self addGestureRecognizer:self.peep_tapRecognizer];

	// Add a fake subview, this allows our gesture recognizer to still be used as the view still has a subview, but it's not visible
	self.peep_fakeSubview = [[UIView alloc] initWithFrame:self.bounds];
	[self addSubview:self.peep_fakeSubview];
}
%end

/* Thanks to kritanta for helping me with this */
static void PeepReloadPrefs() {
	CFPreferencesAppSynchronize((CFStringRef)kIdentifier);

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

	tweakEnabled = [prefs objectForKey:@"enabled"] ? [[prefs valueForKey:@"enabled"] boolValue] : YES;
	animationsEnabled = [prefs objectForKey:@"animations"] ? [[prefs valueForKey:@"animations"] boolValue] : YES;
	saveRespringEnabled = [prefs objectForKey:@"saveRespring"] ? [[prefs valueForKey:@"saveRespring"] boolValue] : NO;
}

%ctor {
	firstLayoutSubviews = YES;

	PeepReloadPrefs();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)PeepReloadPrefs, CFSTR("me.conorthedev.peep.prefs/ReloadPrefs"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}