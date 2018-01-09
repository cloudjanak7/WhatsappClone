#import <Foundation/Foundation.h>

#import "Managers/MessageLog/TLMessageLogManager.h"
#import "Managers/RoomManager/TLRoomManager.h"

#import "TLBaseController.h"

@protocol TLTChatHistoryControllerDelegate;

@interface TLTChatHistoryController: TLBaseController

@property (nonatomic, weak) id<TLMessageLogStorage> storage;

- (id)initWithDelegate:(id<TLTChatHistoryControllerDelegate>)theDelegate;
- (void)populateBuddies;
- (NSInteger)buddiesCount;
- (NSDictionary *)buddyAtIndex:(NSInteger)index;
- (void)receivedNewMessageNotification:(NSNotification *)notification;

@end

@protocol TLTChatHistoryControllerDelegate <TLBaseControllerDelegate>

- (void)updateData;
- (void)startConnectionActivity;
- (void)stopConnectionActivity;
- (void)enableNewGroupButton;
- (void)disableNewGroupButton;

@end
