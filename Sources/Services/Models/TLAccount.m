#import "Application/TLConstants.h"
#import "TLAccount.h"

static __strong TLAccount *kSharedInstance = nil;
static NSUInteger const kPhoneNumberLengthMin = 11;
static NSUInteger const kPhoneNumberLengthMax = 13;

@implementation TLAccount

#pragma mark -
#pragma mark Singleton methods

+ (TLAccount *)sharedInstance
{
    if (kSharedInstance == nil)
        kSharedInstance = [[super allocWithZone:nil] init];
    return kSharedInstance;
}

+ (void)replaceInstance:(TLAccount *)instance
{
    kSharedInstance = instance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    if (kSharedInstance == nil)
    {
        kSharedInstance = [super allocWithZone:zone];
        return kSharedInstance;
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

#pragma mark -
#pragma mark TLAccount

@synthesize phone, password;

+ (BOOL)verifyPhoneNumber:(NSString *)phone
{
    if (phone.length >= kPhoneNumberLengthMin && phone.length <= kPhoneNumberLengthMax)
    {
        return YES;
    }
    return NO;
}

- (NSString *)username
{
    return self.phone;
}

- (void)setUsername:(NSString *)username
{
    self.phone = username;
}

- (NSString *)getUUID
{
    return [self.username stringByAppendingFormat:@"@%@", kTLHostDomain];
}

- (NSString *)getStatus
{
    return (self.status == nil) ? @"online" : self.status;
}

@end
