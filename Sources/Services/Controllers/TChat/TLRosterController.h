#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "TLBaseController.h"
#import "Managers/Networking/Messaging/TLProtocolManager.h"

@protocol TLRosterControllerDelegate;

@interface TLRosterController: TLBaseController

- (id)initWithDelegate:(id<TLRosterControllerDelegate>)theDelegate;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (NSString *)buddyAccountNameForIndex:(NSIndexPath *)index;
- (NSString *)buddyDisplayNameForIndex:(NSIndexPath *)index;
- (TLBuddy *)buddyForIndex:(NSIndexPath *)index;
- (NSData *)buddyDisplayPhotoForIndex:(NSIndexPath *)index;
- (NSString *)buddyStatusForIndex:(NSIndexPath *)index;
- (NSArray *)allBuddies;

@end

@protocol TLRosterControllerDelegate <TLBaseControllerDelegate>

- (void)controllerDidPopulateRoster:(TLRosterController *)controller;

@end
