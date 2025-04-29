#import <Foundation/Foundation.h>

@interface TodoItem : NSObject <NSCoding>

@property (nonatomic, strong) NSAttributedString *text;
@property (nonatomic, assign) BOOL completed;
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, strong) NSDate *completionDate;

- (instancetype)initWithText:(NSAttributedString *)text;

@end
