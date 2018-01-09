#import "Application/TLConstants.h"

#import "Managers/MessageLog/TLMessageLogManager.h"
#import "Managers/Networking/Messaging/TLProtocolManager.h"

#import "Services/Models/TLMediaData.h"
#import "Services/Models/TLMessage.h"

#import "TLTChatController.h"

static NSString *const kUIKeyboardWillHideNotification = @"UIKeyboardWillHideNotification";

@interface TLTChatController()

@property (nonatomic, weak) id<TLTChatControllerDelegate> delegate;

- (void)sendMessage:(NSString *)message accountName:(NSString *)accountName displayName:(NSString *)displayName type:(BOOL)groupMessage;
- (void)sendMedia:(TLMediaData *)mediaData accountName:(NSString *)accountName displayName:(NSString *)displayName;
- (void)receivedMessageNotification:(NSNotification *)notification;
- (void)updateStatusNotification:(NSNotification *)notification;
- (void)UITextViewDidChange:(NSNotification *)notification;
- (void)UITextViewDidEndChange:(NSNotification *)notification;

@end

@implementation TLTChatController

#pragma mark -
#pragma mark NSObject

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kTLMessageReceivedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kTLDidBuddyVCardUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kTLStatusUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"UITextViewDidEndChange" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"UITextViewDidChange" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kUIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kTLProtocolDisconnectNotification object:nil];
}

#pragma mark -
#pragma mark TLBaseController

- (id)initWithDelegate:(id<TLTChatControllerDelegate>)theDelegate
{
    if ((self = [super initWithDelegate:theDelegate]) != nil)
    {
        self.messageLog = [[NSMutableArray alloc] init];
    
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(receivedMessageNotification:)
         name:kTLMessageReceivedNotification
         object:nil];
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(updateVcardNotification:)
         name:kTLDidBuddyVCardUpdatedNotification
         object:nil];
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(updateStatusNotification:)
         name:kTLStatusUpdateNotification
         object:nil];
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(protocolDisconnectedNotification:)
         name:kTLProtocolDisconnectNotification
         object:nil];
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(UITextViewDidChange:)
         name:@"UITextViewDidChange"
         object:nil];
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(UITextViewDidEndChange:)
         name:@"UITextViewDidEndChange"
         object:nil];
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(UITextViewDidEndChange:)
         name:kUIKeyboardWillHideNotification
         object:nil];
        
    }
    return self;
}

#pragma mark -
#pragma mark TLChatController

@synthesize delegate;
@synthesize messageLog;

- (void)populateMessagesForBuddyAccountName:(NSString *)accountName
{
    //obtained from storage
    NSArray *dateSort = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
    id<TLMessageLogStorage> logStorage = [[TLMessageLogManager sharedInstance] storage];
    
    self.messageLog = [NSMutableArray arrayWithArray:[logStorage messagesForJid:accountName sortDescriptors:dateSort]];
    
    [self setMessagesAsRead];
}

- (NSData *)getAvatarForAccountName:(NSString *)accountName
{
    id<TLProtocol> manager = [[TLProtocolManager sharedInstance] protocol];
    TLBuddy *buddy = [[manager buddyList] buddyForAccountName:accountName];
    return [buddy photo];
}

- (BOOL)getAvailabilityForAccountName:(NSString *)accountName
{
    id<TLProtocol> manager = [[TLProtocolManager sharedInstance] protocol];
    TLBuddy *buddy = [[manager buddyList].storage buddyForAccountName:accountName];
    
    if([self.delegate controllerNeedMessageType:self] || buddy == nil || [manager isConnected] == NO)
        return NO;
    
    if([buddy.presence isEqualToString:@"available"])
    {
        [self.delegate controllerDidUpdateStatus:self userInfo:@"online"];
    }
    else
    {
        [manager sendLastActivityQuery:accountName];
    }
    
    return YES;
}

- (NSInteger)messageLogCount
{
    return [self.messageLog count];
}

- (NSDictionary *)messageAtIndex:(NSInteger)index
{
    TLMessage *message = [self.messageLog objectAtIndex:index];
    NSNumber *ownership = [NSNumber numberWithBool:message.received];
    NSString *displayName = (message.groupChatMessage) ? message.room.displayName : message.buddy.displayName;
    
    NSMutableDictionary *arrayTemp = [NSMutableDictionary
                                      dictionaryWithDictionary:@{
                                                                 @"displayName": displayName,
                                                                 @"message": message.message,
                                                                 @"date": message.date,
                                                                 @"ownership": ownership,
                                                                 @"type": @(message.isNote),
                                                                 @"groupMessage": @(message.groupChatMessage)
                                                                 }];
    
    if ([message mediaData] != nil) {
        [arrayTemp setObject:[message mediaData] forKey:@"mediaData"];
    }
    if(message.groupChatMessage == YES && message.sender != nil) {
        [arrayTemp setObject:message.sender forKey:@"sender"];
    }

    return arrayTemp;
}

- (void)setMessagesAsRead
{
    id<TLMessageLogStorage> logStorage = [[TLMessageLogManager sharedInstance] storage];
    NSString *accountName = [self.delegate controllerNeedAccountName:self];
    [logStorage setUnreadMessagesAsRead:accountName];
}

- (void)sendMessage:(NSString *)message accountName:(NSString *)accountName displayName:(NSString *)displayName type:(BOOL)groupMessage
{
    //creating a new TLMessage
    TLMessage *newMessage = [TLMessage messageWithJid:accountName message:message received:NO unread:NO];
    newMessage.groupChatMessage = groupMessage;
    
    [newMessage send];
    [self.messageLog addObject:newMessage];
}

- (void)sendMedia:(TLMediaData *)mediaData accountName:(NSString *)accountName displayName:(NSString *)displayName
{
    //creating a new TLMessage
    TLMessage *newMessage = [TLMessage messageWithJid:accountName mediaData:mediaData received:NO unread:NO];
    
    [newMessage send];
    [self.messageLog addObject:newMessage];
}

#pragma mark -
#pragma mark Actions

- (void)sendTextMessage
{
    if ([self.delegate controllerNeedMessageLength:self] > 0)
    {
        NSString *message = [self.delegate controllerNeedMessageText:self];
        NSString *accountName = [self.delegate controllerNeedAccountName:self];
        NSString *displayName = [self.delegate controllerNeedDisplayName:self];
        BOOL *isGroupChatMessage = [self.delegate controllerNeedMessageType:self];
        [self sendMessage:message accountName:accountName displayName:displayName type:isGroupChatMessage];
        [self.delegate controllerDidSendMessage:self];
    }
}

- (void)sendMediaPhoto:(NSData *)imageData
{
    NSString *accountName = [self.delegate controllerNeedAccountName:self];
    NSString *displayName = [self.delegate controllerNeedDisplayName:self];
    TLMediaData *mediaData = [[TLMediaData alloc] init];
    mediaData.mediaType = kMessageMediaPhoto;
    mediaData.data = imageData;
    [self sendMedia:mediaData accountName:accountName displayName:displayName];
    [self.delegate controllerDidSendMessage:self];
}

- (void)sendMediaVideo:(NSData *)videoData
{
    NSString *accountName = [self.delegate controllerNeedAccountName:self];
    NSString *displayName = [self.delegate controllerNeedDisplayName:self];
    TLMediaData *mediaData = [[TLMediaData alloc] init];
    mediaData.mediaType = kMessageMediaVideo;
    mediaData.data = videoData;
    [self sendMedia:mediaData accountName:accountName displayName:displayName];
    [self.delegate controllerDidSendMessage:self];
}

#pragma mark -
#pragma mark Notifications

- (void)receivedMessageNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    TLMessage *message = [userInfo objectForKey:@"message"];
    
    [self.messageLog addObject:message];
    
    if([message.jid isEqualToString:[self.delegate controllerNeedAccountName:self]])
    {
        [self.delegate controllerDidReceivedMessage:self];
        [self setMessagesAsRead];
    }
}

- (void)updateVcardNotification:(NSNotification *)notification
{
    [self.delegate controllerDidUpdateAvatar:self];
}

- (void)updateStatusNotification:(NSNotification *)notification
{
    NSString *subtitle = nil;
    NSString *accountName = [self.delegate controllerNeedAccountName:self];
    
    if(notification.userInfo && [accountName isEqualToString:notification.userInfo[@"sender"]])
    {
        if([notification.userInfo[@"lastseen"] integerValue])
        {
            NSInteger minutes = [notification.userInfo[@"lastseen"] integerValue] / 60;
            subtitle = [[NSDate dateWithMinutesBeforeNow:minutes] formatWithString:@"HH:mm, dd MMM"];
        }
        else if ([notification.userInfo[@"typing"] boolValue])
        {
            subtitle = @"typing...";
        }
        else
        {
            [self getAvailabilityForAccountName:accountName];
            
            return;
        }
    }
    
    [self.delegate controllerDidUpdateStatus:self userInfo:subtitle];
}

- (void)UITextViewDidChange:(NSNotification *)notification
{
    NSString *accountName = [self.delegate controllerNeedAccountName:self];
    
    if(![self.delegate controllerNeedMessageType:self])
    {
        TLMessage *newMessage = [TLMessage messageWithJid:accountName message:@"" received:NO unread:NO];
        [newMessage sendComposingState];
    }
}

- (void)UITextViewDidEndChange:(NSNotification *)notification
{
    NSString *accountName = [self.delegate controllerNeedAccountName:self];
    
    if(![self.delegate controllerNeedMessageType:self])
    {
        TLMessage *newMessage = [TLMessage messageWithJid:accountName message:@"" received:NO unread:NO];
        [newMessage sendActiveState];
    }
}

- (void)protocolDisconnectedNotification:(NSNotification *)notification
{
    [self.delegate controllerDidUpdateStatus:self userInfo:nil];
}

@end
