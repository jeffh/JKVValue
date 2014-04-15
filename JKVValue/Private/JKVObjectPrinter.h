#import <Foundation/Foundation.h>


@interface JKVObjectPrinter : NSObject

+ (instancetype)sharedInstance;
- (NSString *)descriptionForObject:(id)object withProperties:(NSArray *)properties;

@end
