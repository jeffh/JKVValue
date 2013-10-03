#import "JKVDecoderVisitor.h"

@interface JKVDecoderVisitor ()
@property (strong, nonatomic) NSCoder *coder;
@property (strong, nonatomic) NSObject *target;
@end

@implementation JKVDecoderVisitor

- (id)initWithCoder:(NSCoder *)decoder forObject:(NSObject *)target;
{
    if (self = [super init]) {
        self.coder = decoder;
        self.target = target;
    }
    return self;
}

#pragma mark - <JKVPropertyEncodingTypeVisitor>

- (void)propertyWasNSInteger:(JKVProperty *)property
{
    [self.target setValue:@([self.coder decodeIntegerForKey:property.name])
                   forKey:property.name];
}

- (void)propertyWasFloat:(JKVProperty *)property
{
    [self.target setValue:@([self.coder decodeFloatForKey:property.name])
                   forKey:property.name];
}

- (void)propertyWasBool:(JKVProperty *)property
{
    [self.target setValue:([self.coder decodeBoolForKey:property.name] ? @YES : @NO)
                   forKey:property.name];
}

- (void)propertyWasObjCObject:(JKVProperty *)property
{
    [self.target setValue:[self.coder decodeObjectForKey:property.name]
                   forKey:property.name];
}

- (void)propertyWasUnknownType:(JKVProperty *)property
{
    [NSException raise:@"Unknown Encoding Type" format:@"Unknown encoding type: %@", property.encodingType];
}

@end
