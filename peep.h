#define kIdentifier @"me.conorthedev.peep.prefs"
#define kSettingsChangedNotification (CFStringRef)@"me.conorthedev.peep.prefs/ReloadPrefs"
#define kSettingsPath @"/var/mobile/Library/Preferences/me.conorthedev.peep.prefs.plist"

@interface NSUserDefaults (Private)
- (instancetype)_initWithSuiteName:(NSString *)suiteName
                         container:(NSURL *)container;
@end

@interface SBApplication : NSObject
@property (nonatomic,readonly) NSString *bundleIdentifier;
@end

@interface SBCoverSheetPresentationManager : NSObject
+(id)sharedInstance;
-(BOOL)isPresented;
@end

@interface SpringBoard : NSObject
+(id)sharedApplication;
-(SBApplication*)_accessibilityFrontMostApplication;
@end

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
-(void)peep_checkHiddenState;

-(NSString *)peep_getCurrentApp;
@end