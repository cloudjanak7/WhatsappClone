#import <Foundation/Foundation.h>

#import "Services/Models/TLBuddy.h"

#import "Managers/ContactManager/TLBuddyListManager.h"

@protocol TLContactStorage;

@interface TLBuddyList: NSObject

@property (nonatomic, strong) NSMutableArray *allBuddies;
@property (nonatomic, weak) id<TLBuddyListStorage> storage;

- (void)addBuddy:(TLBuddy *)buddy;
- (TLBuddy *)buddyForAccountName:(NSString *)accountName;
- (NSArray *)allPBuddies;

@end
