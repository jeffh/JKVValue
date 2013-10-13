#import "JKVMutablePerson.h"
#import "JKVPerson.h"
#import "JKVMutableCollections.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(JKVMutableValueSpec)

describe(@"JKVMutableValue", ^{
    __block JKVMutablePerson *person, *otherPerson;
    __block id parent;

    beforeEach(^{
        parent = [[NSObject new] autorelease];
        person = [[[JKVMutablePerson alloc] init] autorelease];
        otherPerson = [[[JKVMutablePerson alloc] init] autorelease];
        person.age       = otherPerson.age       = 28;
        person.firstName = otherPerson.firstName = @"John";
        person.lastName  = otherPerson.lastName  = @"Doe";
        person.married   = otherPerson.married   = YES;
        person.height    = otherPerson.height    = 60.8;
        person.parent    = otherPerson.parent    = parent;
    });

    it(@"should have a custom description", ^{
        NSString *expectedDescription = [NSString stringWithFormat:@"<JKVMutablePerson: %p child=(null) firstName=John lastName=Doe age=28 married=1 height=60.8 parent=<NSObject: %p>>", person, parent];
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
                otherPerson.parent = nil;
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

        itShouldNotEqualWhen(@"age", ^{ otherPerson.age = 12; });
        itShouldNotEqualWhen(@"firstName", ^{ otherPerson.firstName = @"James"; });
        itShouldNotEqualWhen(@"lastName", ^{ otherPerson.firstName = @"Appleseed"; });
        itShouldNotEqualWhen(@"married", ^{ otherPerson.married = NO; });
        itShouldNotEqualWhen(@"height", ^{ otherPerson.height = 2; });
    });

    describe(@"NSCoding", ^{
        __block JKVMutablePerson *deserializedPerson;
        beforeEach(^{
            NSMutableData *data = [NSMutableData data];
            NSKeyedArchiver *archiver = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
            [person encodeWithCoder:archiver];
            [archiver finishEncoding];
            NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
            deserializedPerson = [[[JKVMutablePerson alloc] initWithCoder:unarchiver] autorelease];
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

        it(@"should support copying", ^{
            clonedPerson should_not be_same_instance_as(person);
            clonedPerson should equal((JKVPerson *)person);
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

    describe(@"NSMutableCopying", ^{
        __block JKVMutablePerson *clonedPerson;
        beforeEach(^{
            clonedPerson = [person mutableCopy];
        });

        it(@"should support copying", ^{
            clonedPerson should_not be_same_instance_as(person);
            clonedPerson should equal(person);
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

        itShouldRecursivelyCopy(@"firstName", ^id(JKVMutablePerson *p){ return p.firstName; });
        itShouldRecursivelyCopy(@"lastName", ^id(JKVMutablePerson *p){ return p.lastName; });
    });

    describe(@"collections that are properties", ^{
        __block JKVMutableCollections *collections;
        beforeEach(^{
            collections = [[JKVMutableCollections alloc] initWithItems:@[@1] pairs:@{@"A":@"B"}];
        });

        it(@"should support equality for cloned objects", ^{
            collections should equal([collections copy]);
        });

        it(@"should support equality for mutable cloned objects", ^{
            collections should equal([collections mutableCopy]);
        });
    });
});

SPEC_END
