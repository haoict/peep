#import <UIKit/UIKit.h>

#define kIdentifier @"me.conorthedev.peep.prefs"
#define kSettingsChangedNotification (CFStringRef)@"me.conorthedev.peep.prefs/ReloadPrefs"
#define kSettingsPath @"/var/mobile/Library/Preferences/me.conorthedev.peep.prefs.plist"

@interface UIStatusBarForegroundView : UIView
@end

@interface _UIStatusBar : UIView
@property(nonatomic, strong) UIStatusBarForegroundView *foregroundView;
@property(nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@end

@interface _UIStatusBar (peep)
-(void)gestureRecognizerTapped:(id)sender;
-(void)setupGestureRecognizer;
-(void)updatePreferences;
@end