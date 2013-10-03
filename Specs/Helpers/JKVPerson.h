#import "JKVValue.h"

@interface JKVPerson : JKVValue
@property (nonatomic, strong, readonly) NSString<NSCopying> *firstName;
@property (nonatomic, strong, readonly) NSString *lastName;
@property (nonatomic, assign, readonly) NSInteger age;
@property (nonatomic, assign, getter=isMarried, readonly) BOOL married;
@property (atomic, assign, readonly) CGFloat height;

@property (nonatomic, weak) id parent;

// objc doesn't mark this as weak because of the readonly attribute
//@property (nonatomic, weak, readonly) id nextSibling;

- (id)initWithFirstName:(NSString *)firstName
               lastName:(NSString *)lastName
                    age:(NSInteger)age
                married:(BOOL)married
                 height:(CGFloat)height
                 parent:(id)parent;

@end
