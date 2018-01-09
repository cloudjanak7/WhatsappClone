//
//  SOMessageNotificationCell.m
//  WhatsappClone
//
//  Created by abdel ali on 10/1/14.
//  Copyright (c) 2014 none of your business. All rights reserved.
//

#import "SOMessageNotificationCell.h"
#import "NSString+Calculation.h"

@implementation SOMessageNotificationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.messageLabel = [[TLCustomLabel alloc] init];
        self.messageLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
        self.messageLabel.textColor = [UIColor whiteColor];
        self.messageLabel.numberOfLines = 0;
        self.messageLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        self.messageLabel.textAlignment = NSTextAlignmentCenter;
        self.messageLabel.backgroundColor = [UIColor colorWithRed:74.0/255.0 green:186.0/255.0 blue:251.0/255.0 alpha:1.0];
        self.messageLabel.layer.masksToBounds = YES;
        self.messageLabel.layer.cornerRadius = 5.0;
        
        [self.contentView addSubview:self.messageLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.messageLabel.frame;
    frame.size = [self.messageLabel.text usedSizeForMaxWidth:140 withFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12]];
    frame.size.width += 20;
    frame.size.height += 5;
    
    self.messageLabel.frame =  frame;
    self.messageLabel.center = self.contentView.center;
}

@end
