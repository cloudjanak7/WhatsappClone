#import "Application/TLConstants.h"

#import "Managers/Networking/Messaging/TLProtocolManager.h"

#import "TLMessage.h"

@interface TLMessage()

@property (nonatomic, strong) id<TLProtocol> messageProtocol;

- (id)initWithMessageJid:(NSString *)theConvId
                      message:(NSString *)theMessage
                    mediaData:(TLMediaData *)theMediaData
                     received:(BOOL)beenReceived unread:(BOOL)beenUnread;

@end

@implementation TLMessage

#pragma mark -
#pragma mark TLMessage

@synthesize message, mediaData, buddy, room, date, messageProtocol, jid, sender;

- (NSString *)message
{
    if (message == nil) {
         message = @"";
    }
    return message;
}

- (id<TLProtocol>)messageProtocol
{
    if (messageProtocol == nil) {
        messageProtocol = [[TLProtocolManager sharedInstance] protocol];
    }
    return messageProtocol;
}

+ (TLMessage *)messageWithJid:(NSString *)thId message:(NSString *)message
{
    return [[self alloc] initWithMessageJid:thId message:message];
}

+ (TLMessage *)messageWithJid:(NSString *)thId message:(NSString *)message received:(BOOL)received
{
    return [[self alloc] initWithMessageJid:thId message:message received:received unread:YES];
}

+ (TLMessage *)messageWithJid:(NSString *)thId message:(NSString *)message received:(BOOL)received unread:(BOOL)unread
{
    return [[self alloc] initWithMessageJid:thId message:message received:received unread:unread];
}

+ (TLMessage *)messageWithJid:(NSString *)thId mediaData:(TLMediaData *)mediaData received:(BOOL)received unread:(BOOL)unread
{
    return [[self alloc] initWithMessageJid:thId message:nil mediaData:mediaData received:received unread:unread];
}

- (id)initWithMessageJid:(NSString *)thId message:(NSString *)theMessage
{
    return (self = [self initWithMessageJid:thId message:theMessage received:YES unread:YES]);
}

- (id)initWithMessageJid:(NSString *)thId message:(NSString *)theMessage received:(BOOL)beenReceived unread:(BOOL)beenUnread
{
    if ((self = [super init]) != nil) {
        self.jid = thId;
        self.message = theMessage;
        self.received = beenReceived;
        self.unread = beenUnread;
        self.date = [NSDate date];
    }
    return self;
}

- (void)send
{
    if (self.mediaData != nil)
    {
        [self.messageProtocol sendViaMedia:self];
        return;
    }
    
    if(self.groupChatMessage)
        self.sender = [[self.messageProtocol account] getUUID];
    
    [self.messageProtocol sendMessage:self];
}

- (void)sendComposingState
{
    [self.messageProtocol sendComposingMessage:self];
}

- (void)sendActiveState
{
    [self.messageProtocol sendActiveMessage:self];
}

#pragma mark -
#pragma mark TLMessage(private)

- (id)initWithMessageJid:(NSString *)thId
                      message:(NSString *)theMessage
                    mediaData:(TLMediaData *)theMediaData
                     received:(BOOL)beenReceived unread:(BOOL)beenUnread
{
    if ((self = [super init]) != nil)
    {
        self.jid = thId;
        self.message = theMessage;
        self.received = beenReceived;
        self.unread = beenUnread;
        self.mediaData = theMediaData;
        self.date = [NSDate date];
    }
    return self;
}

#pragma mark -
#pragma mark Test

- (id)initWithProtocol:(id<TLProtocol>)protocol
{
    if ((self = [super init]) != nil)
    {
        self.messageProtocol = protocol;
    }
    return self;
}
@end
