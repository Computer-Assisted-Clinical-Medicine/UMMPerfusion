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


#import "UMMPCMPanelController.h"
#import "UMMPReportChart.h"
#import "UMMPViewerList.h"
#import <OsiriXAPI/browserController.h>
#import <OsiriXAPI/DCMPix.h>
#import <OsiriXAPI/DCMView.h>
#import <OsiriXAPI/Wait.h>
#import <OsiriXAPI/DICOMExport.h>
#import <OsiriXAPI/Notifications.h>


@implementation UMMPCMPanelController

@synthesize mainController = _mainController;
@synthesize cmView = _cmView;
@synthesize name = _name;
@synthesize tracer=_tracer;
@synthesize para1 = _para1;
@synthesize value1 = _value1;
@synthesize unit1 = _unit1;
@synthesize para2 = _para2;
@synthesize value2 = _value2;
@synthesize unit2 = _unit2;
@synthesize para3 = _para3;
@synthesize value3 = _value3;
@synthesize unit3 = _unit3;
@synthesize para4 = _para4;
@synthesize value4 = _value4;
@synthesize unit4 = _unit4;
@synthesize para5 = _para5;
@synthesize value5 = _value5;
@synthesize unit5 = _unit5;
@synthesize para6 = _para6;
@synthesize value6 = _value6;
@synthesize unit6 = _unit6;
@synthesize para7 = _para7;
@synthesize value7 = _value7;
@synthesize unit7 = _unit7;
@synthesize para8 = _para8;
@synthesize value8 = _value8;
@synthesize unit8 = _unit8;
@synthesize para9 = _para9;
@synthesize value9 = _value9;
@synthesize unit9 = _unit9;
@synthesize para10 = _para10;
@synthesize value10 = _value10;
@synthesize unit10 = _unit10;
@synthesize inputParameter;
@synthesize outputParameter;
@synthesize presetParameter;

#pragma mark -
#pragma mark Methods

- (id)initWithViewer:(ViewerController *)viewer withMainController:(UMMPPanelController *)mainController andAifRoiData:(NSArray*)aifRoiData andTissueRoiRec:(UMMPROIRec*)tissueROI andTissueRoiData:(NSArray*)tissueRoiData andTissue:(NSArray *)tissue andFit:(NSArray *)fit andTime:(NSArray *)time andAlgorithmTag:(int)tag
{	
	self = [super initWithWindowNibName:@"UMMPCMPanel"];
	[self window];
   
	alreadyExported = NO;
	
    _tissueROIRec = [tissueROI retain];
    inputParameter = [[NSArray alloc] init];
    outputParameter = [[NSArray alloc] init];
	presetParameter = [[NSArray alloc] init];
    
	NSString *windowTitle= nil;
	if (tissueROI == nil) {                      //from ROI-based (normal/ from UMMPRoiBasedController
		windowTitle = [NSString stringWithFormat:@"%@ - %@ - %@", [[[mainController algorithmPopUpButton] selectedItem] title], [[[mainController algorithmController] tracerButton] titleOfSelectedItem], [[[[mainController algorithmController] tissueButton] selectedItem] title]];
		[[self window] setTitle:windowTitle];
	} else if (tag != -1){                           //from all agorithms controller
                NSString *windowTitle1 = nil;
        switch (tag) {
            case 0:
                windowTitle1 = @"Compartment Model";
                break;
            case 1:
               windowTitle1= @"2-Compartment Exchange";
                break;
            case 2:
                windowTitle1 = @"2-Compartment Filtration";
                break;
            case 3:
                windowTitle1 = @"2-Compartment Uptake";
                break;
            case 4:
                windowTitle1 = @"Modified Tofts";
                break;
            default:
                windowTitle1 = @"could not receive an appropriate title for this window";
                break;
        }
        
        NSString *windowTitle = [NSString stringWithFormat:@"%@ - %@ - %@", windowTitle1, [[[mainController algorithmController] tracerButton] titleOfSelectedItem], [[tissueROI roi] name]];
		[[self window] setTitle:windowTitle];
    }
        else {
            NSString *windowTitle = [NSString stringWithFormat:@"%@ - %@ - %@", [[[mainController   algorithmController]  algorithmButton] titleOfSelectedItem], [[[mainController algorithmController] tracerButton] titleOfSelectedItem], [[tissueROI roi] name]];
            [[self window] setTitle:windowTitle];
	}

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewerWillClose:) name:OsirixCloseViewerNotification object:viewer];
    
	_viewer = [viewer retain];
	_mainController = mainController;
    _aifRoiData = [[NSArray alloc] initWithArray:aifRoiData];
    _tissueRoiData = [[NSArray alloc] initWithArray:tissueRoiData];
	_tissue = [[NSArray alloc] initWithArray:tissue];
	_fit = [[NSArray alloc] initWithArray:fit];
    _time = [[NSArray alloc] initWithArray:time];
	
	// Create Chart for the ROI Based Algorithm
    tissueDataSet = [[[self dataSetClass] alloc] initWithOwnerChart: _chartView];
	[tissueDataSet setProperty: [NSNumber numberWithInt: 1] forKey: GRDataSetDrawPlotLine];
	[tissueDataSet setProperty: [NSNumber numberWithInt: 90] forKey: GRDataSetPieStartAngle];
	[tissueDataSet setProperty:[NSNumber numberWithBool:NO] forKey:GRDataSetDrawMarkers];
	
	fitDataSet = [[[self dataSetClass] alloc] initWithOwnerChart: _chartView];
	[fitDataSet setProperty: [NSNumber numberWithInt: 1] forKey: GRDataSetDrawPlotLine];
	[fitDataSet setProperty: [NSNumber numberWithInt: 90] forKey: GRDataSetPieStartAngle];
	[fitDataSet setProperty:[NSNumber numberWithBool:NO] forKey:GRDataSetDrawMarkers];
	
	[_chartView setProperty: [NSNumber numberWithInt: 0] forKey: GRChartDrawBackground];
	
    // sets the labels for the x and y axis
    GRAxes *axes = [_chartView axes];
    [axes setProperty: @"Signal (a.u.)" forKey: GRAxesYTitle];
    [axes setProperty: @"Time (sec)" forKey: GRAxesXTitle];
    
    // set chart labels visible
    [axes setProperty:[NSNumber numberWithBool:YES] forKey:GRAxesDrawXLabels];
	[axes setProperty:[NSNumber numberWithBool:YES] forKey:GRAxesDrawYLabels];
    
    // Force the Y-axis to display from zero supress negative values
//	GRAxes * axes = [_chartView axes];
//	[axes setProperty: [NSNumber numberWithInt: 0] forKey: @"GRAxesYPlotMin"];
//	[axes setProperty: [NSNumber numberWithInt: 1] forKey: @"GRAxesFixedYPlotMin"];
	
	NSColor *tissueColor = [NSColor redColor];
	NSColor *fitColor = [NSColor blackColor];
	
	[_tissueColorWell setColor:tissueColor];
	[_fitColorWell setColor:fitColor];
	
	[tissueDataSet setProperty:tissueColor forKey:GRDataSetPlotColor];
	[fitDataSet setProperty:fitColor forKey:GRDataSetPlotColor];
	
	[_chartView addDataSet: tissueDataSet loadData: YES];
	[tissueDataSet release];
	[_chartView addDataSet: fitDataSet loadData: YES];
	[fitDataSet release];
    
    // show ROI information ("2D Viewer --> Annotations --> Full" in OsiriX menubar)
    [[NSUserDefaults standardUserDefaults] setBool: NO forKey: @"ROITEXTIFSELECTED"];
	return self;
}


- (void)dealloc
{
	[inputParameter release]; inputParameter = NULL;
    [outputParameter release]; outputParameter = NULL;
	[presetParameter release]; presetParameter = NULL;
	[_viewer release]; _viewer = NULL;
    [_aifRoiData release]; _aifRoiData = NULL;
    [_tissueRoiData release]; _tissueRoiData = NULL;
    [_tissueROIRec release]; _tissueROIRec = NULL;
	[_tissue release]; _tissue = NULL;
	[_fit release]; _fit = NULL;
    [_time release]; _time = NULL;
	[super dealloc];
}


- (void)windowWillClose:(NSNotification *)notification
{
	if ([notification object] == [self window]) {
        [[_mainController cmControllerList] removeObject:self];
        [[self window] orderOut:self];
		[self release];
	}
}

- (void)viewerWillClose:(NSNotification *)notification
{
	[[self window] orderOut:self];
	[[self window] close];
}


- (Class) dataSetClass
{
	// Available: GRXYDataSet, GRPieDataSet, GRAreaDataSet, GRLineDataSet, GRColumnDataSet
	return [GRLineDataSet class];
}

- (IBAction)pushExportButton:(id)sender
{	
    Wait *splash =nil;
	if (!alreadyExported) {
        int tag = [[_mainController algorithmPopUpButton] selectedTag];
        
        if(sender){ 
            splash = [[Wait alloc] initWithString:NSLocalizedString(@"Saving current result...", nil)];
            [splash showWindow:self];
            [[splash progress] setMaxValue: 1];
            [splash setCancel: NO];
        }
        
		int seriesNumber = 85469 + [[NSCalendarDate date] minuteOfHour] + [[NSCalendarDate date] secondOfMinute] + [[_mainController algorithmPopUpButton] selectedTag];
		
		 NSString *exportName = [NSString stringWithFormat:@"%@ - UMMPerfusionReport MPCurveFit", [[self name] stringValue]];
        //NSString *selectedTag = [NSString stringWithFormat:@"%d", [[[_mainController algorithmController] algorithmButton] selectedTag]];
        NSString *selectedTag = [NSString stringWithFormat:@"%d", seriesNumber];
        
        if ( tag == 2 || tag == 3 || tag == 4 || tag == 5 || tag == 6) {
            if ([[_exportName stringValue] isEqualToString:@""]) {
                exportName = [NSString stringWithFormat:@"%@ - UMMPerfusionReport MPCurveFit", [[self name] stringValue]];
            } 
            else {
                exportName = [NSString stringWithFormat:@"%@ - %@ - UMMPerfusionReport MPCurveFit", [_exportName stringValue], [[self name] stringValue]];
            }
        }
        else if(tag == 12 || tag == 13)
        {
            if ([[[[_mainController algorithmController] exportNameTextField] stringValue] isEqualToString:@""]) {
                exportName = [NSString stringWithFormat:@"%@ - UMMPerfusionReport MPCurveFit",[[self name] stringValue]];
            }
            else {
                exportName = [NSString stringWithFormat:@"%@ - %@ - UMMPerfusionReport MPCurveFit", [[[_mainController algorithmController] exportNameTextField] stringValue] ,[[self name] stringValue]];
            }
        }
        
		int k;
        if ((k =[[_mainController userDefaults] int:@"INCOMINGcounter" otherwise:0])) {
            if (k == 1000) {
                k = 1;
            }
            [[_mainController userDefaults] setInt:++k forKey:@"INCOMINGcounter"];
        }
                       
        NSString *fileDirectory = [[[BrowserController currentBrowser] fixedDocumentsDirectory] stringByAppendingPathComponent: [NSString stringWithFormat:@"INCOMING.noindex/%@%@%d.dcm", exportName, selectedTag, k]];
		
		// create view1, max height 400
		NSRect chartRect1 = NSMakeRect(0, 0, 400, 400);
		UMMPReportChart *reportChart1 = [[UMMPReportChart alloc] initWithFrame:chartRect1];
		GRDataSet *dataSetAif = [[[self dataSetClass] alloc] initWithOwnerChart:reportChart1];
		[dataSetAif setProperty:[NSNumber numberWithInt:1] forKey:GRDataSetDrawPlotLine];
		[dataSetAif setProperty:[NSNumber numberWithInt:90] forKey:GRDataSetPieStartAngle];
		[dataSetAif setProperty:[NSNumber numberWithBool:NO] forKey:GRDataSetDrawMarkers];
		[dataSetAif setProperty:[NSColor greenColor] forKey:GRDataSetPlotColor];
		[reportChart1 setDataSet1:dataSetAif];
		
		GRDataSet *dataSetTissue = [[[self dataSetClass] alloc] initWithOwnerChart:reportChart1];
		[dataSetTissue setProperty:[NSNumber numberWithInt:1] forKey:GRDataSetDrawPlotLine];
		[dataSetTissue setProperty:[NSNumber numberWithInt:90] forKey:GRDataSetPieStartAngle];
		[dataSetTissue setProperty:[NSNumber numberWithBool:NO] forKey:GRDataSetDrawMarkers];
		[dataSetTissue setProperty:[NSColor blueColor] forKey:GRDataSetPlotColor];
		[reportChart1 setDataSet2:dataSetTissue];
		
		[reportChart1 setData1:_aifRoiData];
		[reportChart1 setData2:_tissueRoiData];
		
		float baseLine = 0.0;
		NSMutableArray *ip = [[_mainController algorithmController] inputParameter];
		for (NSMutableDictionary *aDict in ip) {
			for (NSString *key in aDict) {
				if ([key isEqualToString:@"Baseline:"]) {
					baseLine = [[aDict objectForKey:key] floatValue];
				}
			}
		}
		
		[reportChart1 setBaseLine:[NSNumber numberWithInt:baseLine]];
		[reportChart1 setShowBaseLine:YES];
		
		[reportChart1 addDataSet:dataSetAif loadData:YES];
		[dataSetAif release];
		[reportChart1 addDataSet:dataSetTissue loadData:YES];
		[dataSetTissue release];
		
		// create view2, max height 400
		NSRect chartRect2 = NSMakeRect(0, 0, 400, 400);
		UMMPReportChart *reportChart2 = [[UMMPReportChart alloc] initWithFrame:chartRect2];
		
		GRDataSet *dataSet3 = [[[self dataSetClass] alloc] initWithOwnerChart:reportChart2];
		[dataSet3 setProperty:[NSNumber numberWithInt:1] forKey:GRDataSetDrawPlotLine];
		[dataSet3 setProperty:[NSNumber numberWithInt:90] forKey:GRDataSetPieStartAngle];
		[dataSet3 setProperty:[NSNumber numberWithBool:NO] forKey:GRDataSetDrawMarkers];
		[dataSet3 setProperty:[NSColor redColor] forKey:GRDataSetPlotColor];
		[reportChart2 setDataSet1:dataSet3];
		
		GRDataSet *dataSet4 = [[[self dataSetClass] alloc] initWithOwnerChart:reportChart2];
		[dataSet4 setProperty:[NSNumber numberWithInt:1] forKey:GRDataSetDrawPlotLine];
		[dataSet4 setProperty:[NSNumber numberWithInt:90] forKey:GRDataSetPieStartAngle];
		[dataSet4 setProperty:[NSNumber numberWithBool:NO] forKey:GRDataSetDrawMarkers];
		[dataSet4 setProperty:[NSColor blackColor] forKey:GRDataSetPlotColor];
		[reportChart2 setDataSet2:dataSet4];
		
		[reportChart2 setData1:_tissue];
		[reportChart2 setData2:_fit];
		
		[reportChart2 addDataSet:dataSet3 loadData:YES];
		[dataSet3 release];
		[reportChart2 addDataSet:dataSet4 loadData:YES];
		[dataSet4 release];
		
		// report view
		NSRect reportRect = NSMakeRect(0, 0, 1024, 1024);
		NSInteger layoutType = 1;
    
		UMMPReport *report = [[UMMPReport alloc] initWithFrame:reportRect andLayoutType:layoutType andView1:reportChart1 andView2:reportChart2 andInputParameters:[NSArray arrayWithArray: inputParameter] andOutputParameters: [NSArray arrayWithArray:outputParameter] andPresetParameters:[NSArray arrayWithArray:presetParameter]];
		
		[self exportReport:report andSeriesDiscription:exportName seriesNumber:seriesNumber backgroundColor:[NSColor whiteColor] toFile:fileDirectory];
		
		[report release];
		[reportChart1 release];
		[reportChart2 release];
		alreadyExported = YES;
		
        if(splash){
            [splash incrementBy:1];
            [splash close];
            [splash release];
        }
    }
	else {
        NSString*newString = [NSString stringWithFormat: @"Report for %@-algorithm has been saved before",  [[self name] stringValue]];
        NSString*newString2 = [NSString stringWithFormat: @"%@\n Did not save it again to avoid duplicate data.", newString];
		NSRunAlertPanel(@"too many exports",newString2,  @"OK" ,nil,nil);
	}
}

- (void)setResults:(NSMutableDictionary *)dict
{
    NSString *name = [dict objectForKey:@"name"];
	NSString *tracer = [dict objectForKey:@"tracer"];
    NSString *para1 = [dict objectForKey:@"para1"];
    NSNumber *value1 = [dict objectForKey:@"value1"];
    NSString *unit1 = [dict objectForKey:@"unit1"];
    NSString *para2 = [dict objectForKey:@"para2"];
    NSNumber *value2 = [dict objectForKey:@"value2"];
    NSString *unit2 = [dict objectForKey:@"unit2"];
    NSString *para3 = [dict objectForKey:@"para3"];
    NSNumber *value3 = [dict objectForKey:@"value3"];
    NSString *unit3 = [dict objectForKey:@"unit3"];
    NSString *para4 = [dict objectForKey:@"para4"];
    NSNumber *value4 = [dict objectForKey:@"value4"];
    NSString *unit4 = [dict objectForKey:@"unit4"];
    NSString *para5 = [dict objectForKey:@"para5"];
    NSNumber *value5 = [dict objectForKey:@"value5"];
    NSString *unit5 = [dict objectForKey:@"unit5"];
    NSString *para6 = [dict objectForKey:@"para6"];
    NSNumber *value6 = [dict objectForKey:@"value6"];
    NSString *unit6 = [dict objectForKey:@"unit6"];
    NSString *para7 = [dict objectForKey:@"para7"];
    NSNumber *value7 = [dict objectForKey:@"value7"];
    NSString *unit7 = [dict objectForKey:@"unit7"];
    NSString *para8 = [dict objectForKey:@"para8"];
    NSNumber *value8 = [dict objectForKey:@"value8"];
    NSString *unit8 = [dict objectForKey:@"unit8"];
	NSString *para9 = [dict objectForKey:@"para9"];
    NSNumber *value9 = [dict objectForKey:@"value9"];
    NSString *unit9 = [dict objectForKey:@"unit9"];
    NSString *para10 = [dict objectForKey:@"para10"];
    NSNumber *value10 = [dict objectForKey:@"value10"];
    NSString *unit10 = [dict objectForKey:@"unit10"];
	
    
    if (name)
        [[self name] setStringValue:name];
    else
        [[self name] setStringValue:@""];
	
	if (tracer)
        [[self tracer] setStringValue:tracer];
    else
        [[self tracer] setStringValue:@""];
    
    if (para1)
        [[self para1] setStringValue:para1];
    else
        [[self para1] setStringValue:@""];
    if (value1 != NULL)
        [[self value1] setDoubleValue:[value1 doubleValue]];
    else
        [[self value1] setStringValue:@""];
    if (unit1)
        [[self unit1] setStringValue:unit1];
    else
        [[self unit1] setStringValue:@""];
    
    if (para2)
        [[self para2] setStringValue:para2];
    else
        [[self para2] setStringValue:@""];
    if (value2 != NULL)
        [[self value2] setDoubleValue:[value2 doubleValue]];
    else
        [[self value2] setStringValue:@""];
    if (unit2)
        [[self unit2] setStringValue:unit2];
    else
        [[self unit2] setStringValue:@""];
    
    if (para3)
        [[self para3] setStringValue:para3];
    else
        [[self para3] setStringValue:@""];
    if (value3 != NULL)
        [[self value3] setDoubleValue:[value3 doubleValue]];
    else
        [[self value3] setStringValue:@""];
    if (unit3)
        [[self unit3] setStringValue:unit3];
    else
        [[self unit3] setStringValue:@""];
    
    if (para4)
        [[self para4] setStringValue:para4];
    else
        [[self para4] setStringValue:@""];
    if (value4 != NULL)
        [[self value4] setDoubleValue:[value4 doubleValue]];
    else
        [[self value4] setStringValue:@""];
    if (unit4)
        [[self unit4] setStringValue:unit4];
    else
        [[self unit4] setStringValue:@""];
    
    if (para5)
        [[self para5] setStringValue:para5];
    else
        [[self para5] setStringValue:@""];
    if (value5 != NULL)
        [[self value5] setDoubleValue:[value5 doubleValue]];
    else
        [[self value5] setStringValue:@""];
    if (unit5)
        [[self unit5] setStringValue:unit5];
    else
        [[self unit5] setStringValue:@""];
    
    if (para6)
        [[self para6] setStringValue:para6];
    else
        [[self para6] setStringValue:@""];
    if (value6 != NULL)
        [[self value6] setDoubleValue:[value6 doubleValue]];
    else
        [[self value6] setStringValue:@""];
    if (unit6)
        [[self unit6] setStringValue:unit6];
    else
        [[self unit6] setStringValue:@""];
    
    if (para7)
        [[self para7] setStringValue:para7];
    else
        [[self para7] setStringValue:@""];
    if (value7 != NULL)
        [[self value7] setDoubleValue:[value7 doubleValue]];
    else
        [[self value7] setStringValue:@""];
    if (unit7)
        [[self unit7] setStringValue:unit7];
    else
        [[self unit7] setStringValue:@""];
    
    if (para8)
        [[self para8] setStringValue:para8];
    else
        [[self para8] setStringValue:@""];
    if (value8 != NULL)
        [[self value8] setDoubleValue:[value8 doubleValue]];
    else
        [[self value8] setStringValue:@""];
    if (unit8)
        [[self unit8] setStringValue:unit8];
    else
        [[self unit8] setStringValue:@""];
	
	if (para9)
        [[self para9] setStringValue:para9];
    else
        [[self para9] setStringValue:@""];
    if (value9 != NULL)
        [[self value9] setDoubleValue:[value9 doubleValue]];
    else
        [[self value9] setStringValue:@""];
    if (unit9)
        [[self unit9] setStringValue:unit9];
    else
        [[self unit9] setStringValue:@""];
    
    if (para10)
        [[self para10] setStringValue:para10];
    else
        [[self para10] setStringValue:@""];
    if (value10 != NULL)
        [[self value10] setDoubleValue:[value10 doubleValue]];
    else
        [[self value10] setStringValue:@""];
    if (unit10)
        [[self unit10] setStringValue:unit10];
    else
        [[self unit10] setStringValue:@""];
}


- (void)exportReport:(UMMPReport*)report andSeriesDiscription:(NSString*)seriesDescription seriesNumber:(int)seriesNumber backgroundColor:(NSColor*)backgroundColor toFile:(NSString*)filename
{
	int x, y;
	
	NSBitmapImageRep* bitmapImageRep = [report bitmapImageRepForCachingDisplayInRect:[report bounds]];
	[report cacheDisplayInRect:[report bounds] toBitmapImageRep:bitmapImageRep];
	NSInteger bytesPerPixel = [bitmapImageRep bitsPerPixel]/8;
	CGFloat backgroundRGBA[4]; [[backgroundColor colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]] getComponents:backgroundRGBA];
	
	// convert RGBA to RGB - alpha values are considered when mixing the background color with the actual pixel color
	NSMutableData* bitmapRGBData = [NSMutableData dataWithCapacity: [bitmapImageRep size].width*[bitmapImageRep size].height*3];
	for (y = 0; y < [bitmapImageRep size].height; ++y)
	{
		unsigned char* rowStart = [bitmapImageRep bitmapData]+[bitmapImageRep bytesPerRow]*y;
		for (x = 0; x < [bitmapImageRep size].width; ++x)
		{
			unsigned char rgba[4];
			memcpy(rgba, rowStart+bytesPerPixel*x, 4);
			
			float ratio = (float) rgba[3] /255.;
			
			rgba[0] = ratio*rgba[0]+(1-ratio)*backgroundRGBA[0]*255;
			rgba[1] = ratio*rgba[1]+(1-ratio)*backgroundRGBA[1]*255;
			rgba[2] = ratio*rgba[2]+(1-ratio)*backgroundRGBA[2]*255;
			[bitmapRGBData appendBytes:rgba length:3];
		}
	}
	
	if ([[ViewerController getDisplayed2DViewers] count]) {
		
		DICOMExport* dicomExport = [[DICOMExport alloc] init];
		
		NSString *dicomSourceFile = [[[[[ViewerController getDisplayed2DViewers] objectAtIndex: 0] imageView] curDCM] sourceFile];
		                
		[dicomExport setSourceFile: dicomSourceFile];
		[dicomExport setSeriesDescription: seriesDescription];
		[dicomExport setSeriesNumber: seriesNumber];
		[dicomExport setPixelData:(unsigned char*)[bitmapRGBData bytes]
				   samplePerPixel:3
					 bitsPerPixel:8
							width:[bitmapImageRep size].width
						   height:[bitmapImageRep size].height];
		[dicomExport writeDCMFile:filename];
		[dicomExport release];
	}
	
}


// Delegate methods for GRChartView

- (NSInteger) chart: (GRChartView *)chartView numberOfElementsForDataSet: (GRDataSet *) dataSet
{
    // returns the number of the image series 
	return [_tissue count];
}

- (double) chart:(GRChartView *)chartView xValueForDataSet:(GRDataSet *)dataSet element:(NSInteger)element
{
    // returns the time in seconds of every image for the x axis
    return [[_time objectAtIndex: element] doubleValue];
}

- (double) chart:(GRChartView *)chartView yValueForDataSet:(GRDataSet *)dataSet element:(NSInteger) element
{
	if (dataSet == tissueDataSet) {
		return [[_tissue objectAtIndex: element] doubleValue];
	} else if (dataSet == fitDataSet) {
		return [[_fit objectAtIndex: element] doubleValue];
	} else {
		return 0.0;
	}
}

// saves the Parameters Time(sec), Timepoint, aif, tissue, tissue(normalized), and fit to an external file
// file format: txt and csv
- (IBAction)pushSaveFitToFileButton:(id)sender
{
    NSSavePanel *savePanel = nil;
    Wait *splash = nil;
    NSString *myString = nil;
    int i=0,j=0, counter=0;
    BOOL _txt = NO;
    BOOL _csv = NO;
    NSString *fileDirectory = nil;
    NSURL *fileDirectoryURL = nil;
    savePanel = [NSSavePanel savePanel]; 
       
    [savePanel setTitle:@"saving fit data"];
    [savePanel setAllowedFileTypes:nil];
    [savePanel setCanSelectHiddenExtension:NO];
    if ((_txt = [[_mainController userDefaults] int:@"UMMPdotTxtCheckbox" otherwise:0])) {
        [_dotTxtCheckbox setState:_txt];
    }
    if ((_csv = [[_mainController userDefaults] int:@"UMMPdotCsvCheckbox" otherwise:0])) {
        [_dotCsvCheckbox setState:_csv];
    }
    [savePanel setAccessoryView:_savePanelView]; 
    
    NSInteger returnValue = [savePanel runModal];
    if (returnValue != NSFileHandlingPanelOKButton) {
        return;
    }
           
    _txt = [_dotTxtCheckbox state];
    _csv = [_dotCsvCheckbox state];
    if(_txt)counter++;
    if(_csv)counter++;
   
    if(!(_txt || _csv)) {
        //NSString*newString = [NSString stringWithFormat: @"",  ];
		NSRunAlertPanel(@"too few arguments",@"Please select at least one file extension.",  @"OK" ,nil,nil);
        
	}    
    else 
    {   
    
        splash = [[Wait alloc] initWithString:NSLocalizedString(@"Saving current fit data to file...", nil)];
        [splash showWindow:self];
        [[splash progress] setMaxValue:[_aifRoiData count]*counter];
        [splash setCancel: NO];
        
        for (j=0; j<counter; j++){
            myString = [NSString stringWithFormat:@""];    
            
            fileDirectoryURL = [savePanel URL];
            fileDirectory = [fileDirectoryURL absoluteString];
            
            if ((_txt)&&(j==0)) {
                fileDirectory =[NSString stringWithFormat:@"%@.txt", fileDirectory];
                myString = [NSString stringWithFormat:@"%@FitCurve Data\n\n", myString];
                myString = [NSString stringWithFormat:@"%@time(sec)\ttimepoint\taif\t\ttissue\t\ttissue(nor)\tfit\n", myString];
                for (i=0; i<[_aifRoiData count]; i++) {
                    [splash incrementBy:1];
                    myString = [NSString stringWithFormat:@"%@%0.3f\t\t%d\t\t%0.3f\t\t%0.3f\t\t%0.3f\t\t%0.3lf \n", myString,[[_time objectAtIndex:i]floatValue],(i+1),[[_aifRoiData objectAtIndex:i]floatValue],[[_tissueRoiData objectAtIndex:i]floatValue],[[_tissue objectAtIndex:i]floatValue],[[_fit objectAtIndex:i] doubleValue]];
                }
                myString = [NSString stringWithFormat:@"%@eof\t\n", myString];
            }  
            if (((_csv)&&(_txt)&&(j>0))||(((_csv)&&(!_txt))&&(j==0))) {
                fileDirectory =[NSString stringWithFormat:@"%@.csv", fileDirectory];
                myString = [NSString stringWithFormat:@"%@FitCurve Data\n", myString];
                myString = [NSString stringWithFormat:@"%@time(sec);timepoint;aif;tissue;tissue(nor);fit\n", myString];
                for (i=0; i<[_aifRoiData count]; i++) {
                    [splash incrementBy:1];
                    myString = [NSString stringWithFormat:@"%@%0.3f;%d;%f;%0.3f;%0.3f;%0.3lf;\n", myString,[[_time objectAtIndex:i]floatValue],(i+1),[[_aifRoiData objectAtIndex:i]floatValue],[[_tissueRoiData objectAtIndex:i]floatValue],[[_tissue objectAtIndex:i]floatValue],[[_fit objectAtIndex:i] doubleValue]];
                }
                myString = [NSString stringWithFormat:@"%@eof;\n", myString];
            } 
           
            fileDirectoryURL = [NSURL URLWithString:fileDirectory];
            NSLog(@"%@ <-- this file has just been saved.",fileDirectoryURL);
            [myString writeToURL:fileDirectoryURL 
                       atomically:YES 
                         encoding:NSUTF8StringEncoding 
                            error: NULL];    
        }
        
        [splash close];
        [splash release];
        
        [[_mainController userDefaults] setInt:_txt forKey:@"UMMPdotTxtCheckbox"];
        [[_mainController userDefaults] setInt:_csv forKey:@"UMMPdotCsvCheckbox"];
    }
}

@end
