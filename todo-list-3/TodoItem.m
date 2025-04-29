#import "TodoItem.h"

@implementation TodoItem

- (instancetype)initWithText:(NSAttributedString *)text {
    self = [super init];
    if (self) {
        _text = [text copy];
        _completed = NO;
        _creationDate = [NSDate date];
        _completionDate = nil;
    }
    return self;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _text = [coder decodeObjectForKey:@"text"];
        _completed = [coder decodeBoolForKey:@"completed"];
        _creationDate = [coder decodeObjectForKey:@"creationDate"];
        _completionDate = [coder decodeObjectForKey:@"completionDate"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.text forKey:@"text"];
    [coder encodeBool:self.completed forKey:@"completed"];
    [coder encodeObject:self.creationDate forKey:@"creationDate"];
    [coder encodeObject:self.completionDate forKey:@"completionDate"];
}

@end
