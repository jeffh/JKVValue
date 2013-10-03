#import "JKVProperty.h"
#import <objc/runtime.h>

@implementation JKVProperty

- (id)initWithName:(NSString *)name attributes:(NSDictionary *)attributes
{
    if (self = [super init]) {
        self.name = name;
        self.attributes = attributes;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ name=%@ attributes=%@>", NSStringFromClass([self class]), self.name, self.attributes.description];
}

- (NSString *)encodingType
{
    return self.attributes[@"T"];
}

- (NSString *)ivarName
{
    return self.attributes[@"V"];
}

- (BOOL)isEncodingType:(const char *)encoding
{
    return strcmp(self.encodingType.UTF8String, encoding) == 0;
}

- (BOOL)isObjCObjectType
{
    return [self.encodingType rangeOfString:@"@"].location != NSNotFound;
}

- (BOOL)isWeak
{
    return self.attributes[@"W"] != nil;
}

- (BOOL)isNonAtomic
{
    return self.attributes[@"N"] != nil;
}

- (BOOL)isReadOnly
{
    return self.attributes[@"R"] != nil;
}

- (void)visitEncodingType:(id<JKVPropertyEncodingTypeVisitor>)visitor
{
    SEL selector;
    if ([self isEncodingType:@encode(int64_t)]) {
        selector = @selector(propertyWasInt64:);
    } else if ([self isEncodingType:@encode(int32_t)]) {
        selector = @selector(propertyWasInt32:);
    } else if ([self isEncodingType:@encode(int16_t)]) {
        selector = @selector(propertyWasInt16:);
    } else if ([self isEncodingType:@encode(float)]) {
        selector = @selector(propertyWasFloat:);
    } else if ([self isEncodingType:@encode(double)]) {
        selector = @selector(propertyWasDouble:);
    } else if ([self isEncodingType:@encode(BOOL)]) {
        selector = @selector(propertyWasBool:);
    } else if ([self isEncodingType:@encode(CGPoint)]) {
        selector = @selector(propertyWasCGPoint:);
    } else if ([self isEncodingType:@encode(CGSize)]) {
        selector = @selector(propertyWasCGSize:);
    } else if ([self isEncodingType:@encode(CGRect)]) {
        selector = @selector(propertyWasCGRect:);
    } else if ([self isEncodingType:@encode(CGAffineTransform)]) {
        selector = @selector(propertyWasCGAffineTransform:);
    } else if ([self isEncodingType:@encode(UIEdgeInsets)]) {
        selector = @selector(propertyWasUIEdgeInsets:);
    } else if ([self isEncodingType:@encode(UIOffset)]) {
        selector = @selector(propertyWasUIOffset:);
    } else if ([self isObjCObjectType]) {
        selector = @selector(propertyWasObjCObject:);
    } else {
        selector = @selector(propertyWasUnknownType:);
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [visitor performSelector:selector withObject:self];
#pragma clang diagnostic pop
}

@end