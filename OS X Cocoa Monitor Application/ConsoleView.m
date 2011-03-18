//
//  ConsoleView.m
//  PropStream
//
//  Created by Jay Kickliter on 2/28/11.
//  Copyright 2011 Chasing 'trons. All rights reserved.
//

#import "ConsoleView.h"

@implementation ConsoleView

- (id)initWithFrame:(NSRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		array = [[[NSMutableArray alloc] init] retain];
	}
	return self;
}

- (void)dealloc {
	[array release];
	[super dealloc];
}

- (BOOL)isFlipped { return YES; } // first line at the top

- (void)drawRect:(NSRect)rect {
	int startLine = rect.origin.y/LINE_HEIGHT;
	int endLine = 1 + (rect.origin.y+rect.size.height)/LINE_HEIGHT;
	if(startLine < 0) startLine = 0;
	if(endLine > [array count]) endLine = [array count];
	int i;
	for(i = startLine; i < endLine; i++) { // only draw the changed lines
		NSString *str = [array objectAtIndex:i];
		[str drawAtPoint:NSMakePoint(0, i * LINE_HEIGHT) withAttributes:nil];
	}
}

- (void)appendLine:(NSString*)line {
	if([array count] > MAX_LINES) [array removeObjectAtIndex:0]; // limit the number of lines
	[array addObject:line];	
	int i = [array count];
	[self setFrame:NSMakeRect(0, 0, LINE_WIDTH, i*LINE_HEIGHT)]; // increase the frame size	
	[self scrollRectToVisible:NSMakeRect(0, (i-1)*LINE_HEIGHT, LINE_WIDTH, LINE_HEIGHT)]; // show the last line
	[self setNeedsDisplay:YES];
}


- (IBAction)test:(id)sender {
	[self appendLine:[sender stringValue]];
}

@end