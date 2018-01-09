#import "Application/TLConstants.h"

#import "Services/Models/TLMediaData.h"

#import "TLMessageLogUserDefaultsStorage.h"

static NSString *const kStorageKey = @"TLMessageLogStorage";
static NSString *const kMessageKey = @"message";
static NSString *const kIdKey = @"id";
static NSString *const kSenderKey = @"sender";
static NSString *const kReceivedKey = @"received";
static NSString *const kUnreadKey = @"unread";
static NSString *const kDateKey = @"date";
static NSString *const kMediaDataKey = @"mediaData";
static NSString *const kGroupKey = @"group";
static NSString *const kTypeKey = @"type";

@interface TLMessageLogUserDefaultsStorage()

@property (nonatomic, strong) NSMutableArray *storageMessages;

- (void)loadFromStorage;
- (void)saveToStorage;
@end

@implementation TLMessageLogUserDefaultsStorage

#pragma mark -
#pragma mark NSObject

- (id)init
{
    if ((self = [super init]) != nil) {
        self.storageMessages = [[NSMutableArray alloc] init];
        [self loadFromStorage];
    }
    return self;
}

#pragma mark -
#pragma mark <TLMessageLogStorage>

- (NSArray *)messages
{
    return self.storageMessages;
}

- (NSArray *)messagesForJid:(NSString *)theId
{
    return [[self messages] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"jid == %@", theId]];
}

- (NSArray *)messagesForJid:(NSString *)theId sortDescriptors:(NSArray *)sortDescriptors
{
    return [[self messagesForJid:theId] sortedArrayUsingDescriptors:sortDescriptors];
}

- (NSArray *)messagesWithSortDescriptors:(NSArray *)sortDescriptors
{
    return [[self messages] sortedArrayUsingDescriptors:sortDescriptors];
}

- (NSInteger)countUnreadMessages:(NSString *)theId
{
    NSPredicate *predicate = [NSPredicate  predicateWithFormat:@"(jid like %@) AND (unread == YES)", theId];
    return [[[self messages] filteredArrayUsingPredicate:predicate] count];
}

- (NSArray *)chatsByMessagesWithSortDescriptors:(NSArray *)sortDescriptors
{
    NSArray *sortedMessages = [self messagesWithSortDescriptors:sortDescriptors];
    
    NSMutableArray *conversations = [[NSMutableArray alloc] init];

    for (TLMessage *message in sortedMessages)
    {
        NSString *accountName = (message.groupChatMessage) ? message.room.accountName : message.buddy.accountName;
        
        if([[conversations filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"accountName like %@", accountName]] count] == 0)
        {
            [conversations addObject:(message.groupChatMessage) ? message.room : message.buddy];
        }
    }
    
    return conversations;
}

- (void)setUnreadMessagesAsRead:(NSString *)theConvId
{
    NSArray *currentConvMessages =  [self messagesForJid:theConvId sortDescriptors:[NSArray array]];
    
    for (TLMessage *message in currentConvMessages) {
        message.unread = NO;
    }
    [self saveToStorage];
}

- (void)addMessage:(TLMessage *)message
{
    [self.storageMessages addObject:message];
    [self saveToStorage];
}

- (void)reloadStorage
{
    [self.storageMessages removeAllObjects];
    [self loadFromStorage];
}

#pragma mark -
#pragma mark TLMessageLogUserDefaultsStorage

- (void)loadFromStorage
{
    id<TLBuddyListStorage> buddiesStorage = [TLBuddyListManager storage];
    id<TLRoomStorage> roomsStorage = [TLRoomManager storage];
    
    NSArray *storedMessages = [[NSUserDefaults standardUserDefaults] arrayForKey:kStorageKey];
    
    for (NSDictionary *entry in storedMessages)
    {
        NSString *messageStr = [entry objectForKey:kMessageKey];
        NSString *jidStr = [entry objectForKey:kIdKey];
        BOOL received = [[entry objectForKey:kReceivedKey] boolValue];
        BOOL unread = [[entry objectForKey:kUnreadKey] boolValue];
        BOOL groupMessage = [[entry objectForKey:kGroupKey] boolValue];
        NSDate *date = [entry objectForKey:kDateKey];
        NSData *mediaData = [entry objectForKey:kMediaDataKey];
        NSString *senderStr = [entry objectForKey:kSenderKey];
        BOOL messageType = [[entry objectForKey:kTypeKey] boolValue];
        
        TLMessage *message = [TLMessage messageWithJid:jidStr message:messageStr received:received unread:unread];
        message.isNote = messageType;
        
        if (mediaData != nil)
        {
            message.mediaData = [TLMediaData mediaDataWithData:mediaData];
        }
        
        if(groupMessage == NO)
        {
            TLBuddy *buddy = [buddiesStorage buddyForAccountName:jidStr];
            
            if(buddy == nil)
            {
                NSString *phone = [[jidStr componentsSeparatedByString:@"@"] firstObject];
                buddy = [TLBuddy buddyWithDisplayName:phone accountName:jidStr];
            }
            
            buddy.lastMessage = message;
            message.buddy = buddy;
        }
        else
        {
            TLRoom *room = [roomsStorage roomForAccountName:jidStr];
            room.lastMessage = message;
            message.room = room;
            message.sender = senderStr;
        }
        
        message.date = date;
        message.groupChatMessage = groupMessage;
        
        [self.storageMessages addObject:message];
    }
}

- (void)saveToStorage
{
    NSMutableArray *messagesToStore = [NSMutableArray array]; 

    for (TLMessage *message in self.storageMessages) {
        
        NSMutableDictionary *entry = [NSMutableDictionary dictionaryWithDictionary:@{
                kMessageKey: message.message,
                kIdKey: message.jid,
                kReceivedKey: [NSNumber numberWithBool:message.received],
                kUnreadKey: [NSNumber numberWithBool:message.unread],
                kDateKey:message.date,
                kGroupKey: [NSNumber numberWithBool:message.groupChatMessage],
                kTypeKey: [NSNumber numberWithBool:message.isNote]
        }];
        
        if(message.groupChatMessage)
        {
            [entry setObject:message.sender forKey:kSenderKey];
        }
    
        if (message.mediaData != nil)
        {
            NSData *mediaDataRaw = [message.mediaData getObjectData];
            [entry setObject:mediaDataRaw forKey:kMediaDataKey];
        }
        [messagesToStore addObject:entry];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:messagesToStore forKey:kStorageKey];
    //send a notifacation for update the chat history
    [[NSNotificationCenter defaultCenter] postNotificationName:kTLNewMessageNotification object:self];
}

#pragma mark -
#pragma mark <TLMessageLogStorageTesting>

- (void)setFixture:(NSArray *)fixture
{
    fixture = fixture;
    [[NSUserDefaults standardUserDefaults] setObject:fixture forKey:kStorageKey];
    [self reloadStorage];
}

@end
