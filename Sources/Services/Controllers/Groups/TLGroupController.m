#import "TLGroupController.h"

@interface TLGroupController()

@property (nonatomic, weak) id<TLGroupControllerDelegate> delegate;
@property (nonatomic, strong) NSArray *datasource;
@property (nonatomic, strong) NSMutableArray *selectedBuddies;

@end

@implementation TLGroupController

#pragma mark -
#pragma mark NSObject

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTLDidCreateGroupNotification object:nil];
}

#pragma mark -
#pragma mark TLBaseController

- (id)initWithDelegate:(id<TLGroupControllerDelegate>)theDelegate
{
    if ((self = [super initWithDelegate:theDelegate]) != nil)
    {
        id<TLProtocol> manager = [[TLProtocolManager sharedInstance] protocol];
        
        self.selectedBuddies = [[NSMutableArray alloc] init];
        self.datasource = [[NSArray alloc] init];
        self.datasource = [self partitionObjects:[[manager buddyList].storage buddies] collationStringSelector:@selector(self)];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupCreatedNotification:)
                                                     name:kTLDidCreateGroupNotification object:nil];
        
    }
    return self;
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

#pragma mark -
#pragma mark Notifications

- (void)groupCreatedNotification:(NSNotification *)notification
{
    id<TLProtocol> manager = [[TLProtocolManager sharedInstance] protocol];
    TLRoom *room = notification.userInfo[@"room"];
    
    TLMessage *newMessage = [TLMessage messageWithJid:room.accountName
                                              message:[@"You created" stringByAppendingFormat:@" \"%@\"", room.displayName]
                                             received:NO unread:NO];
    newMessage.groupChatMessage = YES;
    newMessage.isNote = YES;
    newMessage.sender = [[manager account] getUUID];
    
    [room.storage addMessage:newMessage];
    
    [self.delegate controllerDidCreateGroup:room];
}

#pragma mark -
#pragma mark Pariticipants

- (void)addParticipant:(TLBuddy *)buddy
{
    if([self.selectedBuddies containsObject:buddy])
        [self.selectedBuddies removeObject:buddy];
    else
        [self.selectedBuddies addObject:buddy];
}

- (BOOL)isaParticipant:(TLBuddy *)buddy
{
    if([self.selectedBuddies containsObject:buddy])
        return YES;
    
    return NO;
}

#pragma mark -
#pragma mark Room protocol

- (void)createRoom:(NSString *)roomName WithPicture:(UIImage *)roomPicture
{
    TLRoom *room = [TLRoom roomWithDisplayName:roomName
                                   accountName:[NSString stringWithFormat:@"%@@%@", [roomName lowercaseString], kTLConferenceDomain]];
    
    room.photo = UIImagePNGRepresentation(roomPicture);
    room.participants = [[self.selectedBuddies copy] valueForKey:@"accountName"];
    [room saveRoom];
    
    id<TLProtocol> manager = [[TLProtocolManager sharedInstance] protocol];
    [manager createOrJoinRoomWidthJid:room];
}

@end
