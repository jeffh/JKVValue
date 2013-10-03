#import "JKVTypeContainer.h"

/*

 @property (nonatomic, strong) NSString *obj;
 @property (nonatomic, assign) NSInteger integer;
 @property (nonatomic, assign, getter=isMarried) BOOL boolean;
 @property (atomic, assign) CGFloat floatValue;
 @property (nonatomic, assign) double doubleValue;
 @property (nonatomic, assign) int32_t int32Value;
 @property (nonatomic, assign) int64_t int64Value;
 @property (nonatomic, assign) CGPoint point;
 @property (nonatomic, assign) CGRect rect;
 @property (nonatomic, assign) CGSize size;
 @property (nonatomic, assign) NSRange range;
 @property (nonatomic, assign) CGAffineTransform affineTransform;
 @property (nonatomic, assign) UIEdgeInsets edgeInsets;
 @property (nonatomic, assign) UIOffset offset;
 */
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
        self.int32Value = 32;
        self.int64Value = 64;
        self.point = CGPointMake(2, 3);
        self.size = CGSizeMake(3, 4);
        self.rect = CGRectMake(5, 6, 7, 8);
        self.range = NSMakeRange(2, 5);
        self.affineTransform = CGAffineTransformMake(1, 2, 3, 4, 5, 6);
        self.edgeInsets = UIEdgeInsetsMake(1, 2, 3, 4);
        self.offset = UIOffsetMake(5, 10);
    }
    return self;
}

@end
