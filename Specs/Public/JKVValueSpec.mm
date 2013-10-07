#import "JKVPerson.h"
#import "JKVMutablePerson.h"
#import "JKVClassInspector.h"
#import "JKVTypeContainer.h"
#import "JKVMutableCollections.h"
#import "JKVCollections.h"
#import "JKVRestrictedObject.h"

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

            it(@"should behave as the same value in a set", ^{
                [[NSSet setWithArray:@[person, otherPerson]] count] should equal(1);
            });
        });

        context(@"when the (weak) parent property is not equivalent in value", ^{
            it(@"should be equal", ^{
                otherPerson = [[[JKVPerson alloc] initWithFirstName:person.firstName
                                                           lastName:person.lastName
                                                                age:person.age
                                                            married:person.married
                                                             height:person.height
                                                             parent:@"foo"] autorelease];
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
            box = [[[JKVTypeContainer alloc] initWithPresetData] autorelease];
            otherBox = [[[JKVTypeContainer alloc] initWithPresetData] autorelease];
        });

        it(@"should support various types for encoding", ^{
            box should equal(otherBox);
        });

        describe(@"NSCoding", ^{
            __block JKVTypeContainer *deserializedBox;

            beforeEach(^{
                NSMutableData *data = [NSMutableData data];
                NSKeyedArchiver *archiver = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
                [box encodeWithCoder:archiver];
                [archiver finishEncoding];
                NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
                deserializedBox = [[[JKVTypeContainer alloc] initWithCoder:unarchiver] autorelease];
                [unarchiver finishDecoding];
            });

            it(@"should support serialization", ^{
                deserializedBox should equal(box);
            });
        });
    });

    describe(@"collections that are properties", ^{
        __block JKVCollections *collections;
        beforeEach(^{
            collections = [[JKVCollections alloc] initWithItems:@[@1] pairs:@{@"A":@"B"}];
        });

        it(@"should support equality for cloned objects", ^{
            collections should equal([collections copy]);
        });

        describe(@"mutable clone", ^{
            __block JKVMutableCollections *mutableCollections;
            beforeEach(^{
                mutableCollections = [collections mutableCopy];
            });

            it(@"should support mutation on the properties", ^{
                [mutableCollections.items addObject:@2];
                mutableCollections.pairs[@"C"] = @"D";
                mutableCollections.items should equal(@[@1, @2]);
                mutableCollections.pairs should equal(@{@"A": @"B", @"C": @"D"});
            });

            it(@"should support equality for mutable cloned objects", ^{
                collections should equal(mutableCollections);
            });
        });
    });

    describe(@"operating on a subset of properties", ^{
        __block JKVRestrictedObject *restrictedObject;
        __block id lastReader, lastWriter;
        beforeEach(^{
            restrictedObject = [[[JKVRestrictedObject alloc] initWithPresetData] autorelease];
            restrictedObject.lastReader = lastReader = [[NSObject new] autorelease];
            restrictedObject.lastWriter = lastWriter = [[NSObject new] autorelease];
        });

        describe(@"equality", ^{
            __block JKVRestrictedObject *otherObject;
            beforeEach(^{
                otherObject = [[[JKVRestrictedObject alloc] initWithPresetData] autorelease];
            });

            void (^itShouldNotEqualWhen)(NSString *, void(^)()) = ^(NSString *name, void(^mutator)()) {
                context([NSString stringWithFormat:@"when the %@ is not equivalent in value", name], ^{
                    it(@"should not be equal", ^{
                        mutator();
                        restrictedObject should_not equal(otherObject);
                    });
                });
            };

            void (^itShouldEqualWhen)(NSString *, void(^)()) = ^(NSString *name, void(^mutator)()) {
                context([NSString stringWithFormat:@"when the %@ is not equivalent in value", name], ^{
                    it(@"should be equal", ^{
                        mutator();
                        restrictedObject should equal(otherObject);
                    });
                });
            };

            itShouldEqualWhen(@"accessCount", ^{ otherObject.accessCount = @42; });
            itShouldEqualWhen(@"source", ^{ otherObject.source = @"Barney"; });
            itShouldEqualWhen(@"lastReader", ^{ otherObject.lastWriter = @"John"; });
            itShouldEqualWhen(@"lastWriter", ^{ otherObject.lastWriter = @"Doe"; });
            itShouldNotEqualWhen(@"accessLevel", ^{ otherObject.accessLevel = JKVAccessLevelAdmin; });
            itShouldNotEqualWhen(@"name", ^{ otherObject.name = @"Foobar"; });
        });

        describe(@"NSCopying", ^{
            __block JKVRestrictedObject *clonedObject;
            beforeEach(^{
                clonedObject = [restrictedObject copy];
            });

            it(@"should only clone the identity properties and the assign properties specified", ^{
                clonedObject should equal(restrictedObject);
                clonedObject.accessCount should be_nil;
                clonedObject.source should be_nil;
                clonedObject.lastReader should be_nil;
                clonedObject.lastWriter should be_same_instance_as(lastWriter);
            });
        });

        describe(@"NSMutableCopying", ^{
            __block JKVRestrictedObject *clonedObject;
            beforeEach(^{
                clonedObject = [restrictedObject mutableCopy];
            });

            it(@"should only clone the identity properties and the assign properties specified", ^{
                clonedObject should equal(restrictedObject);
                clonedObject.accessCount should be_nil;
                clonedObject.source should be_nil;
                clonedObject.lastReader should be_nil;
                clonedObject.lastWriter should be_same_instance_as(lastWriter);
            });
        });
    });
});

SPEC_END
