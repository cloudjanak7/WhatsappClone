#import "Application/TLConstants.h"

#import "TLRoomUserDefaultsStorage.h"

static NSString *const kRoomsKey = @"TLRoomStorage";
static NSString *const kJIDKey = @"jid";
static NSString *const kDisplayNameKey = @"displayName";
static NSString *const kPhotoKey = @"photo";
static NSString *const kLastMessageKey = @"message";
static NSString *const kParticipantsKey = @"participants";

@interface TLRoomUserDefaultsStorage()

@property (nonatomic, strong) NSMutableArray *storageRooms;

- (void)loadFromStorage;
- (void)saveToStorage;

@end

@implementation TLRoomUserDefaultsStorage

#pragma mark -
#pragma mark TLContactUserDefaultsStorage

- (id)init
{
    if ((self = [super init]) != nil) {
        self.storageRooms = [[NSMutableArray alloc] init];
        [self loadFromStorage];
    }
    return self;
}

- (TLRoom *)roomForAccountName:(NSString *)accountName
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountName == %@", [accountName lowercaseString]];
    NSArray *matchingRooms = [self.storageRooms filteredArrayUsingPredicate:predicate];
    
    return [matchingRooms lastObject];
}

- (void)loadFromStorage
{
    for (NSDictionary *room in [[NSUserDefaults standardUserDefaults] arrayForKey:kRoomsKey])
    {
        NSString *jid = [room objectForKey:kJIDKey];
        NSString *displayName = [room objectForKey:kDisplayNameKey];
        NSArray *participants = [room objectForKey:kParticipantsKey];
        NSData *photo = [room objectForKey:kPhotoKey];
        
        TLRoom *room = [TLRoom roomWithDisplayName:displayName accountName:jid];

        if (photo != nil) {
            room.photo = photo;
        }
        
        if(participants != nil) {
            room.participants = [NSArray arrayWithArray:participants];
        }

        [self.storageRooms addObject:room];
    }
}

- (void)saveToStorage
{
    NSMutableArray *roomsToStore = [NSMutableArray array];

    for (TLRoom *room in self.storageRooms) {
        
        NSMutableDictionary *entry = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                 kJIDKey: room.accountName,
                                                                 kDisplayNameKey: room.displayName
                                                                 }];
        
        if(room.participants != nil)
        {
            [entry setObject:room.participants forKey:kParticipantsKey];
        }
        
        if (room.photo != nil)
        {
            [entry setObject:room.photo forKey:kPhotoKey];
        }
        
        [roomsToStore addObject:entry];
    }

    [[NSUserDefaults standardUserDefaults] setObject:roomsToStore forKey:kRoomsKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTLRosterDidPopulateNotification object:self];
}

#pragma mark -
#pragma mark <TLRoomtorage>

- (NSArray *)rooms
{
    return self.storageRooms;
}

- (void)addRoom:(TLRoom *)room
{
    if(room == nil)
        return;
    
    if([self roomForAccountName:room.accountName] == nil)
        [self.storageRooms addObject:room];
    else
    {
        TLRoom *tmp = [self roomForAccountName:room.accountName];
        tmp.participants = room.participants;
    }
    
    [self saveToStorage];
}

@end
