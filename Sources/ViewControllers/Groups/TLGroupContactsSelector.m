#import "TLGroupContactsSelector.h"

@implementation TLGroupContactsSelector

#pragma mark -
#pragma mark TLGroupController

@synthesize service;
@synthesize groupName;
@synthesize groupPicture;

- (instancetype)initWithGroupName:(NSString *)theGroupName photo:(UIImage *)thePhoto
{
    if ((self = [super init]) != nil)
    {
        groupName = theGroupName;
        groupPicture = thePhoto;
        self.tableView.allowsMultipleSelection = YES;
        self.title = @"Add Participants";
        
        // Search bar
        UISearchBar * searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0 , 320, 40)]; // frame has no effect.
        searchBar.delegate = self;
            
        self.tableView.tableHeaderView = searchBar;
        
        // Search controller
        self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
        _searchController.delegate = self;
        _searchController.searchResultsDataSource = self;
        _searchController.searchResultsDelegate = self;
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithTitle:@"Create"
                                                  style:UIBarButtonItemStylePlain
                                                  target:self
                                                  action:@selector(createRoom)];
        
    }
    return self;
}

- (TLGroupController *)service
{
    if (service == nil)
        service = [[TLGroupController alloc] initWithDelegate:self];
    return service;
}

#pragma mark -
#pragma mark UITableView Data Source

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [UILocalizedIndexedCollation.currentCollation sectionIndexTitles];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return 1;
    }
    
    //we use sectionTitles and not sections
    return [[UILocalizedIndexedCollation.currentCollation sectionTitles] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return [self.filteredList count];
    }
    return [self.service numberOfRowsInSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    }
    
    BOOL showSection = [self.service numberOfRowsInSection:section] != 0;
    return (showSection) ? [[UILocalizedIndexedCollation.currentCollation sectionTitles] objectAtIndex:section] : nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TableViewCellIdentifier = @"cellIdentifier";
    
    // init the CRTableViewCell
    TLMutlipleTableViewCell *cell = (TLMutlipleTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:TableViewCellIdentifier];
    
    if (cell == nil) {
        cell = [[TLMutlipleTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:TableViewCellIdentifier];
    }
    
    TLBuddy *buddy = nil;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        buddy = self.filteredList[indexPath.row];
    } else {
        buddy = [self.service buddyForIndex:indexPath];
    }
    
    cell.isSelected = [self.service isaParticipant:buddy];
    cell.textLabel.text = buddy.displayName;
    cell.detailTextLabel.text = [buddy getStatus];
    
    return cell;
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        [self.service addParticipant:[self.filteredList objectAtIndex:indexPath.row]];
        [self.searchDisplayController.searchResultsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                                                   withRowAnimation:UITableViewRowAnimationAutomatic];
        
        return;
    }
    
    [self.service addParticipant:[self.service buddyForIndex:indexPath]];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    if(!_filteredList)
        self.filteredList = [[NSMutableArray alloc] init];
    
    [self.filteredList removeAllObjects];
    
    NSArray *people = [NSArray arrayWithArray:[self.service allBuddies]];
    
    for (TLBuddy *obj in people)
    {
        NSComparisonResult result = [obj.displayName compare:[searchText uppercaseString]
                                                     options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)
                                                       range:NSMakeRange(0, [searchText length])];
        
        if (result == NSOrderedSame)
        {
            [self.filteredList addObject:obj];
        }
    }
}

#pragma mark - UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [controller.searchResultsTableView setRowHeight:50];
    [controller.searchResultsTableView setScrollEnabled:YES];
    
    [self filterContentForSearchText:searchString scope:[self.searchDisplayController.searchBar scopeButtonTitles][[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text]
                               scope:[self.searchDisplayController.searchBar scopeButtonTitles][searchOption]];
    
    return YES;
}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    [self.tableView reloadData];
}

#pragma mark - 
#pragma mark Actions

- (void)createRoom
{
    [self.service createRoom:self.groupName WithPicture:self.groupPicture];
}

#pragma mark -
#pragma mark <TLGroupControllerDelegate>

- (void)controllerDidCreateGroup:(TLRoom *)group
{
    TLTabController *tabController = (TLTabController *)self.presentingViewController;
    __weak UIViewController *chats = [(UINavigationController *)tabController.selectedViewController topViewController];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        [chats.navigationController
         pushViewController:[[TLTChatViewController alloc] initWithBuddyAccountName:group.accountName
                                                                        displayName:group.displayName
                                                                              photo:group.photo type:YES]
         animated:YES];
        
        
    }];
}

@end
