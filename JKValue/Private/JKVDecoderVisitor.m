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

- (void)propertyWasInt64:(JKVProperty *)property
{
    [self.target setValue:@([self.coder decodeInt64ForKey:property.name])
                   forKey:property.name];
}

- (void)propertyWasInt32:(JKVProperty *)property
{
    [self.target setValue:@([self.coder decodeInt64ForKey:property.name])
                   forKey:property.name];
}

- (void)propertyWasInt16:(JKVProperty *)property
{
    [self.target setValue:@((int16_t)[self.coder decodeInt32ForKey:property.name])
                   forKey:property.name];
}

- (void)propertyWasFloat:(JKVProperty *)property
{
    [self.target setValue:@([self.coder decodeFloatForKey:property.name])
                   forKey:property.name];
}

- (void)propertyWasDouble:(JKVProperty *)property
{
    [self.target setValue:@([self.coder decodeDoubleForKey:property.name])
                   forKey:property.name];
}

- (void)propertyWasBool:(JKVProperty *)property
{
    [self.target setValue:([self.coder decodeBoolForKey:property.name] ? @YES : @NO)
                   forKey:property.name];
}

- (void)propertyWasCGPoint:(JKVProperty *)property
{
    [self.target setValue:[NSValue valueWithCGPoint:[self.coder decodeCGPointForKey:property.name]]
                   forKey:property.name];
}
- (void)propertyWasCGSize:(JKVProperty *)property
{
    [self.target setValue:[NSValue valueWithCGSize:[self.coder decodeCGSizeForKey:property.name]]
                   forKey:property.name];
}

- (void)propertyWasCGRect:(JKVProperty *)property
{
    [self.target setValue:[NSValue valueWithCGRect:[self.coder decodeCGRectForKey:property.name]]
                   forKey:property.name];
}

- (void)propertyWasCGAffineTransform:(JKVProperty *)property
{
    [self.target setValue:[NSValue valueWithCGAffineTransform:[self.coder decodeCGAffineTransformForKey:property.name]]
                   forKey:property.name];
}

- (void)propertyWasUIEdgeInsets:(JKVProperty *)property
{
    [self.target setValue:[NSValue valueWithUIEdgeInsets:[self.coder decodeUIEdgeInsetsForKey:property.name]]
                   forKey:property.name];
}

- (void)propertyWasUIOffset:(JKVProperty *)property
{
    [self.target setValue:[NSValue valueWithUIOffset:[self.coder decodeUIOffsetForKey:property.name]]
                   forKey:property.name];
}

- (void)propertyWasObjCObject:(JKVProperty *)property
{
    [self.target setValue:[self.coder decodeObjectForKey:property.name]
                   forKey:property.name];
}

- (void)propertyWasUnknownType:(JKVProperty *)property
{
    [NSException raise:@"Unknown Encoding Type" format:@"Unknown encoding type: %@ for %@", property.encodingType, property.name];
}

@end
