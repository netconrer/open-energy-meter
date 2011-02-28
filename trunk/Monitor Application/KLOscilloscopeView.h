//
//  KLOscilloscopeView.h
//  PropStream
//
//  Created by Jay Kickliter on 3/13/09.
//  Copyright 2009 KarmaLabs. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface KLOscilloscopeView : NSView {
	float						interval;
	float						maxValue;
  float						value;
	float						sampleRate;	// How often in seconds to update view
	float						resolution;	// How many samples should fit in view
	bool						loopShouldRun;
	NSBezierPath		*trace;
}

@property float maxValue;
@property float value;
@property float resolution;
@property float sampleRate;
@property bool	loopShouldRun;

- (void)traceLoop;

@end
