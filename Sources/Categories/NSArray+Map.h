#import <Foundation/Foundation.h>

@interface NSArray (Map)

- (NSArray *) map:(id(^)(id obj))block;
- (void) apply:(void(^)(id obj))block;

@end
