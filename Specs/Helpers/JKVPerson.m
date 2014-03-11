#import "JKVPerson.h"
#import "JKVMutablePerson.h"

@interface JKVPerson ()
@property (nonatomic, strong, readwrite) NSString<NSCopying> *firstName;
@property (nonatomic, strong, readwrite) NSString *lastName;
@property (nonatomic, assign, readwrite) NSInteger age;
@property (nonatomic, assign, getter=isMarried, readwrite) BOOL married;
@property (atomic, assign, readwrite) CGFloat height;
@end

@implementation JKVPerson

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithFixtureData
{
    return [self initWithFirstName:@"John"
                          lastName:@"Doe"
                               age:28
                           married:YES
                            height:60.8
                            parent:nil];
}

- (id)initWithFirstName:(NSString *)firstName
               lastName:(NSString *)lastName
                    age:(NSInteger)age
                married:(BOOL)married
                 height:(CGFloat)height
                 parent:(id)parent
{
    if (self = [super init]) {
        self.firstName = firstName;
        self.lastName = lastName;
        self.age = age;
        self.married = married;
        self.height = height;
        self.parent = parent;
        self.child = nil;
    }
    return self;
}

- (Class)JKV_mutableClass
{
    return [JKVMutablePerson class];
}

@end
