//
//  KLConsoleWindow.m
//  PropStream
//
//  Created by Jay Kickliter on 3/19/09.
//  Copyright 2009 Karmalounge. All rights reserved.
//

#import "ConsoleWindowController.h"


@implementation ConsoleWindowController

- (id)init
{
	self = [super initWithWindowNibName:@"Console"];
	return self;
}

- (void)windowDidLoad
{
	//[[self window] setTitle:@"Console"];
  //[self setWindowFrameAutosaveName:@"ConsoleWindowFrame"];
	[outputTextView setFont:[NSFont fontWithName:@"Monaco" size:12]];
	[outputTextView setTextColor:[NSColor greenColor]];
	[outputTextView setBackgroundColor:[NSColor blackColor]];
}

- (IBAction)clearOutputTextView:(id)sender
{
	[outputTextView setString:@""];
}

- (void)appendConsoleText:(NSString *)text;
{
	[outputTextView insertText:text];
	[outputTextView displayIfNeeded];
}

@end
