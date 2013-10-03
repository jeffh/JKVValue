#import <Foundation/Foundation.h>

@interface JKVValue : NSObject <NSCoding, NSMutableCopying, NSCopying>

- (Class)JKV_mutableClass;
- (NSSet *)JKV_propertyNamesForIdentity;
- (NSSet *)JKV_propertyNamesToAssignCopy;

@end
