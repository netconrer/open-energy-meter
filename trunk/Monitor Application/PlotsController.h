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
	CPScatterPlot													*currentDataSourceLinePlot;
	CPScatterPlot													*voltageDataSourceLinePlot;	
	CPScatterPlot													*energyDataSourceLinePlot;
	CPXYPlotSpace													*currentPlotSpace;
	CPXYPlotSpace													*voltagePlotSpace;
	CPXYPlotSpace													*energyPlotSpace;
}

- (void)addNewData:(NSData *)data;
- (void)addNewEnergyPlotPoint:(float)value;

@end