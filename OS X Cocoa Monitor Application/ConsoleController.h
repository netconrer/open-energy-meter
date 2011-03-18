//
//  KLConsoleWindow.h
//  PropStream
//
//  Created by Jay Kickliter on 3/19/09.
//  Copyright 2009 Karmalounge. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ConsoleController : NSWindowController {
	IBOutlet NSTextView *outputTextView;
	IBOutlet NSButton		*clearButton;
	IBOutlet NSWindow   *consoleWindow;
}

- (IBAction)clearOutputTextView:(id)sender;
- (void)appendConsoleText:(NSString *)text;
- (bool)consoleWindowIsVisable;
- (void)hideConsoleWindow;

@end
