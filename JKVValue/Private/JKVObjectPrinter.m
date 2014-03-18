#import "JKVObjectPrinter.h"

NSComparisonResult (^JKVGenericSorter)(id, id) = ^NSComparisonResult(id obj1, id obj2){
    if ((__bridge void *)obj1 > (__bridge void *)obj2) {
        return NSOrderedAscending;
    } else if (obj1 == obj2) {
        return NSOrderedSame;
    } else {
        return NSOrderedDescending;
    }
};

@implementation JKVObjectPrinter

+ (NSString *)stringForObject:(id)object
{
    static JKVObjectPrinter *JKVObjectPrinterInstance__;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        JKVObjectPrinterInstance__ = [self new];
    });
    return [JKVObjectPrinterInstance__ stringForObject:object];
}

- (NSString *)stringForObject:(id)object
{
    if ([object isKindOfClass:[NSDictionary class]]) {
        return [self stringForDictionary:object];
    } else if ([object isKindOfClass:[NSArray class]]) {
        return [self stringForArray:object];
    } else if ([object isKindOfClass:[NSSet class]]) {
        return [self stringForSet:object];
    } else if ([object isKindOfClass:[NSNull class]]) {
        return @"[NSNull null]";
    } else if ([object isKindOfClass:[NSURL class]]) {
        return [NSString stringWithFormat:@"[NSURL URLWithString:%@]",
                [self stringForObject:[object absoluteString]]];
    } else if ([object isKindOfClass:[NSString class]]) {
        return [NSString stringWithFormat:@"@\"%@\"",
                [object stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]];
    } else if (!object) {
        return @"nil";
    }
    return [object description];
}

#pragma mark - Private Stringifiers

- (NSString *)stringForDictionary:(NSDictionary *)dictionary
{
    NSMutableString *output = [NSMutableString string];
    [output appendString:@"@{"];
    NSMutableArray *itemStrings = [NSMutableArray arrayWithCapacity:[dictionary count]];
    BOOL prefixLinePrefix = NO;

    // we sort here for order consistency in tests. Maybe we can have a better generic comparison.
    NSArray *keys = [[dictionary allKeys] sortedArrayUsingComparator:JKVGenericSorter];

    for (id key in keys) {
        id value = [dictionary objectForKey:key];
        NSString *keyString = [self stringWithMultilineString:[self stringForObject:key]
                                               withLinePrefix:@"  "
                                              prefixFirstLine:prefixLinePrefix];
        NSString *string = [NSString stringWithFormat:@"%@: %@", keyString, [self stringForObject:value]];
        NSString *prefixString = [self stringByPaddingString:@"" toLength:keyString.length + 2 withString:@" "];
        [itemStrings addObject:[self stringWithMultilineString:string withLinePrefix:prefixString prefixFirstLine:NO]];
        prefixLinePrefix = YES;
    }
    [output appendString:[itemStrings componentsJoinedByString:@",\n"]];
    [output appendString:@"}"];
    return output;
}

- (NSString *)stringForArray:(NSArray *)array
{
    NSMutableString *output = [NSMutableString string];
    [output appendString:@"@["];
    NSMutableArray *itemStrings = [NSMutableArray arrayWithCapacity:[array count]];
    BOOL prefixLinePrefix = NO;
    for (id item in array) {
        NSString *string = [NSString stringWithFormat:@"%@", [self stringForObject:item]];
        [itemStrings addObject:[self stringWithMultilineString:string withLinePrefix:@"  " prefixFirstLine:prefixLinePrefix]];
        prefixLinePrefix = YES;
    }
    [output appendString:[itemStrings componentsJoinedByString:@",\n"]];
    [output appendString:@"]"];
    return output;
}

- (NSString *)stringForSet:(NSSet *)set
{
    NSMutableString *output = [NSMutableString string];
    NSString *prefix = @"[NSSet setWithArray:";
    [output appendString:prefix];

    // we sort here for order consistency in tests. Maybe we can have a better generic comparison.
    NSString *arrayString = [self stringForArray:[[set allObjects] sortedArrayUsingComparator:JKVGenericSorter]];
    [output appendString:[self stringWithMultilineString:arrayString
                                          withLinePrefix:[self stringByPaddingString:@"" toLength:prefix.length withString:@" "]
                                         prefixFirstLine:NO]];
    [output appendString:@"]"];
    return output;
}

#pragma mark - Private Helpers

- (NSString *)stringByPaddingString:(NSString *)string toLength:(NSInteger)length withString:(NSString *)padString
{
    NSMutableString *output = [NSMutableString string];
    while (output.length + string.length < length) {
        [output appendString:padString];
    }
    [output appendString:string];
    return output;
}

- (NSString *)stringWithMultilineString:(NSString *)content withLinePrefix:(NSString *)linePrefix prefixFirstLine:(BOOL)prefixFirstLine
{
    NSArray *components = [content componentsSeparatedByString:@"\n"];
    NSString *prefix = [NSString stringWithFormat:@"\n%@", linePrefix];
    if (prefixFirstLine) {
        return [linePrefix stringByAppendingString:[components componentsJoinedByString:prefix]];
    } else {
        return [components componentsJoinedByString:prefix];
    }
}


@end
