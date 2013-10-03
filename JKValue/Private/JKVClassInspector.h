#import <Foundation/Foundation.h>

@interface JKVClassInspector : NSObject

+ (instancetype)inspectorForClass:(Class)aClass;
- (id)initWithClass:(Class)aClass;

@property (strong, nonatomic, readonly) NSArray *properties;
@property (strong, nonatomic, readonly) NSArray *weakProperties;
@property (strong, nonatomic, readonly) NSArray *nonWeakProperties;

@end
