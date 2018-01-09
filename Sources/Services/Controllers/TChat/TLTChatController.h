#import <Foundation/Foundation.h>

#import "TLBaseController.h"

#import "NSDate+Utilities.h"

@protocol TLTChatControllerDelegate;

@interface TLTChatController: TLBaseController

@property (nonatomic, strong) NSMutableArray *messageLog;

- (id)initWithDelegate:(id<TLTChatControllerDelegate>)theDelegate;
- (void)populateMessagesForBuddyAccountName:(NSString *)accountName;
- (NSData *)getAvatarForAccountName:(NSString *)accountName;
- (NSInteger)messageLogCount;
- (NSDictionary *)messageAtIndex:(NSInteger)index;
- (void)setMessagesAsRead;
- (void)sendMediaPhoto:(NSData *)imageData;
- (void)sendMediaVideo:(NSData *)videoData;
- (BOOL)getAvailabilityForAccountName:(NSString *)accountName;

// Actions
- (void)sendTextMessage;
@end

@protocol TLTChatControllerDelegate <TLBaseControllerDelegate>

@required
- (NSUInteger)controllerNeedMessageLength:(TLTChatController *)controller;
- (NSString *)controllerNeedMessageText:(TLTChatController *)controller;
- (NSString *)controllerNeedAccountName:(TLTChatController *)controller;
- (NSString *)controllerNeedDisplayName:(TLTChatController *)controller;
- (BOOL)controllerNeedMessageType:(TLTChatController *)controller;

- (void)controllerDidSendMessage:(TLTChatController *)controller;
- (void)controllerDidReceivedMessage:(TLTChatController *)controller;
- (void)controllerDidUpdateAvatar:(TLTChatController *)controller;
- (void)controllerDidUpdateStatus:(TLTChatController *)controller userInfo:(NSString *)subtitle;

@end
