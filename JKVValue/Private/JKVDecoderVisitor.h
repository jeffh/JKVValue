#import "JKVProperty.h"

@interface JKVDecoderVisitor : NSObject <JKVPropertyEncodingTypeVisitor>

- (id)initWithCoder:(NSCoder *)decoder forObject:(NSObject *)target;

@end
