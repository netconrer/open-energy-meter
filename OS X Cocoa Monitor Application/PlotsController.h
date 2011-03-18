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
	CPXYGraph															*currentPlot;
	CPXYGraph															*voltagePlot;
	CPXYGraph															*energyPlot;
	NSMutableArray												*currentPlotData;
	NSMutableArray												*voltagePlotData;
	NSMutableArray												*energyPlotData;
	NSMutableArray												*energyPlotDates;
	CPScatterPlot													*currentDataSourceLinePlot;
	CPScatterPlot													*voltageDataSourceLinePlot;	
	CPScatterPlot													*energyDataSourceLinePlot;
	CPXYPlotSpace													*currentPlotSpace;
	CPXYPlotSpace													*voltagePlotSpace;
	CPXYPlotSpace													*energyPlotSpace;
	
	NSDate																*today;
}

- (void)addNewData:(NSData *)data;
- (void)addNewEnergyPlotPoint:(float)value;

@end