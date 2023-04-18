//
//  UMMPReport.m
//  UMMPerfusion
//
//  Created by Sven Kaiser on 24.02.12.
//  Copyright (c) 2012, Marcel Reich & Sven Kaiser & Markus Daab & Patrick Schülein & Engin Aslan
//  All rights reserved.
//

#import "UMMPReport.h"
#import <OsiriXAPI/DCMView.h>

@implementation UMMPReport

- (id)initWithFrame:(NSRect)frame andLayoutType:(NSInteger)layoutType andView1:(NSView*)view1 andView2:(NSView*)view2 andInputParameters:(NSMutableArray*)inputParameters
andOutputParameters:(NSMutableArray*)outputParameters andPresetParameters:(NSMutableArray *)presetParameters
{
	if (layoutType == 3) {
		factor = 1;
	}
	else {
		factor = 1.3;
	}
	
	frame.size.height *= factor ;
	self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        _layoutType = layoutType;
        _view1 = [view1 retain];
        _view2 = [view2 retain];
        _inputParameters = inputParameters;
        _outputParameters = outputParameters;
		_presetHeaders = [[NSMutableArray alloc] init];
		[_presetHeaders addObject:@"parameter name"];
		[_presetHeaders addObject:@"value"];
		[_presetHeaders addObject:@"limit high"];
		[_presetHeaders addObject:@"limit low"];		
		_presetParameters = presetParameters;
        
//        NSLog(@"%@", _inputParameters);
//        NSLog(@"%@", _outputParameters);
    }
    
    return self;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [_view1 release]; _view1 = NULL;
    [_view2  release]; _view2 = NULL;
	[_presetHeaders release]; _presetHeaders = NULL;
    [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect
{
	//dirtyRect.size.width *=2;
    NSSize frameSize = dirtyRect.size;
	NSFontManager *fontManager = [NSFontManager sharedFontManager];
    
    // fill background of view
	[[NSColor whiteColor] set];
	NSRectFill([self bounds]);
    
    // *** Frame ***
    NSInteger frameOffSet = 10;
    NSRect frameRect = NSMakeRect(frameOffSet, frameOffSet, frameSize.width-(frameOffSet*2), frameSize.height-(frameOffSet*2));
	[[NSColor blackColor] set];
	NSFrameRectWithWidth(frameRect, 1);
    
    // headline
    NSInteger xPositionHeadline = 25;
    NSInteger yPositionHeadline = 30;
    NSFont *headlineFont = [fontManager fontWithFamily:@"Helvetica"
                                                  traits:NSBoldFontMask
                                                  weight:0
                                                    size:36];
    NSDictionary *attrHeadline = [NSDictionary dictionaryWithObjectsAndKeys:headlineFont, NSFontAttributeName, nil];
    [[NSString stringWithFormat:@"UMMPerfusion Report"] drawAtPoint:NSMakePoint(xPositionHeadline, yPositionHeadline) withAttributes:attrHeadline];
        
    if (_layoutType == 1) {
        
        // *** Rect 1 ***
        NSInteger marginTopRect1 = 75;
        NSInteger widthRect1 = (frameSize.width/2)-frameOffSet*2;
        NSInteger heightRect1 = (frameSize.height/(2*factor))-frameOffSet*2;
        NSRect rect1 = NSMakeRect(frameSize.width/2, frameOffSet+marginTopRect1, widthRect1, heightRect1);
        NSInteger marginRect1 = 20;
        
        // *** Label View 1 ***
        NSInteger xPositionLabelView1 = rect1.origin.x+marginRect1;
        NSInteger yPositionLabelView1 = rect1.origin.y+marginRect1;
//        NSFont *labelFontView1 = [NSFont fontWithName:@"Helvetica" size:18];
        NSFont *labelFontView1 = [fontManager fontWithFamily:@"Helvetica"
                                                  traits:NSBoldFontMask
                                                  weight:0
                                                    size:18];
        NSDictionary *attrLabelView1 = [NSDictionary dictionaryWithObjectsAndKeys:labelFontView1, NSFontAttributeName, nil];
        [[NSString stringWithFormat:@"Arterial & Tissue ROI"] drawAtPoint:NSMakePoint(xPositionLabelView1, yPositionLabelView1) withAttributes:attrLabelView1];
        
        // *** View 1 ***
        NSInteger distanceLabel1 = 25;
        NSInteger offSetBottomView1 = 100;    
        NSInteger xPositionView1 = rect1.origin.x+marginRect1;
        NSInteger yPositionView1 = yPositionLabelView1+distanceLabel1;
        NSInteger widthView1 = rect1.size.width-marginRect1;
        NSInteger heightView1 = rect1.size.height-marginRect1-distanceLabel1-offSetBottomView1;
        NSRect rectView1 = NSMakeRect(xPositionView1, yPositionView1, widthView1, heightView1);
        //[[NSColor blueColor] set];
//		NSRectFill(rectView1);
		
		
        NSBitmapImageRep *imageRepView1 = [_view1 bitmapImageRepForCachingDisplayInRect:[_view1 bounds]];
        unsigned char *bitmapDataView1 = [imageRepView1 bitmapData];
        if (bitmapDataView1)
            bzero(bitmapDataView1, [imageRepView1 pixelsWide]*[imageRepView1 pixelsHigh]);
        [_view1 cacheDisplayInRect:[_view1 bounds] toBitmapImageRep:imageRepView1];
        
        NSImage *imageView1 = [[NSImage alloc] init];
        [imageView1 addRepresentation:imageRepView1];
        [imageView1 drawInRect:rectView1 fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
        [imageView1 release];
        
        // *** Legend View 1 ***
        NSInteger marginLegendLeftView1 = 50;
        NSInteger xPositionLegendView1 = rect1.origin.x+marginRect1+marginLegendLeftView1;
        NSInteger yPositionLegendView1 = rectView1.origin.y+rectView1.size.height;
        
        NSFont *legendFontView1 = [NSFont fontWithName:@"Helvetica" size:16];
        NSDictionary *attrLegendView1 = [NSDictionary dictionaryWithObjectsAndKeys:legendFontView1, NSFontAttributeName, nil];
        [[NSString stringWithFormat:@"Arterial"] drawAtPoint:NSMakePoint(xPositionLegendView1, yPositionLegendView1) withAttributes:attrLegendView1];
        [[NSString stringWithFormat:@"Tissue"] drawAtPoint:NSMakePoint(xPositionLegendView1+125, yPositionLegendView1) withAttributes:attrLegendView1];
        [[NSString stringWithFormat:@"Baseline"] drawAtPoint:NSMakePoint(xPositionLegendView1+245, yPositionLegendView1) withAttributes:attrLegendView1];
        
        NSInteger xPositionLegendColorArterial = xPositionLegendView1+65;
        NSInteger yPositionLegendColorArterial = yPositionLegendView1+3;
        NSInteger arterialColorSize = 15;
        NSRect arterialColorRect = NSMakeRect(xPositionLegendColorArterial, yPositionLegendColorArterial, arterialColorSize, arterialColorSize);
        [[NSColor greenColor] set];
        NSRectFill(arterialColorRect);
        
        NSInteger xPositionLegendColorTissue = xPositionLegendView1+185;
        NSInteger yPositionLegendColorTissue = yPositionLegendView1+3;
        NSInteger tissueColorSize = 15;
        NSRect tissueColorRect = NSMakeRect(xPositionLegendColorTissue, yPositionLegendColorTissue, tissueColorSize, tissueColorSize);
        [[NSColor blueColor] set];
        NSRectFill(tissueColorRect);
        
        NSInteger xPositionLegendColorBaseline = xPositionLegendView1+322;
        NSInteger yPositionLegendColorBaseline = yPositionLegendView1+3;
        NSInteger baselineColorSize = 15;
        NSRect baselineColorRect = NSMakeRect(xPositionLegendColorBaseline, yPositionLegendColorBaseline, baselineColorSize, baselineColorSize);
        [[NSColor redColor] set];
        NSRectFill(baselineColorRect);
        
        // *** Rect2 ***
        NSInteger marginTopRect2 = 350;
        NSInteger widthRect2 = (frameSize.width/2)-frameOffSet*2;
        NSInteger heightRect2 = (frameSize.height/(2*factor))-frameOffSet*2;
        NSRect rect2 = NSMakeRect(frameSize.width/2, frameSize.height/(2*factor)+marginTopRect2, widthRect2, heightRect2);
        NSInteger marginRect2 = 20;
		//[[NSColor redColor] set];
//        NSRectFill(rect2);
		
        // *** Label View 2 ***
        NSInteger xPositionLabelView2 = rect2.origin.x+marginRect2;
        NSInteger yPositionLabelView2 = rect2.origin.y+marginRect2;
//        NSFont *labelFontView2 = [NSFont fontWithName:@"Helvetica" size:18];
        NSFont *labelFontView2 = [fontManager fontWithFamily:@"Helvetica"
                                                      traits:NSBoldFontMask
                                                      weight:0
                                                        size:18];
        NSDictionary *attrLabelView2 = [NSDictionary dictionaryWithObjectsAndKeys:labelFontView2, NSFontAttributeName, nil];
        [[NSString stringWithFormat:@"Fit Curve"] drawAtPoint:NSMakePoint(xPositionLabelView2, yPositionLabelView2) withAttributes:attrLabelView2];
        
        // *** View 2 ***
        NSInteger distanceLabel2 = 25;
        NSInteger offSetBottomView2 = 100;
        NSInteger xPositionView2 = xPositionLabelView2;
        NSInteger yPositionView2 = yPositionLabelView2+distanceLabel2;
        NSInteger widthView2 = rect2.size.width-marginRect2;
        NSInteger heightView2 = rect2.size.height-marginRect2-distanceLabel2-offSetBottomView2;
        NSRect rectView2 = NSMakeRect(xPositionView2, yPositionView2, widthView2, heightView2);
        
        NSBitmapImageRep *imageRepView2 = [_view2 bitmapImageRepForCachingDisplayInRect:[_view2 bounds]];
        unsigned char *bitmapDataView2 = [imageRepView2 bitmapData];
        if (bitmapDataView2)
            bzero(bitmapDataView2, [imageRepView2 pixelsWide]*[imageRepView2 pixelsHigh]);
        [_view2 cacheDisplayInRect:[_view2 bounds] toBitmapImageRep:imageRepView2];
        
        NSImage *imageView2 = [[NSImage alloc] init];
        [imageView2 addRepresentation:imageRepView2];
        [imageView2 drawInRect:rectView2 fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
        [imageView2 release];
        
        // *** Legend View 2 ***
        NSInteger marginLegendLeftView2 = 50;
        NSInteger xPositionLegendView2 = rect2.origin.x+marginRect2+marginLegendLeftView2;
        NSInteger yPositionLegendView2 = rectView2.origin.y+rectView2.size.height;
        
        NSFont *legendFontView2 = [NSFont fontWithName:@"Helvetica" size:16];
        NSDictionary *attrLegendView2 = [NSDictionary dictionaryWithObjectsAndKeys:legendFontView2, NSFontAttributeName, nil];
        [[NSString stringWithFormat:@"Tissue"] drawAtPoint:NSMakePoint(xPositionLegendView2, yPositionLegendView2) withAttributes:attrLegendView2];
        [[NSString stringWithFormat:@"Fit Curve"] drawAtPoint:NSMakePoint(xPositionLegendView2+125, yPositionLegendView2) withAttributes:attrLegendView2];
        
        NSInteger xPositionLegendColorTissueCurveFit = xPositionLegendView2+60;
        NSInteger yPositionLegendColorTissueCurveFit = yPositionLegendView2+3;
        NSInteger tissueColorSizeCurveFit = 15;
        NSRect tissueColorRectCurveFit = NSMakeRect(xPositionLegendColorTissueCurveFit, yPositionLegendColorTissueCurveFit, tissueColorSizeCurveFit, tissueColorSizeCurveFit);
        [[NSColor redColor] set];
        NSRectFill(tissueColorRectCurveFit);
        
        NSInteger xPositionLegendColorFitCurve = xPositionLegendView2+205;
        NSInteger yPositionLegendColorFitCurve = yPositionLegendView2+3;
        NSInteger fitCurveColorSize = 15;
        NSRect fitCurveColorRect = NSMakeRect(xPositionLegendColorFitCurve, yPositionLegendColorFitCurve, fitCurveColorSize, fitCurveColorSize);
        [[NSColor blackColor] set];
        NSRectFill(fitCurveColorRect);
        
        // parameters label
        NSInteger xPositionParametersLabel = 25;
        NSInteger yPositionParametersLabel = rect1.origin.y+marginRect1;
//        NSFont *parametersLabelFont = [NSFont fontWithName:@"Helvetica" size:18];
        NSFont *parametersLabelFont = [fontManager fontWithFamily:@"Helvetica"
                                                      traits:NSBoldFontMask
                                                      weight:0
                                                        size:18];
        NSDictionary *attrParametersLabel = [NSDictionary dictionaryWithObjectsAndKeys:parametersLabelFont, NSFontAttributeName, nil];
        [[NSString stringWithFormat:@"Input Parameters"] drawAtPoint:NSMakePoint(xPositionParametersLabel, yPositionParametersLabel) withAttributes:attrParametersLabel];
        
        // parameters
        NSFont *parametersFont = [NSFont fontWithName:@"Helvetica" size:16];
        NSDictionary *attrParameters = [NSDictionary dictionaryWithObjectsAndKeys:parametersFont, NSFontAttributeName, nil];
        int h = yPositionView1+15;
//        for (NSMutableDictionary *tmpDict in _inputParameters) {
//            for (NSString *key in tmpDict) {
//                NSString *parameter = [tmpDict valueForKey:key];
//                NSSize labelSize = [key sizeWithAttributes:attrParameters];
//                NSSize parameterSize = [parameter sizeWithAttributes:attrParameters];
//                NSRect labelRect = NSMakeRect(25, h, labelSize.width, labelSize.height);
//                NSRect parameterRect = NSMakeRect(270, h, parameterSize.width, parameterSize.height);
//                [key drawInRect:labelRect withAttributes:attrParameters];
//                [parameter drawInRect:parameterRect withAttributes:attrParameters];
//                h = labelSize.height + 7 + h;
//            }
//        }
        for (NSMutableDictionary *tmpDict in _inputParameters) {
            for (NSString *key in tmpDict) {
                NSString *parameter = [tmpDict valueForKey:key];
                NSSize labelSize = [key sizeWithAttributes:attrParameters];
                NSSize parameterSize = [parameter sizeWithAttributes:attrParameters];
                NSInteger dynamicSize = labelSize.height;
                NSRect labelRect;
                NSRect parameterRect;
                                
                // Dynamic
                if (labelSize.width > 260 || parameterSize.width > 260) {
                    
                    if (labelSize.height > parameterSize.height) {
                        double tmp = ceil((labelSize.width/260));
                        dynamicSize = labelSize.height*tmp;
                    } else {
                        double tmp = ceil((parameterSize.width/260));
                        dynamicSize = parameterSize.height*tmp;
                    }
                    
                    labelRect = NSMakeRect(25, h, 260, dynamicSize);
                    parameterRect = NSMakeRect(270, h, 260, dynamicSize);
                } else {
                    labelRect = NSMakeRect(25, h, labelSize.width, labelSize.height);
                    parameterRect = NSMakeRect(270, h, parameterSize.width, parameterSize.height);
                }
                
                [key drawInRect:labelRect withAttributes:attrParameters];
                [parameter drawInRect:parameterRect withAttributes:attrParameters];
                h = dynamicSize + 7 + h;
            }
        }
        
        // result label
        NSInteger xPositionResultsLabel = 25;
        NSInteger yPositionResultsLabel = rect2.origin.y+marginRect2;
        //        NSFont *parametersLabelFont = [NSFont fontWithName:@"Helvetica" size:18];
        NSFont *resultsLabelFont = [fontManager fontWithFamily:@"Helvetica"
                                                           traits:NSBoldFontMask
                                                           weight:0
                                                             size:18];
        NSDictionary *attrResultsLabel = [NSDictionary dictionaryWithObjectsAndKeys:resultsLabelFont, NSFontAttributeName, nil];
        [[NSString stringWithFormat:@"Output Parameters"] drawAtPoint:NSMakePoint(xPositionResultsLabel, yPositionResultsLabel) withAttributes:attrResultsLabel];
        
        // results
        NSFont *resultsFont = [NSFont fontWithName:@"Helvetica" size:16];
        NSDictionary *attrResults = [NSDictionary dictionaryWithObjectsAndKeys:resultsFont, NSFontAttributeName, nil];
        h = yPositionView2+15;
        for (NSMutableDictionary *tmpDict in _outputParameters) {
            for (NSString *key in tmpDict) {
                NSString *parameter = [tmpDict valueForKey:key];
                NSSize labelSize = [key sizeWithAttributes:attrParameters];
                NSSize parameterSize = [parameter sizeWithAttributes:attrParameters];
                NSRect labelRect = NSMakeRect(25, h, labelSize.width, labelSize.height);
                NSRect parameterRect = NSMakeRect(270, h, parameterSize.width, parameterSize.height);
                [key drawInRect:labelRect withAttributes:attrParameters];
                [parameter drawInRect:parameterRect withAttributes:attrResults];
                h = labelSize.height + 10 + h;
            }
        }
	
		// *** Rect3 ***
        NSInteger marginTopRect3 = 150;
        NSInteger widthRect3 = (frameSize.width)-frameOffSet*4;
        NSInteger heightRect3 = (frameSize.height/(5))-frameOffSet*2;
        NSRect rect3 = NSMakeRect(25, frameSize.height/(2*factor)+marginTopRect3, widthRect3, heightRect3);
        NSInteger marginRect3 = 20;
		//[[NSColor blueColor] set];
//		NSRectFill(rect3);
		
		//NSInteger xPositionLabelView3 = rect3.origin.x+marginRect3;
        NSInteger yPositionLabelView3 = rect3.origin.y+marginRect3;

		NSInteger distanceLabel3 = 25;
        //NSInteger offSetBottomView3 = 100;
        //NSInteger xPositionView3 = xPositionLabelView3;
        NSInteger yPositionView3 = yPositionLabelView3+distanceLabel3;
        //NSInteger widthView3 = rect3.size.width-marginRect3;
        //NSInteger heightView3 = rect3.size.height-marginRect3-distanceLabel3-offSetBottomView3;	       		
        
		NSInteger xPositionPresetsLabel = 25;
        NSInteger yPositionPresetsLabel = rect3.origin.y+marginRect3;
        //        NSFont *parametersLabelFont = [NSFont fontWithName:@"Helvetica" size:18];
        NSFont *presetsLabelFont = [fontManager fontWithFamily:@"Helvetica"
														traits:NSBoldFontMask
														weight:0
														  size:18];
		NSDictionary *attrPresetsLabel = [NSDictionary dictionaryWithObjectsAndKeys:presetsLabelFont, NSFontAttributeName, nil];
        [[NSString stringWithFormat:@"Preset Parameters"] drawAtPoint:NSMakePoint(xPositionPresetsLabel, yPositionPresetsLabel) withAttributes:attrPresetsLabel];
        
        // presets
        NSFont *presetsFont = [fontManager fontWithFamily:@"Helvetica"
												   traits:NSBoldFontMask
												   weight:0
													 size:16];		
        NSDictionary *attrPresets = [NSDictionary dictionaryWithObjectsAndKeys:presetsFont, NSFontAttributeName, nil];
        h = yPositionView3+15;
		int w = 25;
		int numberOfRows = [_presetParameters count]/4;
		int c2=0;
		NSSize offsetSize;
		
		int counter;
		for(counter=0; counter <4; counter++)
		{
			NSString *label = [_presetHeaders objectAtIndex:counter];
			NSSize labelSize = [label sizeWithAttributes:attrPresets];
			NSRect labelRect = NSMakeRect(w, h, labelSize.width, labelSize.height);
			[label drawInRect:labelRect withAttributes:attrPresets];
			w+=250;
			offsetSize = labelSize;
		}
		
		w = 25;
		h = offsetSize.height + 10 + h;
				
        for (NSMutableDictionary *tmpDict in _presetParameters) {
            for (NSString *key in tmpDict) {
                NSString *parameter = [tmpDict valueForKey:key];
                //NSSize labelSize = [key sizeWithAttributes:attrParameters];
                NSSize parameterSize = [parameter sizeWithAttributes:attrParameters];
                //NSRect labelRect = NSMakeRect(w, h, labelSize.width, labelSize.height);
                NSRect parameterRect = NSMakeRect(w, h, parameterSize.width, parameterSize.height);
                //[key drawInRect:labelRect withAttributes:attrParameters];
                [parameter drawInRect:parameterRect withAttributes:attrParameters];
                h = parameterSize.height + 10 + h;

				c2++; 
				if ((c2%numberOfRows) == 0){
					h = offsetSize.height + 10 + yPositionView3+15;
					w += 250; 
					
				}
            }
        }
		
		
    } else if (_layoutType == 2) {
        
        // *** Rect 1 ***
        NSInteger marginTopRect1 = 75;
        NSInteger widthRect1 = (frameSize.width/2)-frameOffSet*2;
        NSInteger heightRect1 = (frameSize.height/(2*factor))-frameOffSet*2;
        NSRect rect1 = NSMakeRect(frameSize.width/2, frameOffSet+marginTopRect1, widthRect1, heightRect1);
        NSInteger marginRect1 = 20;
        
        // *** Label View 1 ***
        NSInteger xPositionLabelView1 = rect1.origin.x+marginRect1;
        NSInteger yPositionLabelView1 = rect1.origin.y+marginRect1;
        //        NSFont *labelFontView1 = [NSFont fontWithName:@"Helvetica" size:18];
        NSFont *labelFontView1 = [fontManager fontWithFamily:@"Helvetica"
                                                      traits:NSBoldFontMask
                                                      weight:0
                                                        size:18];
        NSDictionary *attrLabelView1 = [NSDictionary dictionaryWithObjectsAndKeys:labelFontView1, NSFontAttributeName, nil];
        [[NSString stringWithFormat:@"Arterial ROI"] drawAtPoint:NSMakePoint(xPositionLabelView1, yPositionLabelView1) withAttributes:attrLabelView1];
        
        // *** View 1 ***
        NSInteger distanceLabel1 = 25;
        NSInteger offSetBottomView1 = 100;    
        NSInteger xPositionView1 = rect1.origin.x+marginRect1;
        NSInteger yPositionView1 = yPositionLabelView1+distanceLabel1;
        NSInteger widthView1 = rect1.size.width-marginRect1;
        NSInteger heightView1 = rect1.size.height-marginRect1-distanceLabel1-offSetBottomView1;
        NSRect rectView1 = NSMakeRect(xPositionView1, yPositionView1, widthView1, heightView1);
        
        NSBitmapImageRep *imageRepView1 = [_view1 bitmapImageRepForCachingDisplayInRect:[_view1 bounds]];
        unsigned char *bitmapDataView1 = [imageRepView1 bitmapData];
        if (bitmapDataView1)
            bzero(bitmapDataView1, [imageRepView1 pixelsWide]*[imageRepView1 pixelsHigh]);
        [_view1 cacheDisplayInRect:[_view1 bounds] toBitmapImageRep:imageRepView1];
        
        NSImage *imageView1 = [[NSImage alloc] init];
        [imageView1 addRepresentation:imageRepView1];
        [imageView1 drawInRect:rectView1 fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
        [imageView1 release];
        
        // *** Legend View 1 ***
        NSInteger marginLegendLeftView1 = 50;
        NSInteger xPositionLegendView1 = rect1.origin.x+marginRect1+marginLegendLeftView1;
        NSInteger yPositionLegendView1 = rectView1.origin.y+rectView1.size.height;
        
        NSFont *legendFontView1 = [NSFont fontWithName:@"Helvetica" size:16];
        NSDictionary *attrLegendView1 = [NSDictionary dictionaryWithObjectsAndKeys:legendFontView1, NSFontAttributeName, nil];
        [[NSString stringWithFormat:@"Arterial"] drawAtPoint:NSMakePoint(xPositionLegendView1, yPositionLegendView1) withAttributes:attrLegendView1];
        [[NSString stringWithFormat:@"Baseline"] drawAtPoint:NSMakePoint(xPositionLegendView1+125, yPositionLegendView1) withAttributes:attrLegendView1];
        
        NSInteger xPositionLegendColorArterial = xPositionLegendView1+65;
        NSInteger yPositionLegendColorArterial = yPositionLegendView1+3;
        NSInteger arterialColorSize = 15;
        NSRect arterialColorRect = NSMakeRect(xPositionLegendColorArterial, yPositionLegendColorArterial, arterialColorSize, arterialColorSize);
        [[NSColor greenColor] set];
        NSRectFill(arterialColorRect);
        
        NSInteger xPositionLegendColorBaseline = xPositionLegendView1+205;
        NSInteger yPositionLegendColorBaseline = yPositionLegendView1+3;
        NSInteger baselineColorSize = 15;
        NSRect baselineColorRect = NSMakeRect(xPositionLegendColorBaseline, yPositionLegendColorBaseline, baselineColorSize, baselineColorSize);
        [[NSColor redColor] set];
        NSRectFill(baselineColorRect);
        
        // *** Rect2 ***
        NSInteger marginTopRect2 = 50;
        NSInteger widthRect2 = (frameSize.width/2)-frameOffSet*2;
        NSInteger heightRect2 = (frameSize.height/(2*factor))-frameOffSet*2;
        NSRect rect2 = NSMakeRect(frameSize.width/2, frameSize.height/(2*factor)+350, widthRect2, heightRect2-marginTopRect2);
        
        NSInteger marginRect2 = 20;
        
        //*** Label View 2 ***
        NSInteger xPositionLabelView2 = rect2.origin.x+marginRect2;
        NSInteger yPositionLabelView2 = rect2.origin.y+marginRect2;
        NSFont *labelFontView2 = [fontManager fontWithFamily:@"Helvetica"
                                                      traits:NSBoldFontMask
                                                      weight:0
                                                        size:18];
        NSDictionary *attrLabelView2 = [NSDictionary dictionaryWithObjectsAndKeys:labelFontView2, NSFontAttributeName, nil];
        [[NSString stringWithFormat:@"Screenshot of arterial Roi"] drawAtPoint:NSMakePoint(xPositionLabelView2, yPositionLabelView2) withAttributes:attrLabelView2];

        // *** View 2 ***
        NSInteger distanceLabel2 = 20;
        NSInteger xPositionView2 = xPositionLabelView2;
        NSInteger yPositionView2 = yPositionLabelView2+distanceLabel2+marginRect2;
        NSInteger widthView2 = widthRect2-distanceLabel2;
        NSInteger heightView2 = heightRect2-marginTopRect2-distanceLabel2-marginTopRect2;
        //NSRect rectView2 = NSMakeRect(xPositionView2, yPositionView2, widthView2, heightView2);
        
        // *** NSImage from DCMView ***
        NSImageView *imageView = (NSImageView*)_view2;
        NSImage *image = [imageView image];
        NSSize imageSize = [image size];
        NSInteger imageHeight = heightView2;
        NSInteger imageWidth = (imageSize.width/imageSize.height)*imageHeight;
        NSRect imageRect = NSMakeRect(xPositionView2+widthView2/(2)-imageWidth/(2), yPositionView2, imageWidth, imageHeight);
        [image drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
        // *** EndRect 2 ***
        
        // parameters label
        NSInteger xPositionParametersLabel = 25;
        NSInteger yPositionParametersLabel = rect1.origin.y+marginRect1;
        //        NSFont *parametersLabelFont = [NSFont fontWithName:@"Helvetica" size:18];
        NSFont *parametersLabelFont = [fontManager fontWithFamily:@"Helvetica"
                                                           traits:NSBoldFontMask
                                                           weight:0
                                                             size:18];
        NSDictionary *attrParametersLabel = [NSDictionary dictionaryWithObjectsAndKeys:parametersLabelFont, NSFontAttributeName, nil];
        [[NSString stringWithFormat:@"Input Parameters"] drawAtPoint:NSMakePoint(xPositionParametersLabel, yPositionParametersLabel) withAttributes:attrParametersLabel];
        
        // parameters
        NSFont *parametersFont = [NSFont fontWithName:@"Helvetica" size:16];
        NSDictionary *attrParameters = [NSDictionary dictionaryWithObjectsAndKeys:parametersFont, NSFontAttributeName, nil];
        int h = yPositionView1+15;
//        for (NSMutableDictionary *tmpDict in _inputParameters) {
//            for (NSString *key in tmpDict) {
//                NSString *parameter = [tmpDict valueForKey:key];
//                NSSize labelSize = [key sizeWithAttributes:attrParameters];
//                NSSize parameterSize = [parameter sizeWithAttributes:attrParameters];
//                NSRect labelRect = NSMakeRect(25, h, labelSize.width, labelSize.height);
//                NSRect parameterRect = NSMakeRect(270, h, parameterSize.width, parameterSize.height);
//                [key drawInRect:labelRect withAttributes:attrParameters];
//                [parameter drawInRect:parameterRect withAttributes:attrParameters];
//                h = labelSize.height + 7 + h;
//            }
//        }
        for (NSMutableDictionary *tmpDict in _inputParameters) {
            for (NSString *key in tmpDict) {
                NSString *parameter = [tmpDict valueForKey:key];
                NSSize labelSize = [key sizeWithAttributes:attrParameters];
                NSSize parameterSize = [parameter sizeWithAttributes:attrParameters];
                NSInteger dynamicSize = labelSize.height;
                NSRect labelRect;
                NSRect parameterRect;
                                
                // Dynamic
                if (labelSize.width > 260 || parameterSize.width > 260) {
                    
                    if (labelSize.height > parameterSize.height) {
                        double tmp = ceil((labelSize.width/260));
                        dynamicSize = labelSize.height*tmp;
                    } else {
                        double tmp = ceil((parameterSize.width/260));
                        dynamicSize = parameterSize.height*tmp;
                    }
                    
                    labelRect = NSMakeRect(25, h, 260, dynamicSize);
                    parameterRect = NSMakeRect(270, h, 260, dynamicSize);
                } else {
                    labelRect = NSMakeRect(25, h, labelSize.width, labelSize.height);
                    parameterRect = NSMakeRect(270, h, parameterSize.width, parameterSize.height);
                }
                
                [key drawInRect:labelRect withAttributes:attrParameters];
                [parameter drawInRect:parameterRect withAttributes:attrParameters];
                h = dynamicSize + 7 + h;
            }
        }
		
		
		// *** Rect3 ***
        NSInteger marginTopRect3 = 150;
        NSInteger widthRect3 = (frameSize.width)-frameOffSet*4;
        NSInteger heightRect3 = (frameSize.height/(5))-frameOffSet*2;
        NSRect rect3 = NSMakeRect(25, frameSize.height/(2*factor)+marginTopRect3, widthRect3, heightRect3);
        NSInteger marginRect3 = 20;
		//[[NSColor blueColor] set];
		//		NSRectFill(rect3);
		
		//NSInteger xPositionLabelView3 = rect3.origin.x+marginRect3;
        NSInteger yPositionLabelView3 = rect3.origin.y+marginRect3;
		
		NSInteger distanceLabel3 = 25;
        //NSInteger offSetBottomView3 = 100;
        //NSInteger xPositionView3 = xPositionLabelView3;
        NSInteger yPositionView3 = yPositionLabelView3+distanceLabel3;
        //NSInteger widthView3 = rect3.size.width-marginRect3;
        //NSInteger heightView3 = rect3.size.height-marginRect3-distanceLabel3-offSetBottomView3;	       		
        
		NSInteger xPositionPresetsLabel = 25;
        NSInteger yPositionPresetsLabel = rect3.origin.y+marginRect3;
        //        NSFont *parametersLabelFont = [NSFont fontWithName:@"Helvetica" size:18];
        NSFont *presetsLabelFont = [fontManager fontWithFamily:@"Helvetica"
														traits:NSBoldFontMask
														weight:0
														  size:18];
		NSDictionary *attrPresetsLabel = [NSDictionary dictionaryWithObjectsAndKeys:presetsLabelFont, NSFontAttributeName, nil];
        [[NSString stringWithFormat:@"Preset Parameters"] drawAtPoint:NSMakePoint(xPositionPresetsLabel, yPositionPresetsLabel) withAttributes:attrPresetsLabel];
        
        // presets
        NSFont *presetsFont = [fontManager fontWithFamily:@"Helvetica"
												   traits:NSBoldFontMask
												   weight:0
													 size:16];		
        NSDictionary *attrPresets = [NSDictionary dictionaryWithObjectsAndKeys:presetsFont, NSFontAttributeName, nil];
        h = yPositionView3+15;
		int w = 25;
		int numberOfRows = [_presetParameters count]/4;
		int c2=0;
		NSSize offsetSize;
		
		int counter;
		for(counter=0; counter <4; counter++)
		{
			NSString *label = [_presetHeaders objectAtIndex:counter];
			NSSize labelSize = [label sizeWithAttributes:attrPresets];
			NSRect labelRect = NSMakeRect(w, h, labelSize.width, labelSize.height);
			[label drawInRect:labelRect withAttributes:attrPresets];
			w+=250;
			offsetSize = labelSize;
		}
		
		w = 25;
		h = offsetSize.height + 10 + h;
		
        for (NSMutableDictionary *tmpDict in _presetParameters) {
            for (NSString *key in tmpDict) {
                NSString *parameter = [tmpDict valueForKey:key];
                //NSSize labelSize = [key sizeWithAttributes:attrParameters];
                NSSize parameterSize = [parameter sizeWithAttributes:attrParameters];
                //NSRect labelRect = NSMakeRect(w, h, labelSize.width, labelSize.height);
                NSRect parameterRect = NSMakeRect(w, h, parameterSize.width, parameterSize.height);
                //[key drawInRect:labelRect withAttributes:attrParameters];
                [parameter drawInRect:parameterRect withAttributes:attrParameters];
                h = parameterSize.height + 10 + h;
				
				c2++; 
				if ((c2%numberOfRows) == 0){
					h = offsetSize.height + 10 + yPositionView3+15;
					w += 250; 
					
				}
            }
        }
        
        if ([_outputParameters count]) {
        
            // result label
            NSInteger xPositionResultsLabel = 25;
            NSInteger yPositionResultsLabel = rect2.origin.y+marginRect2;
            //        NSFont *parametersLabelFont = [NSFont fontWithName:@"Helvetica" size:18];
            NSFont *resultsLabelFont = [fontManager fontWithFamily:@"Helvetica"
                                                            traits:NSBoldFontMask
                                                            weight:0
                                                              size:18];
            NSDictionary *attrResultsLabel = [NSDictionary dictionaryWithObjectsAndKeys:resultsLabelFont, NSFontAttributeName, nil];
            [[NSString stringWithFormat:@"Output Parameters"] drawAtPoint:NSMakePoint(xPositionResultsLabel, yPositionResultsLabel) withAttributes:attrResultsLabel];
            
            // results
            NSFont *resultsFont = [NSFont fontWithName:@"Helvetica" size:16];
            NSDictionary *attrResults = [NSDictionary dictionaryWithObjectsAndKeys:resultsFont, NSFontAttributeName, nil];
            h = yPositionView2+15;
            for (NSMutableDictionary *tmpDict in _outputParameters) {
                for (NSString *key in tmpDict) {
                    NSString *parameter = [tmpDict valueForKey:key];
                    NSSize labelSize = [key sizeWithAttributes:attrParameters];
                    NSSize parameterSize = [parameter sizeWithAttributes:attrParameters];
                    NSRect labelRect = NSMakeRect(25, h, labelSize.width, labelSize.height);
                    NSRect parameterRect = NSMakeRect(270, h, parameterSize.width, parameterSize.height);
                    [key drawInRect:labelRect withAttributes:attrParameters];
                    [parameter drawInRect:parameterRect withAttributes:attrResults];
                    h = labelSize.height + 10 + h;
                }
            }
        }		
        
    }
	
	else if (_layoutType == 3) {
	
		// *** Rect 1 ***
        NSInteger marginTopRect1 = 75;
        NSInteger widthRect1 = (frameSize.width/2)-frameOffSet*2;
        NSInteger heightRect1 = (frameSize.height/(2*factor))-frameOffSet*2;
        NSRect rect1 = NSMakeRect(frameSize.width/2, frameOffSet+marginTopRect1, widthRect1, heightRect1);
        NSInteger marginRect1 = 20;
        
        // *** Label View 1 ***
        NSInteger xPositionLabelView1 = rect1.origin.x+marginRect1;
        NSInteger yPositionLabelView1 = rect1.origin.y+marginRect1;
        //        NSFont *labelFontView1 = [NSFont fontWithName:@"Helvetica" size:18];
        NSFont *labelFontView1 = [fontManager fontWithFamily:@"Helvetica"
                                                      traits:NSBoldFontMask
                                                      weight:0
                                                        size:18];
        NSDictionary *attrLabelView1 = [NSDictionary dictionaryWithObjectsAndKeys:labelFontView1, NSFontAttributeName, nil];
        [[NSString stringWithFormat:@"Arterial ROI"] drawAtPoint:NSMakePoint(xPositionLabelView1, yPositionLabelView1) withAttributes:attrLabelView1];
        
        // *** View 1 ***
        NSInteger distanceLabel1 = 25;
        NSInteger offSetBottomView1 = 100;    
        NSInteger xPositionView1 = rect1.origin.x+marginRect1;
        NSInteger yPositionView1 = yPositionLabelView1+distanceLabel1;
        NSInteger widthView1 = rect1.size.width-marginRect1;
        NSInteger heightView1 = rect1.size.height-marginRect1-distanceLabel1-offSetBottomView1;
        NSRect rectView1 = NSMakeRect(xPositionView1, yPositionView1, widthView1, heightView1);
        
        NSBitmapImageRep *imageRepView1 = [_view1 bitmapImageRepForCachingDisplayInRect:[_view1 bounds]];
        unsigned char *bitmapDataView1 = [imageRepView1 bitmapData];
        if (bitmapDataView1)
            bzero(bitmapDataView1, [imageRepView1 pixelsWide]*[imageRepView1 pixelsHigh]);
        [_view1 cacheDisplayInRect:[_view1 bounds] toBitmapImageRep:imageRepView1];
        
        NSImage *imageView1 = [[NSImage alloc] init];
        [imageView1 addRepresentation:imageRepView1];
        [imageView1 drawInRect:rectView1 fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
        [imageView1 release];
        
        // *** Legend View 1 ***
        NSInteger marginLegendLeftView1 = 50;
        NSInteger xPositionLegendView1 = rect1.origin.x+marginRect1+marginLegendLeftView1;
        NSInteger yPositionLegendView1 = rectView1.origin.y+rectView1.size.height;
        
        NSFont *legendFontView1 = [NSFont fontWithName:@"Helvetica" size:16];
        NSDictionary *attrLegendView1 = [NSDictionary dictionaryWithObjectsAndKeys:legendFontView1, NSFontAttributeName, nil];
        [[NSString stringWithFormat:@"Arterial"] drawAtPoint:NSMakePoint(xPositionLegendView1, yPositionLegendView1) withAttributes:attrLegendView1];
        [[NSString stringWithFormat:@"Baseline"] drawAtPoint:NSMakePoint(xPositionLegendView1+125, yPositionLegendView1) withAttributes:attrLegendView1];
        
        NSInteger xPositionLegendColorArterial = xPositionLegendView1+65;
        NSInteger yPositionLegendColorArterial = yPositionLegendView1+3;
        NSInteger arterialColorSize = 15;
        NSRect arterialColorRect = NSMakeRect(xPositionLegendColorArterial, yPositionLegendColorArterial, arterialColorSize, arterialColorSize);
        [[NSColor greenColor] set];
        NSRectFill(arterialColorRect);
        
        NSInteger xPositionLegendColorBaseline = xPositionLegendView1+205;
        NSInteger yPositionLegendColorBaseline = yPositionLegendView1+3;
        NSInteger baselineColorSize = 15;
        NSRect baselineColorRect = NSMakeRect(xPositionLegendColorBaseline, yPositionLegendColorBaseline, baselineColorSize, baselineColorSize);
        [[NSColor redColor] set];
        NSRectFill(baselineColorRect);
        
        // *** Rect2 ***
        NSInteger marginTopRect2 = 50;
        NSInteger widthRect2 = (frameSize.width/2)-frameOffSet*2;
        NSInteger heightRect2 = (frameSize.height/(2*factor))-frameOffSet*2;
        NSRect rect2 = NSMakeRect(frameSize.width/2, frameSize.height/(2*factor)+50, widthRect2, heightRect2-marginTopRect2);
        
        NSInteger marginRect2 = 20;
        
        //*** Label View 2 ***
        NSInteger xPositionLabelView2 = rect2.origin.x+marginRect2;
        NSInteger yPositionLabelView2 = rect2.origin.y+marginRect2;
        NSFont *labelFontView2 = [fontManager fontWithFamily:@"Helvetica"
                                                      traits:NSBoldFontMask
                                                      weight:0
                                                        size:18];
        NSDictionary *attrLabelView2 = [NSDictionary dictionaryWithObjectsAndKeys:labelFontView2, NSFontAttributeName, nil];
        [[NSString stringWithFormat:@"Screenshot of arterial Roi"] drawAtPoint:NSMakePoint(xPositionLabelView2, yPositionLabelView2) withAttributes:attrLabelView2];
		
        // *** View 2 ***
        NSInteger distanceLabel2 = 20;
        NSInteger xPositionView2 = xPositionLabelView2;
        NSInteger yPositionView2 = yPositionLabelView2+distanceLabel2+marginRect2;
        NSInteger widthView2 = widthRect2-distanceLabel2;
        NSInteger heightView2 = heightRect2-marginTopRect2-distanceLabel2-marginTopRect2;
        //NSRect rectView2 = NSMakeRect(xPositionView2, yPositionView2, widthView2, heightView2);
        
        // *** NSImage from DCMView ***
        NSImageView *imageView = (NSImageView*)_view2;
        NSImage *image = [imageView image];
        NSSize imageSize = [image size];
        NSInteger imageHeight = heightView2;
        NSInteger imageWidth = (imageSize.width/imageSize.height)*imageHeight;
        NSRect imageRect = NSMakeRect(xPositionView2+widthView2/(2)-imageWidth/(2), yPositionView2, imageWidth, imageHeight);
        [image drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
        // *** EndRect 2 ***
        
        // parameters label
        NSInteger xPositionParametersLabel = 25;
        NSInteger yPositionParametersLabel = rect1.origin.y+marginRect1;
        //        NSFont *parametersLabelFont = [NSFont fontWithName:@"Helvetica" size:18];
        NSFont *parametersLabelFont = [fontManager fontWithFamily:@"Helvetica"
                                                           traits:NSBoldFontMask
                                                           weight:0
                                                             size:18];
        NSDictionary *attrParametersLabel = [NSDictionary dictionaryWithObjectsAndKeys:parametersLabelFont, NSFontAttributeName, nil];
        [[NSString stringWithFormat:@"Input Parameters"] drawAtPoint:NSMakePoint(xPositionParametersLabel, yPositionParametersLabel) withAttributes:attrParametersLabel];
        
        // parameters
        NSFont *parametersFont = [NSFont fontWithName:@"Helvetica" size:16];
        NSDictionary *attrParameters = [NSDictionary dictionaryWithObjectsAndKeys:parametersFont, NSFontAttributeName, nil];
        int h = yPositionView1+15;
		//        for (NSMutableDictionary *tmpDict in _inputParameters) {
		//            for (NSString *key in tmpDict) {
		//                NSString *parameter = [tmpDict valueForKey:key];
		//                NSSize labelSize = [key sizeWithAttributes:attrParameters];
		//                NSSize parameterSize = [parameter sizeWithAttributes:attrParameters];
		//                NSRect labelRect = NSMakeRect(25, h, labelSize.width, labelSize.height);
		//                NSRect parameterRect = NSMakeRect(270, h, parameterSize.width, parameterSize.height);
		//                [key drawInRect:labelRect withAttributes:attrParameters];
		//                [parameter drawInRect:parameterRect withAttributes:attrParameters];
		//                h = labelSize.height + 7 + h;
		//            }
		//        }
        for (NSMutableDictionary *tmpDict in _inputParameters) {
            for (NSString *key in tmpDict) {
                NSString *parameter = [tmpDict valueForKey:key];
                NSSize labelSize = [key sizeWithAttributes:attrParameters];
                NSSize parameterSize = [parameter sizeWithAttributes:attrParameters];
                NSInteger dynamicSize = labelSize.height;
                NSRect labelRect;
                NSRect parameterRect;
				
                // Dynamic
                if (labelSize.width > 260 || parameterSize.width > 260) {
                    
                    if (labelSize.height > parameterSize.height) {
                        double tmp = ceil((labelSize.width/260));
                        dynamicSize = labelSize.height*tmp;
                    } else {
                        double tmp = ceil((parameterSize.width/260));
                        dynamicSize = parameterSize.height*tmp;
                    }
                    
                    labelRect = NSMakeRect(25, h, 260, dynamicSize);
                    parameterRect = NSMakeRect(270, h, 260, dynamicSize);
                } else {
                    labelRect = NSMakeRect(25, h, labelSize.width, labelSize.height);
                    parameterRect = NSMakeRect(270, h, parameterSize.width, parameterSize.height);
                }
                
                [key drawInRect:labelRect withAttributes:attrParameters];
                [parameter drawInRect:parameterRect withAttributes:attrParameters];
                h = dynamicSize + 7 + h;
            }
        }
		
		
		// *** Rect3 ***
//        NSInteger marginTopRect3 = 50;
//        NSInteger widthRect3 = (frameSize.width)-frameOffSet*4;
//        NSInteger heightRect3 = (frameSize.height/(5))-frameOffSet*2;
//        NSRect rect3 = NSMakeRect(25, frameSize.height/(2*factor)+marginTopRect3, widthRect3, heightRect3);
//        NSInteger marginRect3 = 20;
//		//[[NSColor blueColor] set];
//		//		NSRectFill(rect3);
//		
//		//NSInteger xPositionLabelView3 = rect3.origin.x+marginRect3;
//        NSInteger yPositionLabelView3 = rect3.origin.y+marginRect3;
//		
//		NSInteger distanceLabel3 = 25;
//        //NSInteger offSetBottomView3 = 100;
//        //NSInteger xPositionView3 = xPositionLabelView3;
//        NSInteger yPositionView3 = yPositionLabelView3+distanceLabel3;
//        //NSInteger widthView3 = rect3.size.width-marginRect3;
//        //NSInteger heightView3 = rect3.size.height-marginRect3-distanceLabel3-offSetBottomView3;	       		
//        
//		NSInteger xPositionPresetsLabel = 25;
//        NSInteger yPositionPresetsLabel = rect3.origin.y+marginRect3;
//        //        NSFont *parametersLabelFont = [NSFont fontWithName:@"Helvetica" size:18];
//        NSFont *presetsLabelFont = [fontManager fontWithFamily:@"Helvetica"
//														traits:NSBoldFontMask
//														weight:0
//														  size:18];
//		NSDictionary *attrPresetsLabel = [NSDictionary dictionaryWithObjectsAndKeys:presetsLabelFont, NSFontAttributeName, nil];
//        [[NSString stringWithFormat:@"Preset Parameters"] drawAtPoint:NSMakePoint(xPositionPresetsLabel, yPositionPresetsLabel) withAttributes:attrPresetsLabel];
//        
//        // presets
//        NSFont *presetsFont = [fontManager fontWithFamily:@"Helvetica"
//												   traits:NSBoldFontMask
//												   weight:0
//													 size:16];		
//        NSDictionary *attrPresets = [NSDictionary dictionaryWithObjectsAndKeys:presetsFont, NSFontAttributeName, nil];
//        h = yPositionView3+15;
//		int w = 25;
//		int numberOfRows = [_presetParameters count]/4;
//		int c2=0;
//		NSSize offsetSize;
//		
//		int counter;
//		for(counter=0; counter <4; counter++)
//		{
//			NSString *label = [_presetHeaders objectAtIndex:counter];
//			NSSize labelSize = [label sizeWithAttributes:attrPresets];
//			NSRect labelRect = NSMakeRect(w, h, labelSize.width, labelSize.height);
//			[label drawInRect:labelRect withAttributes:attrPresets];
//			w+=250;
//			offsetSize = labelSize;
//		}
//		
//		w = 25;
//		h = offsetSize.height + 10 + h;
//		
//        for (NSMutableDictionary *tmpDict in _presetParameters) {
//            for (NSString *key in tmpDict) {
//                NSString *parameter = [tmpDict valueForKey:key];
//                //NSSize labelSize = [key sizeWithAttributes:attrParameters];
//                NSSize parameterSize = [parameter sizeWithAttributes:attrParameters];
//                //NSRect labelRect = NSMakeRect(w, h, labelSize.width, labelSize.height);
//                NSRect parameterRect = NSMakeRect(w, h, parameterSize.width, parameterSize.height);
//                //[key drawInRect:labelRect withAttributes:attrParameters];
//                [parameter drawInRect:parameterRect withAttributes:attrParameters];
//                h = parameterSize.height + 10 + h;
//				
//				c2++; 
//				if ((c2%numberOfRows) == 0){
//					h = offsetSize.height + 10 + yPositionView3+15;
//					w += 250; 
//					
//				}
//            }
//        }
        
        if ([_outputParameters count]) {
			
            // result label
            NSInteger xPositionResultsLabel = 25;
            NSInteger yPositionResultsLabel = rect2.origin.y+marginRect2 + 100;
            //        NSFont *parametersLabelFont = [NSFont fontWithName:@"Helvetica" size:18];
            NSFont *resultsLabelFont = [fontManager fontWithFamily:@"Helvetica"
                                                            traits:NSBoldFontMask
                                                            weight:0
                                                              size:18];
            NSDictionary *attrResultsLabel = [NSDictionary dictionaryWithObjectsAndKeys:resultsLabelFont, NSFontAttributeName, nil];
            [[NSString stringWithFormat:@"Output Parameters"] drawAtPoint:NSMakePoint(xPositionResultsLabel, yPositionResultsLabel) withAttributes:attrResultsLabel];
            
            // results
            NSFont *resultsFont = [NSFont fontWithName:@"Helvetica" size:16];
            NSDictionary *attrResults = [NSDictionary dictionaryWithObjectsAndKeys:resultsFont, NSFontAttributeName, nil];
            h = yPositionView2+ 100;
            for (NSMutableDictionary *tmpDict in _outputParameters) {
                for (NSString *key in tmpDict) {
                    NSString *parameter = [tmpDict valueForKey:key];
                    NSSize labelSize = [key sizeWithAttributes:attrParameters];
                    NSSize parameterSize = [parameter sizeWithAttributes:attrParameters];
                    NSRect labelRect = NSMakeRect(25, h, labelSize.width, labelSize.height);
                    NSRect parameterRect = NSMakeRect(270, h, parameterSize.width, parameterSize.height);
                    [key drawInRect:labelRect withAttributes:attrParameters];
                    [parameter drawInRect:parameterRect withAttributes:attrResults];
                    h = labelSize.height + 10 + h;
                }
            }
        }		
		
	}

}

// Flip the coordinate system to start in the upper left
- (BOOL)isFlipped
{
	return YES;
}

@end
