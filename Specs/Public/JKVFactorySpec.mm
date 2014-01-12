#import "JKVFactory.h"
#import "JKVPersonFactory.h"
#import "JKVPerson.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(JKVFactorySpec)

describe(@"JKVFactory", ^{
    __block JKVFactory *factory;
    __block JKVPerson *person;

    void (^itShouldBeAPersonObjectWithNonNilValues)() = ^{
        context(@"(behaves like a person object with non-nil values)", ^{
            it(@"should return an instance of the given object", ^{
                person should be_instance_of([JKVPerson class]);
            });

            it(@"should generate a person with non-nil values for strong properties", ^{
                person.firstName should equal(@"firstName");
                person.lastName should_not be_nil;
                person.age should equal(1);
                person.married should be_truthy;
                person.height should equal(1.0);
                person.child should_not be_nil;
            });

            it(@"should leave weak properties nil", ^{
                person.parent should be_nil;
            });
        });
    };

    void (^itShouldBehaveLikeAPersonObjectWithModifiedDefaults)() = ^{
        context(@"(behaves like a person object with modified defaults)", ^{
            it(@"should return an instance of the given object", ^{
                person should be_instance_of([JKVPerson class]);
            });

            it(@"should use the provided values, falling back to defaults", ^{
                person.firstName should equal(@"John");
                person.age should equal(42);

                person.lastName should equal(@"lastName");
                person.married should be_truthy;
                person.height should equal(1.0);
                person.child should be_nil;
                person.parent should be_nil;
            });
        });
    };

    void (^itShouldBehaveLikeAPersonFactoryInstance)() = ^{
        context(@"(behaves like a person factory instance)", ^{
            describe(@"building an object", ^{
                beforeEach(^{
                    person = [factory object];
                });

                itShouldBeAPersonObjectWithNonNilValues();
            });

            describe(@"building an object with custom values factory", ^{
                beforeEach(^{
                    person = [[factory factoryWithProperties:@{@"firstName": @"John",
                                                               @"age": @42,
                                                               @"child": [NSNull null]}] object];
                });

                itShouldBehaveLikeAPersonObjectWithModifiedDefaults();
            });

            describe(@"building an object with custom values", ^{
                beforeEach(^{
                    person = [factory objectWithProperties:@{@"firstName": @"John",
                                                             @"age": @42,
                                                             @"child": [NSNull null]}];
                });

                itShouldBehaveLikeAPersonObjectWithModifiedDefaults();
            });

            describe(@"building an object with nested custom factories", ^{
                beforeEach(^{
                    person = [[factory
                               factoryWithProperties:@{@"firstName": @"John",
                                                       @"age": @42,
                                                       @"child": [NSNull null]}]
                              objectWithProperties:@{@"firstName": @"James"}];
                });

                it(@"should have the latest factory properties", ^{
                    person.firstName should equal(@"James");
                    person.age should equal(42);
                });
            });

        });
    };

    describe(@"generic factory", ^{
        beforeEach(^{
            factory = [JKVFactory factoryForClass:[JKVPerson class]];
        });

        itShouldBehaveLikeAPersonFactoryInstance();

        describe(@"+buildObject", ^{
            it(@"should raise an exception", ^{
                ^{ [JKVFactory buildObject]; } should raise_exception;
            });
        });

        describe(@"+buildObjectWithProperties", ^{
            it(@"should raise an exception", ^{
                ^{ [JKVFactory buildObjectWithProperties:@{}]; } should raise_exception;
            });
        });
    });

    describe(@"customized factory", ^{
        beforeEach(^{
            factory = [JKVPersonFactory new];
        });

        itShouldBehaveLikeAPersonFactoryInstance();

        describe(@"building an object without a factory instance", ^{
            beforeEach(^{
                person = [JKVPersonFactory buildObject];
            });

            itShouldBeAPersonObjectWithNonNilValues();
        });

        describe(@"building a custom object without a factory instance", ^{
            beforeEach(^{
                person = [JKVPersonFactory buildObjectWithProperties:@{@"firstName": @"John", @"age": @42, @"child": [NSNull null]}];
            });

            itShouldBehaveLikeAPersonObjectWithModifiedDefaults();
        });
    });
});

SPEC_END
