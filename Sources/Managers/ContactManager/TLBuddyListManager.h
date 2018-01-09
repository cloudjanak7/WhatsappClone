#import <Foundation/Foundation.h>

#import "Services/Models/TLBuddy.h"

@protocol TLBuddyListStorage <NSObject>

- (NSArray *)buddies;
- (NSArray *)pBuddies;
- (TLBuddy *)buddyForAccountName:(NSString *)accountName;
- (void)addBuddy:(TLBuddy *)buddy;
- (void)saveToStorage;

@end

@interface TLBuddyListManager: NSObject

@property (nonatomic, readonly) id<TLBuddyListStorage> storage;

+ (TLBuddyListManager *)sharedInstance;
+ (void)replaceInstance:(TLBuddyListManager *)instance;
+ (id<TLBuddyListStorage>)storage;
+ (void)setStorage:(id<TLBuddyListStorage>)storage;

@end
