#import <Foundation/Foundation.h>

#import "Services/Models/TLMessage.h"
#import "Services/Models/TLBuddy.h"

@protocol TLMessageLogStorage <NSObject>

- (NSArray *)messages;
- (NSArray *)messagesForJid:(NSString *)theId;
- (NSArray *)messagesForJid:(NSString *)theId sortDescriptors:(NSArray *)sortDescriptors;
- (NSArray *)messagesWithSortDescriptors:(NSArray *)sortDescriptors;
- (NSInteger)countUnreadMessages:(NSString *)jid;
- (NSArray *)chatsByMessagesWithSortDescriptors:(NSArray *)sortDescriptors;
- (void)setUnreadMessagesAsRead:(NSString *)theId;
- (void)addMessage:(TLMessage *)message;
- (void)reloadStorage;
- (void)setFixture:(NSArray *)fixture;

@end

@interface TLMessageLogManager: NSObject

@property (nonatomic, readonly) id<TLMessageLogStorage> storage;

+ (TLMessageLogManager *)sharedInstance;

@end
