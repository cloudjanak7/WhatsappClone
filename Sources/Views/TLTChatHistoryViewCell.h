#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TLGroupPicView.h"

@interface TLTChatHistoryViewCell: UITableViewCell

@property (nonatomic, strong) TLGroupPicView *memberPicView;
@property (nonatomic, strong) NSNumber *unreadMessages;
@property (nonatomic, strong) NSDate *lastDate;

+ (CGFloat)getCellHeight;

@end
