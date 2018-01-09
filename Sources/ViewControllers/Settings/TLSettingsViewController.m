#import "TLSettingsViewController.h"

@implementation TLSettingsViewController

@synthesize tableView, manager;

#pragma mark -
#pragma mark View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initSettingsController];
    [self.navigationController.navigationBar setHidden:YES];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)initSettingsController
{
    CGRect rect = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 200);
    tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStyleGrouped];
    
    manager = [[RETableViewManager alloc] initWithTableView:tableView delegate:self];
    [self setupTableView];
    
    TLParallaxView *parallaxView =
    [[TLParallaxView alloc] initWithBackgroundView:[self overView] foregroundView:tableView];
    parallaxView.frame = self.view.frame;
    parallaxView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    parallaxView.backgroundHeight = 200.0f;
    parallaxView.scrollView.scrollsToTop = YES;
    parallaxView.backgroundInteractionEnabled = YES;
    parallaxView.scrollViewDelegate = self;
    [self.view addSubview:parallaxView];
}

#pragma mark -
#pragma mark Overview

- (UIView *)overView
{
    CGRect rect = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 200);
    UIView *backgroundView = [[UIView alloc] initWithFrame:rect];
    [backgroundView setUserInteractionEnabled:NO];
    [backgroundView setBackgroundColor:kBackgrounColor];
    
    __block UIImage *image = [UIImage imageNamed:@"profil.jpg"];
    
    rect.size.height -= 20;
    _imageView = [[UIImageView alloc] initWithFrame:rect];
    [_imageView setContentMode:UIViewContentModeScaleAspectFill];
    [_imageView setImage:image];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        UIImage *blurred = [image applyBlurWithRadius:20 tintColor:nil saturationDeltaFactor:1 maskImage:nil];
        image = [UIImage maskImage:blurred withMask:[UIImage imageNamed:@"mask.png"]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_imageView setImage:image];
        });
    });

    UIView *userView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 140)];
    userView.center = backgroundView.center;
    
    UIImageView *userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100.0, 100.0)];
    [userImageView setContentMode:UIViewContentModeScaleAspectFill];
    [userImageView setClipsToBounds:YES];
    [userImageView setImage:[UIImage imageNamed:@"profil.jpg"]];
    [userImageView.layer setBorderColor:[UIColor colorWithWhite:1.0 alpha:.4].CGColor];
    [userImageView.layer setBorderWidth:4.0];
    [userImageView.layer setCornerRadius:50];
    
    UILabel *userName = [[UILabel alloc] initWithFrame:CGRectMake(0, 105, 100, 35)];
    [userName setText:@"Abdel Ali"];
    [userName setFont:[UIFont systemFontOfSize:24.0]];
    [userName setTextAlignment:NSTextAlignmentCenter];
    [userName setTextColor:[UIColor whiteColor]];
    
    [userView addSubview:userImageView];
    [userView addSubview:userName];
    
    [backgroundView addSubview:_imageView];
    [backgroundView addSubview:userView];
    
    return backgroundView;
}

#pragma mark -
#pragma mark RETableView

- (void)setupTableView
{
    RETableViewSection *section = [RETableViewSection sectionWithHeaderTitle:@"" footerTitle:@""];
    [self.manager addSection:section];
    
    [section addItem:[RETableViewItem itemWithTitle:@"About"
                                      accessoryType:UITableViewCellAccessoryDisclosureIndicator
                                   selectionHandler:^(RETableViewItem *item)
                      {
                          [item deselectRowAnimated:YES];
                      }]];
    
    [section addItem:[RETableViewItem itemWithTitle:@"Tell a Friend"
                                      accessoryType:UITableViewCellAccessoryDisclosureIndicator
                                   selectionHandler:^(RETableViewItem *item)
                      {
                          [item deselectRowAnimated:YES];
                      }]];
}

@end
