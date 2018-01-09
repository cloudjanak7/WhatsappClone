#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Services/Controllers/TChat/TLRosterController.h"
#import "Views/TLContactViewCell.h"
#import "Services/Models/TLBuddy.h"
#import "TLTChatViewController.h"

#import "UIImage+RoundedCorner.h"
#import "UIImage+Resize.h"

@interface TLRosterViewController: UITableViewController<TLRosterControllerDelegate, UISearchDisplayDelegate, UISearchBarDelegate>

@property (nonatomic) BOOL isModalController;
@property (nonatomic) UISearchDisplayController *searchController;
@property (nonatomic, copy) void (^completionBlock)(TLBuddy *contact, TLRosterViewController* controller);

@end
