/**
 * XMPP backend conf
 */
#define kTLHostDomain @"openfire.kindyinfomaroc.com"
#define kTLBaseURL @"kindyinfomaroc.com"
#define kTLConferenceDomain @"conference.kindyinfomaroc.com"
#define kTLHostPort 9090

#define TL_DEFAULT_PARAMETER_METHOD @"POST"
#define TL_PUT_PARAMETER_METHOD @"PUT"
#define TL_BACKEND_HOST_NAME @"ns29646.ovh.net"
#define TL_BACKEND_BASE_URL @"http://" TL_BACKEND_HOST_NAME @"/babble_ws/"
#define TL_BACKEND_POST_PHONE_NUMBER @"ws.php?action=store_generate&JID=%@"
#define TL_BACKEND_POST_VERIFICATION_CODE @"ws.php?action=activate_account&ID=%@&activationCode=%@"
#define TL_BACKEND_POST_CONTACTS @"ws.php"

/**h
 * Endpoint-construction helper
 */
#define ENDPOINT(url) TL_BACKEND_BASE_URL url
#define ENDPOINT_FROM_STRING(url) [TL_BACKEND_BASE_URL stringByAppendingString:url]
#define URL(...) [NSURL URLWithString:[NSString stringWithFormat:__VA_ARGS__]]
#define URL_WITHOUT_PARAMETERS(...) [NSURL URLWithString:__VA_ARGS__]

/**
 * User defaults preferences
 */
#define kTLUsernamePreference @"username_preference"
#define kTLPasswordPreference @"password_preference"

/**
 * Themes and colors
 */
#define TL_TEXT_FIELD_TINT [UIColor whiteColor]
#define TL_DEFAULT_COLOR [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]
#define TL_BORDER_COLOR [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1]
#define TL_FORM_TEXT_FIELD_MAX_SIZE 25
#define TL_FORM_TEXT_FIELD_FONT_SIZE 20

/**
 * Notifications
 */
#define kTLSendMessageNotification @"TLSendMessageNotification"
#define kTLMessageProcessedNotification @"TLMessageProcessedNotification"
#define kTLProtocolLogoutNotification @"TLProtocolLogoutNotification"
#define kTLProtocolLoginFailNotification @"TLProtocolLoginFailNotification"
#define kTLProtocolLoginSuccessNotification @"TLProtocolLoginSuccessNotification"
#define kTLMessageReceivedNotification @"TLMessageReceivedNotification"
#define kTLNewMessageNotification @"TLNewMessageNotification"
#define kTLStatusUpdateNotification @"TLStatusUpdateNotification"
#define kTLProtocolDisconnectNotification @"TLProtocolDisconnectNotification"
#define kTLProtocolDidConnectNotification @"TLProtocolDidConnectNotification"
#define kTLRosterDidPopulateNotification @"TLRosterDidPopulateNotification"
#define kTLProtocolVcardSuccessSaveNotification @"TLProtocolVcardSuccessSaveNotification"
#define kTLDidBuddyVCardUpdatedNotification @"TLDidBuddyVCardUpdatedNotification"
#define kTLDidCreateGroupNotification @"TLDidCreateGroupNotification"

/**
 * Account RegistrationViewController
 */
#define kTLAccountRegistrationViewBackgroundImage @"create_account_bg"
#define kTLAccountRegistrationViewButtonImage @"create_account_button"

/**
 * PhoneFormViewController
 */
#define kTLPhoneFormViewControllerAreaCodeContentInset UIEdgeInsetsMake(0., 7., 0., 7.)
#define kTLPhoneFormViewControllerPhoneContentInset UIEdgeInsetsMake(0., 8., 0., 15.)
#define kTLPhoneFormViewControllerPhoneLength 9
#define kTLPhoneFormViewControllerAreaCodeLength 3
#define kTLPhoneFormViewControllerPhoneFormat @"### ## ## ##"
#define kTLPhoneFormViewControllerAreaCodePlaceholder @"+212"
#define kTLPhoneFormViewControllerPhonePlaceholder @"your phone number"
#define kTLPhoneFormViewControllerInvalidAlertTitle @""
#define kTLPhoneFormViewControllerInvalidAlertMessage @"Seems you entered a wrong number"
#define kTLPhoneControllerRequesFailureKey @"errorMsg"
#define kTLPhoneFormViewControllerConnectionErrorMessage @"Service unavailable, check your internet connection and try again in a few minutes"

/**
 * ConfirmCodeViewController
 */
#define kTLConfirmCodeViewControllerCodeLength 4

/**
 * AccountDataViewController
 */
#define kTLProfileAccountLabelText @"Enter your name and add an optional profile picture"
#define kTLProfileAccountLabelFontSize 14
#define kTLProfileAccountLabelColor [UIColor grayColor]
#define kTLAccountDataFormViewControllerFirstNamePlaceholder @"Your name"
