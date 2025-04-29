// TodoListViewController.m
#import "TodoListViewController.h"
#import "TodoItem.h"
#import "TodoItemCellView.h"

@interface TodoListViewController ()

@property (nonatomic, strong) NSMutableArray<TodoItem *> *todoItems;
@property (nonatomic, strong) NSTableView *tableView;
@property (nonatomic, strong) NSScrollView *scrollView;
@property (nonatomic, strong) NSView *inputContainerView;
@property (nonatomic, strong) NSTextView *inputTextView;
@property (nonatomic, strong) NSButton *addButton;
@property (nonatomic, strong) NSButton *boldButton;
@property (nonatomic, strong) NSButton *italicButton;
@property (nonatomic, strong) NSButton *underlineButton;
@property (nonatomic, strong) NSButton *strikethroughButton;
@property (nonatomic, strong) NSTextField *titleLabel;
@property (nonatomic, strong) NSView *toolbarView;

@end

@implementation TodoListViewController

- (void)loadView {
    self.view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 800, 600)];
    [self.view setWantsLayer:YES];
    [self.view.layer setBackgroundColor:[[NSColor windowBackgroundColor] CGColor]];
    
    [self setupTitleLabel];
    [self setupToolbar];
    [self setupTableView];
    [self setupInputView];
    
    [self loadTodoItems];
}

- (void)setupTitleLabel {
    self.titleLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20, self.view.frame.size.height - 50, self.view.frame.size.width - 40, 30)];
    [self.titleLabel setStringValue:@"Rich Text Todo List"];
    [self.titleLabel setFont:[NSFont systemFontOfSize:20 weight:NSFontWeightBold]];
    [self.titleLabel setBezeled:NO];
    [self.titleLabel setDrawsBackground:NO];
    [self.titleLabel setEditable:NO];
    [self.titleLabel setSelectable:NO];
    [self.view addSubview:self.titleLabel];
}

- (void)setupToolbar {
    self.toolbarView = [[NSView alloc] initWithFrame:NSMakeRect(20, self.view.frame.size.height - 90, self.view.frame.size.width - 40, 30)];
    [self.toolbarView setWantsLayer:YES];
    [self.toolbarView.layer setBackgroundColor:[[NSColor lightGrayColor] CGColor]];
    [self.toolbarView.layer setCornerRadius:4.0];
    
    CGFloat buttonWidth = 30;
    CGFloat buttonSpacing = 8;
    CGFloat currentX = 10;
    
    // Bold button
    self.boldButton = [self createToolbarButtonWithFrame:NSMakeRect(currentX, 3, buttonWidth, 24) title:@"B"];
    [self.boldButton setFont:[NSFont boldSystemFontOfSize:14]];
    [self.boldButton setAction:@selector(toggleBold:)];
    [self.toolbarView addSubview:self.boldButton];
    currentX += buttonWidth + buttonSpacing;
    
    // Italic button
    self.italicButton = [self createToolbarButtonWithFrame:NSMakeRect(currentX, 3, buttonWidth, 24) title:@"I"];
    [self.italicButton setFont:[NSFont systemFontOfSize:14]];
    [self.italicButton setAttributedTitle:[self createItalicAttributedString:@"I"]];
    [self.italicButton setAction:@selector(toggleItalic:)];
    [self.toolbarView addSubview:self.italicButton];
    currentX += buttonWidth + buttonSpacing;
    
    // Underline button
    self.underlineButton = [self createToolbarButtonWithFrame:NSMakeRect(currentX, 3, buttonWidth, 24) title:@"U"];
    [self.underlineButton setFont:[NSFont systemFontOfSize:14]];
    [self.underlineButton setAttributedTitle:[self createUnderlineAttributedString:@"U"]];
    [self.underlineButton setAction:@selector(toggleUnderline:)];
    [self.toolbarView addSubview:self.underlineButton];
    currentX += buttonWidth + buttonSpacing;
    
    // Strikethrough button
    self.strikethroughButton = [self createToolbarButtonWithFrame:NSMakeRect(currentX, 3, buttonWidth, 24) title:@"S"];
    [self.strikethroughButton setFont:[NSFont systemFontOfSize:14]];
    [self.strikethroughButton setAttributedTitle:[self createStrikethroughAttributedString:@"S"]];
    [self.strikethroughButton setAction:@selector(toggleStrikethrough:)];
    [self.toolbarView addSubview:self.strikethroughButton];
    
    [self.view addSubview:self.toolbarView];
}

- (NSButton *)createToolbarButtonWithFrame:(NSRect)frame title:(NSString *)title {
    NSButton *button = [[NSButton alloc] initWithFrame:frame];
    [button setTitle:title];
    [button setBezelStyle:NSBezelStyleRounded];
    [button setTarget:self];
    return button;
}

- (void)setupTableView {
    // Create scroll view for the table
    self.scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(20, 120, self.view.frame.size.width - 40, self.view.frame.size.height - 220)];
    [self.scrollView setBorderType:NSBezelBorder];
    [self.scrollView setHasVerticalScroller:YES];
    [self.scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    // Create the table view
    self.tableView = [[NSTableView alloc] initWithFrame:NSMakeRect(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    
    // Create and add column
    NSTableColumn *taskColumn = [[NSTableColumn alloc] initWithIdentifier:@"TaskColumn"];
    [taskColumn setWidth:self.scrollView.frame.size.width - 20];
    [taskColumn setTitle:@"Task"];
    [self.tableView addTableColumn:taskColumn];
    
    // Configure table view
    [self.tableView setHeaderView:nil]; // Hide the header
    [self.tableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleSourceList];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setRowHeight:50];
    [self.tableView setGridStyleMask:NSTableViewGridNone];
    
    // Add table view to scroll view
    [self.scrollView setDocumentView:self.tableView];
    [self.view addSubview:self.scrollView];
    
    // Initialize todo items array
    self.todoItems = [NSMutableArray array];
}

- (void)setupInputView {
    // Container for input controls
    self.inputContainerView = [[NSView alloc] initWithFrame:NSMakeRect(20, 20, self.view.frame.size.width - 40, 80)];
    [self.inputContainerView setWantsLayer:YES];
    [self.inputContainerView.layer setBackgroundColor:[[NSColor colorWithCalibratedWhite:0.95 alpha:1.0] CGColor]];
    [self.inputContainerView.layer setCornerRadius:8.0];
    
    // Text view for input
    NSScrollView *inputScrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(10, 10, self.inputContainerView.frame.size.width - 110, 60)];
    [inputScrollView setBorderType:NSBezelBorder];
    [inputScrollView setHasVerticalScroller:YES];
    [inputScrollView setAutoresizingMask:NSViewWidthSizable];
    
    self.inputTextView = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, inputScrollView.frame.size.width, inputScrollView.frame.size.height)];
    [self.inputTextView setMinSize:NSMakeSize(0, inputScrollView.frame.size.height)];
    [self.inputTextView setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
    [self.inputTextView setVerticallyResizable:YES];
    [self.inputTextView setHorizontallyResizable:NO];
    [self.inputTextView setAutoresizingMask:NSViewWidthSizable];
    [self.inputTextView setDelegate:self];
    [self.inputTextView setAllowsUndo:YES];
    [self.inputTextView setRichText:YES];
    [self.inputTextView setImportsGraphics:NO];
    
    // Configure input text view appearance
    [self.inputTextView setFont:[NSFont systemFontOfSize:14]];
    [self.inputTextView setTextColor:[NSColor blackColor]];
    [self.inputTextView setBackgroundColor:[NSColor whiteColor]];
    
    [inputScrollView setDocumentView:self.inputTextView];
    [self.inputContainerView addSubview:inputScrollView];
    
    // Add button
    self.addButton = [[NSButton alloc] initWithFrame:NSMakeRect(self.inputContainerView.frame.size.width - 90, 25, 80, 30)];
    [self.addButton setTitle:@"Add Task"];
    [self.addButton setBezelStyle:NSBezelStyleRounded];
    [self.addButton setTarget:self];
    [self.addButton setAction:@selector(addTodoItem:)];
    [self.addButton setKeyEquivalent:@"\r"]; // Enter key
    [self.inputContainerView addSubview:self.addButton];
    
    [self.view addSubview:self.inputContainerView];
}

#pragma mark - Actions

- (void)addTodoItem:(id)sender {
    // Get the attributed text from the input view
    NSAttributedString *text = [self.inputTextView.textStorage copy];
    
    // Check if there's actual text content
    if (text.length > 0) {
        // Create a new todo item
        TodoItem *newItem = [[TodoItem alloc] initWithText:text];
        
        // Add to the array and refresh table
        [self.todoItems addObject:newItem];
        [self.tableView reloadData];
        
        // Clear the input text view
        [self.inputTextView.textStorage deleteCharactersInRange:NSMakeRange(0, self.inputTextView.textStorage.length)];
        
        // Save the updated list
        [self saveTodoItems];
    }
}

- (void)toggleItemCompletion:(NSButton *)sender {
    NSInteger row = [self.tableView rowForView:sender];
    if (row >= 0 && row < self.todoItems.count) {
        TodoItem *item = self.todoItems[row];
        item.completed = (sender.state == NSControlStateValueOn);
        
        // Update completion date
        if (item.completed) {
            item.completionDate = [NSDate date];
        } else {
            item.completionDate = nil;
        }
        
        // Apply strikethrough to the item text if completed
        [self updateCellViewForRow:row];
        
        [self saveTodoItems];
    }
}

- (void)updateCellViewForRow:(NSInteger)row {
    TodoItemCellView *cellView = [self.tableView viewAtColumn:0 row:row makeIfNecessary:NO];
    if (cellView) {
        TodoItem *item = self.todoItems[row];
        
        // Create a mutable copy of the text to potentially add strikethrough
        NSMutableAttributedString *displayText = [[NSMutableAttributedString alloc] initWithAttributedString:item.text];
        
        if (item.completed) {
            // Add strikethrough to the entire text if the item is completed
            [displayText addAttribute:NSStrikethroughStyleAttributeName
                                value:@(NSUnderlineStyleSingle)
                                range:NSMakeRange(0, displayText.length)];
        }
        
        [cellView.textField.textStorage setAttributedString:displayText];
    }
}

- (void)deleteItem:(id)sender {
    NSInteger row = [self.tableView rowForView:sender];
    if (row >= 0 && row < self.todoItems.count) {
        [self.todoItems removeObjectAtIndex:row];
        [self.tableView reloadData];
        [self saveTodoItems];
    }
}

#pragma mark - Text Formatting Actions

- (void)toggleBold:(id)sender {
    [self applyTextAttribute:NSFontAttributeName withAction:^(NSRange selectedRange, NSMutableAttributedString *textStorage) {
        [textStorage enumerateAttribute:NSFontAttributeName inRange:selectedRange options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
            NSFont *currentFont = value ? value : [NSFont systemFontOfSize:14];
            NSFontManager *fontManager = [NSFontManager sharedFontManager];
            
            // Check if the font is already bold
            NSFontTraitMask traits = [fontManager traitsOfFont:currentFont];
            BOOL isBold = (traits & NSBoldFontMask) != 0;
            
            // Toggle bold
            NSFont *newFont;
            if (isBold) {
                newFont = [fontManager convertFont:currentFont toNotHaveTrait:NSBoldFontMask];
            } else {
                newFont = [fontManager convertFont:currentFont toHaveTrait:NSBoldFontMask];
            }
            
            [textStorage addAttribute:NSFontAttributeName value:newFont range:range];
        }];
    }];
}

- (void)toggleItalic:(id)sender {
    [self applyTextAttribute:NSFontAttributeName withAction:^(NSRange selectedRange, NSMutableAttributedString *textStorage) {
        [textStorage enumerateAttribute:NSFontAttributeName inRange:selectedRange options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
            NSFont *currentFont = value ? value : [NSFont systemFontOfSize:14];
            NSFontManager *fontManager = [NSFontManager sharedFontManager];
            
            // Check if the font is already italic
            NSFontTraitMask traits = [fontManager traitsOfFont:currentFont];
            BOOL isItalic = (traits & NSItalicFontMask) != 0;
            
            // Toggle italic
            NSFont *newFont;
            if (isItalic) {
                newFont = [fontManager convertFont:currentFont toNotHaveTrait:NSItalicFontMask];
            } else {
                newFont = [fontManager convertFont:currentFont toHaveTrait:NSItalicFontMask];
            }
            
            [textStorage addAttribute:NSFontAttributeName value:newFont range:range];
        }];
    }];
}

- (void)toggleUnderline:(id)sender {
    [self applyTextAttribute:NSUnderlineStyleAttributeName withAction:^(NSRange selectedRange, NSMutableAttributedString *textStorage) {
        // Check if the selected range already has underline
        __block BOOL hasUnderline = NO;
        [textStorage enumerateAttribute:NSUnderlineStyleAttributeName inRange:selectedRange options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
            if (value && [value integerValue] != NSUnderlineStyleNone) {
                hasUnderline = YES;
                *stop = YES;
            }
        }];
        
        // Toggle underline
        if (hasUnderline) {
            [textStorage removeAttribute:NSUnderlineStyleAttributeName range:selectedRange];
        } else {
            [textStorage addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:selectedRange];
        }
    }];
}

- (void)toggleStrikethrough:(id)sender {
    [self applyTextAttribute:NSStrikethroughStyleAttributeName withAction:^(NSRange selectedRange, NSMutableAttributedString *textStorage) {
        // Check if the selected range already has strikethrough
        __block BOOL hasStrikethrough = NO;
        [textStorage enumerateAttribute:NSStrikethroughStyleAttributeName inRange:selectedRange options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
            if (value && [value integerValue] != NSUnderlineStyleNone) {
                hasStrikethrough = YES;
                *stop = YES;
            }
        }];
        
        // Toggle strikethrough
        if (hasStrikethrough) {
            [textStorage removeAttribute:NSStrikethroughStyleAttributeName range:selectedRange];
        } else {
            [textStorage addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleSingle) range:selectedRange];
        }
    }];
}

- (void)applyTextAttribute:(NSAttributedStringKey)attributeName withAction:(void (^)(NSRange selectedRange, NSMutableAttributedString *textStorage))action {
    NSTextView *textView = self.inputTextView;
    NSRange selectedRange = textView.selectedRange;
    
    // If no text is selected, do nothing
    if (selectedRange.length == 0) {
        return;
    }
    
    // Apply the formatting action
    if (action) {
        action(selectedRange, textView.textStorage);
    }
    
    // Maintain the selection
    textView.selectedRange = selectedRange;
}

#pragma mark - Helper Methods

- (NSAttributedString *)createItalicAttributedString:(NSString *)string {
    NSFont *italicFont = [[NSFontManager sharedFontManager] convertFont:[NSFont systemFontOfSize:14] toHaveTrait:NSItalicFontMask];
    NSDictionary *attributes = @{NSFontAttributeName: italicFont};
    return [[NSAttributedString alloc] initWithString:string attributes:attributes];
}

- (NSAttributedString *)createUnderlineAttributedString:(NSString *)string {
    NSDictionary *attributes = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    return [[NSAttributedString alloc] initWithString:string attributes:attributes];
}

- (NSAttributedString *)createStrikethroughAttributedString:(NSString *)string {
    NSDictionary *attributes = @{NSStrikethroughStyleAttributeName: @(NSUnderlineStyleSingle)};
    return [[NSAttributedString alloc] initWithString:string attributes:attributes];
}

#pragma mark - Persistence

- (void)saveTodoItems {
    NSString *path = [self todoItemsFilePath];
    BOOL success = [NSKeyedArchiver archiveRootObject:self.todoItems toFile:path];
    if (!success) {
        NSLog(@"Failed to save todo items to file: %@", path);
    }
}

- (void)loadTodoItems {
    NSString *path = [self todoItemsFilePath];
    NSArray *savedItems = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    
    if (savedItems) {
        self.todoItems = [savedItems mutableCopy];
        [self.tableView reloadData];
    }
}

- (NSString *)todoItemsFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    return [documentsDirectory stringByAppendingPathComponent:@"TodoItems.data"];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.todoItems.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    // Create or reuse a cell view
    TodoItemCellView *cellView = [tableView makeViewWithIdentifier:@"TodoItemCell" owner:self];
    
    if (!cellView) {
        // Create a new cell view
        cellView = [[TodoItemCellView alloc] initWithFrame:NSMakeRect(0, 0, tableView.frame.size.width, 50)];
        cellView.identifier = @"TodoItemCell";
        
        // Create and configure checkbox
        NSButton *checkbox = [[NSButton alloc] initWithFrame:NSMakeRect(10, 15, 20, 20)];
        [checkbox setButtonType:NSButtonTypeSwitch];
        [checkbox setTitle:@""];
        [checkbox setTarget:self];
        [checkbox setAction:@selector(toggleItemCompletion:)];
        cellView.checkbox = checkbox;
        [cellView addSubview:checkbox];
        
        // Create and configure text field
        NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(40, 5, tableView.frame.size.width - 100, 40)];
        [scrollView setBorderType:NSNoBorder];
        [scrollView setHasVerticalScroller:NO];
        [scrollView setAutoresizingMask:NSViewWidthSizable];
        
        NSTextView *textView = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, scrollView.frame.size.width, scrollView.frame.size.height)];
        [textView setMinSize:NSMakeSize(0, scrollView.frame.size.height)];
        [textView setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
        [textView setVerticallyResizable:YES];
        [textView setHorizontallyResizable:NO];
        [textView setAutoresizingMask:NSViewWidthSizable];
        [textView setEditable:NO];
        [textView setSelectable:YES];
        [textView setRichText:YES];
        [textView setDrawsBackground:NO];
        
        [scrollView setDocumentView:textView];
        cellView.textField = textView;
        [cellView addSubview:scrollView];
        
        // Create and configure delete button
        NSButton *deleteButton = [[NSButton alloc] initWithFrame:NSMakeRect(tableView.frame.size.width - 50, 15, 40, 20)];
        [deleteButton setBezelStyle:NSBezelStyleRounded];
        [deleteButton setTitle:@"×"];
        [deleteButton setTarget:self];
        [deleteButton setAction:@selector(deleteItem:)];
        [deleteButton setFont:[NSFont boldSystemFontOfSize:14]];
        cellView.deleteButton = deleteButton;
        [cellView addSubview:deleteButton];
    }
    
    // Configure cell view with todo item data
    TodoItem *item = self.todoItems[row];
    cellView.checkbox.state = item.completed ? NSControlStateValueOn : NSControlStateValueOff;
    
    // Create a mutable copy of the text to potentially add strikethrough
    NSMutableAttributedString *displayText = [[NSMutableAttributedString alloc] initWithAttributedString:item.text];
    
    if (item.completed) {
        // Add strikethrough to the entire text if the item is completed
        [displayText addAttribute:NSStrikethroughStyleAttributeName
                            value:@(NSUnderlineStyleSingle)
                            range:NSMakeRange(0, displayText.length)];
    }
    
    [cellView.textField.textStorage setAttributedString:displayText];
    
    return cellView;
}
@end
