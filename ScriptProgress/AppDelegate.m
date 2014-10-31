//
//  AppDelegate.m
//  ScriptProgress
//
//  Created by Joris Kluivers on 31/10/14.
//  Copyright (c) 2014 Joris Kluivers. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSProgressIndicator *progressBar;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction) selectScript:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    
    [panel setAllowedFileTypes:@[@"scpt"]];
    
    [panel setParentWindow:self.window];
    
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        NSURL *url = panel.URL;
        NSLog(@"URL: %@", url);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self startUserTaskWithURL:url];
        });
    }];
}

- (void) startUserTaskWithURL:(NSURL *)scriptURL
{
    NSError *error = nil;
    NSUserScriptTask *task = [[NSUserScriptTask alloc] initWithURL:scriptURL error:&error];
    if (!task) {
        NSLog(@"Failed to create task: %@", error);
        return;
    }
    
    [NSProgress addSubscriberForFileURL:scriptURL withPublishingHandler:^NSProgressUnpublishingHandler(NSProgress *progress) {
        self.progress = progress;
        
        return nil;
    }];
    
    [task executeWithCompletionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"Script error: %@", error);
        } else {
            NSLog(@"Script succeeded");
        }
    }];
}

@end
