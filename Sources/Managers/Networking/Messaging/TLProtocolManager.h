#import <Foundation/Foundation.h>

#import "Services/Models/TLAccount.h"
#import "Services/Models/TLBuddyList.h"
#import "Services/Models/TLMessage.h"
#import "Services/Models/TLRoom.h"

#import "Managers/MessageLog/TLMessageLogManager.h"

@protocol TLProtocolBridge <NSObject>

// Framework bridges
- (bool)connectBridge:(NSError **)error;
- (void)sendMessageBridge:(id)payload;
@end

@protocol TLProtocol <NSObject>
@required

@property (atomic, strong) TLAccount *account;
@property (atomic, strong) TLBuddyList *buddyList;
@property (atomic, strong) id<TLMessageLogStorage> storage;

// allow self-assigning using weak reference
@property (atomic, weak) id<TLProtocolBridge> bridge;

- (void)sendLastActivityQuery:(NSString *)jid;
- (void)sendMessage:(TLMessage *)message;
- (void)sendComposingMessage:(TLMessage *)theMessage;
- (void)sendActiveMessage:(TLMessage *)theMessage;
- (void)sendViaMedia:(TLMessage *)message;
- (BOOL)isConnected;
- (void)connectWithPassword:(NSString *)password;
- (void)disconnect;
- (void)updateAccountDataWithTLAccount;
- (void)getContactsList;
- (void)createOrJoinRoomWidthJid:(TLRoom *)room;
- (void)freeXmppRoom;
- (void)sendTimeOfChatQuery:(NSString *)jid;
- (void)sendHistoryQueryFor:(NSString *)roomJid startingFrom:(NSString *)date;

@end

@interface TLProtocolManager: NSObject

// TODO: for now it only uses one protocol, but should be a dictionary later
@property (atomic, readonly) id<TLProtocol> protocol;

+ (TLProtocolManager *)sharedInstance;
+ (void)replaceInstance:(TLProtocolManager *)instance;
@end
