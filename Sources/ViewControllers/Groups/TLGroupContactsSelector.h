#import <UIKit/UIKit.h>

#import "Services/Controllers/Groups/TLGroupController.h"
#import "Services/Models/TLBuddy.h"

#import "Views/TLMutlipleTableViewCell.h"
#import "Views/TLTabController.h"

#import "TLTChatViewController.h"

@interface TLGroupContactsSelector : UITableViewController<TLGroupControllerDelegate, UISearchDisplayDelegate, UISearchBarDelegate>

@property (nonatomic, strong) TLGroupController *service;
@property (nonatomic, strong) NSMutableArray *filteredList;

@property (nonatomic, copy) NSString *groupName;
@property (nonatomic, copy) UIImage *groupPicture;

@property (nonatomic) UISearchDisplayController *searchController;

- (instancetype)initWithGroupName:(NSString *)theGroupName photo:(UIImage *)thePhoto;

@end
