//
//  WaveformWindowController.m
//  PropStream
//
//  Created by Jay Kickliter on 3/2/11.
//  Copyright 2011 Chasing 'trons. All rights reserved.
//

#import "WaveformWindowController.h"


@implementation WaveformWindowController
- (id) init
{
	if (![super initWithWindowNibName:@"Waveform"]) {
		return nil;
	} else {
		return self;
	}
}

- (void)addNewData:(NSData *)data
{
	[waveFormController addNewData:data];
}

@end
