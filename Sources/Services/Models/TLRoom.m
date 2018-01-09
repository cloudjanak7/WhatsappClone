#import "Application/TLConstants.h"

#import "Managers/MessageLog/TLMessageLogManager.h"
#import "Managers/RoomManager/TLRoomManager.h"

#import "TLMessage.h"
#import "TLRoom.h"

@implementation TLRoom

@synthesize displayName, accountName, storage, lastMessage, photo, participants;

+ (TLRoom *)roomWithDisplayName:(NSString *)roomName accountName:(NSString *)roomJid
{
    return [[self alloc] initWithDisplayName:roomName accountName:roomJid];
}

- (id)initWithDisplayName:(NSString *)roomName accountName:(NSString *)roomJid
{
    if ((self = [super init]) != nil)
    {
        self.displayName = roomName;
        self.accountName = roomJid;
    }
    
    return self;
}

- (id<TLMessageLogStorage>)storage;
{
    if (storage == nil)
    {
        storage = [[TLMessageLogManager sharedInstance] storage];
    }
    return storage;
}

- (NSInteger)unreadMessages
{
    return [self.storage countUnreadMessages:self.accountName];
}

- (void)receiveMessage:(TLMessage *)message
{
    if (message != nil)
    {
        self.lastMessage = message;
        [[NSNotificationCenter defaultCenter] postNotificationName:kTLMessageProcessedNotification object:self];
    }
}

- (void)saveRoom
{
    TLRoomManager *manager = [TLRoomManager sharedInstance];
    [manager.storage addRoom:self];
}

@end
