#import "XMPPMessage+XEP0045.h"
#import "NSXMLElement+XMPP.h"


@implementation XMPPMessage(XEP0045)

- (BOOL)isGroupChatMessage
{
	return [[[self attributeForName:@"type"] stringValue] isEqualToString:@"groupchat"];
}

- (BOOL)isGroupChatMessageWithBody
{
	if ([self isGroupChatMessage])
	{
		NSString *body = [[self elementForName:@"body"] stringValue];
		
		return ([body length] > 0);
	}
	
	return NO;
}

- (BOOL)isGroupChatMessageWithSubject
{
    if ([self isGroupChatMessage])
	{
        NSString *subject = [[self elementForName:@"subject"] stringValue];

		return ([subject length] > 0);
    }

    return NO;
}

- (BOOL)isGroupChatInvite
{
    NSXMLElement * x = [self elementForName:@"x" xmlns:@"http://jabber.org/protocol/muc#user"];
	NSXMLElement * invite  = [x elementForName:@"invite"];
    NSXMLElement * directInvite = [self elementForName:@"x" xmlns:@"jabber:x:conference"];
	
	if (invite || directInvite)
    {
		return YES;
    }
    else {
        return NO;
    }
    
}

@end
