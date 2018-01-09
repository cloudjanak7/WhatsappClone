#import <Foundation/Foundation.h>

#import "Application/TLConstants.h"

#import "TLMediaData.h"
#import "TLBuddy.h"
#import "TLRoom.h"

@protocol TLProtocol;

@interface TLMessage: NSObject

@property (nonatomic, strong) TLBuddy *buddy;
@property (nonatomic, strong) TLRoom *room;
@property (nonatomic, strong) TLMediaData *mediaData;

@property (nonatomic, copy) NSString *jid;
@property (nonatomic, copy) NSString *sender;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSDate *date;

@property (nonatomic, assign) BOOL received;
@property (nonatomic, assign) BOOL unread;
@property (nonatomic, assign) BOOL groupChatMessage;
@property (nonatomic, assign) BOOL isNote;

+ (TLMessage *)messageWithJid:(NSString *)id message:(NSString *)message;
+ (TLMessage *)messageWithJid:(NSString *)id message:(NSString *)message received:(BOOL)received;
+ (TLMessage *)messageWithJid:(NSString *)id message:(NSString *)message received:(BOOL)received unread:(BOOL)unread;
+ (TLMessage *)messageWithJid:(NSString *)id mediaData:(TLMediaData *)mediaData received:(BOOL)received unread:(BOOL)unread;

- (id)initWithMessageJid:(NSString *)id message:(NSString *)message;
- (id)initWithMessageJid:(NSString *)id message:(NSString *)message received:(BOOL)received unread:(BOOL)unread;

- (void)send;
- (void)sendComposingState;
- (void)sendActiveState;

//just for tests
- (id)initWithProtocol:(id<TLProtocol>)protocol;

@end
