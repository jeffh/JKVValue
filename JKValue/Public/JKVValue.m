#import "JKVValue.h"
#import "JKVProperty.h"
#import "JKVDecoderVisitor.h"
#import "JKVEncoderVisitor.h"
#import "JKVClassInspector.h"

@interface JKVValue () {
    NSArray *_JKV_propertiesForIdentity;
    NSArray *_JKV_propertiesToAssignCopy;
    JKVClassInspector *_JKV_inspector;
}

- (NSArray *)JKV_cachedPropertiesForIdentity;
- (NSArray *)JKV_cachedPropertiesToAssignCopy;
- (JKVClassInspector *)JKV_inspector;
@end


@implementation JKVValue

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    if (self) {
        JKVDecoderVisitor *visitor = [[JKVDecoderVisitor alloc] initWithCoder:aDecoder forObject:self];
        for (JKVProperty *property in self.JKV_cachedPropertiesForIdentity) {
            [property visitEncodingType:visitor];
        }
    }
    return self;
}

#pragma mark - <NSCoding>

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    JKVEncoderVisitor *visitor = [[JKVEncoderVisitor alloc] initWithCoder:aCoder forObject:self];
    for (JKVProperty *property in self.JKV_cachedPropertiesForIdentity) {
        [property visitEncodingType:visitor];
    }
}

#pragma - <NSCopying>

- (id)copyWithZone:(NSZone *)zone
{
    if (![self JKV_isMutable]) {
        return self;
    }

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


#pragma - <NSMutableCopying>

- (id)mutableCopyWithZone:(NSZone *)zone
{
    id clone = [[[self JKV_mutableClass] allocWithZone:zone] init];
    for (NSString *name in [self.JKV_cachedPropertiesForIdentity valueForKey:@"name"]) {
        id value = [self valueForKey:name];
        if ([value conformsToProtocol:@protocol(NSMutableCopying)]) {
            [clone setValue:[value mutableCopyWithZone:zone] forKey:name];
        } else {
            [clone setValue:value forKey:name];
        }
    }
    for (NSString *name in [self.JKV_cachedPropertiesToAssignCopy valueForKey:@"name"]) {
        [clone setValue:[self valueForKey:name] forKey:name];
    }

    return clone;
}

#pragma - <NSObject>

- (NSString *)description
{
    NSMutableString *string = [NSMutableString new];
    [string appendFormat:@"<%@ %p", NSStringFromClass([self class]), self];
    for (JKVProperty *property in self.JKV_inspector.properties) {
        NSString *name = property.name;
        [string appendFormat:@" %@=%@", name, [self valueForKey:name]];
    }
    [string appendString:@">"];
    return string;
}

- (BOOL)isEqual:(id)object
{
    for (NSString *name in [self.JKV_cachedPropertiesForIdentity valueForKey:@"name"]) {
        id value = [self valueForKey:name];
        if (![value isEqual:[object valueForKey:name]]){
            return NO;
        }
    }
    return YES;
}

- (NSUInteger)hash
{
    NSUInteger code = 0x77777777;
    for (NSString *name in [self.JKV_cachedPropertiesForIdentity valueForKey:@"name"]) {
        code ^= [[self valueForKey:name] hash];
    }
    return code;
}

#pragma mark - Public / Protected

- (BOOL)JKV_isMutable
{
    return NO;
}

- (Class)JKV_mutableClass
{
    return [self class];
}

- (Class)JKV_immutableClass
{
    return [self class];
}

- (NSSet *)JKV_propertyNamesForIdentity
{
    return [NSSet setWithArray:[self.JKV_inspector.nonWeakProperties valueForKey:@"name"]];
}

- (NSSet *)JKV_propertyNamesToAssignCopy
{
    return [NSSet setWithArray:[self.JKV_inspector.weakProperties valueForKey:@"name"]];
}

#pragma mark - Private

- (NSArray *)JKV_cachedPropertiesForIdentity
{
    if (!_JKV_propertiesForIdentity){
        NSSet *whitelist = [self JKV_propertyNamesForIdentity];
        _JKV_propertiesForIdentity = [self.JKV_inspector.properties filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name in %@", whitelist]];
    }
    return _JKV_propertiesForIdentity;
}

- (NSArray *)JKV_cachedPropertiesToAssignCopy
{
    if (!_JKV_propertiesToAssignCopy){
        NSSet *whitelist = [self JKV_propertyNamesToAssignCopy];
        _JKV_propertiesToAssignCopy = [self.JKV_inspector.properties filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name in %@", whitelist]];
    }
    return _JKV_propertiesToAssignCopy;
}

- (JKVClassInspector *)JKV_inspector
{
    if (!_JKV_inspector) {
        _JKV_inspector = [JKVClassInspector inspectorForClass:[self class]];
    }
    return _JKV_inspector;
}

@end
