#define kIdentifier @"me.conorthedev.peep.prefs"
#define kSettingsChangedNotification (CFStringRef)@"me.conorthedev.peep.prefs/ReloadPrefs"
#define kSettingsPath @"/var/mobile/Library/Preferences/me.conorthedev.peep.prefs.plist"

@interface UIStatusBarForegroundView : UIView
@end

@interface _UIStatusBar : UIView
@property(nonatomic, strong) UIStatusBarForegroundView *foregroundView;
@end

@interface _UIStatusBar (peep)
@property (nonatomic, strong) UITapGestureRecognizer *peep_tapRecognizer;
@property (nonatomic, strong) UIView *peep_fakeSubview;
-(void)peep_gestureRecognizerTapped:(id)sender;
-(void)peep_setupGestureRecognizer;
@end