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
    @synchronized (self) {
        if (!inspectors__) {
            inspectors__ = [NSMutableDictionary new];
        }
        if (!inspectors__[key]) {
            inspectors__[key] = [[self alloc] initWithClass:aClass];
        }
        return inspectors__[key];
    }
}

- (id)initWithClass:(Class)aClass
{
    if (self = [super init]) {
        self.aClass = aClass;
    }
    return self;
}

- (BOOL)object:(id)object1 isEqualToObject:(id)object2 byProperties:(NSArray *)propertyNames
{
    for (NSString *name in propertyNames) {
        id value = [object1 valueForKey:name];
        if (![value isEqual:[object2 valueForKey:name]]){
            return NO;
        }
    }
    return YES;
}

- (id)copyOfObject:(id)object
           ofClass:(Class)clonedClass
              zone:(NSZone *)zone
identityProperties:(NSArray *)propertyNames
propertiesToAssign:(NSArray *)assignPropertyNames
{
    id clone = [[clonedClass allocWithZone:zone] init];
    for (NSString *name in propertyNames) {
        id value = [object valueForKey:name];
        if ([value conformsToProtocol:@protocol(NSMutableCopying)]) {
            [clone setValue:[value mutableCopyWithZone:zone] forKey:name];
        } else {
            [clone setValue:value forKey:name];
        }
    }
    for (NSString *name in assignPropertyNames) {
        [clone setValue:[object valueForKey:name] forKey:name];
    }

    return clone;
}

- (id)mutableCopyOfObject:(id)object
                  ofClass:(Class)clonedClass
                     zone:(NSZone *)zone
       identityProperties:(NSArray *)propertyNames
       propertiesToAssign:(NSArray *)assignPropertyNames
{
    id clone = [[clonedClass allocWithZone:zone] init];
    for (NSString *name in propertyNames) {
        id value = [object valueForKey:name];
        if ([value conformsToProtocol:@protocol(NSMutableCopying)]) {
            [clone setValue:[value mutableCopyWithZone:zone] forKey:name];
        } else {
            [clone setValue:value forKey:name];
        }
    }
    for (NSString *name in assignPropertyNames) {
        [clone setValue:[object valueForKey:name] forKey:name];
    }

    return clone;
}

- (NSString *)descriptionForObject:(id)object
{
    NSMutableString *string = [NSMutableString new];
    [string appendFormat:@"<%@ %p", NSStringFromClass([object class]), object];
    for (JKVProperty *property in self.properties) {
        NSString *name = property.name;
        [string appendFormat:@" %@=%@", name, [object valueForKey:name]];
    }
    [string appendString:@">"];
    return string;
}

#pragma mark - Properties

- (NSArray *)nonWeakProperties
{
    if (!_nonWeakProperties){
        _nonWeakProperties = [self.properties filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isWeak = NO"]];
    }
    return _nonWeakProperties;
}

- (NSArray *)weakProperties
{
    if (!_weakProperties){
        _weakProperties = [self.properties filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isWeak = YES"]];
    }
    return _weakProperties;
}

- (NSArray *)properties
{
    if (!_properties){
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

@end
