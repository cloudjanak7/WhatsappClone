#import "TLTChatHistoryViewCell.h"

@implementation TLTChatHistoryViewCell

#pragma mark -
#pragma mark TLTChatHistoryViewCell

@synthesize unreadMessages, lastDate;

+ (CGFloat)getCellHeight
{
    return 60.;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
    if((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
    {
        CGRect accesoryRect = CGRectMake(.0, .0, 85., 40.);
        UIView *accessoryView = [[UIView alloc] initWithFrame:accesoryRect];
        self.textLabel.font = [UIFont boldSystemFontOfSize:15];
        self.detailTextLabel.textColor = [UIColor grayColor];
        self.accessoryView = accessoryView;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

- (void)prepareForReuse
{
    [self.memberPicView reset];
    
    for (UIView *subview in [self.accessoryView subviews])
    {
        [subview removeFromSuperview];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.memberPicView = [[TLGroupPicView alloc] initWithFrame:CGRectMake(8., 5., 45., 45.)];
    self.memberPicView.totalEntries = 1;
    [self addSubview:self.memberPicView];
    
    CGRect tmpFrame = self.textLabel.frame;
    tmpFrame.origin.x = 58;
    tmpFrame.origin.y = 5;
    self.textLabel.frame = tmpFrame;

    tmpFrame = self.detailTextLabel.frame;
    tmpFrame.origin.x = 58;
    self.detailTextLabel.frame = tmpFrame;

    UILabel *dateLabel = nil;
    
    //date text
    if(self.lastDate != nil)
    {
        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(.0, .0, 60., 15.)];
        dateLabel.font = [UIFont systemFontOfSize:12];
        dateLabel.textAlignment = NSTextAlignmentCenter;
        dateLabel.textColor = [UIColor grayColor];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setDoesRelativeDateFormatting:YES];
        dateLabel.text = [dateFormatter stringFromDate:self.lastDate];
        if (!([dateLabel.text isEqualToString:@"Today"] || [dateLabel.text isEqualToString:@"Yesterday"]))
        {
            [dateFormatter setDoesRelativeDateFormatting:NO];
            [dateFormatter setDateFormat:@"MMM d"];
            dateLabel.text = [dateFormatter stringFromDate:self.lastDate];
            
        }
        [self.accessoryView addSubview:dateLabel];
    }

    //unread text
    if(self.unreadMessages != nil && [self.unreadMessages intValue] > 0)
    {
        UILabel *unreadLabel = [[UILabel alloc] initWithFrame:CGRectMake(.0, 0., 21., 21.)];
        unreadLabel.center = CGPointMake(dateLabel.center.x, 30);
        unreadLabel.font = [UIFont systemFontOfSize:12];
        unreadLabel.textAlignment = NSTextAlignmentCenter;
        unreadLabel.backgroundColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
        unreadLabel.textColor = [UIColor whiteColor];
        unreadLabel.text = [self.unreadMessages stringValue];
        unreadLabel.layer.cornerRadius = 10;
        unreadLabel.layer.masksToBounds = YES;
        [self.accessoryView addSubview:unreadLabel];
    }
}
@end
