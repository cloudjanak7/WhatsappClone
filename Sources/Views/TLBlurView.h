#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface TLBlurView : UIView

- (void) setBlurColor:(UIColor *)blurColor;
- (void) setBlurAlpha:(CGFloat)alphaValue;

@end
