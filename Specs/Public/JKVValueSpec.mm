#import "JKVPerson.h"
#import "JKVMutablePerson.h"
#import "JKVClassInspector.h"
#import "JKVTypeContainer.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(JKVValueSpec)

describe(@"JKVValue", ^{
    __block JKVPerson *person, *otherPerson;
    __block id parent;

    beforeEach(^{
        parent = [[@"Ignorable" dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
        person = [[[JKVPerson alloc] initWithFirstName:@"John"
                                              lastName:@"Doe"
                                                   age:28
                                               married:YES
                                                height:60.8
                                                parent:parent] autorelease];
        otherPerson = [[[JKVPerson alloc] initWithFirstName:person.firstName
                                                   lastName:person.lastName
                                                        age:person.age
                                                    married:person.married
                                                     height:person.height
                                                     parent:parent] autorelease];
    });

    it(@"should have a custom description", ^{
        NSString *expectedDescription = [NSString stringWithFormat:@"<JKVPerson %p firstName=John lastName=Doe age=28 married=1 height=60.8 parent=%@>", person, [parent description]];
        person.description should contain(expectedDescription);
    });

    describe(@"equality", ^{
        context(@"when all properties are equivalent in value", ^{
            it(@"should be equal", ^{
                person should equal(otherPerson);
            });

            it(@"should have the same hash code", ^{
                person.hash should equal(otherPerson.hash);
            });
        });

        context(@"when the (weak) parent property is not equivalent in value", ^{
            it(@"should be equal", ^{
                otherPerson = [[[JKVPerson alloc] initWithFirstName:person.firstName
                                                           lastName:person.lastName
                                                                age:person.age
                                                            married:person.married
                                                             height:person.height
                                                             parent:nil] autorelease];
                person should equal(otherPerson);
            });
        });

        void (^itShouldNotEqualWhen)(NSString *, void(^)()) = ^(NSString *name, void(^mutator)()) {
            context([NSString stringWithFormat:@"when the %@ is not equivalent in value", name], ^{
                it(@"should not be equal", ^{
                    mutator();
                    person should_not equal(otherPerson);
                });
            });
        };

        itShouldNotEqualWhen(@"age", ^{
            otherPerson = [[[JKVPerson alloc] initWithFirstName:person.firstName
                                                       lastName:person.lastName
                                                            age:18
                                                        married:person.married
                                                         height:person.height
                                                         parent:parent] autorelease];
        });
        itShouldNotEqualWhen(@"firstName", ^{
            otherPerson = [[[JKVPerson alloc] initWithFirstName:@"James"
                                                       lastName:person.lastName
                                                            age:person.age
                                                        married:person.married
                                                         height:person.height
                                                         parent:parent] autorelease];
        });
        itShouldNotEqualWhen(@"lastName", ^{
            otherPerson = [[[JKVPerson alloc] initWithFirstName:person.firstName
                                                       lastName:@"Appleseed"
                                                            age:person.age
                                                        married:person.married
                                                         height:person.height
                                                         parent:parent] autorelease];
        });
        itShouldNotEqualWhen(@"married", ^{
            otherPerson = [[[JKVPerson alloc] initWithFirstName:person.firstName
                                                       lastName:person.lastName
                                                            age:person.age
                                                        married:NO
                                                         height:person.height
                                                         parent:parent] autorelease];
        });

        itShouldNotEqualWhen(@"height", ^{
            otherPerson = [[[JKVPerson alloc] initWithFirstName:person.firstName
                                                       lastName:person.lastName
                                                            age:person.age
                                                        married:person.married
                                                         height:2.2
                                                         parent:parent] autorelease];
        });
    });

    describe(@"NSCoding", ^{
        __block JKVPerson *deserializedPerson;
        beforeEach(^{
            NSMutableData *data = [NSMutableData data];
            NSKeyedArchiver *archiver = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
            [person encodeWithCoder:archiver];
            [archiver finishEncoding];
            NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
            deserializedPerson = [[[JKVPerson alloc] initWithCoder:unarchiver] autorelease];
            [unarchiver finishDecoding];
        });

        it(@"should support serialization", ^{
            deserializedPerson should equal(person);
        });
    });

    describe(@"NSCopying", ^{
        __block JKVPerson *clonedPerson;
        beforeEach(^{
            clonedPerson = [person copy];
        });

        it(@"should return the same instance", ^{
            clonedPerson should be_same_instance_as(person);
        });
    });

    describe(@"NSMutableCopying", ^{
        __block JKVPerson *clonedPerson;
        beforeEach(^{
            clonedPerson = [person mutableCopy];
        });

        it(@"should support copying", ^{
            clonedPerson should_not be_same_instance_as(person);
            clonedPerson should equal(person);
        });

        it(@"should be a mutable class variant", ^{
            clonedPerson should be_instance_of([JKVMutablePerson class]);
        });

        void (^itShouldRecursivelyCopy)(NSString *, id (^)(id)) = ^(NSString *name, id (^getter)(id obj)) {
            it([NSString stringWithFormat:@"should recursively copy %@", name], ^{
                getter(person) should_not be_same_instance_as(getter(clonedPerson));
                getter(person) should equal(getter(clonedPerson));
            });
        };

        it(@"should preserve the weak properties", ^{
            clonedPerson.parent should be_same_instance_as(parent);
        });

        itShouldRecursivelyCopy(@"firstName", ^id(JKVPerson *p){ return p.firstName; });
        itShouldRecursivelyCopy(@"lastName", ^id(JKVPerson *p){ return p.lastName; });
    });

    describe(@"type encoding", ^{
        __block JKVTypeContainer *box;
        __block JKVTypeContainer *otherBox;
        beforeEach(^{
            box = [[[JKVTypeContainer alloc] init] autorelease];
            otherBox = [[[JKVTypeContainer alloc] init] autorelease];
        });

        it(@"should support various types for encoding", ^{
            box should equal(otherBox);
        });

        describe(@"NSCoding", ^{
            __block JKVTypeContainer *deserializedBox;
            void (^serialize)() = ^{
                NSMutableData *data = [NSMutableData data];
                NSKeyedArchiver *archiver = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
                [box encodeWithCoder:archiver];
                [archiver finishEncoding];
                NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
                deserializedBox = [[[JKVTypeContainer alloc] initWithCoder:unarchiver] autorelease];
                [unarchiver finishDecoding];
            };
            beforeEach(serialize);

            it(@"should support serialization", ^{
                deserializedBox should equal(box);
            });
        });
    });
});

SPEC_END
