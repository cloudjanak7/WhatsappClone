#import "TLTChatViewController.h"

@interface Message : NSObject <SOMessage>
@end

@implementation Message
@synthesize attributes,text,date,fromMe,media,thumbnail,type,sender;

- (id)init
{
    if (self = [super init]) {
    }
    
    return self;
}

@end

@interface TLTChatViewController()

@property (nonatomic, strong) TLTChatController *service;

@property (nonatomic, copy) NSString *accountName;
@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, assign) BOOL *isRoom;
@property (nonatomic, strong) UIImage *myAvatar;
@property (nonatomic, strong) UIImage *buddyAvatar;

@property (strong, nonatomic) NSMutableArray *dataSource;

- (void)basicSetupWithBuddyAccountName:(NSString *)theAccountName displayName:(NSString *)theDisplayName photo:(NSData *)thePhoto;

@end

@implementation TLTChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.service getAvailabilityForAccountName:self.accountName];
}

#pragma mark -
#pragma mark UIView

- (void)viewWillDisappear:(BOOL)animated
{
    [self.service setMessagesAsRead];
    [super viewWillDisappear:animated];
}

#pragma mark -
#pragma mark <SOMessagingViewController>

- (NSMutableArray *)messages
{
    return self.dataSource;
}

- (NSTimeInterval)intervalForMessagesGrouping
{
    return 1 * 24 * 3600;
}

- (void)configureMessageCell:(SOMessageCell *)cell forMessageAtIndex:(NSInteger)index
{
    Message *message = self.dataSource[index];
    
    // Adjusting content for 3pt. (In this demo the width of bubble's tail is 6pt)
    if (!message.fromMe)
    {
        cell.contentInsets = UIEdgeInsetsMake(0, 3.0f, 0, 0); //Move content for 3 pt. to right
        cell.textView.textColor = [UIColor blackColor];
    }
    else
    {
        cell.contentInsets = UIEdgeInsetsMake(0, 0, 0, 3.0f); //Move content for 3 pt. to left
        cell.textView.textColor = [UIColor whiteColor];
    }
    
    cell.panGesture.enabled = NO;
    
    [self generateTimeLabelForCell:cell];
    if(self.isRoom) [self generateUsernameLabelForCell:cell];
}

- (CGFloat)messageMaxWidth
{
    return 140;
}

#pragma mark -
#pragma mark Generate custom labels

- (void)generateTimeLabelForCell:(SOMessageCell *)cell
{
    static NSInteger labelTag = 555;
    
    Message *message = (Message *)cell.message;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:labelTag];
    if (!label) {
        label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:10];
        label.textColor = [UIColor grayColor];
        label.tag = labelTag;
        [cell.containerView addSubview:label];
    }
    label.text = [[formatter stringFromDate:message.date] stringByAppendingString:@""];
    [label sizeToFit];
    CGRect frame = label.frame;
    
    CGFloat topMargin = 5.0f;
    CGFloat leftMargin = 15.0f;
    CGFloat rightMargin = 20.0f;
    
    if (message.fromMe) {
        frame.origin.x = cell.containerView.frame.size.width - frame.size.width - rightMargin;
        frame.origin.y = cell.containerView.frame.origin.y + cell.containerView.frame.size.height + topMargin;
        label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    } else {
        frame.origin.x = cell.containerView.frame.origin.x + leftMargin;
        frame.origin.y = cell.containerView.frame.origin.y + cell.containerView.frame.size.height + topMargin;
        label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    }
    
    label.frame = frame;
}

- (void)generateUsernameLabelForCell:(SOMessageCell *)cell
{
    static NSInteger labelTag = 666;
    
    Message *message = (Message *)cell.message;
    UILabel *label = (UILabel *)[cell.containerView viewWithTag:labelTag];
    if (!label) {
        label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:10];
        label.textColor = [UIColor grayColor];
        label.tag = labelTag;
        [cell.containerView addSubview:label];
    }
    label.text = message.fromMe ? @"Me" : message.sender;
    [label sizeToFit];
    
    CGRect frame = label.frame;
    
    CGFloat topMargin = 15.0f;
    CGFloat leftMargin = 18.0f;
    
    if (message.fromMe)
    {
        frame.origin.x = cell.containerView.frame.size.width - frame.size.width - leftMargin;
        frame.origin.y = cell.containerView.frame.origin.y - topMargin;
        label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    }
    else
    {
        frame.origin.x = cell.containerView.frame.origin.x + leftMargin;
        frame.origin.y = cell.containerView.frame.origin.y - topMargin;
        label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    }
    label.frame = frame;
}

#pragma mark -
#pragma mark SOMessaging delegate

- (void)didSelectMedia:(NSData *)media inMessageCell:(SOMessageCell *)cell
{
    // Show selected media in fullscreen
    [super didSelectMedia:media inMessageCell:cell];
}

- (void)messageInputView:(SOMessageInputView *)inputView didSendMessage:(NSString *)message
{
    if (![[message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]) {
        return;
    }
    
    self.message = [message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self.service sendTextMessage];
}

- (void)messageInputViewDidSelectMediaButton:(SOMessageInputView *)inputView
{
    // Take a photo/video or choose from gallery
}

#pragma mark -
#pragma mark TLTChatViewController

@synthesize service;
@synthesize accountName;
@synthesize displayName;
@synthesize myAvatar;
@synthesize buddyAvatar;

- (instancetype)initWithBuddyAccountName:(NSString *)theAccountName displayName:(NSString *)theDisplayName photo:(NSData *)thePhoto type:(BOOL)isRoom
{
    if ((self = [super init]) != nil)
    {
        [self basicSetupWithBuddyAccountName:theAccountName displayName:theDisplayName photo:thePhoto];
        self.title = [theDisplayName uppercaseString];
        self.isRoom = isRoom;
    }
    return self;
}

- (TLTChatController *)service
{
    if (service == nil)
        service = [[TLTChatController alloc] initWithDelegate:self];
    return service;
}

- (void)basicSetupWithBuddyAccountName:(NSString *)theAccountName displayName:(NSString *)theDisplayName photo:(NSData *)thePhoto
{
    // controller conf
    self.accountName = theAccountName;
    self.displayName = theDisplayName;
    self.title = [theDisplayName uppercaseString];
    
    // Message log conf
    [self.service populateMessagesForBuddyAccountName:theAccountName];
    
    self.dataSource = [NSMutableArray arrayWithCapacity:[self.service messageLogCount]];
    
    for (int i=0; i<[self.service messageLogCount]; i++)
    {
        NSDictionary *msg = [self.service messageAtIndex:i];
        
        Message *obj = [[Message alloc] init];
        obj.type = ([msg[@"type"] boolValue]) ? SOMessageTypeOther : SOMessageTypeText;
        obj.date = msg[@"date"];
        obj.text = msg[@"message"];
        obj.fromMe = ![msg[@"ownership"] boolValue];
        
        if(self.isRoom) obj.sender = msg[@"sender"];
        
        [self.dataSource addObject:obj];
    }
    
    // conf avatars
    self.myAvatar = nil;
    self.buddyAvatar = nil;
    self.buddyAvatar = [[UIImage alloc] initWithData:thePhoto];
    
    NSData *imageData = [self.service getAvatarForAccountName:theAccountName];
    
    if (imageData != nil) {
        self.buddyAvatar = [[UIImage alloc] initWithData:imageData];
    }
    
}

#pragma mark -
#pragma mark <TLMediaInputViewDelegate>

- (void)sendImage:(UIImage *)image
{
    NSData *imageData = UIImagePNGRepresentation(image);
    [self.service sendMediaPhoto:imageData];
}

- (void)sendVideoURL:(NSURL *)videoURL
{
    NSData *videoData = [NSData dataWithContentsOfURL:videoURL];
    [self.service sendMediaVideo:videoData];
}

#pragma mark -
#pragma mark <TLTChatControllerDelegate>

- (NSUInteger)controllerNeedMessageLength:(TLTChatController *)controller
{
    return self.message.length;
}

- (NSString *)controllerNeedMessageText:(TLTChatController *)controller
{
    return self.message;
}

- (NSString *)controllerNeedAccountName:(TLTChatController *)controller
{
    return self.accountName;
}

- (NSString *)controllerNeedDisplayName:(TLTChatController *)controller
{
    return self.displayName;
}

- (BOOL)controllerNeedMessageType:(TLTChatController *)controller
{
    return self.isRoom;
}

- (void)controllerDidSendMessage:(TLTChatController *)controller
{
    Message *msg = [[Message alloc] init];
    msg.text = self.message;
    msg.fromMe = YES;
    msg.date = [NSDate date];
    [self sendMessage:msg];
}

- (void)controllerDidReceivedMessage:(TLTChatController *)controller
{
    NSDictionary *msg = [self.service messageAtIndex:[self.service messageLogCount]-1];
    
    Message *obj = [[Message alloc] init];
    obj.type = ([msg[@"type"] boolValue]) ? SOMessageTypeOther : SOMessageTypeText;
    obj.date = msg[@"date"];
    obj.text = msg[@"message"];
    obj.fromMe = ![msg[@"ownership"] boolValue];
    
    if(self.isRoom) obj.sender = msg[@"sender"];
    
    [self receiveMessage:obj];
}

- (void)controllerDidUpdateAvatar:(TLTChatController *)controller
{
    
}

- (void)controllerDidUpdateStatus:(TLTChatController *)controller userInfo:(NSString *)subtitle
{
    self.subtitle = subtitle;
}

@end
