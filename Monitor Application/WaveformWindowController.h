//
//  WaveformWindowController.h
//  PropStream
//
//  Created by Jay Kickliter on 3/2/11.
//  Copyright 2011 Chasing 'trons. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WaveformController.h"


@interface WaveformWindowController : NSWindowController {
	IBOutlet	WaveformController	*waveFormController;
}


- (void)addNewData:(NSData *)data;

@end
