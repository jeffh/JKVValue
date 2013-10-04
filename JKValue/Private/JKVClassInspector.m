#import "JKVClassInspector.h"
#import "JKVProperty.h"
#import <objc/runtime.h>

@interface JKVClassInspector ()
@property (strong, nonatomic) Class aClass;
@property (strong, nonatomic, readwrite) NSArray *properties;
@property (strong, nonatomic, readwrite) NSArray *weakProperties;
@property (strong, nonatomic, readwrite) NSArray *nonWeakProperties;
@property (strong, nonatomic, readwrite) NSArray *ivars;

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
