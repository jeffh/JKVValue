#import <Foundation/Foundation.h>

@interface JKVValue : NSObject <NSCoding, NSMutableCopying, NSCopying>

- (BOOL)JKV_isMutable;
- (Class)JKV_immutableClass;
- (Class)JKV_mutableClass;
- (NSSet *)JKV_propertyNamesForIdentity;
- (NSSet *)JKV_propertyNamesToAssignCopy;

@end
