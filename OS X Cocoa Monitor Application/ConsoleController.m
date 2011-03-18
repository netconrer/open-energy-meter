//
//  KLConsoleWindow.m
//  PropStream
//
//  Created by Jay Kickliter on 3/19/09.
//  Copyright 2009 Karmalounge. All rights reserved.
//

#import "ConsoleController.h"


@implementation ConsoleController

- (id) init
{
	if (![super initWithWindowNibName:@"Console"]) {
		return nil;
	} else {
		return self;
	}
	
}

- (void)windowDidLoad
{
	[outputTextView setFont:[NSFont fontWithName:@"Monaco" size:12]];
	[outputTextView setTextColor:[NSColor greenColor]];
	[outputTextView setBackgroundColor:[NSColor blackColor]];
}

- (IBAction)clearOutputTextView:(id)sender
{
	[outputTextView setString:@""];
}

- (void)appendConsoleText:(NSString *)text
{
	[outputTextView insertText:text];
	[outputTextView displayIfNeeded];
}

- (bool)consoleWindowIsVisable
{
	return [consoleWindow isVisible];
}

- (void)hideConsoleWindow
{
	[consoleWindow close];
}


@end
