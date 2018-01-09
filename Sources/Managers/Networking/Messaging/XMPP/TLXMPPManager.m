#import "TLXMPPManager.h"
#import <dispatch/dispatch.h>
#import <UIKit/UIKit.h>

#import "XMPPFramework.h"
#import "DDLog.h"
#import "DDTTYLogger.h"

#import "Application/TLConstants.h"

#import "Services/Models/TLAccount.h"
#import "Services/Models/TLBuddy.h"
#import "Services/Models/TLMessage.h"
#import "Services/Models/TLRoom.h"

#import "Managers/AccountManager/TLAccountManager.h"
#import "Managers/MessageLog/TLMessageLogManager.h"
#import "Managers/ContactManager/TLBuddyListManager.h"
#import "Managers/RoomManager/TLRoomManager.h"

#import "Categories/NSArray+Map.h"

// Log levels: OFF, ERROR, WARN, INFO, VERBOS
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
static NSString *const xmlns_chatstates = @"http://jabber.org/protocol/chatstates";

@interface TLXMPPManager()
@property (nonatomic, strong) XMPPStream *xmppStream;
@property (nonatomic, strong) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong) XMPPRoster *xmppRoster;
@property (nonatomic, strong) XMPPRosterMemoryStorage *xmppRosterStorage;
@property (nonatomic, strong) XMPPvCardCoreDataStorage *xmppvCardStorage;
@property (nonatomic, strong) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong) XMPPLastActivity *xmppLastActivity;
@property (nonatomic, strong) XMPPMessageDeliveryReceipts *xmppMessageDeliveryRecipts;
@property (nonatomic, strong) XMPPMUC *xmppMuc;
@property (nonatomic, strong) XMPPRoom *xmppRoom;
@property (nonatomic, strong) XMPPRoom *prevXmppRoom;
@property (nonatomic, assign) BOOL isXmppConnected;
@property (nonatomic, assign) BOOL updateMyVcard;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, strong) NSMutableArray *turnSockets;
@property (nonatomic, strong) NSMutableArray *delegates;
@property (nonatomic, strong) NSData *sendData;
@property (nonatomic, assign) BOOL *isSending;

- (void)setupStream;
- (void)teardownStream;
- (void)connectWithJID:(NSString *)JID password:(NSString *)password;
- (void)goOnline;
- (void)goOffline;
- (void)failedToConnect;
- (TLBuddy *)buddyWithMessage:(XMPPMessage *)message;
- (void)updateBuddyWithVCard:(XMPPvCardTemp *)vCardTemp forJid:(XMPPJID *)jid;
- (void)applicationWillResignActiveNotification:(NSNotification *)notification;
- (void)upload:(NSData*)dataToUpload inBucket:(NSString*)bucket forKey:(NSString*)key;
@end

@implementation TLXMPPManager

#pragma mark -
#pragma mark NSObject

- (id)init
{
    if ((self = [super init]) != nil)
    {
        // Configure logging framework
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        
        // Setup the XMPP stream
        [self setupStream];
        self.buddyList = [[TLBuddyList alloc] init];
        
        // conf notifications
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillResignActiveNotification:)
                                                     name:UIApplicationWillResignActiveNotification object:nil];
        
		// Initialize other stuff
		self.turnSockets = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [self teardownStream];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

#pragma mark -
#pragma mark <TLProtocol>

- (BOOL)isConnected
{
    return !self.xmppStream.isDisconnected;
}

- (void)sendLastActivityQuery:(NSString *)jid
{
    [self.xmppLastActivity sendLastActivityQueryToJID:[XMPPJID jidWithString:jid]];
}

- (void)sendTimeOfChatQuery:(NSString *)jid
{
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addAttributeWithName:@"id" stringValue:@"time-of-chat"];
    
    NSXMLElement *retrieve = [NSXMLElement elementWithName:@"list" xmlns:@"urn:xmpp:archive"];
    [retrieve addAttributeWithName:@"with" stringValue:jid];
    
    NSXMLElement *set = [NSXMLElement elementWithName:@"set" xmlns:@"http://jabber.org/protocol/rsm"];
    NSXMLElement *max = [NSXMLElement elementWithName:@"max" stringValue:@"100"];
    
    [iq addChild:retrieve];
    [retrieve addChild:set];
    [set addChild:max];
    
    [self.bridge sendMessageBridge:iq];
}

- (void)sendHistoryQueryFor:(NSString *)jid startingFrom:(NSString *)date
{
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addAttributeWithName:@"id" stringValue:@"chat-history"];
    
    NSXMLElement *retrieve = [NSXMLElement elementWithName:@"retrieve" xmlns:@"urn:xmpp:archive"];
    [retrieve addAttributeWithName:@"with" stringValue:jid];
    [retrieve addAttributeWithName:@"start" stringValue:date];
    
    NSXMLElement *set = [NSXMLElement elementWithName:@"set" xmlns:@"http://jabber.org/protocol/rsm"];
    NSXMLElement *max = [NSXMLElement elementWithName:@"max" stringValue:@"100"];
    
    [iq addChild:retrieve];
    [retrieve addChild:set];
    [set addChild:max];
    
    [self.bridge sendMessageBridge:iq];
}

- (void)sendComposingMessage:(TLMessage *)theMessage
{
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    [message addAttributeWithName:@"to" stringValue: theMessage.jid];
    [message addAttributeWithName:@"id" stringValue:[[NSUUID UUID] UUIDString]];
    [message addChild:[NSXMLElement elementWithName:@"composing" xmlns:xmlns_chatstates]];
    
    [self.bridge sendMessageBridge:message];
}

- (void)sendActiveMessage:(TLMessage *)theMessage
{
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    [message addAttributeWithName:@"to" stringValue: theMessage.jid];
    [message addAttributeWithName:@"id" stringValue:[[NSUUID UUID] UUIDString]];
    [message addChild:[NSXMLElement elementWithName:@"active" xmlns:xmlns_chatstates]];
    
    [self.bridge sendMessageBridge:message];
}

- (void)sendMessage:(TLMessage *)theMessage
{
    NSString *messageStr = theMessage.message;
    
    if ([messageStr length] > 0)
    {
        NSString *messageId=[self.xmppStream generateUUID];
        
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:messageStr];
        
        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
        [message addAttributeWithName:@"type" stringValue:(theMessage.groupChatMessage) ? @"groupchat" : @"chat"];
        [message addAttributeWithName:@"to" stringValue: theMessage.jid];
        [message addAttributeWithName:@"id" stringValue:messageId];
        
        NSXMLElement * receiptRequest = [NSXMLElement elementWithName:@"request"];
        [receiptRequest addAttributeWithName:@"xmlns" stringValue:@"urn:xmpp:receipts"];
        
        NSXMLElement *sender = [NSXMLElement elementWithName:@"sender"];
        [sender setStringValue:[self.account getUUID]];
        
        [message addChild:sender];
        [message addChild:receiptRequest];
        [message addChild:body];
        [self.bridge sendMessageBridge:message];
        [self.storage addMessage:theMessage];
    }
}

- (void)sendViaMedia:(TLMessage *)theMessage
{
}

-(void)upload:(NSData*)dataToUpload inBucket:(NSString*)bucket forKey:(NSString*)key
{
}

- (void)connectWithPassword:(NSString *)thePassword
{
    [self connectWithJID:[self.account getUUID] password:thePassword];
}

- (void)disconnect
{
    [self goOffline];
    [self.xmppStream disconnect];
//    [self.xmppRosterStorage clearAllUsersAndResourcesForXMPPStream:self.xmppStream];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kTLProtocolLogoutNotification
     object:self];
}

- (void)updateAccountDataWithTLAccount
{
    if (self.xmppvCardTempModule)
    {
        [self.xmppvCardTempModule removeDelegate:self delegateQueue:dispatch_get_main_queue()];
        [self.xmppvCardTempModule deactivate];
    }
    
    self.xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
    [self.xmppvCardTempModule activate:self.xmppStream];
    [self.xmppvCardTempModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    self.updateMyVcard = YES;
    [self.xmppvCardTempModule fetchvCardTempForJID:self.xmppStream.myJID];
}

- (void)getContactsList
{
    // mock fake friends
    [self.xmppRoster addUser:[XMPPJID jidWithString:@"bouchaib@kindyinfomaroc.com"] withNickname:@"bouchaib"];
    [self.xmppRoster subscribePresenceToUser:[XMPPJID jidWithString:@"bouchaib@kindyinfomaroc.com"]];
    [self.buddyList.storage addBuddy:[TLBuddy buddyWithDisplayName:@"bouchaib" accountName:@"bouchaib"]];
    
    [self.xmppRoster addUser:[XMPPJID jidWithString:@"boutahri@kindyinfomaroc.com"] withNickname:@"najlae"];
    [self.xmppRoster subscribePresenceToUser:[XMPPJID jidWithString:@"boutahri@kindyinfomaroc.com"]];
    [self.buddyList.storage addBuddy:[TLBuddy buddyWithDisplayName:@"najlae" accountName:@"boutahri"]];
    
    [self.xmppRoster addUser:[XMPPJID jidWithString:@"00212644357131@kindyinfomaroc.com"] withNickname:@"iphone6"];
    [self.xmppRoster subscribePresenceToUser:[XMPPJID jidWithString:@"00212644357131@kindyinfomaroc.com"]];
    [self.buddyList.storage addBuddy:[TLBuddy buddyWithDisplayName:@"iphone6" accountName:@"00212644357131"]];
}

- (void)createOrJoinRoomWidthJid:(TLRoom *)room
{
    XMPPJID *roomJID = [XMPPJID jidWithString:room.accountName];
    
    if (self.xmppRoom && [delegates indexOfObject:self.xmppRoom] != NSNotFound)
    {
        [delegates removeObject:self.xmppRoom];
        
        [self.xmppRoom removeDelegate:self delegateQueue:dispatch_get_main_queue()];
        [self.xmppRoom deactivate];
        self.xmppRoom = nil;
    }
    else if (self.xmppRoom)
    {
        self.xmppRoom = nil;
    }
    
    XMPPRoomMemoryStorage *xmppRoomStorage = [[XMPPRoomMemoryStorage alloc] init];
    self.xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:xmppRoomStorage
                                                      jid:roomJID
                                            dispatchQueue:dispatch_get_main_queue()];
    
    [self.xmppRoom activate:self.xmppStream];
    [self.xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.xmppRoom joinRoomUsingNickname:self.account.displayname history:nil];
    
    [delegates addObject:self.xmppRoom];
}

- (void)freeXmppRoom
{
    for (XMPPRoom *xmppRoom in delegates)
    {
        [xmppRoom removeDelegate:self delegateQueue:dispatch_get_main_queue()];
        [xmppRoom deactivate];
    }
    
    [delegates removeAllObjects];
    delegates = nil;
}

#pragma mark -
#pragma mark <TLProtocolBridge>

- (void)sendMessageBridge:(NSXMLElement *)message
{
    [self.xmppStream sendElement:message];
}

- (bool)connectBridge:(NSError **)error
{
    return [self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:error];
}

#pragma mark -
#pragma mark <XMPPStreamDelegate>

- (void)xmppStreamWillConnect:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTLProtocolDidConnectNotification object:nil];
}

- (void) xmppStreamDidRegister: (XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    [self.xmppStream disconnect];
    [self connectWithPassword:self.account.password];
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    NSError *error = nil;
    
    if (![self.xmppStream authenticateWithPassword:self.password error:&error])
    {
        DDLogError(@"Error authenticating: %@", error);
        self.isXmppConnected = NO;
        return;
    }
    
    self.isXmppConnected = YES;
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    [self autoJoinRooms];
    [self goOnline];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    if (self.xmppStream.supportsInBandRegistration)
    {
        if (![self.xmppStream registerWithPassword:self.password error:nil])
            [self failedToConnect];
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    if ([message isChatMessageWithBody])
    {
        NSString *body = [[message elementForName:@"body"] stringValue];
        NSString *from = [message from].bare;
        
        // i don't know why buddyWithMessage doesn't work !!
        TLBuddy *buddy = nil;//[self buddyWithMessage:message];
        
        if(buddy == nil)
        {
            NSString *phone = [[from componentsSeparatedByString:@"@"] firstObject];
            buddy = [TLBuddy buddyWithDisplayName:phone accountName:from];
            
            if([self.buddyList buddyForAccountName:from] == nil)
                [self.buddyList addBuddy:buddy];
        }
        
        // Parse the message
        TLMessage *incomingMessage = [TLMessage messageWithJid:buddy.accountName message:body];
        incomingMessage.buddy = buddy;
        [buddy receiveMessage:incomingMessage];
        
        [self.storage addMessage:incomingMessage];
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:kTLMessageReceivedNotification
         object:self
         userInfo:@{@"message": incomingMessage}];
        
    }
    
    if([message isGroupChatMessageWithBody])
    {
        if([[[message elementForName:@"sender"] stringValue] isEqualToString:[self.account getUUID]])
            return;
        
        NSString *body = [[message elementForName:@"body"] stringValue];
        
        NSString *roomJid = [[[[message attributeForName:@"from"] stringValue]
                              componentsSeparatedByString:@"/"] firstObject];
        
        NSString *buddyJid = [[[[message attributeForName:@"from"] stringValue]
                               componentsSeparatedByString:@"/"] lastObject];
        
        id<TLRoomStorage> roomsStorage = [TLRoomManager sharedInstance].storage;
        TLRoom *room = [roomsStorage roomForAccountName:roomJid];
        
        TLMessage *incomingMessage = [TLMessage messageWithJid:roomJid message:body];
        incomingMessage.room = room;
        incomingMessage.groupChatMessage = YES;
        incomingMessage.sender = buddyJid;
        [room receiveMessage:incomingMessage];
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:kTLMessageReceivedNotification
         object:self
         userInfo:@{@"message": incomingMessage}];
        
        [self.storage addMessage:incomingMessage];
    }
    
    if ([message isChatMessage])
    {
        BOOL typing = NO;
        
        if([message hasComposingChatState])
        {
            typing = YES;
        }
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:kTLStatusUpdateNotification object:self
         userInfo:@{@"typing" : @(typing), @"sender": [message from].bare}];
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    TLBuddy *buddy = [self.buddyList buddyForAccountName:[[presence from] bare]];
    
    if(buddy == nil)
        return;
    
    buddy.status = [presence status];
    buddy.presence = [presence type];
    [self.buddyList.storage addBuddy:buddy];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kTLStatusUpdateNotification object:self
     userInfo:@{@"presence" : [presence type], @"sender": [presence from].bare}];
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, error.description);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTLProtocolDisconnectNotification object:self];
    
    if (!self.isXmppConnected)
    {
        DDLogError(@"Unable to connect to server. Check xmppStream.hostName");
        [self failedToConnect];
    }
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    NSLog(@"%@", iq);
    
    if([[iq attributeStringValueForName:@"id"] isEqualToString:@"time-of-chat"])
    {
    }
    
    return YES;
}

#pragma mark -
#pragma mark <XMPPReconnectDelegate

- (void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkConnectionFlags)connectionFlags
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

#pragma mark -
#pragma mark <XMPPRoomDelegate>

- (void)xmppRoomDidJoin:(XMPPRoom *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    [sender fetchMembersList];
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchMembersList:(NSArray *)items
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    id<TLRoomStorage> roomsStorage = [TLRoomManager sharedInstance].storage;
    TLRoom *room = [roomsStorage roomForAccountName:sender.roomJID.bare];
    
    NSMutableArray *jids = [NSMutableArray array];
    
    for (NSXMLElement *jid in items)
    {
        // room members
        [jids addObject:[jid attributeStringValueForName:@"jid"]];
    }
    
    room.participants = [jids copy];
    [room saveRoom];
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchModeratorsList:(NSArray *)items
{
    DDLogInfo(@"%@: %@ --- %@", THIS_FILE, THIS_METHOD, sender.roomJID.bare);
}

- (void)xmppRoomDidCreate:(XMPPRoom *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:data"];
    [x addAttributeWithName:@"type" stringValue:@"submit"];
    
    NSXMLElement *root =[NSXMLElement elementWithName:@"field"];
    [root addAttributeWithName:@"type" stringValue:@"hidden"];
    [root addAttributeWithName:@"var"  stringValue:@"FORM_TYPE"];
    [root addChild:[NSXMLElement elementWithName:@"value" stringValue:@"http://jabber.org/protocol/muc#roomconfig"]];
    
    NSXMLElement *loggingfield = [NSXMLElement elementWithName:@"field"];
    [loggingfield addAttributeWithName:@"type" stringValue:@"boolean"];
    [loggingfield addAttributeWithName:@"var" stringValue:@"muc#roomconfig_enable_logging"];
    [loggingfield addAttributeWithName:@"value" stringValue:@"1"];
    
    id<TLRoomStorage> roomsStorage = [TLRoomManager sharedInstance].storage;
    TLRoom *room = [roomsStorage roomForAccountName:sender.roomJID.bare];
    
    NSXMLElement *namefield = [NSXMLElement elementWithName:@"field"];
    [namefield addAttributeWithName:@"type" stringValue:@"text-single"];
    [namefield addAttributeWithName:@"var" stringValue:@"muc#roomconfig_roomname"];
    [namefield addAttributeWithName:@"value" stringValue:room.displayName];
    
    NSXMLElement *subjectField = [NSXMLElement elementWithName:@"field"];
    [subjectField addAttributeWithName:@"type" stringValue:@"boolean"];
    [subjectField addAttributeWithName:@"var" stringValue:@"muc#roomconfig_changesubject"];
    [subjectField addAttributeWithName:@"value" stringValue:@"1"];
    
    NSXMLElement *membersonlyField = [NSXMLElement elementWithName:@"field"];
    [membersonlyField addAttributeWithName:@"type" stringValue:@"boolean"];
    [membersonlyField addAttributeWithName:@"var" stringValue:@"muc#roomconfig_membersonly"];
    [membersonlyField addAttributeWithName:@"value" stringValue:@"1"];
    
    NSXMLElement *moderatedfield = [NSXMLElement elementWithName:@"field"];
    [moderatedfield addAttributeWithName:@"type" stringValue:@"boolean"];
    [moderatedfield addAttributeWithName:@"var" stringValue:@"muc#roomconfig_moderatedroom"];
    [moderatedfield addAttributeWithName:@"value" stringValue:@"0"];
    
    NSXMLElement *persistentroomfield = [NSXMLElement elementWithName:@"field"];
    [persistentroomfield addAttributeWithName:@"type" stringValue:@"boolean"];
    [persistentroomfield addAttributeWithName:@"var" stringValue:@"muc#roomconfig_persistentroom"];
    [persistentroomfield addAttributeWithName:@"value" stringValue:@"1"];
    
    NSXMLElement *publicroomfield = [NSXMLElement elementWithName:@"field"];
    [publicroomfield addAttributeWithName:@"type" stringValue:@"boolean"];
    [publicroomfield addAttributeWithName:@"var" stringValue:@"muc#roomconfig_publicroom"];
    [publicroomfield addAttributeWithName:@"value" stringValue:@"0"];
    
    NSXMLElement *maxusersField = [NSXMLElement elementWithName:@"field"];
    [maxusersField addAttributeWithName:@"type" stringValue:@"text-single"];
    [maxusersField addAttributeWithName:@"var" stringValue:@"muc#roomconfig_maxusers"];
    [maxusersField addAttributeWithName:@"value" stringValue:@"10"];
    
    NSXMLElement *ownerField = [NSXMLElement elementWithName:@"field"];
    [ownerField addAttributeWithName:@"type" stringValue:@"jid-multi"];
    [ownerField addAttributeWithName:@"var" stringValue:@"muc#roomconfig_roomowners"];
    [ownerField addAttributeWithName:@"value" stringValue:[self.account getUUID]];
    
    [root addChild:loggingfield];
    [root addChild:namefield];
    [root addChild:membersonlyField];
    [root addChild:moderatedfield];
    [root addChild:persistentroomfield];
    [root addChild:publicroomfield];
    [root addChild:maxusersField];
    [root addChild:ownerField];
    [root addChild:subjectField];
    [x addChild:root];
    
    [sender configureRoomUsingOptions:x];
}

- (void)xmppRoom:(XMPPRoom *)sender didConfigure:(XMPPIQ *)iqResult
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    id<TLRoomStorage> roomsStorage = [TLRoomManager sharedInstance].storage;
    TLRoom *room = [roomsStorage roomForAccountName:sender.roomJID.bare];
    
    for (NSString *jid in room.participants)
    {
        NSString *_jid = [NSString stringWithFormat:@"%@@%@", jid, kTLBaseURL];
        
        [self.xmppRoom inviteUser:[XMPPJID jidWithString:_jid] withMessage:@"Come join me"];
        [self.xmppRoom editRoomPrivileges:@[[XMPPRoom itemWithAffiliation:@"member" jid:[XMPPJID jidWithString:_jid]]]];
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kTLDidCreateGroupNotification
     object:nil userInfo:@{@"room": room}];
}

- (void)xmppRoomDidLeave:(XMPPRoom *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppRoomDidDestroy:(XMPPRoom *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppMUC:(XMPPMUC *)sender roomJID:(XMPPJID *)roomJID didReceiveInvitation:(XMPPMessage *)message
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    if ([message isGroupChatInvite])
    {
        NSString *name = [NSString stringWithString:[message fromStr]];
        name = [name stringByReplacingOccurrencesOfString:[@"@" stringByAppendingString:kTLConferenceDomain] withString:@""];
        name = [name stringByReplacingOccurrencesOfString:@"_" withString:@" "];
        
        TLRoom *room = [TLRoom roomWithDisplayName:name accountName:[message fromStr]];
        [room saveRoom];
        [self createOrJoinRoomWidthJid:room];
        
        NSXMLElement * x = [message elementForName:@"x" xmlns:XMPPMUCUserNamespace];
        NSString *from = [[[x elementForName:@"invite"] attributeForName:@"from"] stringValue];
        TLBuddy *buddy = [self.buddyList buddyForAccountName:from];
        
        NSString *displayName = (buddy == nil) ? [from stringByReplacingOccurrencesOfString:[@"@" stringByAppendingString:kTLConferenceDomain] withString:@""] : buddy.displayName;
        
        TLMessage *newMessage = [TLMessage messageWithJid:[message fromStr]
                                                  message:[NSString stringWithFormat:@"%@ created \"%@\"", displayName, name]
                                                 received:NO unread:NO];
        
        newMessage.groupChatMessage = YES;
        newMessage.isNote = YES;
        newMessage.sender = from;
        
        [self.storage addMessage:newMessage];
    }
}

- (void)xmppMUC:(XMPPMUC *)sender roomJID:(XMPPJID *)roomJID didReceiveInvitationDecline:(XMPPMessage *)message
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

#pragma mark -
#pragma mark <XMPPRosterMemoryStorageDelegate>

- (void)xmppRosterDidPopulate:(XMPPRosterMemoryStorage *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    if(sender == nil || [sender sortedUsersByName].count <= 0)
        return;
    
    for (XMPPUserMemoryStorageObject *user in [sender sortedUsersByName])
    {
        //populate the vcard for buddy
        XMPPvCardTemp *vCardTemp = [self.xmppvCardTempModule vCardTempForJID:user.jid shouldFetch:YES];
        
        if (vCardTemp != nil)
        {
            [self updateBuddyWithVCard:vCardTemp forJid:[user jid]];
//            call again for update the data
//            [self.xmppvCardTempModule fetchvCardTempForJID:[user jid] ignoreStorage:YES];
        }
    }
}

- (void)xmppRoster:(XMPPRoster*)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    // auto accept user subscription
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    [self.xmppRoster acceptPresenceSubscriptionRequestFrom:[presence from] andAddToRoster:YES];
}

#pragma mark -
#pragma mark <XMPPRosterMemoryStorageDelegate>

- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp forJID:(XMPPJID *)jid
{
    [self updateBuddyWithVCard:vCardTemp forJid:jid];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTLProtocolVcardSuccessSaveNotification object:self];
    [[[TLAccountManager sharedInstance] storage] saveAccount:self.account];
}

#pragma mark -
#pragma mark <XMPPLastActivityDelegate>

- (void)xmppLastActivity:(XMPPLastActivity *)sender didReceiveResponse:(XMPPIQ *)response
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kTLStatusUpdateNotification object:self
     userInfo:@{@"lastseen" : @([response lastActivitySeconds]), @"sender" : response.from.bare}];
}

- (void)xmppLastActivity:(XMPPLastActivity *)sender didNotReceiveResponse:(NSString *)queryID dueToTimeout:(NSTimeInterval)timeout
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kTLStatusUpdateNotification object:self
     userInfo:nil];
}

#pragma mark -
#pragma mark TLXMPPManager

@synthesize account;
@synthesize buddyList;
@synthesize storage;
@synthesize bridge;
@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize xmppRoster;
@synthesize xmppRosterStorage;
@synthesize xmppvCardStorage;
@synthesize xmppvCardTempModule;
@synthesize xmppvCardAvatarModule;
@synthesize isXmppConnected;
@synthesize password;
@synthesize updateMyVcard;
@synthesize turnSockets;
@synthesize sendData;
@synthesize isSending;
@synthesize delegates;

- (id<TLMessageLogStorage>)storage
{
    @synchronized(self)
    {
        if (storage == nil)
        {
            storage = [[TLMessageLogManager sharedInstance] storage];
        }
    }
    return storage;
}

- (id<TLProtocolBridge>)bridge
{
    @synchronized(self)
    {
        if (bridge == nil)
        {
            bridge = self;
        }
    }
    return bridge;
}

- (void)setupStream
{
    NSAssert(self.xmppStream == nil, @"Method setupStream invoked multiple times");
    
    // Setup xmpp stream
    //
    // The XMPPStream is the base class for all activity.
    // Everything else plugs into the xmppStream, such as modules/extensions
    // and delegates.
    self.xmppStream = [[XMPPStream alloc] init];
    
#if !TARGET_IPHONE_SIMULATOR
    // Want xmpp to run in the background?
    //
    // P.S. - The simulator doesn't support backgrounding yet.
    //        When you try to set the associated property on the simulator,
    //        it simply fails.
    //        And when you background an app on the simulator,
    //        it just queues network traffic til the app is foregrounded
    //        again.
    //        We are patiently waiting for a fix from Apple.
    //        If you do enableBackgroundingOnSocket on the simulator,
    //        you will simply see an error message from the xmpp stack when
    //        it fails to set the property.
    self.xmppStream.enableBackgroundingOnSocket = YES;
#endif
    
    // Setup reconnect
    //
    // The XMPPReconnect module monitors for "accidental disconnections" and
    // automatically reconnects the stream for you.
    // There's a bunch more information in the XMPPReconnect header file.
    self.xmppReconnect = [[XMPPReconnect alloc] init];
//    self.xmppReconnect.autoReconnect = YES;
    
    // Setup roster
    //
    // The XMPPRoster handles the xmpp protocol stuff related to the roster.
    // The storage for the roster is abstracted.
    // So you can use any storage mechanism you want.
    // You can store it all in memory, or use core data and store it on disk, or
    // use core data with an in-memory store,
    // or setup your own using raw SQLite, or create your own storage mechanism.
    // You can do it however you like! It's your application.
    // But you do need to provide the roster with some storage facility.
    
    //NSLog(@"Unique Identifier: %@",self.account.uniqueIdentifier);
    
    //xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc]
    //  initWithDatabaseFilename:self.account.uniqueIdentifier];
    //xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    self.xmppRosterStorage = [[XMPPRosterMemoryStorage alloc] init];
    self.xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:self.xmppRosterStorage];
    self.xmppRoster.autoFetchRoster = YES;
    self.xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    
    //ROOM
    self.xmppMuc = [[XMPPMUC alloc] initWithDispatchQueue:dispatch_get_main_queue()];
    
    // Setup vCard support
    //
    // The vCard Avatar module works in conjuction with the standard vCard Temp
    // module to download user avatars.
    // The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to
    // cache roster photos in the roster.
    self.xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    self.xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
    self.xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
    
    // Setup Last-Activity support
    self.xmppLastActivity = [[XMPPLastActivity alloc] initWithDispatchQueue:dispatch_get_main_queue()];
    self.xmppLastActivity.respondsToQueries = YES;
    
    self.xmppMessageDeliveryRecipts = [[XMPPMessageDeliveryReceipts alloc] initWithDispatchQueue:dispatch_get_main_queue()];
    self.xmppMessageDeliveryRecipts.autoSendMessageDeliveryReceipts = YES;
    self.xmppMessageDeliveryRecipts.autoSendMessageDeliveryRequests = YES;
    
    // Activate xmpp modules
    [self.xmppReconnect activate:self.xmppStream];
    [self.xmppRoster activate:self.xmppStream];
    [self.xmppvCardTempModule activate:self.xmppStream];
    [self.xmppvCardAvatarModule activate:self.xmppStream];
    [self.xmppLastActivity activate:self.xmppStream];
    [self.xmppMuc activate:self.xmppStream];
    [self.xmppMessageDeliveryRecipts activate:self.xmppStream];
    
    // Add ourself as a delegate to anything we may be interested in
    [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.xmppvCardTempModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.xmppLastActivity addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.xmppMuc addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
}

- (void)teardownStream
{
    [self.xmppStream removeDelegate:self];
    [self.xmppStream disconnect];
    
    [self.xmppRoster removeDelegate:self];
    [self.xmppRoster deactivate];
    
    [self.xmppvCardTempModule removeDelegate:self];
    [self.xmppvCardTempModule deactivate];
    
    [self.xmppMuc removeDelegate:self];
    [self.xmppMuc deactivate];
    
    [self.xmppLastActivity removeDelegate:self];
    [self.xmppLastActivity deactivate];
    
    [self.xmppReconnect deactivate];
    [self.xmppvCardAvatarModule deactivate];
    [self.xmppMessageDeliveryRecipts deactivate];
}

- (void)connectWithJID:(NSString *)JIDStr password:(NSString *)thePassword
{
    if (![self.xmppStream isDisconnected]) {
        // TODO should raise an exception here or err
        return;
    }
    if (JIDStr == nil || thePassword == nil) {
        // TODO should raise an exception here or err
        DDLogWarn(@"JID and password must be set before connecting!");
        return;
    }
    self.xmppStream.myJID = [XMPPJID jidWithString:JIDStr resource:nil];
    self.password = thePassword;
    
    NSError *error = nil;
    
    if (![self.bridge connectBridge:&error])
    {
        [self failedToConnect];
        DDLogError(@"Error connecting: %@", error);
    }
}

- (void)goOnline
{
    // TODO: for some reason xmppRoster.autoFetchRoster doesn't do anything
    // [self.xmppRoster fetchRoster];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTLProtocolLoginSuccessNotification object:self];
    
    // type="available" is implicit
    XMPPPresence *presence = [XMPPPresence presence];
    NSXMLElement *status = [NSXMLElement elementWithName:@"status" stringValue:[self.account getStatus]];
    [presence addChild:status];
    [self.xmppStream sendElement:presence];
}

- (void)autoJoinRooms
{
    delegates = [[NSMutableArray alloc] init];
    
    id<TLRoomStorage> roomsStorage = [TLRoomManager sharedInstance].storage;
    
    for (TLRoom *room in roomsStorage.rooms)
    {
        XMPPRoomMemoryStorage *xmppRoomStorage = [[XMPPRoomMemoryStorage alloc] init];
        
        XMPPRoom *newXmppRoom = [[XMPPRoom alloc]
                                 initWithRoomStorage:xmppRoomStorage
                                 jid:[XMPPJID jidWithString:room.accountName]
                                 dispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)];
        
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
        
        [newXmppRoom activate: xmppStream];
        [newXmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        // ge room histor since last received message date
        NSXMLElement *history = [NSXMLElement elementWithName:@"history"];
        [history addAttributeWithName:@"since" stringValue:[dateFormatter stringFromDate:[room.lastMessage.date dateByAddingTimeInterval:2]]];
        
        [newXmppRoom joinRoomUsingNickname:self.account.displayname history:history];
        
        [delegates addObject:newXmppRoom];
    }
}

- (void)goOffline
{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [self.xmppStream sendElement:presence];
}

- (void)failedToConnect
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kTLProtocolLoginFailNotification object:self];
}

- (TLBuddy *)buddyWithMessage:(XMPPMessage *)message
{
    XMPPUserMemoryStorageObject *user = [self.xmppRosterStorage userForJID:[message from]];
    return [self.buddyList buddyForAccountName:[user.jid bare]];
}

- (void)applicationWillResignActiveNotification:(NSNotification *)notification
{
    self.buddyList = [[TLBuddyList alloc] init];
}

- (void)updateBuddyWithVCard:(XMPPvCardTemp *)vCardTemp forJid:(XMPPJID *)jid
{
    XMPPJID *myJid = self.xmppStream.myJID;
    
    if ([myJid isEqualToJID:jid options:XMPPJIDCompareUser])
    {
        if (updateMyVcard == YES)
        {
            vCardTemp.nickname = self.account.displayname;
            vCardTemp.photo = self.account.photo;
            updateMyVcard = NO;
            [self.xmppvCardTempModule updateMyvCardTemp:vCardTemp];
        }
    }
    else
    {
        TLBuddy *aBuddy = [self.buddyList buddyForAccountName:jid.bare];
        aBuddy.photo = vCardTemp.photo;
        
        [self.buddyList.storage addBuddy:aBuddy];
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:kTLDidBuddyVCardUpdatedNotification
         object:self];
    }
}

@end
