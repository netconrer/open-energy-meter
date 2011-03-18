//
//  PreferenceController.m
//  PropStream
//
//  Created by Jay Kickliter on 2/28/11.
//  Copyright 2011 Chasing 'trons. All rights reserved.
//

#import "PreferenceController.h"


@implementation PreferenceController
- (id) init
{
	if (![super initWithWindowNibName:@"Preferences"]) {
		return nil;
	} else {
		return self;
	}

}

@end
