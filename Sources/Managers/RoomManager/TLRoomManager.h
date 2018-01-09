#import <Foundation/Foundation.h>

#import "Services/Models/TLRoom.h"

@protocol TLRoomStorage <NSObject>

- (NSArray *)rooms;
- (void)addRoom:(TLRoom *)room;
- (TLRoom *)roomForAccountName:(NSString *)accountName;

@end

@interface TLRoomManager: NSObject

@property (nonatomic, readonly) id<TLRoomStorage> storage;

+ (TLRoomManager *)sharedInstance;
+ (void)replaceInstance:(TLRoomManager *)instance;
+ (id<TLRoomStorage>)storage;
+ (void)setStorage:(id<TLRoomStorage>)storage;

@end
