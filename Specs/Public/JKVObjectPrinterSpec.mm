#import "JKVObjectPrinter.h"
#import "JKVPerson.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(JKVObjectPrinterSpec)

describe(@"JKVObjectPrinter", ^{
    __block NSArray *array;
    __block NSDictionary *dictionary;
    __block NSSet *set;

    beforeEach(^{
        array = @[[[JKVPerson alloc] initWithFixtureData]];
        dictionary = @{@"key": [[JKVPerson alloc] initWithFixtureData]};
        set = [NSSet setWithArray:@[[[JKVPerson alloc] initWithFixtureData]]];
    });

    context(@"without swizzling", ^{
        beforeEach(^{
            [JKVObjectPrinter unswizzleContainers];
        });

        it(@"should display the default 'escaped' description", ^{
            [array description] should contain(@"\\n");
            [dictionary description] should contain(@"\\n");
            [set description] should contain(@"{(");
        });
    });

    context(@"with swizzling", ^{
        beforeEach(^{
            [JKVObjectPrinter swizzleContainers];
        });

        afterEach(^{
            [JKVObjectPrinter unswizzleContainers];
        });

        it(@"should display the custom description", ^{
            [array description] should_not contain(@"\\n");
            [dictionary description] should_not contain(@"\\n");
            [set description] should_not contain(@"{(");
        });
    });
});

SPEC_END
