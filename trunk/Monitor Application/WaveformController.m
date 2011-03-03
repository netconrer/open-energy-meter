
#import "WaveformController.h"
#import <CorePlot/CorePlot.h>


@implementation WaveformController

-(void)dealloc 
{
	[plotData release];
    [graph release];
    [super dealloc];
}

-(void)awakeFromNib
{
    [super awakeFromNib];
	packets = 0;
		
	  rawData = [[NSMutableArray alloc] init];
    
    // If you make sure your dates are calculated at noon, you shouldn't have to 
    // worry about daylight savings. If you use midnight, you will have to adjust
    // for daylight savings time.

    // Create graph from theme
    graph = [(CPXYGraph *)[CPXYGraph alloc] initWithFrame:CGRectZero];
	  CPTheme *theme = [CPTheme themeNamed:kCPDarkGradientTheme];
		[graph applyTheme:theme];
		hostView.hostedLayer = graph;
    
    // Setup scatter plot space
    plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(-20.0) length:CPDecimalFromFloat(130.0)];
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(-3000.0) length:CPDecimalFromFloat(6000)];
    
    // Axes
		CPXYAxisSet *axisSet = (CPXYAxisSet *)graph.axisSet;
    CPXYAxis *x = axisSet.xAxis;
		x.majorIntervalLength = CPDecimalFromString(@"25");
		x.orthogonalCoordinateDecimal = CPDecimalFromFloat(0.0);
		x.minorTicksPerInterval = 0;
   

    CPXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength = CPDecimalFromString(@"1000");
    y.minorTicksPerInterval = 5;
    y.orthogonalCoordinateDecimal = CPDecimalFromFloat(0.0);
					
    // Create a plot that uses the data source method
		dataSourceLinePlot = [[[CPScatterPlot alloc] init] autorelease];
    dataSourceLinePlot.identifier = @"Date Plot";
		dataSourceLinePlot.dataLineStyle.lineWidth = 2.f;
    dataSourceLinePlot.dataLineStyle.lineColor = [CPColor greenColor];
    dataSourceLinePlot.dataSource = self;
    [graph addPlot:dataSourceLinePlot];
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot
{
    return plotData.count;
}

-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{

    NSDecimalNumber *num = [[plotData objectAtIndex:index] objectForKey:[NSNumber numberWithInt:fieldEnum]];
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
		[rawData addObject:y];
	}
	i = [rawData count];
 if (i > 100) {
		[rawData removeObjectsInRange: NSMakeRange(0, i-100)];
	}
	
	NSMutableArray *newData = [NSMutableArray array];
	for ( i = 0; i < [rawData count]; i++ ) {			
		NSTimeInterval x = i;			
		id y = [rawData objectAtIndex:i];			
		[newData addObject:
	        	[NSDictionary dictionaryWithObjectsAndKeys:
	               [NSDecimalNumber numberWithFloat:x], [NSNumber numberWithInt:CPScatterPlotFieldX], 
	                y, [NSNumber numberWithInt:CPScatterPlotFieldY], 
	                nil]];		
	}	
	plotData = newData;
	packets++;
	if (packets > 3) {
		[dataSourceLinePlot reloadData];
		packets = 0;
	}
	
		
}


@end
