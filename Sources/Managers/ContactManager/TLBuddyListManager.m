#import "TLBuddyListManager.h"

#import "Storage/TLBuddyListUserDefaultsStorage.h"

static __strong TLBuddyListManager *kSharedInstance = nil;
static __strong id<TLBuddyListStorage> kSharedStorage = nil;

@implementation TLBuddyListManager

#pragma mark -
#pragma mark Singleton methods

+ (TLBuddyListManager *)sharedInstance
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

+ (void)replaceInstance:(TLBuddyListManager *)instance
{
    kSharedInstance = nil;
}

+ (id<TLBuddyListStorage>)storage
{
    @synchronized (self) {
        if (kSharedStorage == nil)
            kSharedStorage = [[TLBuddyListUserDefaultsStorage alloc] init];
    }
    return kSharedStorage;
}

+ (void)setStorage:(id<TLBuddyListStorage>)storage
{
    kSharedStorage = storage;
}

- (id<TLBuddyListStorage>)storage
{
    @synchronized (self) {
        if (storage == nil) {
            storage = [[self class] storage];
        }
    }
    return storage;
}


@end
