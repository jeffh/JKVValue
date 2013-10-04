#import "JKVProperty.h"

@interface JKVEncoderVisitor : NSObject <JKVPropertyEncodingTypeVisitor>
- (id)initWithCoder:(NSCoder *)coder forObject:(NSObject *)target;
@end
