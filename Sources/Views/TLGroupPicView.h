#import <UIKit/UIKit.h>

@interface TLGroupPicView : UIView

@property (nonatomic, assign) NSUInteger totalEntries;

- (void)addImage:(UIImage *)image withInitials:(NSString *)initials;
- (void)updateLayout;
- (void)reset;

@end