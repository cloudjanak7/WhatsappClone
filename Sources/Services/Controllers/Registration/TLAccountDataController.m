#import "Services/Models/TLAccount.h"
#import "TLAccountDataController.h"

@interface TLAccountDataController ()

@property (nonatomic, weak) id<TLAccountDataControllerDelegate> delegate;
@property (nonatomic, strong) id<TLProtocol> protocol;

- (void)sendUpdateData;

@end

@implementation TLAccountDataController

#pragma mark -
#pragma mark NSObject

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTLProtocolLoginSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTLProtocolVcardSuccessSaveNotification object:nil];
}

#pragma mark -
#pragma mark TLBaseController

@synthesize delegate;

- (id)initWithDelegate:(id<TLBaseControllerDelegate>)theDelegate
{
    if ((self = [super initWithDelegate:theDelegate]) != nil)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sendUpdateData)
                                                     name:kTLProtocolLoginSuccessNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didSuccessfullSaveNotification)
                                                     name:kTLProtocolVcardSuccessSaveNotification object:nil];
    }
    return self;
}

#pragma mark -
#pragma mark TLAccountDataController

@synthesize protocol;

- (id<TLProtocol>)protocol
{
    if (protocol == nil)
    {
        protocol = [[TLProtocolManager sharedInstance] protocol];
    }
    return protocol;
}

+ (id)accountDataControllerWithProtocol:(id<TLProtocol>)protocol
{
    TLAccountDataController *accountDataController = [[TLAccountDataController alloc] initWithDelegate:nil];
    accountDataController.protocol = protocol;
    
    return accountDataController;
}

- (void)updateAccountWithDisplayName:(NSString *)username photo:(NSData *)photo
{
    TLAccount *account = [TLAccount sharedInstance];
    account.displayname = username;
    account.photo = photo;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self.protocol connectWithPassword:account.password];
    });
}

- (void)sendUpdateData
{
    [self.protocol updateAccountDataWithTLAccount];
}

- (void)didSuccessfullSaveNotification
{
    [self.delegate didAcountSavedSuccessFullyNotification];
}

@end
