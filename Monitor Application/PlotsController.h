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
	NSArray																*currentPlotData;
	NSArray																*voltagePlotData;
	NSArray																*energyPlotData;	
	NSMutableArray												*currentRawData;
	NSMutableArray												*voltageRawData;
	NSMutableArray												*energyRawData;
	CPScatterPlot													*currentDataSourceLinePlot;
	CPXYPlotSpace													*currentPlotSpace;
	CPXYPlotSpace													*voltagePlotSpace;
	CPXYPlotSpace													*energyPlotSpace;
	int																	  packets;
}

- (void)addNewData:(NSData *)data;
- (void)reloadData;

@end