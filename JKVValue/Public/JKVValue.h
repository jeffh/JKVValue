#import <Foundation/Foundation.h>

@interface JKVValue : NSObject <NSCoding, NSMutableCopying, NSCopying, NSSecureCoding>

// Override this method to return YES to indicate that this subclass is
// mutable. This changes the behavior of how NSCopying protocol works
// from returning itself to copying all properties.
//
// The default returns NO. The JKVMutableValue subclass returns YES.
- (BOOL)JKV_isMutable;

// Override this method to return the class to instanciate when using
// the NSCopying protocol. This is useful for when you want a mutable
// class to return an immutable class when -[copy] is called.
//
// For example, you would override this if you wanted MyArray class to
// use MyMutableArray.
//
// The default returns the current class.
- (Class)JKV_immutableClass;

// The reverse of -[JKV_immutableClass]. Override this method to return
// the class to instanciate when using the NSMutableCopying protocol.
// This is useful for when you want an immutable class to return a
// mutable class when -[mutableCopy] is called.
//
// For example, you would override this if you wanted MyMutableArray
// class to use MyArray.
//
// The default returns the current class.
- (Class)JKV_mutableClass;
- (NSArray *)JKV_propertyNamesForIdentity;
- (NSArray *)JKV_propertyNamesToAssignCopy;

@end
