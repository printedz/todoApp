#import "AppDelegate.h"
#import "TodoListViewController.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    // Create the main window
    self.window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 800, 600)
                                              styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable
                                                backing:NSBackingStoreBuffered
                                                  defer:NO];
    [self.window setTitle:@"Rich Text Todo App"];
    [self.window setMinSize:NSMakeSize(400, 300)];
    [self.window center];
    
    // Initialize the view controller
    TodoListViewController *todoListVC = [[TodoListViewController alloc] init];
    
    // Set the content view and make the window visible
    self.window.contentView = todoListVC.view;
    [self.window makeKeyAndOrderFront:nil];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

@end
