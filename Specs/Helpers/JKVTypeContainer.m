#import "JKVTypeContainer.h"

@implementation JKVTypeContainer

- (id)init
{
    self = [super init];
    if (self) {
        self.obj = @"Hello World";
        self.integer = 2;
        self.boolean = YES;
        self.floatValue = 2.5;
        self.doubleValue = 5.0;
        self.int16Value = 16;
        self.int32Value = 32;
        self.int64Value = 64;
        self.point = CGPointMake(2, 3);
        self.size = CGSizeMake(3, 4);
        self.rect = CGRectMake(5, 6, 7, 8);
        self.affineTransform = CGAffineTransformMake(1, 2, 3, 4, 5, 6);
        self.edgeInsets = UIEdgeInsetsMake(1, 2, 3, 4);
        self.offset = UIOffsetMake(5, 10);
    }
    return self;
}

@end
