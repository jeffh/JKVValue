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
    if (object1 == object2){
        return YES;
    }

    Class class1 = [object1 class];
    Class class2 = [object2 class];

    if (![class1 isSubclassOfClass:class2] && ![class2 isSubclassOfClass:class1]){
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
        if ([value conformsToProtocol:@protocol(NSMutableCopying)]) {
            [targetObject setValue:[value mutableCopyWithZone:zone] forKey:name];
        } else {
            [targetObject setValue:value forKey:name];
        }
    }
    for (NSString *name in assignPropertyNames) {
        [targetObject setValue:[object valueForKey:name] forKey:name];
    }

    return targetObject;
}

- (NSString *)descriptionForObject:(id)object withProperties:(NSArray *)properties
{
    NSMutableString *string = [NSMutableString new];
    [string appendFormat:@"<%@: %p", NSStringFromClass([object class]), object];
    NSInteger maxLengthPropertyName = 0;

    for (JKVProperty *property in properties) {
        maxLengthPropertyName = MAX(property.name.length, maxLengthPropertyName);
    }

    for (JKVProperty *property in properties) {
        NSString *name = property.name;
        id value = [object valueForKey:name];
        [string appendFormat:@"\n %@ = ", [self stringByPaddingString:name
                                                             toLength:maxLengthPropertyName
                                                           withString:@" "]];
        if (property.isWeak && value) {
            [string appendFormat:@"<%@: %p>", NSStringFromClass([value class]), value];
        } else {
            NSString *prefix = [self stringByPaddingString:@"" toLength:maxLengthPropertyName + 4 withString:@" "];
            [string appendFormat:@"%@", [self stringWithMultilineString:[self descriptionForObject:value]
                                                         withLinePrefix:prefix
                                                        prefixFirstLine:NO]];
        }
    }
    [string appendString:@">"];
    return string;
}

- (NSString *)descriptionForObject:(id)object
{
    NSMutableString *output = [NSMutableString string];
    if ([object isKindOfClass:[NSArray class]]) {
        [output appendString:@"@["];
        NSMutableArray *itemStrings = [NSMutableArray arrayWithCapacity:[object count]];
        BOOL prefixLinePrefix = NO;
        for (id item in object) {
            NSString *string = [NSString stringWithFormat:@"%@", [self descriptionForObject:item]];
            [itemStrings addObject:[self stringWithMultilineString:string withLinePrefix:@"  " prefixFirstLine:prefixLinePrefix]];
            prefixLinePrefix = YES;
        }
        [output appendString:[itemStrings componentsJoinedByString:@",\n"]];
        [output appendString:@"]"];
    } else if ([object isKindOfClass:[NSSet class]]) {
        [output appendString:@"[NSSet setWithArray:"];
        [output appendString:[self stringWithMultilineString:[self descriptionForObject:[object allObjects]]
                                              withLinePrefix:@"                      "
                                             prefixFirstLine:NO]];
        [output appendString:@"]"];
    } else if ([object isKindOfClass:[NSDictionary class]]) {
        [output appendString:@"@{"];
        NSMutableArray *itemStrings = [NSMutableArray arrayWithCapacity:[object count]];
        BOOL prefixLinePrefix = NO;
        for (id key in object) {
            id value = [object objectForKey:key];
            NSString *keyString = [self stringWithMultilineString:[self descriptionForObject:key]
                                                   withLinePrefix:@"  "
                                                  prefixFirstLine:prefixLinePrefix];
            NSString *string = [NSString stringWithFormat:@"%@: %@", keyString, [self descriptionForObject:value]];
            NSString *prefixString = [self stringByPaddingString:@"" toLength:keyString.length + 2 withString:@" "];
            [itemStrings addObject:[self stringWithMultilineString:string withLinePrefix:prefixString prefixFirstLine:NO]];
            prefixLinePrefix = YES;
        }
        [output appendString:[itemStrings componentsJoinedByString:@",\n"]];
        [output appendString:@"}"];
    } else if ([object isKindOfClass:[NSNull class]]) {
        [output appendString:@"[NSNull null]"];
    } else if ([object isKindOfClass:[NSURL class]]) {
        [output appendFormat:@"[NSURL URLWithString:%@]", [self descriptionForObject:[object absoluteString]]];
    } else if ([object isKindOfClass:[NSString class]]) {
        [output appendFormat:@"@\"%@\"", [object stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]];
    } else if (!object) {
        [output appendString:@"nil"];
    } else {
        [output appendString:[object description]];
    }
    return output;
}

#pragma mark - Private

- (NSString *)stringByPaddingString:(NSString *)string toLength:(NSInteger)length withString:(NSString *)padString
{
    NSMutableString *output = [NSMutableString string];
    while (output.length + string.length < length) {
        [output appendString:padString];
    }
    [output appendString:string];
    return output;
}

- (NSString *)stringWithMultilineString:(NSString *)content withLinePrefix:(NSString *)linePrefix prefixFirstLine:(BOOL)prefixFirstLine
{
    NSArray *components = [content componentsSeparatedByString:@"\n"];
    NSString *prefix = [NSString stringWithFormat:@"\n%@", linePrefix];
    if (prefixFirstLine) {
        return [linePrefix stringByAppendingString:[components componentsJoinedByString:prefix]];
    } else {
        return [components componentsJoinedByString:prefix];
    }
}

#pragma mark - Properties

- (NSArray *)nonWeakProperties
{
    if (!_nonWeakProperties){
        _nonWeakProperties = [self.allProperties filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isWeak = NO"]];
    }
    return _nonWeakProperties;
}

- (NSArray *)weakProperties
{
    if (!_weakProperties){
        _weakProperties = [self.allProperties filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isWeak = YES"]];
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
