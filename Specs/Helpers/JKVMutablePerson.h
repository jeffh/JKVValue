#import "JKVMutableValue.h"

@interface JKVMutablePerson : JKVMutableValue
@property (nonatomic, strong) NSString<NSCopying> *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, assign, getter=isMarried) BOOL married;
@property (atomic, assign) CGFloat height;
@property (nonatomic, weak) id parent;
@end

