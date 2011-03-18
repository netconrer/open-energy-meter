//
//  KLConsoleWindow.m
//  PropStream
//
//  Created by Jay Kickliter on 3/19/09.
//  Copyright 2009 Karmalounge. All rights reserved.
//

#import "KLConsoleWindowController.h"


@implementation KLConsoleWindowController

- (id)init
{
	self = [super initWithWindowNibName:@"ConsoleWindow"];
	return self;
}

- (void)windowDidLoad
{
	[[self window] setTitle:@"Console"];
  [self setWindowFrameAutosaveName:@"ConsoleWindowFrame"];
	[outputTextView setFont:[NSFont fontWithName:@"Monaco" size:12]];
	[outputTextView setTextColor:[NSColor greenColor]];
	[outputTextView setBackgroundColor:[NSColor blackColor]];
}

- (IBAction)clearOutputTextView:(id)sender
{
	[outputTextView setString:@""];
}

- (void)appendXbeePacketText:(NSString *)packetText
{
	[outputTextView insertText:packetText];
	[outputTextView displayIfNeeded];
}

@end
