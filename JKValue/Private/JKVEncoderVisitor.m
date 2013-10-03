#import "JKVEncoderVisitor.h"

@interface JKVEncoderVisitor ()
@property (strong, nonatomic) NSCoder *coder;
@property (strong, nonatomic) NSObject *target;
@end

@implementation JKVEncoderVisitor

- (id)initWithCoder:(NSCoder *)coder forObject:(NSObject *)target;
{
    if (self = [super init]) {
        self.coder = coder;
        self.target = target;
    }
    return self;
}

#pragma mark - <JKVPropertyEncodingTypeVisitor>

- (void)propertyWasNSInteger:(JKVProperty *)property
{
    [self.coder encodeInteger:[[self.target valueForKey:property.name] integerValue]
                       forKey:property.name];
}

- (void)propertyWasFloat:(JKVProperty *)property
{
    [self.coder encodeFloat:[[self.target valueForKey:property.name] floatValue]
                     forKey:property.name];
}

- (void)propertyWasBool:(JKVProperty *)property
{
    [self.coder encodeBool:[[self.target valueForKey:property.name] boolValue]
                    forKey:property.name];
}

- (void)propertyWasObjCObject:(JKVProperty *)property
{
    [self.coder encodeObject:[self.target valueForKey:property.name]
                      forKey:property.name];
}

- (void)propertyWasUnknownType:(JKVProperty *)property
{
    [NSException raise:@"Unknown Encoding Type" format:@"Unknown encoding type: %@", property.encodingType];
}

@end
