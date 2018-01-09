#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

#import "Services/Controllers/TChat/TLTChatController.h"
#import "Services/Models/TLMediaData.h"
#import "Application/TLConstants.h"

#import "SOMessagingViewController.h"
#import "SOMessage.h"

#import "UIImage+animatedGIF.h"

#import "ZGNavigationBarTitleViewController.h"

@interface TLTChatViewController: SOMessagingViewController<TLTChatControllerDelegate>

- (id)initWithBuddyAccountName:(NSString *)theAccountName
                   displayName:(NSString *)theDisplayName
                         photo:(NSData *)thePhoto
                          type:(BOOL)isRoom;

@end
