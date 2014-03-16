#import "JKVPerson.h"
#import "JKVMutablePerson.h"
#import "JKVClassInspector.h"
#import "JKVTypeContainer.h"
#import "JKVMutableCollections.h"
#import "JKVCollections.h"
#import "JKVRestrictedObject.h"
#import "JKVBasicValue.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(JKVValueSpec)

describe(@"JKVValue", ^{
    __block JKVPerson *person, *otherPerson;
    __block id parent;

    beforeEach(^{
        parent = [NSObject new];
        person = [[JKVPerson alloc] initWithFirstName:@"John"
                                              lastName:@"Doe"
                                                   age:28
                                               married:YES
                                                height:60.8
                                                parent:parent];
        otherPerson = [[JKVPerson alloc] initWithFirstName:person.firstName
                                                   lastName:person.lastName
                                                        age:person.age
                                                    married:person.married
                                                     height:person.height
                                                     parent:parent];
    });

    describe(@"descriptions", ^{
        it(@"should have a custom description", ^{
            NSString *expectedDescription = [NSString stringWithFormat:
                                             @"<JKVPerson: %p\n"
                                             @" firstName = @\"John\"\n"
                                             @"  lastName = @\"Doe\"\n"
                                             @"       age = 28\n"
                                             @"   married = 1\n"
                                             @"    height = 60.8\n"
                                             @"    parent = <NSObject: %p>\n"
                                             @"     child = nil>", person, parent];
            person.description should contain(expectedDescription);
        });
        
        it(@"should have a debug description be the same as the description", ^{
            person.debugDescription should contain(person.description);
        });

        it(@"should pretty print objective-c containers", ^{
            JKVCollections *container = [[JKVCollections alloc] initWithItems:@[@{@"hi": [NSSet setWithArray:@[@"lo", @"what up"]],
                                                                                  @"some": @"value"}]
                                                                        pairs:@{@"items": @[@{@"good": @"eats"},
                                                                                            @1],
                                                                                @"place": [NSURL URLWithString:@"http://google.com"]}];
            NSString *expectedDescription = [NSString stringWithFormat:
                                             @"<JKVCollections: %p\n"
                                             @" items = @[@{@'some': @'value',\n"
                                             @"             @'hi': [NSSet setWithArray:@[@'what up',\n"
                                             @"                                          @'lo']]}]\n"
                                             @" pairs = @{@'place': [NSURL URLWithString:@'http://google.com'],\n"
                                             @"           @'items': @[@{@'good': @'eats'},\n"
                                             @"                       1]}>", container];
            expectedDescription = [expectedDescription stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
            container.description should equal(expectedDescription);
        });
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

            it(@"should be equal to mutable variant", ^{
                person should equal([person mutableCopy]);
            });
        });

        context(@"when the (weak) parent property is not equivalent in value", ^{
            it(@"should be equal", ^{
                otherPerson = [[JKVPerson alloc] initWithFirstName:person.firstName
                                                           lastName:person.lastName
                                                                age:person.age
                                                            married:person.married
                                                             height:person.height
                                                             parent:@"foo"];
                person should equal(otherPerson);
            });
        });

        it(@"should not be equal to another object", ^{
            person should_not equal((id)@1);
        });

        void (^itShouldNotEqualWhen)(NSString *, void(^)()) = ^(NSString *name, void(^mutator)()) {
            context([NSString stringWithFormat:@"when the %@ is not equivalent in value", name], ^{
                it(@"should not be equal", ^{
                    mutator();
                    person should_not equal(otherPerson);
                });
            });
        };

        itShouldNotEqualWhen(@"value's NSObject property is nil", ^{
            person = [[JKVPerson alloc] initWithFirstName:nil
                                                  lastName:person.lastName
                                                       age:person.age
                                                   married:person.married
                                                    height:person.height
                                                    parent:parent];
        });

        itShouldNotEqualWhen(@"age", ^{
            otherPerson = [[JKVPerson alloc] initWithFirstName:person.firstName
                                                       lastName:person.lastName
                                                            age:18
                                                        married:person.married
                                                         height:person.height
                                                         parent:parent];
        });
        itShouldNotEqualWhen(@"firstName", ^{
            otherPerson = [[JKVPerson alloc] initWithFirstName:@"James"
                                                       lastName:person.lastName
                                                            age:person.age
                                                        married:person.married
                                                         height:person.height
                                                         parent:parent];
        });
        itShouldNotEqualWhen(@"lastName", ^{
            otherPerson = [[JKVPerson alloc] initWithFirstName:person.firstName
                                                       lastName:@"Appleseed"
                                                            age:person.age
                                                        married:person.married
                                                         height:person.height
                                                         parent:parent];
        });
        itShouldNotEqualWhen(@"married", ^{
            otherPerson = [[JKVPerson alloc] initWithFirstName:person.firstName
                                                       lastName:person.lastName
                                                            age:person.age
                                                        married:NO
                                                         height:person.height
                                                         parent:parent];
        });

        itShouldNotEqualWhen(@"height", ^{
            otherPerson = [[JKVPerson alloc] initWithFirstName:person.firstName
                                                       lastName:person.lastName
                                                            age:person.age
                                                        married:person.married
                                                         height:2.2
                                                         parent:parent];
        });

        itShouldNotEqualWhen(@"child", ^{
            otherPerson = [[JKVPerson alloc] initWithFirstName:person.firstName
                                                       lastName:person.lastName
                                                            age:person.age
                                                        married:person.married
                                                         height:person.height
                                                         parent:parent];
            otherPerson.child = @"FOO";
        });
    });

    describe(@"NSSecureCoding", ^{
        __block JKVBasicValue *deserializedValue;
        __block NSMutableData *data;
        __block NSKeyedUnarchiver *unarchiver;

        beforeEach(^{
            data = [NSMutableData data];
            NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
            [archiver encodeObject:@"bad" forKey:@"number"];
            [archiver finishEncoding];

            unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
            spy_on(unarchiver);
        });

        afterEach(^{
            [unarchiver finishDecoding];
        });

        it(@"should support secure coding", ^{
            [JKVPerson supportsSecureCoding] should be_truthy;
        });

        context(@"when secure coding is required", ^{
            beforeEach(^{
                // OSX doesn't support setter of requiresSecureCoding
                unarchiver stub_method(@selector(requiresSecureCoding)).and_return(YES);
            });

            it(@"should raise exception if decoding a bad value", ^{
                ^{
                    deserializedValue = [[JKVBasicValue alloc] initWithCoder:unarchiver];
                } should raise_exception([NSException exceptionWithName:NSInvalidUnarchiveOperationException reason:@"Failed to unarchive 'number' as 'NSNumber'" userInfo:nil]);
            });
        });

        context(@"when secure coding is not required", ^{
            beforeEach(^{
                // OSX doesn't support setter of requiresSecureCoding
                unarchiver stub_method(@selector(requiresSecureCoding)).and_return(NO);
            });

            it(@"should not raise exception if decoding a bad value", ^{
                ^{
                    deserializedValue = [[JKVBasicValue alloc] initWithCoder:unarchiver];
                } should_not raise_exception();
            });
        });
    });

    describe(@"NSCoding", ^{
        __block JKVPerson *parent;
        __block JKVPerson *deserializedPerson;
        __block NSMutableData *data;

        beforeEach(^{
            data = [NSMutableData data];
            parent = [[JKVPerson alloc] initWithFixtureData];
            person.parent = parent;
            parent.child = person;
        });

        context(@"conditional coding", ^{
            beforeEach(^{
                NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
                [archiver encodeObject:parent];
                [archiver finishEncoding];

                NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
                deserializedPerson = [unarchiver decodeObject];
                [unarchiver finishDecoding];
            });

            it(@"should have its child.parent encoded", ^{
                deserializedPerson should equal(parent);
                deserializedPerson.child should equal(person);
                (JKVPerson *)[deserializedPerson.child parent] should be_same_instance_as(deserializedPerson);
            });
        });

        context(@"Keyed Coding", ^{
            beforeEach(^{
                NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
                [archiver encodeObject:person];
                [archiver finishEncoding];
                NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
                deserializedPerson = [unarchiver decodeObject];
                [unarchiver finishDecoding];
            });

            it(@"should support serialization", ^{
                deserializedPerson should equal(person);
            });
        });

        context(@"Non-Keyed Coding", ^{
            // iOS doesn't support NSArchiver
            context(@"with an archiver", ^{
                __block NSKeyedArchiver *archiver;

                beforeEach(^{
                    archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
                    spy_on(archiver);
                    archiver stub_method(@selector(allowsKeyedCoding)).and_return(NO);
                });

                afterEach(^{
                    [archiver finishEncoding];
                });

                it(@"should raise an exception", ^{
                    ^{
                        [person encodeWithCoder:archiver];
                    } should raise_exception([NSException exceptionWithName:NSInvalidArchiveOperationException reason:@"Only Keyed-Archivers are supported" userInfo:nil]);
                });
            });

            // iOS doesn't support NSUnarchiver
            context(@"with an unarchiver", ^{
                __block NSKeyedUnarchiver *unarchiver;

                beforeEach(^{
                    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
                    [archiver encodeObject:person];
                    [archiver finishEncoding];

                    unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
                    spy_on(unarchiver);
                    unarchiver stub_method(@selector(allowsKeyedCoding)).and_return(NO);
                });

                afterEach(^{
                    [unarchiver finishDecoding];
                });

                it(@"should raise an exception", ^{
                    ^{
                        deserializedPerson = [[JKVPerson alloc] initWithCoder:unarchiver];
                    } should raise_exception([NSException exceptionWithName:NSInvalidUnarchiveOperationException reason:@"Only Keyed-Unarchivers are supported" userInfo:nil]);
                });
            });
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
            box = [[JKVTypeContainer alloc] initWithPresetData];
            otherBox = [[JKVTypeContainer alloc] initWithPresetData];
        });

        it(@"should support various types for encoding", ^{
            box should equal(otherBox);
        });

        describe(@"NSCoding", ^{
            __block JKVTypeContainer *deserializedBox;

            beforeEach(^{
                NSMutableData *data = [NSMutableData data];
                NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
                [archiver encodeObject:box];
                [archiver finishEncoding];
                NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
                deserializedBox = [unarchiver decodeObject];
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
            restrictedObject = [[JKVRestrictedObject alloc] initWithPresetData];
            restrictedObject.lastReader = lastReader = [NSObject new];
            restrictedObject.lastWriter = lastWriter = [NSObject new];
        });

        describe(@"equality", ^{
            __block JKVRestrictedObject *otherObject;
            beforeEach(^{
                otherObject = [[JKVRestrictedObject alloc] initWithPresetData];
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
