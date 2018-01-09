#import "TLCustomLabel.h"

@implementation TLCustomLabel

- (id)init
{
    self = [super init];
    
    if(self) {
        self.edgeInsets = UIEdgeInsetsMake(2, 5, 2, 5);
    }
    
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.edgeInsets)];
}

- (CGSize)intrinsicContentSize
{
    CGSize size = [super intrinsicContentSize];
    size.width  += self.edgeInsets.left + self.edgeInsets.right;
    size.height += self.edgeInsets.top + self.edgeInsets.bottom;
    return size;
}

@end
