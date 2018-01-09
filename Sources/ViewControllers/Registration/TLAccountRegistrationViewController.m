#import "TLAccountRegistrationViewController.h"

@interface TLAccountRegistrationViewController ()

@property (nonatomic, strong) TLAccountDataController *service;

// setup methods
- (void)basicSetup;
- (void)backgroundSetup;
- (void)createAccountButtonSetup;
- (void)toggleNavigationBar;
- (void)createAccountAction;
@end

@implementation TLAccountRegistrationViewController

#pragma mark -
#pragma mark UIViewController

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
    if ((self = [super initWithNibName:nibName bundle:bundle]) != nil)
        [self basicSetup];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder]) != nil)
        [self basicSetup];
    return self;
}

- (void)viewDidLoad
{
    [self backgroundSetup];
    [self createAccountButtonSetup];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self toggleNavigationBar];
}

- (BOOL)shouldAutorotate
{
    // Disable autorotation
    return NO;
}

#pragma mark -
#pragma mark TLAccountRegistrationViewController

- (TLAccountDataController *)service
{
    if (_service == nil)
        _service = [[TLAccountDataController alloc] initWithDelegate:self];
    
    return _service;
}

- (void)basicSetup
{
    self.wantsFullScreenLayout = YES;
}

- (void)backgroundSetup
{
    NSString *imageNamed = kTLAccountRegistrationViewBackgroundImage;
    UIImage *background = [UIImage imageNamed568h:imageNamed];
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:background];

    [backgroundView sizeToFit];
    [self.view insertSubview:backgroundView atIndex:0];
}

- (void)createAccountButtonSetup
{
    NSString *imageNamed = kTLAccountRegistrationViewButtonImage;
    UIImage *buttonImage = [UIImage imageNamed:imageNamed];
    
    [self.accountButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.accountButton addTarget:self action:@selector(createAccountAction) forControlEvents:UIControlEventTouchUpInside];
    [self.accountButton sizeToFit];
}

- (void)toggleNavigationBar
{
    BOOL hidden = !self.navigationController.navigationBarHidden;
    [self.navigationController setNavigationBarHidden:hidden animated:YES];
}

#pragma mark -
#pragma mark Actions

- (IBAction)createAccountAction
{
    // mock current user
    TLAccount *account = [TLAccount sharedInstance];
    account.username = @"00212644357132";
    account.password = @"kindy";
    
    [self.service updateAccountWithDisplayName:@"abdel" photo:[NSData new]];
}

#pragma mark -
#pragma mark Actions

- (void)didAcountSavedSuccessFullyNotification
{
    [self dismissViewControllerAnimated:(BOOL)YES completion:NULL];
    TLAppDelegate *delegate = (TLAppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate didCompleteRegistrationProcess];
}

@end
