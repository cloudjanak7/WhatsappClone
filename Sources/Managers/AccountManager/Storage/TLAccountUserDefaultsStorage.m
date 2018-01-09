#import "TLAccountUserDefaultsStorage.h"

static NSString *const kStorageKey = @"TLAccountSingletonStorage";
static NSString *const kPhoneKey = @"phone";
static NSString *const kPasswordKey = @"password";
static NSString *const kDisplayNameKey = @"pseudo";
static NSString *const kPhotoKey = @"photo";
static NSString *const kStatusKey = @"status";

@interface TLAccountUserDefaultsStorage()

- (TLAccount *)loadFromStorage;
- (void)saveToStorage:(TLAccount *)account;
@end

@implementation TLAccountUserDefaultsStorage

#pragma mark -
#pragma mark <TLAccountStorage>

- (TLAccount *)getAccount
{
    return [self loadFromStorage];
}

- (void)saveAccount:(TLAccount *)account
{
    return [self saveToStorage:account];
}

- (void)clearStorage
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kStorageKey];
}

#pragma mark -
#pragma mark TLAccountUserDefaultsStorage

- (TLAccount *)loadFromStorage
{
    NSDictionary *storedAccount =
        [[NSUserDefaults standardUserDefaults] dictionaryForKey:kStorageKey];

    if (storedAccount == nil)
        return nil;

    NSString *phone = storedAccount[kPhoneKey];
    NSString *password = storedAccount[kPasswordKey];
    NSString *displayName = storedAccount[kDisplayNameKey];
    NSData *photo = storedAccount[kPhotoKey];
    NSString *status = storedAccount[kStatusKey];

    TLAccount *account = [TLAccount sharedInstance];

    account.phone = phone;
    account.password = password;
    account.displayname = displayName;
    account.photo = photo;
    account.status = status;

    return account;
}

- (void)saveToStorage:(TLAccount *)account
{
    NSMutableDictionary *entry = [NSMutableDictionary dictionary];
    [entry setValue:account.phone forKey:kPhoneKey];
    
    if (account.password != nil) {
        [entry setValue:account.password forKey:kPasswordKey];
    }
    if (account.displayname != nil) {
        [entry setValue:account.displayname forKey:kDisplayNameKey];
    }
    if (account.photo != nil) {
        [entry setValue:account.photo forKey:kPhotoKey];
    }
    if(account.status != nil) {
        [entry setValue:account.status forKey:kStatusKey];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:entry forKey:kStorageKey];
}
@end
