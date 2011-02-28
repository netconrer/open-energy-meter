//
//  KLConsoleWindow.h
//  PropStream
//
//  Created by Jay Kickliter on 3/19/09.
//  Copyright 2009 Karmalounge. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ConsoleWindowController : NSWindowController {
	IBOutlet NSTextView *outputTextView;
	IBOutlet NSButton		*clearButton;
}

- (IBAction)clearOutputTextView:(id)sender;
- (void)appendConsoleText:(NSString *)text;

@end
