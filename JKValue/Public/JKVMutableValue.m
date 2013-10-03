#import "JKVMutableValue.h"
#import "JKVProperty.h"
#import "JKVClassInspector.h"

@interface JKVValue (Protected)
- (NSArray *)JKV_cachedPropertiesForIdentity;
- (NSArray *)JKV_cachedPropertiesToAssignCopy;
@end

@implementation JKVMutableValue

#pragma - <NSCopying>

- (id)copyWithZone:(NSZone *)zone
{
    id clone = [[[self JKV_immutableClass] allocWithZone:zone] init];
    for (JKVProperty *property in self.JKV_cachedPropertiesForIdentity) {
        NSString *name = property.name;
        id value = [self valueForKey:name];
        if ([value conformsToProtocol:@protocol(NSMutableCopying)]) {
            [clone setValue:[value mutableCopyWithZone:zone] forKey:name];
        } else {
            [clone setValue:value forKey:name];
        }
    }
    for (JKVProperty *property in self.JKV_cachedPropertiesToAssignCopy) {
        NSString *name = property.name;
        [clone setValue:[self valueForKey:name] forKey:name];
    }

    return clone;
}

#pragma mark - Public / Protected

- (Class)JKV_immutableClass
{
    return [self class];
}

@end
