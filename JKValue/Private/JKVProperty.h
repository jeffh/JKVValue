#import <Foundation/Foundation.h>

@class JKVProperty;

@protocol JKVPropertyEncodingTypeVisitor <NSObject>
- (void)propertyWasInt64:(JKVProperty *)property;
- (void)propertyWasInt32:(JKVProperty *)property;
- (void)propertyWasInt16:(JKVProperty *)property;
- (void)propertyWasFloat:(JKVProperty *)property;
- (void)propertyWasDouble:(JKVProperty *)property;
- (void)propertyWasBool:(JKVProperty *)property;
- (void)propertyWasCGPoint:(JKVProperty *)property;
- (void)propertyWasCGSize:(JKVProperty *)property;
- (void)propertyWasCGRect:(JKVProperty *)property;
- (void)propertyWasCGAffineTransform:(JKVProperty *)property;
- (void)propertyWasUIEdgeInsets:(JKVProperty *)property;
- (void)propertyWasUIOffset:(JKVProperty *)property;
- (void)propertyWasObjCObject:(JKVProperty *)property;
- (void)propertyWasUnknownType:(JKVProperty *)property;
@end

@interface JKVProperty : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSDictionary *attributes;

- (id)initWithName:(NSString *)name attributes:(NSDictionary *)attributes;

- (NSString *)encodingType;
- (NSString *)ivarName;
- (BOOL)isEncodingType:(const char *)encoding;
- (BOOL)isObjCObjectType;
- (BOOL)isWeak;
- (BOOL)isNonAtomic;
- (BOOL)isReadOnly;
- (void)visitEncodingType:(id<JKVPropertyEncodingTypeVisitor>)visitor;

@end