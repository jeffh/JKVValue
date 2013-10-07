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

    NSArray *propertiesForIdentity = [self.JKV_cachedPropertiesForIdentity valueForKey:@"name"];
    NSArray *propertiesToAssign = [self.JKV_cachedPropertiesToAssignCopy valueForKey:@"name"];
    id cloned = [[[self JKV_immutableClass] allocWithZone:zone] init];
    return [self.JKV_inspector copyToObject:cloned
                                 fromObject:self
                                     inZone:zone
                              propertyNames:propertiesForIdentity
                          weakPropertyNames:propertiesToAssign];
}


#pragma - <NSMutableCopying>

- (id)mutableCopyWithZone:(NSZone *)zone
{
    NSArray *propertiesForIdentity = [self.JKV_cachedPropertiesForIdentity valueForKey:@"name"];
    NSArray *propertiesToAssign = [self.JKV_cachedPropertiesToAssignCopy valueForKey:@"name"];
    id cloned = [[[self JKV_mutableClass] allocWithZone:zone] init];
    return [self.JKV_inspector copyToObject:cloned
                                 fromObject:self
                                     inZone:zone
                              propertyNames:propertiesForIdentity
                          weakPropertyNames:propertiesToAssign];
}

#pragma - <NSObject>

- (NSString *)description
{
    return [self debugDescription];
}

- (NSString *)debugDescription
{
    return [self.JKV_inspector descriptionForObject:self
                                     withProperties:self.JKV_inspector.properties];
}

- (BOOL)isEqual:(id)object
{
    NSArray *propertyNames = [self.JKV_cachedPropertiesForIdentity valueForKey:@"name"];
    return [self.JKV_inspector isObject:self
                          equalToObject:object
                        byPropertyNames:propertyNames];

}

- (NSUInteger)hash
{
    NSArray *propertyNames = [self.JKV_cachedPropertiesForIdentity valueForKey:@"name"];
    return [self.JKV_inspector hashObject:self byPropertyNames:propertyNames];
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

- (NSArray *)JKV_propertyNamesForIdentity
{
    return [self.JKV_inspector.nonWeakProperties valueForKey:@"name"];
}

- (NSArray *)JKV_propertyNamesToAssignCopy
{
    return [self.JKV_inspector.weakProperties valueForKey:@"name"];
}

#pragma mark - Private

- (NSArray *)JKV_cachedPropertiesForIdentity
{
    if (!_JKV_propertiesForIdentity){
        NSSet *whitelist = [NSSet setWithArray:[self JKV_propertyNamesForIdentity]];
        _JKV_propertiesForIdentity = [self.JKV_inspector.properties filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name in %@", whitelist]];
    }
    return _JKV_propertiesForIdentity;
}

- (NSArray *)JKV_cachedPropertiesToAssignCopy
{
    if (!_JKV_propertiesToAssignCopy){
        NSSet *whitelist = [NSSet setWithArray:[self JKV_propertyNamesToAssignCopy]];
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
