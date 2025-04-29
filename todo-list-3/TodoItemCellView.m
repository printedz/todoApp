#import "TodoItemCellView.h"

@implementation TodoItemCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Draw a subtle separator at the bottom of the cell
    [[NSColor colorWithCalibratedWhite:0.9 alpha:1.0] set];
    NSRectFill(NSMakeRect(0, 0, self.frame.size.width, 1));
}

@end
