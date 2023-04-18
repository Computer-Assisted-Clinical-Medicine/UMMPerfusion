//
//  UMMPReportChart.m
//  UMMPerfusion
//
//  Created by Sven Kaiser on 23.02.12.
//  Copyright (c) 2012, Marcel Reich & Sven Kaiser & Markus Daab & Patrick Schülein & Engin Aslan
//  All rights reserved.
//

#import "UMMPReportChart.h"
#import "GRAxes.h"

@implementation UMMPReportChart 

@synthesize baseLine;
@synthesize showBaseLine;
@synthesize data1;
@synthesize data2;
@synthesize dataSet1;
@synthesize dataSet2;


- (id)initWithFrame:(NSRect)fp8
{
    self = [super initWithFrame:fp8];
    if (self) {
        // do something
        cache = [[NSMutableDictionary dictionaryWithCapacity:128] retain];
        
        [self setDelegate:self];
        [self setDataSource:self];
    }
    return self;
}

- (void)dealloc
{
  	[cache release]; cache = NULL;
    [super dealloc];
}

// Delegates

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    if (showBaseLine) {
        [self drawValue: [baseLine floatValue]];
    }
}

- (NSInteger)chart:(GRChartView *)chart numberOfElementsForDataSet:(GRDataSet *)dataSet
{
	return [data1 count];
}

- (double)chart:(GRChartView *)chart yValueForDataSet:(GRDataSet *)dataSet element:(NSInteger)element
{
    if (dataSet == dataSet1)
        return [[data1 objectAtIndex:element] doubleValue];
    if (dataSet == dataSet2)
        return [[data2 objectAtIndex:element] doubleValue];
	return 0.0;
}

//

- (void)drawValue:(float)value
{
    int xPlotMin;
    int fixedXPlotMax;
    
    float pointX;
    float pointY;
    float inRangeX;
    float inRangeXLower;
    
    GRAxes *axes = [self axes];
    
//    NSString *baseLineString;
    
//    NSFont *font = [NSFont systemFontOfSize:[NSFont smallSystemFontSize]-2];
    NSGraphicsContext* context = [NSGraphicsContext currentContext];
    
    NSPoint linePoint1;
    NSPoint linePoint2;
    NSPoint baseLinePoint;
//    NSPoint deltaTPoint;
    
    NSRect baseLineRect;
//    NSRect deltaT;
//    NSRect legendRect;
    NSRect bezierPathRect;
    NSRect plotRect = [[self axes] plotRect];
    
    NSSize baseLineSize;
//    NSSize deltaTSize;
    
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
	
//	NSDictionary* attributes = [[NSDictionary dictionaryWithObjectsAndKeys: font,
//                                 NSFontAttributeName,
//                                 NULL] retain];
	
//	baseLineString = [NSString stringWithFormat: @"Baseline: %1.0f", value];
	
//	baseLineSize = [baseLineString sizeWithAttributes: attributes];
	
//	legendRect = NSMakeRect(0, 0, deltaTSize.width, 10);
	
	[NSBezierPath setDefaultLineWidth: 0];
	[[[NSColor whiteColor] colorWithAlphaComponent: .0] setFill];
	
	baseLinePoint = NSMakePoint(pointX, pointY);
//    deltaTPoint = NSMakePoint(plotRect.origin.x + plotRect.size.width - legendRect.size.width-5,
//                              plotRect.origin.y + plotRect.size.height-5 -legendRect.size.height);
	
	if ((inRangeX - pointX - 2) <= baseLineSize.width) { // Jump to the left
		baseLineRect = NSMakeRect(baseLinePoint.x-4 - baseLineSize.width,
                              baseLinePoint.y+2,
                              baseLineSize.width,
                              baseLineSize.height);
	} else if ((inRangeXLower - pointX) == baseLineSize.width) { // Jump to the right
		baseLineRect = NSMakeRect(baseLinePoint.x-4 - baseLineSize.width,
                              baseLinePoint.y+2,
                              baseLineSize.width,
                              baseLineSize.height);
	} else {
		baseLineRect = NSMakeRect(baseLinePoint.x+4,
                              baseLinePoint.y+2,
                              baseLineSize.width,
                              baseLineSize.height);
	}
	
//	deltaT = NSMakeRect(deltaTPoint.x,
//                        deltaTPoint.y,
//                        deltaTSize.width,
//                        deltaTSize.height);
	
    bezierPathRect = NSMakeRect(baseLineRect.origin.x-2,
                                baseLineRect.origin.y,
                                baseLineRect.size.width+3,
                                baseLineRect.size.height-1);
    
	[[NSBezierPath bezierPathWithRect: bezierPathRect] fill];
//	[baseLineString drawInRect: baseLineRect withAttributes: attributes];
	
	[context restoreGraphicsState];
	
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
