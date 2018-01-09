#import "TLBuddyListUserDefaultsStorage.h"

#import "Application/TLConstants.h"

#import "Services/Models/TLBuddyList.h"

#import "Categories/NSString+TLPhoneNumber.h"

static NSString *const kBuddyListKey = @"TLBuddyListStorage";
static NSString *const kJIDKey = @"jid";
static NSString *const kDisplayNameKey = @"displayName";
static NSString *const kPhotoKey = @"photo";
static NSString *const kLastMessageKey = @"message";
static NSString *const kPresenceKey = @"presence";

@interface TLBuddyListUserDefaultsStorage()

@property (nonatomic, strong) NSMutableArray *storageContacts;
@property (nonatomic, strong) NSMutableArray *storagePhoneBook;

- (TLBuddy *)buddyForAccountName:(NSString *)accountName;
- (void)loadFromPhoneBook;
- (void)loadFromStorage;
- (void)saveToStorage;

@end

@implementation TLBuddyListUserDefaultsStorage

@synthesize storagePhoneBook, storageContacts;

#pragma mark -
#pragma mark TLContactUserDefaultsStorage

- (id)init
{
    if ((self = [super init]) != nil) {
    }
    return self;
}

- (NSMutableArray *)storagePhoneBook
{
    if (storagePhoneBook == nil) {
        storagePhoneBook = [[NSMutableArray alloc] init];
        [self loadFromPhoneBook];
    }
    
    return storagePhoneBook;
}

- (NSMutableArray *)storageContacts
{
    if (storageContacts == nil) {
        storageContacts = [[NSMutableArray alloc] init];
        [self loadFromStorage];
    }
    
    return storageContacts;
}

- (BOOL)addressBookGetAuthorizationStatus
{
    __block BOOL userDidGrantAddressBookAccess = '\0';
    
    CFErrorRef addressBookError = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if ( ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined ||
        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized )
    {
        addressBook = ABAddressBookCreateWithOptions(NULL, &addressBookError);
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error){
            userDidGrantAddressBookAccess = granted;
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    else
    {
        if ( ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
            ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted )
        {
        }
    }
    
    return userDidGrantAddressBookAccess;
}

- (void)loadFromPhoneBook
{
    if([self addressBookGetAuthorizationStatus])
    {
        ABAddressBookRef addressbook = ABAddressBookCreateWithOptions(NULL, NULL);
        ABRecordRef source = ABAddressBookCopyDefaultSource(addressbook);
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressbook, source, kABPersonSortByFirstName);
        CFIndex nPeople = ABAddressBookGetPersonCount(addressbook);
        
        for (int i = 0; i < nPeople; i++)
        {
            ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
            
            NSString *displayName = @"";
            NSString *firstName = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
            NSString *lastName = (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
            
            if(firstName != nil) {
                displayName = [displayName stringByAppendingFormat:@"%@", firstName];
            }
            if(displayName.length > 0) {
                displayName = [displayName stringByAppendingString:@" "];
            }
            if(lastName != nil) {
                displayName = [displayName stringByAppendingFormat:@"%@", lastName];
            }
            
            ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
            
            for(CFIndex i=0; i < ABMultiValueGetCount(phoneNumbers); i++) {
                
                CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(phoneNumbers, i);
                NSString *jid = (__bridge NSString *)phoneNumberRef;
                
                jid = [jid stringCleaningPhoneNumber];
                jid = [jid stringByAppendingFormat:@"@%@", kTLHostDomain];
                
                if([self buddyForAccountName:jid] == nil)
                {
                    TLBuddy *person = [TLBuddy buddyWithDisplayName:displayName accountName:jid];
                    [self.storagePhoneBook addObject:person];
                }
            }
        }
    }
}

- (TLBuddy *)buddyForAccountName:(NSString *)accountName
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountName == %@", accountName];
    NSArray *matchingBuddies = [self.storageContacts filteredArrayUsingPredicate:predicate];
    
    return [matchingBuddies lastObject];
}

- (void)loadFromStorage
{
    for (NSDictionary *person in [[NSUserDefaults standardUserDefaults] arrayForKey:kBuddyListKey])
    {
        NSString *jid = [person objectForKey:kJIDKey];
        NSString *displayName = [person objectForKey:kDisplayNameKey];
        NSString *presence = [person objectForKey:kPresenceKey];
        NSData *photo = [person objectForKey:kPhotoKey];
        
        TLBuddy *buddy = [TLBuddy buddyWithDisplayName:displayName accountName:jid];
        buddy.presence = presence;
        
        if (photo != nil) {
            buddy.photo = photo;
        }
        
        [self.storageContacts addObject:buddy];
    }
}

- (void)saveToStorage
{
    NSMutableArray *contactsToStore = [NSMutableArray array];
    
    for (TLBuddy *contact in self.storageContacts) {
        
        NSMutableDictionary *entry = [NSMutableDictionary
                                      dictionaryWithDictionary:@{
                                                                 kJIDKey: contact.accountName,
                                                                 kDisplayNameKey: contact.displayName,
                                                                 kPresenceKey: [contact getPresence]
                                                                 }];
        
        if (contact.photo != nil)
        {
            [entry setObject:contact.photo forKey:kPhotoKey];
        }
        
        [contactsToStore addObject:entry];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:contactsToStore forKey:kBuddyListKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTLRosterDidPopulateNotification object:self];
}

#pragma mark -
#pragma mark <TLContactstorage>

- (NSArray *)buddies
{
    return self.storageContacts;
}

- (NSArray *)pBuddies
{
    return self.storagePhoneBook;
}

- (void)addBuddy:(TLBuddy *)contact
{
    if(contact == nil)
        return;
    
    TLBuddy *buddy = [self buddyForAccountName:contact.accountName];
    
    if(buddy != nil)
        [self.storageContacts removeObject:buddy];
    
    [self.storageContacts addObject:contact];
    [self saveToStorage];
}

@end
