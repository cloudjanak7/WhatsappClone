#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "Application/TLConstants.h"

#import "Categories/UIKit/UIImage+TL568h.h"

#import "UIImage+BlurredFrame.h"

#import "Services/Controllers/Registration/TLAccountDataController.h"

#import "Application/TLAppDelegate.h"

@interface TLAccountRegistrationViewController: UIViewController<TLAccountDataControllerDelegate>

@property (nonatomic, weak) IBOutlet UIButton *accountButton;

@end
