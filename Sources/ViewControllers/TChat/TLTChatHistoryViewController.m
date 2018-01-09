#import "TLTChatHistoryViewController.h"

NSString *const kTLHistoryViewCellId = @"TLHistoryViewCellId";
NSString *const kTLHistoryViewActionsCellId = @"TLHistoryViewActionsCellId";

@interface TLTChatHistoryViewController ()

@property (nonatomic, strong) TLTChatHistoryController *service;
@property (nonatomic, strong) TLActivityView* activityView;

- (void)newChatWindow;
@end

@implementation TLTChatHistoryViewController

#pragma mark -
#pragma mark UITableViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]) != nil)
    {
        self.title = @"Chats";
        [self.service populateBuddies];
        
        UIButton *newChatButton = [[UIButton alloc] initWithFrame:CGRectMake(.0, .0, 25., 25.)];
        [newChatButton setImage:[[UIImage imageNamed:@"NewChat"] imageWithColor:TL_DEFAULT_COLOR]
                       forState:UIControlStateNormal];
        [newChatButton addTarget:self action:@selector(newChatWindow)
                forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *newChatButtonItem = [[UIBarButtonItem alloc] initWithCustomView:newChatButton];
       
        self.navigationItem.rightBarButtonItem = newChatButtonItem;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self activityIndicator];
    [self fixHeaderBorders];
}

- (void)fixHeaderBorders
{
    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 320, .5)];
    borderView.backgroundColor = [UIColor colorWithRed:200/255.0 green:199/255.0 blue:204/255.0 alpha:1.0];
    [self.tableView.tableHeaderView addSubview:borderView];
}

#pragma mark -
#pragma mark Activity indicator

- (void)activityIndicator
{
    UIImage* activityImage = [[UIImage imageWithColor:TL_DEFAULT_COLOR]
                              resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)];
    
    self.activityView = [[TLActivityView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 4)
                                               andActivityBar:activityImage];
    
    [self.view addSubview:_activityView];
}

#pragma mark -
#pragma mark <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.service buddiesCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    
    TLTChatHistoryViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTLHistoryViewCellId];
    
    if (cell == nil)
        cell = [[TLTChatHistoryViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kTLHistoryViewCellId];

    NSDictionary *buddy = [self.service buddyAtIndex:index];

    NSData *photoData = [buddy objectForKey:@"photo"];
    
    cell.textLabel.text = [buddy objectForKey:@"displayName"];
    cell.detailTextLabel.numberOfLines = 2;
    cell.detailTextLabel.text = [buddy objectForKey:@"lastMessage"];

    [cell.memberPicView reset];
    [cell.memberPicView addImage:[[UIImage alloc] initWithData:photoData]
                    withInitials:[buddy objectForKey:@"displayName"]];
    [cell.memberPicView updateLayout];
    
    cell.lastDate = [buddy objectForKey:@"lastDate"];
    cell.unreadMessages = [buddy objectForKey:@"unreadMessages"];
    
    return cell;
}

#pragma mark -
#pragma mark <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *buddy = [self.service buddyAtIndex:indexPath.row];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController
     pushViewController:[[TLTChatViewController alloc]
                         initWithBuddyAccountName:[buddy objectForKey:@"accountName"] displayName:[buddy objectForKey:@"displayName"]
                                            photo:[buddy objectForKey:@"photo"] type:[buddy[@"groupChatMessage"] boolValue]]
               animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [TLTChatHistoryViewCell getCellHeight];
}

#pragma mark -
#pragma mark <TLTChatHistoryControllerDelegate>

- (void)updateData
{
    [self.tableView reloadData];
}

- (void)startConnectionActivity
{
    [self.activityView start];
}

- (void)stopConnectionActivity
{
    [self.activityView stop];
}

- (void)enableNewGroupButton
{
    self.createGroup.enabled = YES;
}

- (void)disableNewGroupButton
{
    self.createGroup.enabled = NO;
}

#pragma mark -
#pragma mark TLTChatHistoryViewController

@synthesize service;

- (TLTChatHistoryController *)service
{
    if (service == nil)
        service = [[TLTChatHistoryController alloc] initWithDelegate:self];
    return service;
}

- (void)newChatWindow
{
    TLRosterViewController *controller = (TLRosterViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"TLRosterViewController"];
    
    controller.isModalController = YES;
    controller.completionBlock = ^(TLBuddy *obj, TLRosterViewController *controller) {
        
        __weak TLTChatHistoryViewController *_self = self;
        
        [controller dismissViewControllerAnimated:YES completion:^{
            [_self.navigationController pushViewController:[[TLTChatViewController alloc]
                                                                initWithBuddyAccountName:obj.accountName
                                                                displayName:obj.displayName
                                                                photo:obj.photo
                                                                type:NO]
                                                  animated:YES];
        }];
    };
    
    [self presentViewController:[[ZGNavigationBarTitleViewController alloc] initWithRootViewController:controller]
                       animated:YES completion:nil];
}

#pragma mark -
#pragma mark Actions

- (IBAction)newGroup:(id)sender
{
    [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"TLNewGroupViewController"] animated:YES completion:nil];
}

@end
