#import <Cocoa/Cocoa.h>

@interface TodoItemCellView : NSTableCellView

@property (nonatomic, strong) NSButton *checkbox;
@property (nonatomic, strong) NSTextView *textField;
@property (nonatomic, strong) NSButton *deleteButton;

@end
