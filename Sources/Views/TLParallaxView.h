#import <UIKit/UIKit.h>


@interface TLParallaxView : UIView

/// The scrollView used to display the parallax effect.
@property (nonatomic, readonly) UIScrollView *scrollView;
/// The delegate of scrollView. You must use this property when setting the scrollView delegate--attempting to set the scrollView delegate directly using `scrollView.delegate` will cause the parallax effect to stop updating.
@property (nonatomic, weak) id<UIScrollViewDelegate> scrollViewDelegate;
/// The height of the background view when at rest.
@property (nonatomic, assign) CGFloat backgroundHeight;
/// YES if the backgroundView should handle touch input. 
@property (nonatomic, getter = isBackgroundInteractionEnabled) BOOL backgroundInteractionEnabled;

/// *Designated initializer.* Creates a MDCParallaxView with the given views.
/// @param backgroundView The view to be displayed in the background. This view scrolls slower than the foreground, creating the illusion that it is "further away".
/// @param foregroundView The view to be displayed in the foreground. This view scrolls normally, and should be the one users primarily interact with.
/// @return An initialized view object or nil if the object couldn't be created.
- (id)initWithBackgroundView:(UIView *)backgroundView
              foregroundView:(UIView *)foregroundView;

@end
