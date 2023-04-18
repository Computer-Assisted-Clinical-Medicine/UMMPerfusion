//
//  UMMPBinding.h
//  UMMPerfusion
//
//  Created by Sven Kaiser on 19.10.11.
//  Copyright (c) 2012, Marcel Reich & Sven Kaiser & Markus Daab & Patrick Schülein & Engin Aslan
//  All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UMMPBinding : NSObject {
    
    NSInteger tracerIndex;
    NSInteger baselineLength;
    double htc;
    double regularization;
    
    int startSlider;
	int startSliceSlider;
    int startSliderMin;
    int startSliderMax;
	int startSliceSliderMin;
	int startSliceSliderMax;
	
		
    int stopSlider;
	int stopSliceSlider;
    int stopSliderMin;
    int stopSliderMax;
	int stopSliceSliderMin;
	int stopSliceSliderMax;
    NSInteger startField;
	NSInteger startSliceField;
    NSInteger stopField;
	NSInteger stopSliceField;
    NSInteger autosaveBox;
    NSString *exportName;
}

@end
