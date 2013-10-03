#import "JKVPerson.h"
#import "JKVMutablePerson.h"

@interface JKVPerson ()
@end

@implementation JKVPerson


- (id)initWithFirstName:(NSString *)firstName
               lastName:(NSString *)lastName
                    age:(NSInteger)age
                married:(BOOL)married
                 height:(CGFloat)height
                 parent:(id)parent
{
    if (self = [super init]) {
        _firstName = firstName;
        _lastName = lastName;
        _age = age;
        _married = married;
        _height = height;
        _parent = parent;
    }
    return self;
}

- (Class)JKV_mutableClass
{
    return [JKVMutablePerson class];
}

@end
