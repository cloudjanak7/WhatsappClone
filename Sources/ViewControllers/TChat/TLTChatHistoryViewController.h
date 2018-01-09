#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "Services/Controllers/TChat/TLTChatHistoryController.h"

#import "Views/TLTChatHistoryViewCell.h"
#import "Views/TLActivityView.h"

#import "TLTChatViewController.h"

#import "TLRosterViewController.h"
#import "TLNewGroupViewController.h"
#import "ZGNavigationBarTitleViewController.h"

#import "UIImage+RoundedCorner.h"
#import "UIImage+Tint.h"
#import "UIImage+Color.h"

@interface TLTChatHistoryViewController: UITableViewController<TLTChatHistoryControllerDelegate>

@property (nonatomic, weak) IBOutlet UIButton *createGroup;

@end
