#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString * const kBorderTop;
extern NSString * const kBorderBottom;
extern NSString * const kBorderLeft;
extern NSString * const kBorderRight;

@interface TLPaddedTextField: UITextField

@property (nonatomic, assign) UIEdgeInsets contentInset;

@property UIEdgeInsets borderWidths;                    /* For specifying individual widths */
@property CGFloat borderWidthsAll;                      /* If set, overrides individual widths */
@property (nonatomic, strong) UIColor *borderColorAll;  /* If set, overrides individual colors */
@property (nonatomic, strong) UIColor *borderColorTop;
@property (nonatomic, strong) UIColor *borderColorBottom;
@property (nonatomic, strong) UIColor *borderColorLeft;
@property (nonatomic, strong) UIColor *borderColorRight;

/*!
 @abstract
 Optional.  Specifies the order of drawing the sides.
 Defaults to kNABorderLeft, kNABorderRight, kNABorderTop, kNABorderBottom.
 If provided, any omitted sides will not be drawn.
 
 @discussion
 For example, the default order will draw the top and bottom borders over top of the
 left and right borders.
 e.g.
 --------
 |      |
 --------
 An order of top, right, bottom, left would look like:
 |-------|
 |       |
 |--------
 */
@property (nonatomic, strong) NSOrderedSet *drawOrder;

@end
