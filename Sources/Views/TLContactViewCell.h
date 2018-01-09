#import <UIKit/UIKit.h>
#import "TLGroupPicView.h"

@interface TLContactViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet TLGroupPicView *memberImageView;
@property (weak, nonatomic) IBOutlet UILabel *accoutNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *accountStatusLabel;

@end
