//
//  PlotsController.h
//  PropStream
//
//  Created by Jay Kickliter on 3/3/11.
//  Copyright 2011 Chasing 'trons. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CorePlot/CorePlot.h>

@interface PlotsController : NSObject <CPPlotDataSource> {
	IBOutlet				CPLayerHostingView		*currentHostView;
	IBOutlet				CPLayerHostingView		*voltageHostView;
	IBOutlet				CPLayerHostingView		*energyHostView;
	CPXYGraph															*currentGraph;
	CPXYGraph															*voltageGraph;
	CPXYGraph															*energyGraph;
	NSMutableArray												*currentPlotData;
	NSMutableArray												*voltagePlotData;
	NSMutableArray												*energyPlotData;
	NSMutableArray												*energyPlotDates;
	CPScatterPlot													*currentPlot;
	CPScatterPlot													*voltagePlot;	
	CPScatterPlot													*energyPlot;
	CPXYPlotSpace													*currentPlotSpace;
	CPXYPlotSpace													*voltagePlotSpace;
	CPXYPlotSpace													*energyPlotSpace;
	
	NSDate																*today;
}

- (void)addNewData:(NSData *)data;
- (void)addNewEnergyPlotPoint:(float)value;

- (IBAction)energyPlotVerticalRangeZoomIn:(id)sender;
- (IBAction)energyPlotVerticalRangeZoomOut:(id)sender;


@end