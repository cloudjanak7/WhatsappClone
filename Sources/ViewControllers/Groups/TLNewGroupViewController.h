#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "UIImage+Resize.h"

#import "Application/TLConstants.h"

#import "Views/TLPaddedTextField.h"

#import "TLGroupContactsSelector.h"

@interface TLNewGroupViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>

@property (nonatomic, weak) UIImage *photoImage;
@property (nonatomic, weak) IBOutlet UIButton *photoButton;
@property (nonatomic, weak) IBOutlet TLPaddedTextField *groupName;
@property (nonatomic, weak) IBOutlet UILabel *imageLabel;

@end
