#import <UIKit/UIKit.h>

#import "Views/TLParallaxView.h"

#import "Categories/UIKit/UIImage+Mask.h"
#import "Categories/UIKit/UIImage+ImageEffects.h"

#import "RETableViewManager.h"

#define kBackgrounColor [UIColor colorWithRed:239/255.0f green:239/255.0f blue:244/255.0f alpha:1.0]
#define kMGOffsetEffects = 20.0
#define kMGOffsetBlurEffect = 2.0

@interface TLSettingsViewController : UIViewController <RETableViewManagerDelegate>
{
    UIImageView *_imageView;
}

@property (strong, readwrite, nonatomic) RETableViewManager *manager;
@property (strong, nonatomic) UITableView *tableView;

@end
