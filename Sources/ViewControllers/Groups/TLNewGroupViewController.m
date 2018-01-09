#import "TLNewGroupViewController.h"

@interface TLNewGroupViewController ()

//@property (nonatomic, strong) TLAccountDataController *service;
@property (nonatomic, assign) BOOL isPhotoGiven;

//setup methods
- (void)setImageLabel;
- (void)setPhotoButton;
- (void)setGroupNameField;

//actions
- (void)pickPhotoAction;

@end

@implementation TLNewGroupViewController

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setImageLabel];
    [self setPhotoButton];
    [self setGroupNameField];
    [self createNavigationBarButton];
    
    self.title = @"New Group";
}

#pragma mark -
#pragma mark Actions

- (void)createNavigationBarButton
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@"Cancel"
                                             style:UIBarButtonItemStylePlain
                                             target:self
                                             action:@selector(dismissViewController)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"Next"
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(createGroupViewController)];
}

- (void)dismissViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)createGroupViewController
{
    [self.navigationController pushViewController:[[TLGroupContactsSelector alloc] initWithGroupName:self.groupName.text photo:self.photoImage]
                                         animated:YES];
}

#pragma mark -
#pragma mark TLNewGroupViewController

@synthesize photoImage;
@synthesize photoButton;
@synthesize groupName;
@synthesize isPhotoGiven;

- (void)setImageLabel
{
    self.imageLabel.font = [UIFont systemFontOfSize:14];;
    self.imageLabel.textColor = [UIColor grayColor];
    self.imageLabel.backgroundColor = [UIColor clearColor];
    self.imageLabel.textAlignment = NSTextAlignmentLeft;
}

- (void)setPhotoButton
{
    [self.photoButton setTitle:@"add photo" forState:UIControlStateNormal];
    [self.photoButton addTarget:self action:@selector(pickPhotoAction) forControlEvents:UIControlEventTouchUpInside];
    [self.photoButton.layer setBorderColor:TL_BORDER_COLOR.CGColor];
    [self.photoButton.layer setBorderWidth:1.0];
    [self.photoButton.layer setCornerRadius:30.];
    [self.photoButton.titleLabel setLineBreakMode:UILineBreakModeWordWrap];
    [self.photoButton.titleLabel setNumberOfLines:0];
    [self.photoButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [self.photoButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.photoButton setClipsToBounds:YES];
}

- (void)setGroupNameField
{
    self.groupName.textColor = [UIColor blackColor];
    self.groupName.clearsOnBeginEditing = NO;
    self.groupName.font = [UIFont systemFontOfSize:TL_FORM_TEXT_FIELD_FONT_SIZE];
    self.groupName.returnKeyType = UIReturnKeyDone;
    self.groupName.placeholder = @"Group Subject";
    self.groupName.delegate = self;
    self.groupName.borderWidthsAll = 1.0f;
    self.groupName.borderColorTop = TL_BORDER_COLOR;
    self.groupName.borderColorBottom = TL_BORDER_COLOR;
    self.groupName.backgroundColor = TL_TEXT_FIELD_TINT;
    self.groupName.returnKeyType = UIReturnKeyDefault;
    
    [self.groupName becomeFirstResponder];
}

#pragma mark -
#pragma mark Actions

- (void)pickPhotoAction
{
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES)
    {
        pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        pickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    } else
        pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    pickerController.delegate = self;
    pickerController.allowsEditing = YES;
    [self presentModalViewController:pickerController animated:YES];
}


#pragma mark -
#pragma mark <UITextFieldDelegate>

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (![string isEqualToString:@"\n"])
    {
        NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        NSUInteger maximumLength = TL_FORM_TEXT_FIELD_MAX_SIZE;
        
        if ([text length] <= maximumLength)
            textField.text = [text capitalizedString];
        
        return NO;
    }
    
    return YES;
}


#pragma mark -
#pragma mark <UIImagePickerControllerDelegate>

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *preImage = info[UIImagePickerControllerEditedImage];
    CGSize newSIze = CGSizeMake(100, 100);
    self.photoImage = [preImage resizedImage:newSIze interpolationQuality:1];
    [self.photoButton setImage:self.photoImage forState:UIControlStateNormal];
    [self dismissModalViewControllerAnimated:YES];
    self.isPhotoGiven = YES;
}

@end
