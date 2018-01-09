//
//  TLContactViewCell.m
//  WhatsappClone
//
//  Created by abdel ali on 9/13/14.
//  Copyright (c) 2014 none of your business. All rights reserved.
//

#import "TLContactViewCell.h"

@implementation TLContactViewCell

- (void)prepareForReuse
{
    [self.memberImageView reset];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.accoutNameLabel.font = [UIFont systemFontOfSize:15];
    self.accountStatusLabel.textColor = [UIColor grayColor];
    self.accountStatusLabel.font = [UIFont systemFontOfSize:12];
    
}


@end
