//
//  UMMPReportChart.h
//  UMMPerfusion
//
//  Created by Sven Kaiser on 23.02.12.
//  Copyright (c) 2012, Marcel Reich & Sven Kaiser & Markus Daab & Patrick Schülein & Engin Aslan
//  All rights reserved.
//

#import "GRChartView.h"
#import "GRDataSet.h"

@interface UMMPReportChart : GRChartView {
    
    NSNumber *baseLine;
    BOOL showBaseLine;
    
    NSArray *data1;
    NSArray *data2;
    GRDataSet *dataSet1;
    GRDataSet *dataSet2;
    
    NSMutableDictionary *cache;
}

@property (retain) NSNumber *baseLine;
@property (readwrite) BOOL showBaseLine;
@property (retain) NSArray *data1;
@property (retain) NSArray *data2;
@property (retain) GRDataSet *dataSet1;
@property (retain) GRDataSet *dataSet2;

- (id)initWithFrame:(NSRect)fp8;
- (void)drawValue:(float)value;
- (NSImage *)image;

@end
