#import <Foundation/Foundation.h>

#import "XMPPFramework.h"

#import "GBVersionTracking.h"
#import "../TLProtocolManager.h"

@interface TLXMPPManager: NSObject <TLProtocol, TLProtocolBridge, XMPPStreamDelegate, XMPPRosterMemoryStorageDelegate, XMPPMUCDelegate, XMPPRoomDelegate>
{
    
}

@end
