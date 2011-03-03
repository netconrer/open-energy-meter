

#import <Cocoa/Cocoa.h>
#import <CorePlot/CorePlot.h>

@interface WaveformController : NSObject <CPPlotDataSource> {
	IBOutlet					CPLayerHostingView	*hostView;	
	CPXYGraph															*graph;
	NSArray																*plotData;
	NSMutableArray												*rawData;
	CPScatterPlot *dataSourceLinePlot;
	CPXYPlotSpace *plotSpace;
	int																	  packets;
}

- (void)addNewData:(NSData *)data;

@end

