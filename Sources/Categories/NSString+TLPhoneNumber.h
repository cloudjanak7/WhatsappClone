#import <Foundation/Foundation.h>

@interface NSString (TLPhoneNumber)

- (NSString *)stringApplyingFormat:(NSString *)format;
- (NSString *)stringRemovingFormat:(NSString *)format;
- (NSString *)stringCleaningPhoneNumber;

@end
