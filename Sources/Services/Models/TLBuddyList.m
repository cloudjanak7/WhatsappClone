#import "TLBuddyList.h"

@implementation TLBuddyList

@synthesize storage;

#pragma mark -
#pragma mark NSObject

- (id)init
{
    if ((self = [super init]) != nil)
    {
        self.allBuddies = [[NSMutableArray alloc] initWithArray:[self.storage buddies]];
    }
    return self;
}

- (id<TLBuddyListStorage>)storage;
{
    if (storage == nil)
    {
        storage = [[TLBuddyListManager sharedInstance] storage];
    }
    return storage;
}

#pragma mark -
#pragma mark TLBuddyList

@synthesize allBuddies;

- (void)addBuddy:(TLBuddy *)buddy
{
    if([self buddyForAccountName:buddy.accountName] == nil)
    {
        [self.allBuddies addObject:buddy];
    }
}

- (TLBuddy *)buddyForAccountName:(NSString *)accountName
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountName == %@", accountName];
    NSArray *matchingBuddies = [self.allBuddies filteredArrayUsingPredicate:predicate];
    
    return [matchingBuddies lastObject];
}

- (NSArray *)allPBuddies
{
    return [self.storage pBuddies];
}

@end
