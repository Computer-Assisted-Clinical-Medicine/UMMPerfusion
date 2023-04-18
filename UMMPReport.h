//
//  UMMPReport.h
//  UMMPerfusion
//
//  Created by Sven Kaiser on 24.02.12.
//  Copyright (c) 2012, Marcel Reich & Sven Kaiser & Markus Daab & Patrick Schülein & Engin Aslan
// All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface UMMPReport : NSView {
    NSInteger _layoutType;
    NSView *_view1;
    NSView *_view2;
    NSMutableArray *_inputParameters;
    NSMutableArray *_outputParameters;
	NSMutableArray *_presetHeaders;
	NSMutableArray *_presetParameters;
	
	double factor;
}

- (id)initWithFrame:(NSRect)frame andLayoutType:(NSInteger)layoutType andView1:(NSView*)view1 andView2:(NSView*)view2 andInputParameters:(NSMutableArray*)inputParameters
andOutputParameters:(NSMutableArray*)outputParameters andPresetParameters:(NSMutableArray*)presetParameters;

@end
