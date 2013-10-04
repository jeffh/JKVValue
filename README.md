JKVValue
========

Simple Value Objects for Objective-C.

Value Objects are great for well-designed programs!

They're great for documenting data from an API or your internal
application data, but are terrible to maintain.

When you add (or change) a property, you usually have to do:

- Add the `@property`
- Add property to the constructor (optional)
- Add it to `-[mutableCopyWithZone:]` if it supports NSMutableCopying
- Add it to `-[copyWithZone:]` if it supports NSCopying
- Add it to `-[isEqual:]` to support equality for that modified property
- Add it to `-[hash:]` to support hashing
- Add it to `-[initWithCoder:]` to support deserialization
- Add it to `-[encodeWithCoder:]` to support serialization (NSCoding)

And forget about doing the right thing, and having both mutable and immutable
versions of value objects like Apple's Foundation data structures...
until now!

JKVValue simplifies your work to only setting the @property and constructor!

Installation
------------

Currently installation is by git submodule add this project and adding it
to your XCodeProject (for now).

Add the JKVValue static library for your dependencies or use the source directly.

Usage
-----

There are two classes you can subclass, JKVValue and JKVMutableValue.
Any properties you declare will automatically be detected and have their
corresponding methods in NSCopying, NSMutableCopying, NSCoding, NSObject
protocols supported automatically:

    #import "JKVValue.h"

    @interface MyPerson : JKVValue
    @property (strong, nonatomic, readonly) NSString *firstName;
    @property (strong, nonatomic, readonly) NSString *lastName;

    - (id)initWithFirstName:(NSString *)firstName lastName:(NSString *)lastName;
    @end

    @implementation MyPerson
    - (id)initWithFirstName:(NSString *)firstName lastName:(NSString *)lastName
    {
        if (self = [super init]) {
            _firstName = firstName;
            _lastName = lastName;
        }
        return self;
    }
    @end

That's it! All the cool methods are supported now:

    MyPerson *person = [[MyPerson alloc] initWithFirstName:@"John" lastName:"Doe"];

    // Since copy returns same instance here, since it assumes immutability.
    MyPerson *cloned = [person copy];

    // this creates a MyPerson copy, but still read only. We'll see how to change that later
    MyPerson *mutableClone = [person mutableCopy];

    [person isEqual:mutableClone]; // => true
    [NSSet setWithArray:@[person, mutableClone]]; // => set of 1 person

    // get a nice description for free
    [person description]; // => <MyPerson 0xdeadbeef firstName=John lastName=Doe>

We want -[mutableCopy] to use a different, mutable class. Not a problem!

    @class MyMutablePerson;

    // using a category is purely optional
    @interface MyPerson (MutableCopying)
    @end

    @implementation MyPerson (MutableCopying)

    - (Class)JKV_mutableClass
    {
        return [MyMutablePerson class];
    }

    @end

    @interface MyMutablePerson : MyPerson
    @property (strong, nonatomic, readwrite) NSString *firstName;
    @property (strong, nonatomic, readwrite) NSString *lastName;
    @end

    @implementation MyMutablePerson
    // we need to explicitly synthesize to generate setters.
    @synthesize firstName;
    @synthesize lastName;

    - (BOOL)JKV_isMutable
    {
        return YES; // to hint to JKVValue that this class is mutable.
    }

    - (Class)JKV_immutableClass
    {
        return [MyPerson class];
    }

    @end

Now you can switch between mutable and immutable variants like NSArray or NSDictionary:

    // assuming MyPerson *person from above
    MyMutablePerson *mutablePerson = [person mutableCopy];
    MyPerson *immutablePerson = [mutablePerson copy];

If you prefer to use use only mutable objects, `JKVMutableValue` is provided as a
convinence, it simply overrides JKVValue's `-[JVK_isMutable]` to be `YES` instead of its
default of `NO`.

It's worth noting that copy/mutableCopy is called on all properties if they support
NSCopying or NSMutableCopying correspondingly.

