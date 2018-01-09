#import "TLRosterViewController.h"

NSString *const kTLRosterViewCellId = @"TLRosterViewCell";

@interface TLRosterViewController()

@property (nonatomic, strong) TLRosterController *service;
@property (nonatomic, strong) NSMutableArray *filteredList;

@end

@implementation TLRosterViewController

#pragma mark -
#pragma mark UITableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createSearchBar];
    
    if(self.isModalController)
    {
        [self createCancelButton];
        self.title = @"Select Contact";
    }
    else
        self.title = @"Contacts";
}

- (void)createSearchBar
{
    if (self.tableView && !self.tableView.tableHeaderView)
    {
        UISearchBar * searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0 , 320, 40)]; // frame has no effect.
        searchBar.delegate = self;
        //searchBar.showsCancelButton = YES;
        
        self.tableView.tableHeaderView = searchBar;
        
        self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
        _searchController.delegate = self;
        _searchController.searchResultsDataSource = self;
        _searchController.searchResultsDelegate = self;
        //_searchController.displaysSearchBarInNavigationBar = YES;
        //[_searchController setActive:YES animated:YES];
        
        [searchBar becomeFirstResponder];
        [self.tableView reloadData];
    }
}

- (void)createCancelButton
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(dismissViewController)];;
}

- (void)dismissViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark <UITableViewDataSource>

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
        return [_filteredList count];
    }
    return [self.service numberOfRowsInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TLContactViewCell *cell = (TLContactViewCell *)[self.tableView dequeueReusableCellWithIdentifier:kTLRosterViewCellId];
    
    if (cell == nil)
        cell = [[TLContactViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTLRosterViewCellId];
    
    TLBuddy *obj = nil;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        obj = self.filteredList[indexPath.row];
    } else {
        obj = [self.service buddyForIndex:indexPath];
    }
    
    [cell.memberImageView reset];
    cell.memberImageView.totalEntries = 1;
    cell.accoutNameLabel.text = obj.displayName;
    cell.accountStatusLabel.text = [obj getStatus];
    [cell.memberImageView addImage:[UIImage imageWithData:obj.photo] withInitials:cell.accoutNameLabel.text];
    [cell.memberImageView updateLayout];
    
    return cell;
}

#pragma mark -
#pragma mark <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *accountName = [self.service buddyAccountNameForIndex:indexPath];
    NSString *displayName = [self.service buddyDisplayNameForIndex:indexPath];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(self.isModalController && self.completionBlock)
    {
        TLBuddy *obj = nil;
        
        if(tableView == self.searchDisplayController.searchResultsTableView) {
            obj = self.filteredList[indexPath.row];
        }
        else {
            obj = [self.service buddyForIndex:indexPath];
        }
        
        self.completionBlock(obj, self);
    }
    else
    {
        [self.navigationController
            pushViewController:[[TLTChatViewController alloc] initWithBuddyAccountName:accountName
                                                                           displayName:displayName
                                                                                 photo:nil
                                                                                  type:NO]
            animated:YES];
    }
}

#pragma mark -
#pragma mark <TLRosterViewController>

- (void)controllerDidPopulateRoster:(TLRosterController *)controller
{
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark TLRosterViewController

@synthesize service;

- (TLRosterController *)service
{
    if (service == nil)
        service = [[TLRosterController alloc] initWithDelegate:self];
    return service;
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

#pragma mark - searchBar delegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
}

@end
