#import "TLRoomManager.h"

#import "Storage/TLRoomUserDefaultsStorage.h"

static __strong TLRoomManager *kSharedInstance = nil;
static __strong id<TLRoomStorage> kSharedStorage = nil;

@implementation TLRoomManager

#pragma mark -
#pragma mark Singleton methods

+ (TLRoomManager *)sharedInstance
{
    @synchronized(self)
    {
        if (kSharedInstance == nil)
            kSharedInstance = [[super allocWithZone:nil] init];
    }
    return kSharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (kSharedInstance == nil)
        {
            kSharedInstance = [super allocWithZone:zone];
            return kSharedInstance;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

#pragma mark -
#pragma mark TLMessageLogManager

@synthesize storage;

+ (void)replaceInstance:(TLRoomManager *)instance
{
    kSharedInstance = nil;
}

+ (id<TLRoomStorage>)storage
{
    @synchronized (self) {
        if (kSharedStorage == nil)
            kSharedStorage = [[TLRoomUserDefaultsStorage alloc] init];
    }
    return kSharedStorage;
}

+ (void)setStorage:(id<TLRoomStorage>)storage
{
    kSharedStorage = storage;
}

- (id<TLRoomStorage>)storage
{
    @synchronized (self) {
        if (storage == nil) {
            storage = [[self class] storage];
        }
    }
    return storage;
}


@end
