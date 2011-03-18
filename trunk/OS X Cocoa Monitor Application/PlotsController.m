//
//  PlotsController.m
//  PropStream
//
//  Created by Jay Kickliter on 3/3/11.
//  Copyright 2011 Chasing 'trons. All rights reserved.
//

static NSString * const CURRENT_PLOT = @"Current Plot";
static NSString * const VOLTAGE_PLOT = @"Voltage Plot";
static NSString * const ENERGY_PLOT  = @"Energy Plot";

#import <CorePlot/CorePlot.h>
#import "PlotsController.h"


@implementation PlotsController

-(void)dealloc 
{
	[currentPlotData release];
	[voltagePlotData release];
	[energyPlotData release];
	[currentGraph release];
	[voltageGraph release];
	[energyGraph release];
	[energyPlotDates release];
	[today release];
	[super dealloc];
}

-(void)awakeFromNib
{
	[super awakeFromNib];
	today = [[NSDate alloc] initWithTimeIntervalSinceNow:0.0];
	NSLog(@"%@", today);
	
	currentPlotData = [[NSMutableArray alloc] init];
	voltagePlotData = [[NSMutableArray alloc] init];
	energyPlotData = [[NSMutableArray alloc] init];
	energyPlotDates = [[NSMutableArray alloc] init];
	

	// Create graph from theme
	currentGraph = [(CPXYGraph *)[CPXYGraph alloc] initWithFrame:CGRectZero];
	voltageGraph = [(CPXYGraph *)[CPXYGraph alloc] initWithFrame:CGRectZero];
	energyGraph = [(CPXYGraph *)[CPXYGraph alloc]  initWithFrame:CGRectZero];
	
	CPTheme *theme = [CPTheme themeNamed:kCPSlateTheme];
	[currentGraph applyTheme:theme];	
	[currentGraph setTitle: @"Current Waveform"];
	[currentGraph setTitleDisplacement: CGPointMake(0, -10)];
	currentGraph.plotAreaFrame.paddingTop = 10.0;
	currentGraph.plotAreaFrame.paddingBottom = 10.0;
	
	[voltageGraph applyTheme: theme];
	voltageGraph.title = @"Voltage Waveform";
	voltageGraph.titleDisplacement = CGPointMake(0, -10);
	voltageGraph.plotAreaFrame.paddingTop = 10.0;
	voltageGraph.plotAreaFrame.paddingBottom = 10.0;
	
	[energyGraph  applyTheme:theme];
	energyGraph.title = @"Power";
	energyGraph.titleDisplacement = CGPointMake(0, -10);
	energyGraph.plotAreaFrame.paddingTop = 20.0;
	energyGraph.plotAreaFrame.paddingBottom = 30.0;
	energyGraph.plotAreaFrame.paddingLeft = 10.0;
	energyGraph.plotAreaFrame.paddingRight = 10.0;
	energyGraph.plotAreaFrame.cornerRadius = 10.0;
	
	
	currentHostView.hostedLayer = currentGraph;
	voltageHostView.hostedLayer = voltageGraph;
	energyHostView.hostedLayer	= energyGraph;
	
	// Setup scatter plot space
	currentPlotSpace = (CPXYPlotSpace *)currentGraph.defaultPlotSpace;
	currentPlotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromInt(0) length:CPDecimalFromInt(99)];
	currentPlotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromInt(-2050) length:CPDecimalFromFloat(4100)];
	
	
	
	// Setup scatter plot space
	voltagePlotSpace = (CPXYPlotSpace *)voltageGraph.defaultPlotSpace;
	voltagePlotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromInt(0) length:CPDecimalFromInt(99)];
	voltagePlotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromInt(-2050) length:CPDecimalFromFloat(4100)];
	
	// Setup scatter plot space
	energyPlotSpace = (CPXYPlotSpace *)energyGraph.defaultPlotSpace;
	energyPlotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0) length:CPDecimalFromInt(99)];
	energyPlotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0) length:CPDecimalFromFloat(2000)];
	energyPlotSpace.delegate = self;
	
	// Axes
	CPXYAxisSet *axisSet = (CPXYAxisSet *)currentGraph.axisSet;
	CPXYAxis *x = axisSet.xAxis;
	x.majorTickLineStyle = nil;
	x.majorIntervalLength = CPDecimalFromString(@"25");
	x.orthogonalCoordinateDecimal = CPDecimalFromInt(0);
	x.minorTicksPerInterval = 0;
	x.labelFormatter = nil;
															 
	CPXYAxis *y = axisSet.yAxis;
	y.majorIntervalLength = CPDecimalFromInt(1);
	y.minorTicksPerInterval = 5;
	y.orthogonalCoordinateDecimal = CPDecimalFromFloat(-100);
	
	
	// Axes
	axisSet = (CPXYAxisSet *)voltageGraph.axisSet;
	x = axisSet.xAxis;
	x.majorTickLineStyle = nil;
	x.majorIntervalLength = CPDecimalFromString(@"25");
	x.orthogonalCoordinateDecimal = CPDecimalFromInt(0);
	x.minorTicksPerInterval = 0;
	x.labelFormatter = nil;
	
	y = axisSet.yAxis;
	y.majorIntervalLength = CPDecimalFromString(@"1");
	y.minorTicksPerInterval = 5;
	y.orthogonalCoordinateDecimal = CPDecimalFromFloat(-100);
	
	// Axes
	axisSet = (CPXYAxisSet *)energyGraph.axisSet;
	x = axisSet.xAxis;
	
	NSInteger oneXUnit = 60;
	x.majorIntervalLength    =  CPDecimalFromInt(oneXUnit);
	NSDateFormatter *dateFormatter   =   [[[NSDateFormatter alloc] init]autorelease];
	[dateFormatter setDateStyle:kCFDateFormatterShortStyle];
	[dateFormatter setDateFormat:@"M/d/yy HHmm"];
	CPTimeFormatter *timeFormatter  =   [[CPTimeFormatter alloc] initWithDateFormatter:dateFormatter];
	timeFormatter.referenceDate =   today;
	x.labelFormatter    =   timeFormatter;
	
	
	//x.majorIntervalLength = CPDecimalFromString(@"25");
	//x.orthogonalCoordinateDecimal = CPDecimalFromInt(0);
	//x.minorTicksPerInterval = 0;
	CPLineStyle *majorGridLineStyle = [CPLineStyle lineStyle];
	majorGridLineStyle.lineWidth = 0.75;
	majorGridLineStyle.lineColor = [CPColor blueColor];
	
	y = axisSet.yAxis;	
	y.majorIntervalLength = CPDecimalFromFloat(100.0F);
	y.majorGridLineStyle = majorGridLineStyle;
	y.minorTicksPerInterval = 10;
	y.orthogonalCoordinateDecimal = CPDecimalFromFloat(8);
	y.labelAlignment = CPAlignmentBottom;
	y.visibleRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromInt(0) length:CPDecimalFromInt(4000)];
	y.title = @"Watts";
	y.titleOffset = 50.0;
	y.labelingPolicy = CPAxisLabelingPolicyAutomatic;
	
	
	
	// Create a plot that uses the data source method
	voltagePlot = [[[CPScatterPlot alloc] init] autorelease];
	voltagePlot.identifier = VOLTAGE_PLOT;
	voltagePlot.dataLineStyle.lineWidth = 1.5f;
	voltagePlot.dataLineStyle.lineColor = [CPColor blueColor];
	voltagePlot.dataSource = self;
	[voltageGraph addPlot:voltagePlot];
	
	// Create a plot that uses the data source method
	currentPlot = [[[CPScatterPlot alloc] init] autorelease];
	currentPlot.identifier = CURRENT_PLOT;
	currentPlot.dataLineStyle.lineWidth = 1.5f;
	currentPlot.dataLineStyle.lineColor = [CPColor blueColor];
	currentPlot.dataSource = self;
	[currentGraph addPlot:currentPlot];
	
	
	
	// Create a plot that uses the data source method
	CPColor *energyPlotLineColor = [[CPColor blueColor] colorWithAlphaComponent:0.5];
	energyPlot = [[[CPScatterPlot alloc] init] autorelease];
	energyPlot.identifier = ENERGY_PLOT;
	energyPlot.dataLineStyle.lineWidth = 2.f;
	energyPlot.dataLineStyle.lineColor = energyPlotLineColor;
	energyPlot.dataSource = self;
	energyPlot.areaFill = [CPFill fillWithColor:energyPlotLineColor];	
	energyPlot.areaBaseValue = CPDecimalFromInt(0);
	[energyGraph addPlot:energyPlot];
}

#pragma mark -
#pragma mark Plot Data Source Methods




-(NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot
{
	NSUInteger count = 0;
	
	if ([(NSString *)plot.identifier isEqualToString:CURRENT_PLOT]) {
		count = [currentPlotData count];
	} else if ([(NSString *)plot.identifier isEqualToString:VOLTAGE_PLOT]) {
		count = [voltagePlotData count];
	} else {
		count = [energyPlotData count];
	}

	return count;
}





-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
	NSNumber *num = nil;
	if ([(NSString *)plot.identifier isEqualToString:CURRENT_PLOT]) {
		switch (fieldEnum) {
			case CPScatterPlotFieldX:
				num = [NSNumber numberWithUnsignedInt:index];
				break;
			case CPScatterPlotFieldY:
				num = [currentPlotData objectAtIndex:index];				
				break;
			default:
				break;
		}
	} else if ([(NSString *)plot.identifier isEqualToString:VOLTAGE_PLOT]) {
		switch (fieldEnum) {
			case CPScatterPlotFieldX:
				num = [NSNumber numberWithUnsignedInt:index];
				break;
			case CPScatterPlotFieldY:
				num = [voltagePlotData objectAtIndex:index];
				break;
			default:
				break;
		}
	} else if ([(NSString *)plot.identifier isEqualToString:ENERGY_PLOT]) {
			switch (fieldEnum) {
				case CPScatterPlotFieldX:
					num = [energyPlotDates objectAtIndex:index];
					//NSLog(@"%@", num);
					break;
				case CPScatterPlotFieldY:
					num = [energyPlotData objectAtIndex:index];
					break;
				default:
					break;
			}
	}
	
	return num;
}




- (void)addNewData:(NSData *)data
{
	short			 tempShort;
	NSInteger	 i;
	char			 packetType;
	char			 reloadFlag;
	NSNumber	 *num = nil;
	id				 plotDataToUpdate;
	id				 plotToReload;
	//id				 plotSpaceToScale;

	[data getBytes: &packetType range: NSMakeRange(0, 1)];
	[data getBytes: &reloadFlag range: NSMakeRange(1, 1)];	
	
	switch (packetType) {
			
		case 0x63:
			plotDataToUpdate	= currentPlotData;
			plotToReload			= currentPlot;
			//plotSpaceToScale  = (CPXYPlotSpace *)currentGraph.defaultPlotSpace;
			break;
		case 0x76:
			plotDataToUpdate  = voltagePlotData;
			plotToReload			=	voltagePlot;
			//plotSpaceToScale  = (CPXYPlotSpace *)voltageGraph.defaultPlotSpace;
			break;
		default:
			return;
	}
	
	for (i = 2; i < [data length]; i += 2)
	{
		[data getBytes:&tempShort range: NSMakeRange(i,2)];
		num = [NSNumber numberWithShort: tempShort];
		[plotDataToUpdate addObject:num];
	}
	i = [plotDataToUpdate count];
	if (i > 100) {
		[plotDataToUpdate removeObjectsInRange: NSMakeRange(0, i-100)];
	}
	
	if (reloadFlag == 1) {		
		[plotToReload reloadData];		
		//[plotSpaceToScale scaleToFitPlots:[NSArray arrayWithObject:plotToReload]];		
	}
}




- (void)addNewEnergyPlotPoint:(float)value
{
	NSNumber *num = [NSNumber numberWithFloat: value];
	[energyPlotData addObject:num];
	num = [NSNumber numberWithDouble: [[NSDate date] timeIntervalSinceDate: today]];
	[energyPlotDates addObject: num];
	
	CPXYAxisSet *axisSet = (CPXYAxisSet *)energyGraph.axisSet;
	CPPlotRange *newRange = [CPPlotRange plotRangeWithLocation: CPDecimalFromFloat([[energyPlotDates lastObject] floatValue] - 100.00) length:CPDecimalFromFloat(100.0)];	
	energyPlotSpace.xRange = newRange;
	axisSet.yAxis.orthogonalCoordinateDecimal = CPDecimalFromFloat(newRange.locationDouble+8.0F);
	[energyPlot reloadData];

}




- (IBAction)energyPlotVerticalRangeZoomIn:(id)sender
{
	energyPlotSpace = (CPXYPlotSpace *)energyGraph.defaultPlotSpace;
	double oldYRangeLength = energyPlotSpace.yRange.lengthDouble;
	float scaleFactor = 0.5;
	float newYRangeLength = oldYRangeLength * scaleFactor;
	energyPlotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0) length:CPDecimalFromFloat(newYRangeLength)];
}



- (IBAction)energyPlotVerticalRangeZoomOut:(id)sender
{
	double oldYRangeLength = energyPlotSpace.yRange.lengthDouble;
	float scaleFactor = 2.0;
	float newYRangeLength = oldYRangeLength * scaleFactor;
	energyPlotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0) length:CPDecimalFromFloat(newYRangeLength)];
}






//- (CPPlotRange *)plotSpace:(CPPlotSpace *)space
//		 willChangePlotRangeTo:(CPPlotRange *)newRange
//						 forCoordinate:(CPCoordinate)coordinate
//{
//	CPXYAxisSet *axisSet = (CPXYAxisSet *)energyPlot.axisSet;
//	if (coordinate == CPCoordinateX) {
//		axisSet.yAxis.orthogonalCoordinateDecimal = CPDecimalFromFloat(newRange.locationDouble+8.0F);
//	} else {
//		//newRange.location = CPDecimalFromFloat(-50.0F);
//		//axisSet.xAxis.orthogonalCoordinateDecimal = CPDecimalFromFloat(0.0F);
//	}
//	
//	return newRange;
//}


@end
