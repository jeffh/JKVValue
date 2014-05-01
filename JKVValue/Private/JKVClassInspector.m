#import "JKVClassInspector.h"
#import "JKVProperty.h"
#import <objc/runtime.h>


@interface JKVClassInspector ()

@property (strong, nonatomic) Class aClass;
@property (strong, nonatomic, readwrite) NSArray *properties;
@property (strong, nonatomic, readwrite) NSArray *weakProperties;
@property (strong, nonatomic, readwrite) NSArray *nonWeakProperties;

@end


@implementation JKVClassInspector

static NSMutableDictionary *inspectors__;

+ (instancetype)inspectorForClass:(Class)aClass
{
    NSString *key = NSStringFromClass(aClass);
    __block JKVClassInspector *inspector = nil;
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (!inspectors__) {
            inspectors__ = [NSMutableDictionary new];
        }
        if (!inspectors__[key]) {
            inspectors__[key] = [[self alloc] initWithClass:aClass];
        }
        inspector = inspectors__[key];
    });
    return inspector;
}

- (id)initWithClass:(Class)aClass
{
    if (self = [super init]) {
        self.aClass = aClass;
    }
    return self;
}

- (NSUInteger)hashObject:(id)object byPropertyNames:(NSArray *)propertyNames
{
    // http://stackoverflow.com/questions/254281/best-practices-for-overriding-isequal-and-hash
    NSUInteger prime = 31;
    NSUInteger result = 1;
    for (NSString *propertyName in propertyNames){
        result = prime * result + [[object valueForKey:propertyName] hash];
    }
    return result;
}

- (BOOL)isObject:(id)object1 equalToObject:(id)object2 withPropertyNames:(NSArray *)propertyNames
{
    if (object1 == object2) {
        return YES;
    }

    Class class1 = [object1 class];
    Class class2 = [object2 class];

    if (![class1 isSubclassOfClass:class2] && ![class2 isSubclassOfClass:class1]) {
        return NO;
    }

    return [self isObject:object1 equalToObject:object2 byPropertyNames:propertyNames];
}

- (BOOL)isObject:(id)object1 equalToObject:(id)object2 byPropertyNames:(NSArray *)propertyNames
{
    for (NSString *name in propertyNames) {
        id value = [object1 valueForKey:name];
        id otherValue = [object2 valueForKey:name];
        if (value != otherValue && ![value isEqual:otherValue]){
            return NO;
        }
    }
    return YES;
}

- (id)copyToObject:(id)targetObject
        fromObject:(id)object
            inZone:(NSZone *)zone
     propertyNames:(NSArray *)identityPropertyNames
 weakPropertyNames:(NSArray *)assignPropertyNames
{
    for (NSString *name in identityPropertyNames) {
        id value = [object valueForKey:name];
        if ([value isKindOfClass:[NSArray class]]) {
            value = [[NSMutableArray alloc] initWithArray:value copyItems:YES];
        } else if ([value isKindOfClass:[NSDictionary class]]) {
            value = [[NSMutableDictionary alloc] initWithDictionary:value copyItems:YES];
        } else if ([value conformsToProtocol:@protocol(NSMutableCopying)]) {
            value = [value mutableCopyWithZone:zone];
        }
        [targetObject setValue:value forKey:name];
    }
    for (NSString *name in assignPropertyNames) {
        [targetObject setValue:[object valueForKey:name] forKey:name];
    }

    return targetObject;
}

#pragma mark - Properties

- (NSArray *)nonWeakProperties
{
    if (!_nonWeakProperties) {
        _nonWeakProperties = [self.allProperties filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isWeak = NO"]];
    }
    return _nonWeakProperties;
}

- (NSArray *)weakProperties
{
    if (!_weakProperties) {
        _weakProperties = [self.allProperties filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isWeak = YES"]];
    }
    return _weakProperties;
}

- (NSArray *)properties
{
    if (!_properties) {
        NSMutableArray *properties = [NSMutableArray new];
        unsigned int numProperties = 0;
        objc_property_t *objc_properties = class_copyPropertyList(self.aClass, &numProperties);
        for (NSUInteger i=0; i<numProperties; i++) {
            objc_property_t objc_property = objc_properties[i];

            unsigned int numAttributes = 0;
            objc_property_attribute_t *objc_attributes = property_copyAttributeList(objc_property, &numAttributes);
            NSMutableDictionary *attributesDict = [NSMutableDictionary new];
            for (NSUInteger j=0; j<numAttributes; j++) {
                objc_property_attribute_t attribute = objc_attributes[j];
                NSString *key = [NSString stringWithCString:attribute.name encoding:NSUTF8StringEncoding];
                NSString *value = [NSString stringWithCString:attribute.value encoding:NSUTF8StringEncoding];
                attributesDict[key] = value;
            }
            free(objc_attributes);

            NSString *propertyName = [NSString stringWithUTF8String:property_getName(objc_property)];

            [properties addObject:[[JKVProperty alloc] initWithName:propertyName
                                                         attributes:attributesDict]];
        }
        free(objc_properties);
        _properties = properties;
    }
    return _properties;
}

- (NSArray *)allProperties
{
    NSArray *classProperties = self.properties;
    NSSet *classPropertyNames = [NSSet setWithArray:[classProperties valueForKey:@"name"]];
    NSMutableArray *properties = [NSMutableArray new];
    Class parentClass = class_getSuperclass(self.aClass);
    if (parentClass && parentClass != [NSObject class]) {
        for (JKVProperty *property in [[JKVClassInspector inspectorForClass:parentClass] allProperties]) {
            if (![classPropertyNames containsObject:property.name]) {
                [properties addObject:property];
            }
        }
    }
    [properties addObjectsFromArray:classProperties];
    return properties;
}

@end
