#import <Foundation/Foundation.h>

@class TLMessage;
@protocol TLMessageLogStorage;

@interface TLRoom : NSObject

@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, copy) NSString *accountName;
@property (nonatomic, copy) NSData *photo;
@property (nonatomic, copy) NSArray *participants;
@property (nonatomic, weak) TLMessage *lastMessage;
@property (nonatomic, weak) id<TLMessageLogStorage> storage;

+ (TLRoom *)roomWithDisplayName:(NSString *)roomName accountName:(NSString *)roomJid;
- (id)initWithDisplayName:(NSString *)roomName accountName:(NSString *)roomJid;
- (NSInteger)unreadMessages;
- (void)receiveMessage:(TLMessage *)message;
- (void)saveRoom;

@end
