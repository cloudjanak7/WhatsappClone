#import "Application/TLConstants.h"

#import "Managers/Networking/Messaging/TLProtocolManager.h"
#import "Managers/MessageLog/TLMessageLogManager.h"

#import "TLTChatHistoryController.h"

@interface TLTChatHistoryController()

@property (nonatomic, weak) id<TLTChatHistoryControllerDelegate> delegate;
@property (nonatomic, strong) NSArray *buddies;

@end

@implementation TLTChatHistoryController

#pragma mark -
#pragma mark NSObject

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTLNewMessageNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTLDidBuddyVCardUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTLProtocolLoginSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTLProtocolLoginFailNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTLProtocolDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTLProtocolDisconnectNotification object:nil];
}

#pragma mark -
#pragma mark TLBaseController

@synthesize delegate;
@synthesize buddies;

#pragma mark -
#pragma mark TLTChatHistoryController

@synthesize storage;

- (id<TLMessageLogStorage>)storage
{
    if (storage == nil)
    {
        storage = [[TLMessageLogManager sharedInstance] storage];
    }
    return storage;
}

- (id)initWithDelegate:(id<TLTChatHistoryControllerDelegate>)theDelegate
{
    if ((self = [super initWithDelegate:theDelegate]) != nil)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectingNotification:)
                                                     name:kTLProtocolDidConnectNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failStatusNotification:)
                                                     name:kTLProtocolLoginFailNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successStatusNotification:)
                                                     name:kTLProtocolLoginSuccessNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failStatusNotification:)
                                                     name:kTLProtocolDisconnectNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNewMessageNotification:)
                                                     name:kTLNewMessageNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNewMessageNotification:)
                                                     name:kTLDidBuddyVCardUpdatedNotification object:nil];
    }
    return self;
}

- (void)populateBuddies
{
    NSArray *dateSort = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
    self.buddies = [NSMutableArray arrayWithArray:[self.storage chatsByMessagesWithSortDescriptors:dateSort]];
}

- (NSInteger)buddiesCount
{
    return [self.buddies count];
}

- (NSDictionary *)buddyAtIndex:(NSInteger)index
{
    NSMutableDictionary *sendDict  = [NSMutableDictionary dictionary];
    
    NSString *lastMessage = nil;
    NSString *displayName = nil;
    NSString *accountName = nil;
    NSNumber *unreadMessages = nil;
    NSNumber *groupChat = nil;
    NSDate *lastDate = nil;
    NSData *photo = nil;
    
    if([[self.buddies objectAtIndex:index] isKindOfClass:[TLBuddy class]])
    {
        TLBuddy *buddy = [self.buddies objectAtIndex:index];
    
        lastMessage = buddy.lastMessage.message;
        displayName = buddy.displayName;
        accountName = buddy.accountName;
        unreadMessages = @([buddy unreadMessages]);
        groupChat = @(NO);
        lastDate = buddy.lastMessage.date;
        
        if(buddy.photo)
            photo = buddy.photo;
        
    }
    else
    {
        TLRoom *room = [self.buddies objectAtIndex:index];
        
        lastMessage = room.lastMessage.message;
        displayName = room.displayName;
        accountName = room.accountName;
        unreadMessages = @([room unreadMessages]);
        groupChat = @(YES);
        lastDate = room.lastMessage.date;
        
        if(room.photo)
            photo = room.photo;
    }
    
    sendDict =
    [NSMutableDictionary dictionaryWithDictionary:@{
                                                    @"accountName": accountName,
                                                    @"displayName": displayName,
                                                    @"lastMessage": lastMessage,
                                                    @"groupChatMessage": groupChat,
                                                    @"lastDate": lastDate,
                                                    @"unreadMessages": unreadMessages
                                                    }];
    
    if (photo != nil)
    {
        [sendDict setObject:photo forKey:@"photo"];
    }
    
    return sendDict;
}

- (BOOL)enableNewGroupButton
{
    id<TLProtocol> manager = [[TLProtocolManager sharedInstance] protocol];
    return [manager isConnected];
}

#pragma mark -
#pragma mark Notifications

- (void)receivedNewMessageNotification:(NSNotification *)notification
{
    [self.storage reloadStorage];
    [self populateBuddies];
    [self.delegate updateData];
}

- (void)connectingNotification:(NSNotification *)notification
{
    [self.delegate startConnectionActivity];
}

- (void)failStatusNotification:(NSNotification *)notification
{
    [self.delegate stopConnectionActivity];
    [self.delegate disableNewGroupButton];
}

- (void)successStatusNotification:(NSNotification *)notification
{
    [self.delegate stopConnectionActivity];
    [self.delegate enableNewGroupButton];
}

@end
