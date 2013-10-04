#import <Foundation/Foundation.h>

@interface JKVClassInspector : NSObject

@property (strong, nonatomic, readonly) NSArray *properties;
@property (strong, nonatomic, readonly) NSArray *weakProperties;
@property (strong, nonatomic, readonly) NSArray *nonWeakProperties;

+ (instancetype)inspectorForClass:(Class)aClass;
- (id)initWithClass:(Class)aClass;

- (BOOL)object:(id)object1 isEqualToObject:(id)object2 byProperties:(NSArray *)propertyNames;

- (id)copyOfObject:(id)object
           ofClass:(Class)clonedClass
              zone:(NSZone *)zone
identityProperties:(NSArray *)propertyNames
propertiesToAssign:(NSArray *)assignPropertyNames;
- (id)mutableCopyOfObject:(id)object
                  ofClass:(Class)clonedClass
                     zone:(NSZone *)zone
       identityProperties:(NSArray *)propertyNames
       propertiesToAssign:(NSArray *)assignPropertyNames;
- (NSString *)descriptionForObject:(id)object;

@end
