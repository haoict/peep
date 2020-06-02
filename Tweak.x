/*
 Peep
 A tweak that allows you to hide and show your status bar by tapping on it
 Copyright (c) ConorTheDev 2020
*/
#import "peep.h"

BOOL peep_tweakEnabled;
BOOL peep_animationsEnabled;
BOOL peep_shouldLayoutSubviews;
int peep_numberOfTaps;
NSDictionary *peep_prefs;
NSUserDefaults *defaults;
_UIStatusBar *globalStatusBar;

%hook _UIStatusBar
%property (nonatomic, strong) UITapGestureRecognizer *peep_tapRecognizer;
%property (nonatomic, strong) UIView *peep_fakeSubview;

-(id)initWithStyle:(long long)arg1 {		
 	self = %orig;		

  	if(self) {		
		globalStatusBar = self;
 		[self peep_setupGestureRecognizer];		
 	}

  	return self;		
}

-(void)layoutSubviews {
	%orig;
	if(self.foregroundView && peep_shouldLayoutSubviews && peep_tweakEnabled) {
		self.foregroundView.hidden = [defaults boolForKey:[NSString stringWithFormat:@"%@-%@", [self peep_getCurrentApp], @"peep_statusbar"]];
		peep_shouldLayoutSubviews = NO;
	}
}

-(long long)style {
	if(peep_tweakEnabled) {
		// When `style` is set or accessed, it seems to modify the `hidden` property of the foregroundView, the way to fix this is to tell peep 
		// that it is okay to set the hidden property on the next layoutSubviews call
		peep_shouldLayoutSubviews = YES;
		[self peep_setupGestureRecognizer];
	}

	return %orig;
}

%new 
-(void)peep_gestureRecognizerTapped:(id)sender {
	if(peep_tweakEnabled) {
		[UIView transitionWithView:self
			duration:peep_animationsEnabled ? 0.25 : 0
			options:UIViewAnimationOptionTransitionCrossDissolve
			animations:^{
				self.foregroundView.hidden = !self.foregroundView.hidden;
			}
			completion:^(BOOL finished){ [self peep_setupGestureRecognizer]; }];
		
		[defaults setBool:self.foregroundView.hidden forKey:[NSString stringWithFormat:@"%@-%@", [self peep_getCurrentApp], @"peep_statusbar"]];
		[defaults synchronize];
	}
}

%new
-(void)peep_setupGestureRecognizer {
	self.userInteractionEnabled = YES;

	if(self.peep_tapRecognizer) {
		[self removeGestureRecognizer:self.peep_tapRecognizer];
	}

	self.peep_tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(peep_gestureRecognizerTapped:)];
	self.peep_tapRecognizer.numberOfTapsRequired = peep_numberOfTaps;
	
	[self addGestureRecognizer:self.peep_tapRecognizer];

	// Add a fake subview, this allows our gesture recognizer to still be used as the view still has a subview, but it's not visible
	self.peep_fakeSubview = [[UIView alloc] initWithFrame:self.bounds];
	[self addSubview:self.peep_fakeSubview];
}

%new
-(NSString *)peep_getCurrentApp {
	NSString *app = [[%c(SpringBoard) sharedApplication] _accessibilityFrontMostApplication].bundleIdentifier;
	if([[%c(SBCoverSheetPresentationManager) sharedInstance] isPresented]) {
		app = @"com.apple.sblockscreen";
	} else if(app == NULL || [app isEqualToString:@""]) {
		app = @"com.apple.springboard";
	}
	
	return app;
}
%end

%hook CoverSheetClass
-(bool)shouldDisplayFakeStatusBar {
	if(peep_tweakEnabled) {
		return ![self isPresented];
	} else {
		return %orig;
	}
}

-(bool)needsFakeStatusBarUpdate {
	if(peep_tweakEnabled) {
		return ![self isPresented];
	} else {
		return %orig;
	}
}
%end

%hook CSCoverSheetViewController
-(id)fakeStatusBar {
	if(peep_tweakEnabled) {
		return NULL;
	} else {
		return %orig;
	}
}

- (id)_createFakeStatusBar {
	if(peep_tweakEnabled) {
		return NULL;
	} else {
		return %orig;
	}
}

- (void)_setFakeStatusBarEnabled:(_Bool)arg1 {
	if(peep_tweakEnabled) {
		arg1 = FALSE;
	}
	%orig;
}
%end

/* Thanks to kritanta for helping me with this */
static void PeepReloadPrefs() {
	CFPreferencesAppSynchronize((CFStringRef)kIdentifier);

    if ([NSHomeDirectory()isEqualToString:@"/var/mobile"]) {
        CFArrayRef keyList = CFPreferencesCopyKeyList((CFStringRef)kIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);

        if (keyList) {
            peep_prefs = (NSDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, (CFStringRef)kIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost));

            if (!peep_prefs) {
                peep_prefs = [NSDictionary new];
            }
            CFRelease(keyList);
        }
    } else {
        peep_prefs = [NSDictionary dictionaryWithContentsOfFile:kSettingsPath];
    }

	peep_tweakEnabled = [peep_prefs objectForKey:@"enabled"] ? [[peep_prefs valueForKey:@"enabled"] boolValue] : YES;
	peep_animationsEnabled = [peep_prefs objectForKey:@"animations"] ? [[peep_prefs valueForKey:@"animations"] boolValue] : YES;
	peep_numberOfTaps = [peep_prefs objectForKey:@"taps"] ? [[peep_prefs valueForKey:@"taps"] intValue] : 1;

	[globalStatusBar peep_setupGestureRecognizer];
}

%ctor {
	defaults = [[NSUserDefaults alloc]
        _initWithSuiteName:@"me.conorthedev.peep"
                 container:[NSURL URLWithString:@"/var/mobile"]];

	PeepReloadPrefs();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)PeepReloadPrefs, CFSTR("me.conorthedev.peep.prefs/ReloadPrefs"), NULL, CFNotificationSuspensionBehaviorCoalesce);

	NSString *coverSheetClass = @"SBDashBoardViewController";
	if(@available(iOS 13.0, *)) {
		coverSheetClass = @"SBCoverSheetPresentationManager";
	}

	%init(CoverSheetClass = NSClassFromString(coverSheetClass));
}