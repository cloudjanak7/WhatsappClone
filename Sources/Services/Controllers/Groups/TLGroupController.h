#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "TLBaseController.h"
#import "Application/TLConstants.h"

#import "Managers/Networking/Messaging/TLProtocolManager.h"

#import "Services/Models/TLRoom.h"

@protocol TLGroupControllerDelegate;

@interface TLGroupController: TLBaseController

- (id)initWithDelegate:(id<TLGroupControllerDelegate>)theDelegate;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (TLBuddy *)buddyForIndex:(NSIndexPath *)index;
- (void)addParticipant:(TLBuddy *)buddy;
- (BOOL)isaParticipant:(TLBuddy *)buddy;
- (NSArray *)allBuddies;
- (void)createRoom:(NSString *)roomName WithPicture:(UIImage *)roomPicture;

@end

@protocol TLGroupControllerDelegate <TLBaseControllerDelegate>

- (void)controllerDidCreateGroup:(TLRoom *)group;

@end
