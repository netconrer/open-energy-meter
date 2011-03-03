//
//  PlotsController.m
//  PropStream
//
//  Created by Jay Kickliter on 3/3/11.
//  Copyright 2011 Chasing 'trons. All rights reserved.
//

#import <CorePlot/CorePlot.h>
#import "PlotsController.h"


@implementation PlotsController

-(void)dealloc 
{
	[currentPlotData release];
	[currentPlot release];
	[super dealloc];
}

-(void)awakeFromNib
{
	[super awakeFromNib];
	packets = 0;
	
	currentRawData = [[NSMutableArray alloc] init];
	

	// Create graph from theme
	currentPlot = [(CPXYGraph *)[CPXYGraph alloc] initWithFrame:CGRectZero];
	CPTheme *theme = [CPTheme themeNamed:kCPSlateTheme];
	[currentPlot applyTheme:theme];
	currentHostView.hostedLayer = currentPlot;
	
	// Setup scatter plot space
	currentPlotSpace = (CPXYPlotSpace *)currentPlot.defaultPlotSpace;
	currentPlotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromInt(0) length:CPDecimalFromInt(99)];
	currentPlotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromInt(-2048) length:CPDecimalFromFloat(4096)];
	
	// Axes
	CPXYAxisSet *axisSet = (CPXYAxisSet *)currentPlot.axisSet;
	CPXYAxis *x = axisSet.xAxis;
	x.majorIntervalLength = CPDecimalFromString(@"25");
	x.orthogonalCoordinateDecimal = CPDecimalFromInt(-6000);
	x.minorTicksPerInterval = 0;
	
	
	CPXYAxis *y = axisSet.yAxis;
	y.majorIntervalLength = CPDecimalFromString(@"1000");
	y.minorTicksPerInterval = 5;
	y.orthogonalCoordinateDecimal = CPDecimalFromFloat(-100);
	
	// Create a plot that uses the data source method
	dataSourceLinePlot = [[[CPScatterPlot alloc] init] autorelease];
	dataSourceLinePlot.identifier = @"Date Plot";
	dataSourceLinePlot.dataLineStyle.lineWidth = 2.f;
	dataSourceLinePlot.dataLineStyle.lineColor = [CPColor greenColor];
	dataSourceLinePlot.dataSource = self;
	[currentPlot addPlot:dataSourceLinePlot];
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot
{
	return currentPlotData.count;
}

-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
	NSDecimalNumber *num = [[currentPlotData objectAtIndex:index] objectForKey:[NSNumber numberWithInt:fieldEnum]];
	return num;
}

- (void)addNewData:(NSData *)data
{
	short tempInt;
	int i;
	//NSMutableArray *newData = [NSMutableArray array];
	for (i = 1; i < [data length]; i += 2)
	{
		[data getBytes:&tempInt range: NSMakeRange(i,2)];
		id y = [NSDecimalNumber numberWithShort: tempInt];
		[currentRawData addObject:y];
	}
	i = [currentRawData count];
	if (i > 100) {
		[currentRawData removeObjectsInRange: NSMakeRange(0, i-100)];
	}
	
	NSMutableArray *newData = [NSMutableArray array];
	for ( i = 0; i < [currentRawData count]; i++ ) {			
		NSTimeInterval x = i;			
		id y = [currentRawData objectAtIndex:i];			
		[newData addObject:
		 [NSDictionary dictionaryWithObjectsAndKeys:
			[NSDecimalNumber numberWithFloat:x], [NSNumber numberWithInt:CPScatterPlotFieldX], 
			y, [NSNumber numberWithInt:CPScatterPlotFieldY], 
			nil]];		
	}	
	currentPlotData = newData;
	packets++;
	if (packets > 3) {
		[self reloadData];
		packets = 0;
	}
}

- (void)reloadData
{
	[dataSourceLinePlot reloadData];
}

@end
