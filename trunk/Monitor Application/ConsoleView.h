//
//  ConsoleView.h
//  PropStream
//
//  Created by Jay Kickliter on 2/28/11.
//  Copyright 2011 Chasing 'trons. All rights reserved.
//

#define LINE_HEIGHT	20
#define MAX_LINES   100
#define LINE_WIDTH   100

#import <Cocoa/Cocoa.h>


@interface ConsoleView : NSView {
	NSMutableArray *array;
}
- (void)appendLine:(NSString*)line;

@end