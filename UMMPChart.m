/*
 Copyright (c) 2012, Marcel Reich & Sven Kaiser & Markus Daab & Patrick Schülein & Engin Aslan
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 - Redistributions of source code must retain the above copyright notice,
 this list of conditions and the following disclaimer.
 - Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 - Neither the name of the Universitätsmedizin Mannheim nor the names of its
 contributors may be used to endorse or promote products derived from this
 software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 */

#import "UMMPChart.h"
#import "UMMPPanelController.h"
#import "UMMPROIList.h"
#import "UMMPBinding.h"

#import <OsiriXAPI/DCMPix.h>
#import <OsiriXAPI/DCMView.h>
#import <OsiriXAPI/ROI.h>
#import <OsiriXAPI/ViewerController.h>

#import "DCMObject.h"
#import "DCMCalendarDate.h"

#import <GRAxes.h>
#import <GRLineDataSet.h>

static UMMPChart *chart = nil;

@implementation UMMPChart

@synthesize stopDraw;

+ (UMMPChart *)chart
{
	return chart;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	chart = self;
	
	cache = [[NSMutableDictionary dictionaryWithCapacity:128] retain];
	[self setDelegate:self];
	[self setDataSource:self];
    
    // sets the identification for the x and y axis
    GRAxes *axes = [self axes];
    [axes setProperty: @"Signal (a.u.)" forKey: GRAxesYTitle];
    [axes setProperty: @"Timepoint" forKey: GRAxesXTitle];
    
	[self setProperty:[NSNumber numberWithBool:NO] forKey:GRChartDrawBackground];
	[[self axes] setProperty:[NSFont labelFontOfSize:[NSFont smallSystemFontSize]] forKey:GRAxesLabelFont];
	[[self axes] setProperty:[NSFont labelFontOfSize:[NSFont smallSystemFontSize]] forKey:GRAxesLabelFont];
	[[self axes] setProperty:[NSArray array] forKey:GRAxesMinorLineDashPattern];
	
	// set chart labels visible 
    [[self axes] setProperty:[NSNumber numberWithBool:YES] forKey:GRAxesDrawXLabels];
	[[self axes] setProperty:[NSNumber numberWithBool:YES] forKey:GRAxesDrawYLabels];
	
    // set chart ticks visible for the x-axis
	[[self axes] setProperty:[NSNumber numberWithBool:YES] forKey:GRAxesDrawXMajorTicks];
	[[self axes] setProperty:[NSNumber numberWithBool:YES] forKey:GRAxesDrawXMinorTicks];
	
    // set chart ticks visible for the y-axis
	[[self axes] setProperty:[NSNumber numberWithBool:YES] forKey:GRAxesDrawYMajorTicks];
	[[self axes] setProperty:[NSNumber numberWithBool:YES] forKey:GRAxesDrawYMinorTicks];
		
	// show chart only from Timepoint 0 to Timepoint 30
    [[self axes] setProperty:[NSNumber numberWithFloat:0] forKey:GRAxesXPlotMin];
	[[self axes] setProperty:[NSNumber numberWithFloat:0] forKey:GRAxesFixedXPlotMin];
	[[self axes] setProperty:[NSNumber numberWithFloat:30] forKey:GRAxesXPlotMax];
	[[self axes] setProperty:[NSNumber numberWithFloat:30] forKey:GRAxesFixedXPlotMax];
    
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeBaseLineLength:) name:NSControlTextDidChangeNotification object:nil];
}


- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[cache release]; cache = NULL;
	
	[super dealloc];
}


- (void)resetCursorRects
{
	[self addCursorRect:[self bounds] cursor:[NSCursor crosshairCursor]];
}

- (GRLineDataSet *)createOwnedLineDataSet
{
	GRLineDataSet *dataSet = [[GRLineDataSet alloc] initWithOwnerChart:self];
	[dataSet setProperty:[NSNumber numberWithBool:NO] forKey:GRDataSetDrawMarkers];
	
	return [dataSet autorelease];
}


- (void)refresh:(UMMPROIRec *)roiRec
{
	if (roiRec) {
		
		RGBColor rgb = [[roiRec roi] rgbcolor];
		NSColor* color = [NSColor colorWithDeviceRed:(float)(rgb.red)/0xffff green:(float)(rgb.green)/0xffff blue:(float)(rgb.blue)/0xffff alpha:1];
		[[roiRec meanDataSet] setProperty:color forKey:GRDataSetPlotColor];
		[cache removeObjectForKey:[roiRec roi]];
	} else {
		
		[cache removeAllObjects];
	}
    
    if ([roiRec tag] == [[[[controller algorithmController] venousButton] selectedItem] tag] || [roiRec tag] == [[[[controller algorithmController] arterialButton] selectedItem] tag] || [roiRec tag] == [[[[controller algorithmController] tissueButton] selectedItem] tag]) {
		[self setNeedsToReloadData:YES];
    }
}


- (NSInteger)chart:(GRChartView *)chart numberOfElementsForDataSet:(GRDataSet *)dataSet
{
    return [[controller viewerController] maxMovieIndex];
    
}


- (void)yValueForRoiRec:(UMMPROIRec *)roiRec element:(NSInteger)element min:(float *)min mean:(float *)mean max:(float *)max
{
    
    NSString *keyPix = [NSString stringWithFormat:@"%@", [[controller viewerController] pixList:element]];
    
    NSMutableDictionary *dictCache = [cache objectForKey:[roiRec roi]];
    
    if ([dictCache objectForKey:keyPix] == NULL) {
        
        // check if the ROIRec is from the external ROI and get the values of it
        if ([[controller roiList] externalRoiRecTag] == [roiRec tag]) {
            *mean = [[controller prefController] getAifValue:element];
            
        } else {
            [roiRec computeMeanValue:mean forImageIndex:element];
        }
        NSMutableDictionary *imageCache = [NSMutableDictionary dictionary];
        [imageCache setValue:[NSNumber numberWithFloat:*mean] forKey: @"mean"];
        
        if (!dictCache) {
            dictCache = [NSMutableDictionary dictionary];
            [cache setObject:dictCache forKey:[roiRec roi]];
        }
        
        [dictCache setObject:imageCache forKey:keyPix];
        
    } else {
        NSDictionary *imageCache = [dictCache objectForKey:keyPix];
        *mean = [[imageCache valueForKey:@"mean"] floatValue];
    }
}


- (double)chart:(GRChartView *)chart yValueForDataSet:(GRDataSet *)dataSet element:(NSInteger)element
{
	UMMPROIRec *roiRec = [[controller roiList] findRecordByDataSet:dataSet];
	
	float min = 0, mean = 0, max = 0;
	
	[self yValueForRoiRec:roiRec element:element min:&min mean:&mean max:&max];
    
	return mean;
}


- (NSString *)chart:(GRChartView *)chart yLabelForAxes:(GRAxes *)axes value:(double)value defaultLabel:(NSString *)defaultLabel
{
	return [NSString stringWithFormat:@"%1.0f", value];
}


- (void)mouseDown:(NSEvent *)theEvent
{
	float locationInWindow = round([[self axes] xValueAtPoint:[self convertPointFromBase:[theEvent locationInWindow]]]);
	int baselineCorrection = [[[self axes] propertyForKey:GRAxesXPlotMin] intValue];
	
    NSNumber *baselineLength = [NSNumber numberWithFloat: locationInWindow - baselineCorrection];
    [binding setValue:baselineLength forKey:@"baselineLength"];
	
	[self setNeedsDisplay:YES];
	[[self window] makeFirstResponder: self];
}


- (void)mouseDragged:(NSEvent*)theEvent {
	[self mouseDown:theEvent];
}

- (void)drawValue:(float)value
{
    int xPlotMin;
    int fixedXPlotMax;
    
    float pointX;
    float pointY;
    float inRangeX;
    float inRangeXLower;
    float deltaTValue = [controller deltaT];
    
    GRAxes *axes = [self axes];
    
    NSString *baseLineString;
    NSString *deltaTString;
    
    NSFont *font = [NSFont systemFontOfSize:[NSFont smallSystemFontSize]-2];
    NSGraphicsContext* context = [NSGraphicsContext currentContext];
    
    NSPoint linePoint1;
    NSPoint linePoint2;
    NSPoint baseLinePoint;
    NSPoint deltaTPoint;
    
    NSRect baseLine;
    NSRect deltaT;
    NSRect legendRect;
    NSRect bezierPathRect;
    NSRect plotRect = [[self axes] plotRect];
    
    NSSize baseLineSize;
    NSSize deltaTSize;
    
    xPlotMin = [[axes propertyForKey: GRAxesXPlotMin] intValue];
    fixedXPlotMax = [[axes propertyForKey: GRAxesFixedXPlotMax] intValue];
    pointX = [axes locationForXValue: (value + xPlotMin) yValue: 0 ].x;
    pointY = [axes locationForXValue:value yValue: 0].y;
    inRangeX = [axes locationForXValue: fixedXPlotMax yValue: 0].x;
    inRangeXLower = [axes locationForXValue: fixedXPlotMax-1 yValue: 0].x;
    
    linePoint1 = NSMakePoint(pointX, plotRect.origin.y);
    linePoint2 = NSMakePoint(pointX, plotRect.origin.y + plotRect.size.height);
	
	[context saveGraphicsState];
	[[NSBezierPath bezierPathWithRect: plotRect] setClip];
	[[NSColor redColor] setStroke];
	[NSBezierPath setDefaultLineWidth: 1];
	[NSBezierPath strokeLineFromPoint: linePoint1 toPoint: linePoint2];
	
	NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys: font,
                                 NSFontAttributeName,
                                 NULL];
	
	NSNumber * baselineLength1 = [binding valueForKey: @"baselineLength"];
	NSNumber * baselineOffset = [binding valueForKey:@"startSlider"];
	value = [baselineOffset floatValue]  + [baselineLength1 floatValue];
	
	
	baseLineString = [NSString stringWithFormat: @"Baseline: %1.0f", value];
    

	//value = [NSNumber numberWithFloat:([baselineOffset floatValue]  + [baselineLength1 floatValue])];

//    
//    ViewerController *vc;
//    NSString *modalityTag     = [NSString stringWithFormat:@"%04X,%04X", 0X0008, 0X0060];
//    NSString *modalityVal     = [controller getStringValueForDicomTag:modalityTag];
//    NSString *filePath= [[[vc pixList:0] objectAtIndex:0] sourceFile];
//    DCMObject *dcmObject = [DCMObject objectWithContentsOfFile:filePath decodingPixelData:NO];
//    
//    DCMSequenceAttribute *scanOptionsValue = (DCMSequenceAttribute *)[dcmObject attributeWithName:@"ScanOptions"];
//    NSString *adaptive4DSpiralValue = scanOptionsValue.values[1] ;
//

    
    
    
    //##################################################################--Adaptive-4D-Spiral--#######################################################################//
    // Part 4/4:
    // Visualisation of DeltaT in Chart:
    
    if ( ![controller isShuttleMode]){        
        deltaTString = [NSString stringWithFormat: @"∆t: %1.2f", deltaTValue];
    }
    else deltaTString = @"0.00";
    
    
    //
    // zurück zur To-Do-Liste unter Punkt 1/4 im UMMPPanelController.m
    
    //###############################################################################################################################################################//
    
	
	baseLineSize = [baseLineString sizeWithAttributes: attributes];
    deltaTSize = [deltaTString sizeWithAttributes: attributes];
	
	legendRect = NSMakeRect(0, 0, deltaTSize.width, 10);
	
	[NSBezierPath setDefaultLineWidth: 0];
	[[[NSColor whiteColor] colorWithAlphaComponent: .0] setFill];
	
	baseLinePoint = NSMakePoint(pointX, pointY);
    deltaTPoint = NSMakePoint(plotRect.origin.x + plotRect.size.width - legendRect.size.width-5,
                              plotRect.origin.y + plotRect.size.height-5 -legendRect.size.height);
	
	if ((inRangeX - pointX - 2) <= baseLineSize.width) { // Jump to the left
		baseLine = NSMakeRect(baseLinePoint.x-4 - baseLineSize.width,
                              baseLinePoint.y+2,
                              baseLineSize.width,
                              baseLineSize.height);
	} else if ((inRangeXLower - pointX) == baseLineSize.width) { // Jump to the right
		baseLine = NSMakeRect(baseLinePoint.x-4 - baseLineSize.width,
                              baseLinePoint.y+2,
                              baseLineSize.width,
                              baseLineSize.height);
	} else {
		baseLine = NSMakeRect(baseLinePoint.x+4,
                              baseLinePoint.y+2,
                              baseLineSize.width,
                              baseLineSize.height);
	}
	
	deltaT = NSMakeRect(deltaTPoint.x,
                        deltaTPoint.y,
                        deltaTSize.width,
                        deltaTSize.height);
	
    bezierPathRect = NSMakeRect(baseLine.origin.x-2,
                                baseLine.origin.y,
                                baseLine.size.width+3,
                                baseLine.size.height-1);
    
	[[NSBezierPath bezierPathWithRect: bezierPathRect] fill];
	[baseLineString drawInRect: baseLine withAttributes: attributes];
	//if (![deltaTString isEqualToString:@"A4DS"])
	[deltaTString drawInRect: deltaT withAttributes: attributes];
	
	[context restoreGraphicsState];
	
	[self setNeedsDisplay:YES];
}


- (void)drawRect:(NSRect)dirtyRect
{
	if (stopDraw) return;
	
	[super drawRect: dirtyRect];
	NSNumber *baselineLength = [binding valueForKey: @"baselineLength"];
	[self drawValue: [baselineLength floatValue]];
}


- (void)changeBaseLineLength:(NSNotification *)notification
{
	if ([notification object] == [[controller algorithmController] baseLineLength]) 
		[self setNeedsDisplay:YES];
}


- (NSImage *)image
{
	NSBitmapImageRep *imageRep = [self bitmapImageRepForCachingDisplayInRect:[self bounds]];
	unsigned char *bitmapData = [imageRep bitmapData];
	
	if (bitmapData)
		bzero(bitmapData, [imageRep pixelsWide]*[imageRep pixelsHigh]);
	
	[self cacheDisplayInRect:[self bounds] toBitmapImageRep:imageRep];
	
	NSImage *image = [[NSImage alloc] init];
	[image addRepresentation:imageRep];
	
	return [image autorelease];
}

@end
