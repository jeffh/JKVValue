#import <Foundation/Foundation.h>

@protocol JKVObjectStringer;

@interface JKVObjectPrinter : NSObject

+ (instancetype)sharedInstance;
- (NSString *)descriptionForObject:(id)object withProperties:(NSArray *)properties;

@end
