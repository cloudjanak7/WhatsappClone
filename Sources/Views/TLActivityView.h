#import <UIKit/UIKit.h>

@interface TLActivityView : UIView

- (id)initWithFrame:(CGRect)frame andActivityBar:(UIImage*)image;
- (void)start;
- (void)stop;

@end