#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "Managers/Networking/Messaging/TLProtocolManager.h"
#import "../TLBaseController.h"

@protocol TLAccountDataControllerDelegate <TLBaseControllerDelegate>

- (void)didAcountSavedSuccessFullyNotification;

@end

@interface TLAccountDataController: TLBaseController

+ (id)accountDataControllerWithProtocol:(id<TLProtocol>)protocol;
- (void)updateAccountWithDisplayName:(NSString *)username photo:(NSData *)photo;

@end
