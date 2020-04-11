#import <UIKit/UIKit.h>

@interface UIStatusBarForegroundView : UIView
@end

@interface _UIStatusBar : UIView
@property(nonatomic, strong) UIStatusBarForegroundView *foregroundView;
@end

@interface _UIStatusBar (peep)
-(void)gestureRecognizerTapped:(id)sender;
-(void)setupGestureRecognizer;
@end