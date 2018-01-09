#import "TLActivityView.h"

@interface TLActivityView ()

@property(strong) UIImageView* activityImageView;

@end


@implementation TLActivityView

@synthesize activityImageView;

- (id)initWithFrame:(CGRect)frame andActivityBar:(UIImage*)image
{
    self = [super initWithFrame:frame];
    if (self) {
        int barWidth = self.frame.size.width/3;
        activityImageView = [[UIImageView alloc] initWithFrame:CGRectMake(barWidth, 0, barWidth, frame.size.height)];
        activityImageView.image = image;
    }
    return self;
}

- (void)start
{
    [activityImageView.layer removeAllAnimations];
    
    int barWidth = self.frame.size.width/3;
    
    activityImageView.transform = CGAffineTransformIdentity;
    activityImageView.frame = CGRectMake(barWidth, 0, barWidth, self.frame.size.height);
    [self addSubview:activityImageView];
    

    typedef void (^completionBlock)(BOOL);
    
    completionBlock move = ^(BOOL finished){
        [UIView animateWithDuration:1
                              delay:0.0
                            options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse
                         animations:^{
                             activityImageView.transform = CGAffineTransformMakeTranslation(-activityImageView.frame.origin.x+barWidth, 0);
                         }
                         completion:nil
         ];
    };
    
    //move to the right
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         activityImageView.transform = CGAffineTransformMakeTranslation(activityImageView.frame.origin.x, 0);
                     }
                     completion:move
     ];
}

- (void)stop
{
    [activityImageView.layer removeAllAnimations];
    [activityImageView removeFromSuperview];
}



@end
