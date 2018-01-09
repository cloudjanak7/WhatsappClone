#import "TLPaddedTextField.h"

NSString * const kBorderTop                   = @"net.dialy.BorderTop";
NSString * const kBorderBottom                = @"net.dialy.BorderBottom";
NSString * const kBorderLeft                  = @"net.dialy.BorderLeft";
NSString * const kBorderRight                 = @"net.dialy.BorderRight";
#define kNAUIViewWithBorders_DefaultDrawOrder   @[kBorderLeft, kBorderRight, kBorderTop, kBorderBottom]

@implementation TLPaddedTextField

#pragma mark -
#pragma mark UITextField

- (CGRect)textRectForBounds:(CGRect)bounds
{
    if (UIEdgeInsetsEqualToEdgeInsets(self.contentInset, UIEdgeInsetsZero))
    {
        return [super textRectForBounds:bounds];
    }

    return CGRectMake(bounds.origin.x + contentInset.left,
                      bounds.origin.y + contentInset.top,
                      bounds.size.width - contentInset.right,
                      bounds.size.height - contentInset.bottom);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return [self textRectForBounds:bounds];
}

#pragma mark -
#pragma mark TLPaddedTextField

@synthesize contentInset;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _borderWidthsAll = -1.0f;
        //custom initialization
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    if (_borderColorAll) {
        _borderColorTop = _borderColorBottom = _borderColorLeft = _borderColorRight = _borderColorAll;
    }
    
    //ivars for speed
    CGFloat xMin = CGRectGetMinX(rect);
    CGFloat xMax = CGRectGetMaxX(rect);
    
    CGFloat yMin = CGRectGetMinY(rect);
    CGFloat yMax = CGRectGetMaxY(rect);
    
    CGFloat fWidth = self.frame.size.width;
    CGFloat fHeight = self.frame.size.height;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (!_drawOrder) {
        _drawOrder = [NSOrderedSet orderedSetWithArray:kNAUIViewWithBorders_DefaultDrawOrder];
    }
    if (_borderWidthsAll > 0) {
        _borderWidths = UIEdgeInsetsMake(_borderWidthsAll, _borderWidthsAll, _borderWidthsAll, _borderWidthsAll);
    }
    
    //Draw the borders in the specified order-----
    for (id item in _drawOrder)
    {
        if ([item isKindOfClass:[NSString class]])
        {
            [self drawBorder:(NSString*)item
                   inContext:context
                        xMin:xMin
                        xMax:xMax
                        yMin:yMin
                        yMax:yMax
                  frameWidth:fWidth
                 frameHeight:fHeight];
        }
    }
}


- (void) drawBorder:(NSString *)borderName
          inContext:(CGContextRef)context
               xMin:(CGFloat)xMin
               xMax:(CGFloat)xMax
               yMin:(CGFloat)yMin
               yMax:(CGFloat)yMax
         frameWidth:(CGFloat)fWidth
        frameHeight:(CGFloat)fHeight
{
    //Draw the respective border if valid--------------
    
    if (borderName == kBorderLeft)
    {
        if ( _borderColorLeft) {
            CGContextSetFillColorWithColor(context, _borderColorLeft.CGColor);
            CGContextFillRect(context, CGRectMake(xMin, yMin, _borderWidths.left, fHeight));
        }
    }
    else if (borderName == kBorderRight)
    {
        if (_borderColorRight) {
            CGContextSetFillColorWithColor(context, _borderColorRight.CGColor);
            CGContextFillRect(context, CGRectMake(xMax - _borderWidths.right, yMin, _borderWidths.right, fHeight));
        }
    }
    else if (borderName == kBorderBottom)
    {
        if ( _borderColorBottom) {
            CGContextSetFillColorWithColor(context, _borderColorBottom.CGColor);
            CGContextFillRect(context, CGRectMake(xMin, yMax - _borderWidths.bottom, fWidth, _borderWidths.bottom));
        }
    }
    else if (borderName == kBorderTop)
    {
        if ( _borderColorTop) {
            CGContextSetFillColorWithColor(context, _borderColorTop.CGColor);
            CGContextFillRect(context, CGRectMake(xMin, yMin, fWidth, _borderWidths.top));
        }
    }
}


@end
