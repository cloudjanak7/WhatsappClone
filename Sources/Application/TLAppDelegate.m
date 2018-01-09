#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "TLAppDelegate.h"
#import "TLConstants.h"
#import "ZGNavigationBarTitleViewController.h"

#import "ViewControllers/TChat/TLRosterViewController.h"
#import "ViewControllers/TChat/TLTChatHistoryViewController.h"
#import "ViewControllers/TChat/TLTChatHistoryViewController.h"
#import "ViewControllers/Settings/TLSettingsViewController.h"

#import "Services/Controllers/Application/TLApplicationController.h"
#import "Services/Models/TLAccount.h"

#import "Views/TLTabController.h"

#define CURRENT_SYS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

@interface TLAppDelegate ()

@property (nonatomic, strong) TLApplicationController *service;
@end

@implementation TLAppDelegate

#pragma mark -
#pragma mark <UIApplicationDelegate>

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:
        [[UIScreen mainScreen] bounds]];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    if ([self.service shouldPresentRegistrationForm])
    {
        self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"TLAccountRegistrationViewController"];
    }
    else
    {
        [self didCompleteRegistrationProcess];
    }
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self.service connect];
}

- (void)applicationWillResignActive:(UIApplication *)application 
{
    [self.service disconnect];
}

#pragma mark -
#pragma mark TLAppDelegate

@synthesize service;

- (TLApplicationController *)service
{
    if (service == nil)
        service = [[TLApplicationController alloc] init];
    return service;
}

- (BOOL)didCompleteRegistrationProcess
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    ZGNavigationBarTitleViewController *messageController =
    [storyboard instantiateViewControllerWithIdentifier:@"TLTChatHistoryNavController"];
    ZGNavigationBarTitleViewController *rosterController =
    [storyboard instantiateViewControllerWithIdentifier:@"TLRosterNavController"];
    ZGNavigationBarTitleViewController *settingsController =
    [storyboard instantiateViewControllerWithIdentifier:@"TLSettingsNavController"];
    
    TLTabController *rootTabBarController = [[TLTabController alloc] init];
    rootTabBarController.viewControllers = @[messageController, rosterController, settingsController];
    rootTabBarController.tabBar.translucent = false;
    
    UITabBarItem *chats = [rootTabBarController.tabBar.items objectAtIndex:0];
    [chats setTitle:@"Chats"];
    [chats setFinishedSelectedImage:[[UIImage imageNamed:@"ChatsOn"] imageWithColor:TL_DEFAULT_COLOR]
        withFinishedUnselectedImage:[[UIImage imageNamed:@"ChatsOff"] imageWithColor:[UIColor grayColor]]];
    
    UITabBarItem *contacts = [rootTabBarController.tabBar.items objectAtIndex:1];
    [contacts setTitle:@"Contacts"];
    [contacts setFinishedSelectedImage:[[UIImage imageNamed:@"ContactsOn"] imageWithColor:TL_DEFAULT_COLOR]
           withFinishedUnselectedImage:[[UIImage imageNamed:@"ContactsOff"] imageWithColor:[UIColor grayColor]]];
    
    UITabBarItem *settings = [rootTabBarController.tabBar.items objectAtIndex:2];
    [settings setTitle:@"Settings"];
    [settings setFinishedSelectedImage:[[UIImage imageNamed:@"SettingsOn"] imageWithColor:TL_DEFAULT_COLOR]
           withFinishedUnselectedImage:[[UIImage imageNamed:@"SettingsOff"] imageWithColor:[UIColor grayColor]]];
    
    self.window.rootViewController = rootTabBarController;
    
    return YES;
}



@end
