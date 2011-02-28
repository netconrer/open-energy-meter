//
//  KLOscilloscopeView.m
//  PropStream
//
//  Created by Jay Kickliter on 3/13/09.
//  Copyright 2009 KarmaLabs. All rights reserved.
//

#import "KLOscilloscopeView.h"

@implementation KLOscilloscopeView

@synthesize maxValue;
@synthesize value;
@synthesize resolution;
@synthesize sampleRate;
@synthesize loopShouldRun;

- (id)initWithFrame:(NSRect)frame 
{
    if (self = [super initWithFrame:frame]) {
			[self setResolution:1];
			[self setValue:0.0];
			[self setSampleRate:17.0];
			[self setMaxValue:100.0];
			[self setLoopShouldRun:YES];
			trace = [[NSBezierPath alloc] init];
			[trace setLineWidth:1];
			[NSThread detachNewThreadSelector:@selector(traceLoop) toTarget:self withObject:nil];
		}
    return self;
}

- (void)traceLoop
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSRect bounds = [self bounds];
	//NSLog(@"Width: %f, Height: %f", bounds.size.width, bounds.size.height);
	NSMutableArray *traceArray = [NSMutableArray arrayWithCapacity:bounds.size.width*resolution];
	CGFloat halfHeight = bounds.size.height/2;
	//NSLog(@"halfHeight: %f", halfHeight);
	CGFloat width = bounds.size.width;
	CGFloat	widthAndResolution = bounds.size.width*resolution;
	CGFloat halfHeightOverMaxValue;
	NSPoint point;
	int i;
	for (i=0; i<widthAndResolution; i++) {
		[traceArray addObject:[NSNumber numberWithFloat:0]];
	}
	while (loopShouldRun) {
		bounds = [self bounds];
		halfHeight = bounds.size.height/2;
		halfHeightOverMaxValue = halfHeight / maxValue;
		width = bounds.size.width;
		widthAndResolution = bounds.size.width * resolution;
		[trace removeAllPoints];
		if ([traceArray count] < widthAndResolution) {
			for (i=0; i < (int)widthAndResolution - [traceArray count]; i++) {
				[traceArray addObject:[NSNumber numberWithFloat:0.0]];
			}
		}
		[traceArray insertObject:[NSNumber numberWithFloat:value] atIndex:0];
		[traceArray removeObjectsInRange:NSMakeRange([traceArray count] - 1, 1)];
		point = NSMakePoint(width, [[traceArray objectAtIndex:0] floatValue] * halfHeightOverMaxValue + halfHeight);
		[trace moveToPoint:point];
		for (i = 1; i < [traceArray count]; i++) {
			point = NSMakePoint(width - 1 - resolution * i, halfHeight + [[traceArray objectAtIndex:i] floatValue] * halfHeightOverMaxValue);
			[trace lineToPoint:point];
		}
		[self setNeedsDisplay:YES];
		[NSThread sleepForTimeInterval:1/sampleRate];
	}
	[pool release];
}

- (void)drawRect:(NSRect)rect
{
	NSRect bounds = [self bounds];
	[[NSColor blackColor] set];
	[NSBezierPath fillRect:bounds];
	[[NSColor yellowColor] set];
	[trace stroke];
}

- (BOOL)isOpaque
{
	return YES;
}

- (void)dealloc
{
	[self setLoopShouldRun:NO];
	[trace release];
	[super dealloc];
}

@end