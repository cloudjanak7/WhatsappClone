#import "Application/TLConstants.h"
#import "TLRosterController.h"

@interface TLRosterController()

@property (nonatomic, weak) id<TLRosterControllerDelegate> delegate;
@property (nonatomic, strong) NSArray *datasource;

- (void)rosterDidPopulateNotification:(NSNotification *)notification;

@end

@implementation TLRosterController

@synthesize datasource;

#pragma mark -
#pragma mark NSObject

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTLRosterDidPopulateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTLDidBuddyVCardUpdatedNotification object:nil];
}

#pragma mark -
#pragma mark TLBaseController

- (id)initWithDelegate:(id<TLRosterControllerDelegate>)theDelegate
{
    if ((self = [super initWithDelegate:theDelegate]) != nil)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rosterDidPopulateNotification:)
                                                     name:kTLRosterDidPopulateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rosterDidPopulateNotification:)
                                                     name:kTLDidBuddyVCardUpdatedNotification object:nil];
        
        id<TLProtocol> manager = [[TLProtocolManager sharedInstance] protocol];
        [manager getContactsList];
    }
    
    return self;
}

#pragma mark -
#pragma mark Datasource

- (NSArray *)datasource
{
    if(datasource == nil)
        datasource = [[NSArray alloc] init];
    
    id<TLProtocol> manager = [[TLProtocolManager sharedInstance] protocol];
    datasource = [self partitionObjects:[[manager buddyList].storage buddies] collationStringSelector:@selector(self)];
    
    return datasource;
}

#pragma mark -
#pragma mark TLRosterController

@synthesize delegate;

- (NSArray *)partitionObjects:(NSArray *)array collationStringSelector:(SEL)selector
{
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    NSInteger sectionCount = [[collation sectionTitles] count];
    NSMutableArray *unsortedSections = [NSMutableArray arrayWithCapacity:sectionCount];
    
    for (int i = 0; i < sectionCount; i++) {
        [unsortedSections addObject:[NSMutableArray array]];
    }
    
    for (TLBuddy* obj in array) {
        NSInteger index = [collation sectionForObject:obj.displayName collationStringSelector:selector];
        [[unsortedSections objectAtIndex:index] addObject:obj];
    }
    
    NSMutableArray *sections = [NSMutableArray arrayWithCapacity:sectionCount];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayName"
                                                                   ascending:YES
                                                                    selector:@selector(localizedCaseInsensitiveCompare:)];
    
    for (NSMutableArray *section in unsortedSections) {
        
        NSArray *sortedArray = [section sortedArrayUsingDescriptors:@[sortDescriptor]];
        [sections addObject:sortedArray];
    }
    
    return sections;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    return [self.datasource[section] count];
}

- (TLBuddy *)buddyForIndex:(NSIndexPath *)index
{
    return [self.datasource[index.section] objectAtIndex:index.row];
}

- (NSString *)buddyAccountNameForIndex:(NSIndexPath *)index
{
    TLBuddy *buddy = [self buddyForIndex:index];
    return buddy.accountName;
}

- (NSArray *)allBuddies
{
    id<TLProtocol> manager = [[TLProtocolManager sharedInstance] protocol];
    return [[manager buddyList].storage buddies];
}

- (NSString *)buddyDisplayNameForIndex:(NSIndexPath *)index
{
    TLBuddy *buddy = [self buddyForIndex:index];
    return buddy.displayName;
}

- (NSData *)buddyDisplayPhotoForIndex:(NSIndexPath *)index
{
    TLBuddy *buddy = [self buddyForIndex:index];
    return buddy.photo;
}

- (NSString *)buddyStatusForIndex:(NSIndexPath *)index
{
    TLBuddy *buddy = [self buddyForIndex:index];
    return [buddy getStatus];
}

#pragma mark -
#pragma mark Notifications

- (void)rosterDidPopulateNotification:(NSNotification *)notification
{
    [self.delegate controllerDidPopulateRoster:self];
}

@end
