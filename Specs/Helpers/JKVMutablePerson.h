#import "JKVPerson.h"

@interface JKVMutablePerson : JKVPerson
@property (nonatomic, strong, readwrite) NSString<NSCopying> *firstName;
@property (nonatomic, strong, readwrite) NSString *lastName;
@property (nonatomic, assign, readwrite) NSInteger age;
@property (nonatomic, assign, readwrite, getter=isMarried) BOOL married;
@property (atomic, assign, readwrite) CGFloat height;
@property (nonatomic, weak, readwrite) id parent;
@end

