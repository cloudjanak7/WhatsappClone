#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TLHud : UIView

@property (nonatomic, strong) UIColor *hudColor;

-(void)showAnimated:(BOOL)animated;
-(void)hide;

@end