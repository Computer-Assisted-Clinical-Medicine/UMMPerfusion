//
//  UMMPAlgorithmController.m
//  UMMPerfusion
//
//  Created by Marcel Reich on 04.10.11.
//  Copyright (c) 2012, Marcel Reich & Sven Kaiser & Markus Daab & Patrick Schülein & Engin Aslan
//  All rights reserved.
//

#import "UMMPAlgorithmController.h"
#import "UMMPFastDeconvolutionController.h"
#import "UMMPPanelController.h"
#import "UMMPReportChart.h"
#import "UMMPReport.h"
#import "UMMPBinding.h"
#import "UMMPPreset.h"

#import "GRAxes.h"
#import "GRDataSet.h"
#import "GRLineDataSet.h"

#import <OsiriXAPI/browserController.h>
#import <OsiriXAPI/DICOMExport.h>
#import <OsiriXAPI/Wait.h>
#import "DCMCalendarDate.h"
#import "DCMObject.h"

@implementation UMMPAlgorithmController

@synthesize controller;
@synthesize inputParameter;
@synthesize outputParameter;
@synthesize presetParameter;
//@synthesize startSliceValue;
//@synthesize stopSliceValue;
@synthesize algorithmButton;
@synthesize arterialButton;
@synthesize venousButton;
@synthesize tissueButton;
@synthesize tracerButton;
@synthesize presetButton;
@synthesize baseLineLength;
@synthesize hematocrit;
@synthesize regularizationParameter;
@synthesize startSlider;
@synthesize endSlider;
@synthesize startSliceSlider;
@synthesize endSliceSlider;
@synthesize startField;
@synthesize endField;
@synthesize startSliceField;
@synthesize endSliceField;
@synthesize exportNameTextField;
@synthesize autosaveCheckButton;
@synthesize mapSelectionPanel;

#pragma mark -
#pragma mark start of methods

- (void)awakeFromNib {
    
    inputParameter = [[NSMutableArray alloc] init];
    outputParameter = [[NSMutableArray alloc] init];
	presetParameter = [[NSMutableArray alloc] init];

    // Initialize sliders
    int startSliderMax = [[controller viewerController] maxMovieIndex]-2;
    int stopSliderValue = [[controller viewerController] maxMovieIndex]-1;
	
	int startSliceSliderMax = [[[controller viewerController] pixList] count];
	int stopSliceSliderValue = [[[controller viewerController] pixList] count];
			
    [binding setValue: [NSNumber numberWithInt: 0] forKey: @"startSlider"];
    [binding setValue: [NSNumber numberWithInt: 0] forKey: @"startSliderMin"];
    [binding setValue: [NSNumber numberWithInt: startSliderMax] forKey:@"startSliderMax"];
    [binding setValue: [NSNumber numberWithInt: 1] forKey: @"startField"];
	
	[binding setValue: [NSNumber numberWithInt: 1] forKey: @"startSliceSlider"];
    [binding setValue: [NSNumber numberWithInt: 1] forKey: @"startSliceSliderMin"];
    [binding setValue: [NSNumber numberWithInt: startSliceSliderMax] forKey:@"startSliceSliderMax"];
    [binding setValue: [NSNumber numberWithInt: 1] forKey: @"startSliceField"];
    
    [binding setValue: [NSNumber numberWithInt: stopSliderValue] forKey: @"stopSlider"];
    [binding setValue: [NSNumber numberWithInt: 1] forKey: @"stopSliderMin"];
    [binding setValue: [NSNumber numberWithInt: stopSliderValue] forKey:@"stopSliderMax"];
    [binding setValue: [NSNumber numberWithInt: stopSliderValue+1] forKey:@"stopField"];
		
    [binding setValue: [NSNumber numberWithInt: stopSliceSliderValue] forKey: @"stopSliceSlider"];
    [binding setValue: [NSNumber numberWithInt: 1] forKey: @"stopSliceSliderMin"];
    [binding setValue: [NSNumber numberWithInt: stopSliceSliderValue] forKey:@"stopSliceSliderMax"];
    [binding setValue: [NSNumber numberWithInt: stopSliceSliderValue] forKey:@"stopSliceField"];
	
	[startSliceSlider setNumberOfTickMarks: stopSliceSliderValue];
	[endSliceSlider setNumberOfTickMarks: stopSliceSliderValue];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activateAutoSave:) name:NSControlTextDidChangeNotification object:exportNameTextField];
}


- (void)dealloc
{
    [inputParameter release];  self.inputParameter = nil;
	[outputParameter release]; self.outputParameter = nil;
	[presetParameter release]; self.presetParameter = nil;

	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)resizeWindowOnSpotWithRect:(NSRect)aRect
{
    NSRect r = NSMakeRect([mapSelectionPanel frame].origin.x - 
						  (aRect.size.width - [mapSelectionPanel frame].size.width),
						  [mapSelectionPanel frame].origin.y - 
						  (aRect.size.height+16 - [mapSelectionPanel frame].size.height),
						  aRect.size.width,
						  aRect.size.height+16);
    [mapSelectionPanel setFrame:r display:YES animate:YES];
}

- (void)resizeWindowOnSpotWithView:(NSView*)aView
{
    NSSize currentSize = [[mapSelectionPanel contentView] frame].size;
    NSSize newSize = [aView frame].size;
    float deltaWidth = newSize.width - currentSize.width;
    float deltaHeight = newSize.height - currentSize.height;
    NSRect windowFrame = [mapSelectionPanel frame];
    windowFrame.size.height += deltaHeight;
    windowFrame.origin.y -= deltaHeight;
    windowFrame.size.width += deltaWidth;
    [mapSelectionPanel setContentView: nil];
    [mapSelectionPanel setFrame: windowFrame display: YES animate: YES];
}

- (IBAction)selectROIs:(id)sender
{
    NSMenuItem *arterialItem = [arterialButton selectedItem];
    NSMenuItem *venousItem = [venousButton selectedItem];
    NSMenuItem *tissueItem = [tissueButton selectedItem];
    
    if (arterialItem)
        [controller setSelectedArterialRoiTag:[arterialItem tag]];
    else
        [controller setSelectedArterialRoiTag:[[NSNumber numberWithInt:-1] integerValue]];
    
    if (venousItem)
        [controller setSelectedVenousRoiTag:[venousItem tag]];
    else
        [controller setSelectedVenousRoiTag:[[NSNumber numberWithInt:-1] integerValue]];
    
    if (tissueItem)
        [controller setSelectedTissueRoiTag:[tissueItem tag]];
    else
        [controller setSelectedTissueRoiTag:[[NSNumber numberWithInt:-1] integerValue]];
    
    [self drawSelectedROIRecs];
}


- (IBAction)selectPreset:(id)sender
{
    NSMenuItem *presetItem = [presetButton selectedItem];
    
    if (presetItem)
        [controller setSelectedPresetTag:[presetItem tag]];
    else
        [controller setSelectedPresetTag:[[NSNumber numberWithInt:-1] integerValue]];
}

- (IBAction)moveStartSlider:(id)sender
{
	UMMPChart *chart = [controller chart];
    GRAxes *axes = [chart axes];
	
    int value = [sender intValue];
    
    [binding setValue: [NSNumber numberWithInt: [startSlider intValue]+1] forKey:@"startField"];
    [binding setValue: [NSNumber numberWithInt: [endSlider intValue]+1] forKey:@"stopField"];
    
	if (value+1 > [endSlider intValue])		
        [binding setValue:[NSNumber numberWithInt: value+1] forKey:@"stopSlider"];
	
	if (([endSlider intValue] - [startSlider intValue]) < 30) {
		[axes setProperty:[NSNumber numberWithFloat: [startSlider intValue]] forKey:GRAxesXPlotMin];
		[axes setProperty:[NSNumber numberWithFloat: [startSlider intValue]] forKey:GRAxesFixedXPlotMin];
		[axes setProperty:[NSNumber numberWithFloat: [endSlider intValue]] forKey:GRAxesXPlotMax];
		[axes setProperty:[NSNumber numberWithFloat: [endSlider intValue]] forKey:GRAxesFixedXPlotMax];
	} else if ([startSlider intValue]+29 <= [startSlider maxValue]) {
		// Calculate new x range depending on slider
		[axes setProperty:[NSNumber numberWithFloat: [startSlider intValue]] forKey:GRAxesXPlotMin];
		[axes setProperty:[NSNumber numberWithFloat: [startSlider intValue]] forKey:GRAxesFixedXPlotMin];
		[axes setProperty:[NSNumber numberWithFloat: [startSlider intValue]+30] forKey:GRAxesXPlotMax];
		[axes setProperty:[NSNumber numberWithFloat: [startSlider intValue]+30] forKey:GRAxesFixedXPlotMax];
	}
	
	// Adjust baselinelength to the trimmed interval
	if (([[axes propertyForKey:GRAxesXPlotMax] intValue]-[[axes propertyForKey:GRAxesXPlotMin] intValue]) < [baseLineLength intValue]) {
		NSNumber *baselineLength = [NSNumber numberWithInt: [[axes propertyForKey:GRAxesXPlotMax] intValue]-[[axes propertyForKey:GRAxesXPlotMin] intValue]];
        
        if ([baselineLength intValue] <= 0)
            baselineLength = [NSNumber numberWithInt: 1];
        
        [binding setValue: baselineLength forKey: @"baselineLength"];
    }
	
	// Calculate deltaT in trimmed interval
	[self searchDeltaT: [startSlider intValue] end: [endSlider intValue]];
	
	[chart setNeedsDisplay:YES];
}

- (IBAction)moveSliceStartSlider:(id)sender
{
	int value = [sender intValue];
	[binding setValue:[NSNumber numberWithInt:[startSliceSlider intValue]] forKey:@"startSliceField"];
	[binding setValue:[NSNumber numberWithInt:[endSliceSlider intValue]] forKey:@"stopSliceField"];	
	
	if (value+1 > [endSliceSlider intValue])		
        [binding setValue:[NSNumber numberWithInt: value] forKey:@"stopSliceSlider"];

}

- (IBAction)moveEndSlider:(id)sender
{
	UMMPChart *chart = [controller chart];
    GRAxes *axes = [chart axes];
    
    int value = [sender intValue];
	
    [binding setValue: [NSNumber numberWithInt: [startSlider intValue]+1] forKey:@"startField"];
    [binding setValue: [NSNumber numberWithInt: [endSlider intValue]+1] forKey:@"stopField"];
	
	if (value-1 < [startSlider intValue])
		[binding setValue:[NSNumber numberWithInt: value-1] forKey:@"startSlider"];
	
	if (([endSlider intValue] - [startSlider intValue]) < 30) {
		[axes setProperty:[NSNumber numberWithFloat: [startSlider intValue]] forKey:GRAxesXPlotMin];
		[axes setProperty:[NSNumber numberWithFloat: [startSlider intValue]] forKey:GRAxesFixedXPlotMin];
		[axes setProperty:[NSNumber numberWithFloat: [endSlider intValue]] forKey:GRAxesXPlotMax];
		[axes setProperty:[NSNumber numberWithFloat: [endSlider intValue]] forKey:GRAxesFixedXPlotMax];
	} else if ([endSlider intValue]+29 <= [endSlider maxValue]) {
		[axes setProperty:[NSNumber numberWithFloat: [startSlider intValue]] forKey:GRAxesXPlotMin];
		[axes setProperty:[NSNumber numberWithFloat: [startSlider intValue]] forKey:GRAxesFixedXPlotMin];
		[axes setProperty:[NSNumber numberWithFloat: [startSlider intValue]+30] forKey:GRAxesXPlotMax];
		[axes setProperty:[NSNumber numberWithFloat: [startSlider intValue]+30] forKey:GRAxesFixedXPlotMax];
	}
	
	// Adjust baselinelength to the trimmed interval
	if (([endSlider intValue] - [[axes propertyForKey:GRAxesXPlotMin] intValue]) < [baseLineLength intValue]) {
		NSNumber *baselineLength = [NSNumber numberWithInt: [[axes propertyForKey:GRAxesXPlotMax] intValue]-[[axes propertyForKey:GRAxesXPlotMin] intValue]];
        
        if ([baselineLength intValue] <= 0)
            baselineLength = [NSNumber numberWithInt: 1];
            
        [binding setValue: baselineLength forKey: @"baselineLength"];
    }
	
	// Calculate deltaT in trimmed interval
	[self searchDeltaT: [startSlider intValue] end: [endSlider intValue]];
	
	[chart setNeedsDisplay:YES];
}

- (IBAction)moveSliceEndSlider:(id)sender
{
	int value = [sender intValue];
	
    [binding setValue: [NSNumber numberWithInt: [startSliceSlider intValue]] forKey:@"startSliceField"];
    [binding setValue: [NSNumber numberWithInt: [endSliceSlider intValue]] forKey:@"stopSliceField"];	
	
	if (value-1 < [startSliceSlider intValue])
		[binding setValue:[NSNumber numberWithInt: value] forKey:@"startSliceSlider"];
		
}

- (void)activateAutoSave:(NSNotification *)notification
{	
	if ([notification object] == exportNameTextField) {
		[autosaveCheckButton setState:NSOnState];
		[binding setValue:[NSNumber numberWithInteger:NSOnState] forKey:@"autosaveBox"];
	}
}


- (void)searchDeltaT:(NSInteger)start end:(NSInteger)end
{
	int i;
	double *dTime = [controller dTime];
   // double *dTime = [controller dTimeArray]
	double deltaT, max;
	
	deltaT = dTime[start];//([startSlider intValue] +1);
	max = dTime[start];//([startSlider intValue] +1);

	
	//NSLog(@"1. in searchDeltaT: start: %d, end: %d, deltaT:%f, max: %f ", start, end, deltaT, max);
	
	for (i = start; i < end; i++) {
		
		if (dTime[i] < deltaT)
			deltaT = dTime[i];
		
		if (dTime[i] > max) {
			max = dTime[i];
		}
	}
	
	if (deltaT == 0.0)
		deltaT = 1.0;

	[controller setDeltaT:deltaT];
	[controller setInterpolation:[controller isInterpolationNeeded:deltaT max:max]];
	//NSLog(@"2. in searchDeltaT: start: %d, end: %d, deltaT:%f, max: %f ", start, end, deltaT, max);
	
	
}


- (void)addROIRec:(UMMPROIRec *)roiRec
{
	[self addROIRec:roiRec withName:@""];
}


- (void)addROIRec:(UMMPROIRec *)roiRec withName:(NSString *)name
{
	NSMenuItem *menuItem = [[[NSMenuItem alloc] init] autorelease];
    
    // check if the ROIRec which you want to add is imported from a csv file
    if ([[controller roiList] externalRoiRecTag] == [roiRec tag]) {
        [menuItem setTitle:[[controller prefController] extROIFilename]];
        [menuItem setTag:externalROITag];
        [[arterialButton menu] addItem:menuItem];
        [[venousButton menu] addItem:[menuItem copy]];
        [[controller prefController] setExtROI:NO];
    } else {
        [menuItem setTitle:[NSString stringWithFormat:@"%@   SL:%ld   TP:%ld", [[roiRec roi] name], (long)[roiRec slice]+1, (long)[roiRec timePoint]+1]];
        [menuItem setTag:[roiRec tag]];
        [[arterialButton menu] addItem:menuItem];
        [[venousButton menu] addItem:[menuItem copy]];
        [[tissueButton menu] addItem:[menuItem copy]];
    }
	
    // check if ROIRecs exists and open the chart
	if ([[arterialButton menu] numberOfItems] > 0) {
		[arterialButton setEnabled:YES];
        [venousButton setEnabled:YES];
		[tissueButton setEnabled:YES];
		[self drawSelectedROIRecs];
		[[controller drawer] open];
	}
}


- (void)changeROIRec:(UMMPROIRec *)roiRec
{
	NSMenuItem *arterialMenuItem = [[arterialButton menu] itemWithTag:[roiRec tag]];
    NSMenuItem *venousMenuItem = [[venousButton menu] itemWithTag:[roiRec tag]];
	NSMenuItem *tissueMenuItem = [[tissueButton menu] itemWithTag:[roiRec tag]];
    [arterialMenuItem setTitle:[NSString stringWithFormat:@"%@   SL:%ld   TP:%ld", [[roiRec roi] name], (long)[roiRec slice]+1, (long)[roiRec timePoint]+1]];
    [venousMenuItem setTitle:[NSString stringWithFormat:@"%@   SL:%ld   TP:%ld", [[roiRec roi] name], (long)[roiRec slice]+1, (long)[roiRec timePoint]+1]];
	[tissueMenuItem setTitle:[NSString stringWithFormat:@"%@   SL:%ld   TP:%ld", [[roiRec roi] name], (long)[roiRec slice]+1, (long)[roiRec timePoint]+1]];
}


- (void)loadROIRecs:(NSMutableArray *)roiRecords
{
	[arterialButton removeAllItems];
    [venousButton removeAllItems];
	[tissueButton removeAllItems];
	
	for (UMMPROIRec *roiRec in roiRecords)
		[self addROIRec:roiRec withName:[[roiRec roi] name]];
}


- (void)removeROIRec:(UMMPROIRec *)roiRec
{
	NSMenuItem *arterialMenuItem = [[arterialButton menu] itemWithTag:[roiRec tag]];
    NSMenuItem *venousMenuItem = [[venousButton menu] itemWithTag:[roiRec tag]];
	NSMenuItem *tissueMenuItem = [[tissueButton menu] itemWithTag:[roiRec tag]];
	
	[[arterialButton menu] removeItem:arterialMenuItem];
    [[venousButton menu] removeItem:venousMenuItem];
	[[tissueButton menu] removeItem:tissueMenuItem];
	[self drawSelectedROIRecs];
	
	BOOL recordsExist = [[arterialButton menu] numberOfItems] > 0;
	if (!recordsExist) {
		[arterialButton setEnabled:NO];
        [venousButton setEnabled:NO];
		[tissueButton setEnabled:NO];
		[[controller drawer] close];
	}
}

- (void)removeExternalROIRec:(UMMPROIRec *)roiRec
{
	NSMenuItem *arterialMenuItem = [[arterialButton menu] itemWithTag:externalROITag];
    NSMenuItem *venousMenuItem = [[venousButton menu] itemWithTag:externalROITag];
	
	[[arterialButton menu] removeItem:arterialMenuItem];
    [[venousButton menu] removeItem:venousMenuItem];
    [self drawSelectedROIRecs];
	
	BOOL recordsExist = [[arterialButton menu] numberOfItems] > 0;
	if (!recordsExist) {
		[arterialButton setEnabled:NO];
        [venousButton setEnabled:NO];
		[tissueButton setEnabled:NO];
		[[controller drawer] close];
	}
}

- (void)drawSelectedROIRecs
{
    NSMutableArray *records = [[controller roiList] records];
	
	for (UMMPROIRec *roiRec in records) {
        
        // check which ROIRec in the RoiRec records is selected
		if ([roiRec tag] == [[arterialButton selectedItem] tag] || [roiRec tag] == [[tissueButton selectedItem] tag] || [roiRec tag] == [[venousButton selectedItem] tag] || (([roiRec tag] == [[controller roiList] externalRoiRecTag]) && ([[arterialButton selectedItem] tag] == externalROITag))) {
            
            // draw ROIRec
			[[roiRec meanDataSet] setProperty:[NSNumber numberWithBool:NO] forKey:GRDataSetHidden];
        } else {
			[[roiRec meanDataSet] setProperty:[NSNumber numberWithBool:YES] forKey:GRDataSetHidden];
        }
        [[controller chart] refresh:roiRec];
	}
    [[controller chart] setNeedsDisplay:YES];
}


- (void)selectUserROIs
{
    [arterialButton selectItemWithTag:[controller selectedArterialRoiTag]];
    [venousButton selectItemWithTag:[controller selectedVenousRoiTag]];
    [tissueButton selectItemWithTag:[controller selectedTissueRoiTag]];
}

- (void)selectUserPreset
{
    [presetButton selectItemWithTag:[controller selectedPresetTag]];
}

-(void)addPreset:(UMMPPreset *)preset
{
    NSMenuItem *menuItem = [[[NSMenuItem alloc] init] autorelease];
	[menuItem setTitle:[preset name]];
	[menuItem setTag:[preset presetTag]];
    
    [[presetButton menu] addItem:menuItem];
}

- (void)loadPresets:(NSMutableArray *)presets
{
    [presetButton removeAllItems];
    
    for (UMMPPreset *preset in presets)
        [self addPreset:preset];
}

- (void)drawReportWithAif:(NSArray *)aif
{
    // Create UMMPReportChart
    NSRect chartRect1 = NSMakeRect(0, 0, 400, 400);
    UMMPReportChart *reportChart1 = [[UMMPReportChart alloc] initWithFrame:chartRect1];
    
    [aif retain];
    
    // Plot aif to UMMPReportChart
    GRDataSet *dataSetAif = [[GRLineDataSet alloc] initWithOwnerChart:reportChart1];
    [dataSetAif setProperty:[NSNumber numberWithInt:1] forKey:GRDataSetDrawPlotLine];
    [dataSetAif setProperty:[NSNumber numberWithInt:90] forKey:GRDataSetPieStartAngle];
    [dataSetAif setProperty:[NSNumber numberWithBool:NO] forKey:GRDataSetDrawMarkers];
    [dataSetAif setProperty:[NSColor greenColor] forKey:GRDataSetPlotColor];
    [reportChart1 setDataSet1:dataSetAif];
    [reportChart1 setData1:aif];
    [aif release];
    [reportChart1 addDataSet:dataSetAif loadData:YES];
    [dataSetAif release];
    
    // Plot baseline to UMMPReportChart
    int baseLine = 0;
    for (NSMutableDictionary *aDict in inputParameter) {
        for (NSString *key in aDict) {
            if ([key isEqualToString:@"Baseline:"])
                baseLine = [[aDict objectForKey:key] intValue];
        }
    }
    [reportChart1 setShowBaseLine:YES];
    [reportChart1 setBaseLine:[NSNumber numberWithInt:baseLine]];
        
	// Save current viewercontroller slice and timepoint
    ViewerController *viewer = [controller viewerController];
	int oldMovieIndex = [viewer curMovieIndex];
	int oldSlice = [[viewer imageView] curImage];
	
	// find roi and take screenshot
	[viewer setMovieIndex:[[[controller roiList] findRecordByTag:[arterialButton selectedTag]] timePoint]];
	[[viewer imageView] setIndex:[[[controller roiList] findRecordByTag:[arterialButton selectedTag]] slice]];
	[[viewer imageView] sendSyncMessage:0];
	[viewer adjustSlider];
    
    NSInteger originalAnnotationsState = [[NSUserDefaults standardUserDefaults] integerForKey:@"ANNOTATIONS"];
	NSInteger originalClutbarsState = [[NSUserDefaults standardUserDefaults] integerForKey:@"CLUTBARS"];
    
    // set 2D Viewer --> Annotations --> Graphics Only before taking the Report screenshot
    // (annotGraphics = Graphics Only)
    [[NSUserDefaults standardUserDefaults] setInteger: annotGraphics forKey: @"ANNOTATIONS"];
    
	[[NSUserDefaults standardUserDefaults] setInteger: 0 forKey: @"CLUTBARS"];
    [DCMView setDefaults];
    
    DCMView *viewWithArterialRoi = [viewer imageView];
    NSImage *image = [viewWithArterialRoi nsimage];
    NSSize imageSize = [image size];
    NSRect imageRect = NSMakeRect(0, 0, imageSize.width, imageSize.height);
    NSImageView *imageView = [[NSImageView alloc] initWithFrame:imageRect];
    
    [imageView setImage:image];
    
	// go back to old slice and timepoint
	[viewer setMovieIndex:oldMovieIndex];
	[[viewer imageView] setIndex:oldSlice];
	[[viewer imageView] sendSyncMessage:0];
	[viewer adjustSlider];
    
    // set the original Annotation setting after taking the Report screenhot
    [[NSUserDefaults standardUserDefaults] setInteger: originalAnnotationsState forKey:@"ANNOTATIONS"];
    
	[[NSUserDefaults standardUserDefaults] setInteger: originalClutbarsState forKey:@"CLUTBARS"];
    [[NSUserDefaults standardUserDefaults] setBool: NO forKey: @"ROITEXTIFSELECTED"];
    [DCMView setDefaults];
        
    // Create UMMPReport
    NSRect reportRect = NSMakeRect(0, 0, 1024, 1024);
	
	NSLog(@"%@", [[controller algorithmPopUpButton] titleOfSelectedItem]);
	if ([[[controller algorithmPopUpButton] titleOfSelectedItem] isEqualToString:@"   Fast Deconvolution"] )
	{
		report = [[UMMPReport alloc] initWithFrame:reportRect andLayoutType:3 andView1:reportChart1 andView2:imageView andInputParameters:inputParameter andOutputParameters:outputParameter andPresetParameters:presetParameter];
	} 
	else if ([self class] == [UMMPFastDeconvolutionController class])
	{
		report = [[UMMPReport alloc] initWithFrame:reportRect andLayoutType:3 andView1:reportChart1 andView2:imageView andInputParameters:inputParameter andOutputParameters:outputParameter andPresetParameters:presetParameter];
	} 
	else 
	{
		report = [[UMMPReport alloc] initWithFrame:reportRect andLayoutType:2 andView1:reportChart1 andView2:imageView andInputParameters:inputParameter andOutputParameters:outputParameter andPresetParameters:presetParameter];
	}	
        
    [imageView release];
}
#pragma mark -
#pragma mark calculations
- (void)exportResults
{   
    UMMPViewerList *viewerList = [controller viewerList];
    
    unsigned i;
//	int seriesNumber = 85469;
	int viewersCount = [viewerList count];
    
	// Export all open UMMPViewers
	if ([viewerList count]) {
		
		Wait *splash = [[Wait alloc] initWithString:NSLocalizedString(@"Saving results...", nil)];
		[splash showWindow:self];
		[[splash progress] setMaxValue: viewersCount];
		[splash setCancel: YES];
		[splash incrementBy: 1];
		
		for (i = 0; i < viewersCount; i++) {
			[self exportViewer:[viewerList objectAtIndex:i]];
			
			[splash incrementBy: 1];
			if( [splash aborted])
				i = viewersCount;
		}
        
        // Export UMMPReport
        if (report) {
            
            // Add custom string in front of exportName
            NSString *name = nil;
            NSString *exportName = nil;
            
            for (NSMutableDictionary *aDict in inputParameter) {
                for (NSString *key in aDict) {
                    if ([key isEqualToString:@"Algorithm:"])
                        name = [aDict objectForKey:key];
                }
            }
            
            exportName = [NSString stringWithFormat:@"%@ - UMMPerfusionReport", name];
		
            
            if (![[exportNameTextField stringValue] isEqualToString:@""]) {
                exportName = [NSString stringWithFormat:@"%@ - %@", [exportNameTextField stringValue], exportName];
            }
            
            int seriesNumber = 8200 + [[NSCalendarDate date] minuteOfHour] + [[NSCalendarDate date] secondOfMinute];
            
            NSString *fileDirectory = [[[BrowserController currentBrowser] fixedDocumentsDirectory] stringByAppendingPathComponent: [NSString stringWithFormat:@"INCOMING.noindex/%@.dcm", exportName]];
                        
            [self exportReport:report andSeriesDiscription:exportName seriesNumber:seriesNumber backgroundColor:[NSColor whiteColor] toFile:fileDirectory];
            [report dealloc];
            //[report release]; report = NULL;
        }
        
        [splash close];
		[splash release];
        
	} else {
		NSRunAlertPanel(@"Data error", @"No results to export.", @"OK", nil, nil);
	}
}

- (void)exportReport:(UMMPReport*)exReport andSeriesDiscription:(NSString*)seriesDescription seriesNumber:(int)seriesNumber backgroundColor:(NSColor*)backgroundColor toFile:(NSString*)filename
{
	int x, y;
	
	id waitWindow = [[controller viewerController] startWaitWindow:@"Saving..."];
	
	NSBitmapImageRep* bitmapImageRep = [exReport bitmapImageRepForCachingDisplayInRect:[exReport bounds]];
	[exReport cacheDisplayInRect:[exReport bounds] toBitmapImageRep:bitmapImageRep];
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
	
	[[controller viewerController] endWaitWindow:waitWindow];
}

- (void)exportViewer:(UMMPViewer *)viewer
{
	int i;
	
	ViewerController *vc = [viewer viewer];
	NSString *exportName = [viewer name];
    NSMutableArray *producedFiles = [NSMutableArray array];
	
	// Add custom string in front of exportName
	if (![[exportNameTextField stringValue] isEqualToString:@""])
		exportName = [NSString stringWithFormat:@"%@ - %@", [exportNameTextField stringValue], exportName];
	
	if (exportDCM == nil) exportDCM = [[DICOMExport alloc] init];
    
    int seriesNumber = 8200 + [[NSCalendarDate date] minuteOfHour] + [[NSCalendarDate date] secondOfMinute];
	[exportDCM setSeriesNumber:seriesNumber];
	[exportDCM setSeriesDescription: exportName];
	
	// save current viewercontroller slice and timepoint
	int oldMovieIndex = [vc curMovieIndex];
	int oldSlice = [[vc imageView] curImage];
	
	for (i=0; i<[[vc pixList] count]; i++) {
        
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

		[[vc imageView] setIndex:i];
		[[vc imageView] sendSyncMessage:0];
		[vc adjustSlider];
		
		// export now uses data in memory -->fusion is not supported in export!
		NSDictionary *s = [self exportDICOMFileInt:0 withName:exportName viewer:vc];
        if (s)
            [producedFiles addObject: s];
        
        [pool release];
	}
    
	// go back to old slice and timepoint
	[vc setMovieIndex:oldMovieIndex];
	[[vc imageView] setIndex:oldSlice];
	[[vc imageView] sendSyncMessage:0];
	[vc adjustSlider];
	
	[NSThread sleepForTimeInterval: 1.0];
    
    if( [producedFiles count])
	{
		NSArray *objects = [BrowserController addFiles: [producedFiles valueForKey: @"file"]
											 toContext: [[BrowserController currentBrowser] managedObjectContext]
											toDatabase: [BrowserController currentBrowser]
											 onlyDICOM: YES 
									  notifyAddedFiles: YES
								   parseExistingObject: YES
											  dbFolder: [[BrowserController currentBrowser] documentsDirectory]
									 generatedByOsiriX: YES];
		
		if( [[NSUserDefaults standardUserDefaults] boolForKey: @"afterExportSendToDICOMNode"])
			[[BrowserController currentBrowser] selectServer: objects];
	}
    
	[[BrowserController currentBrowser] checkIncoming: self];
	
}

- (NSDictionary*) exportDICOMFileInt:(int)screenCapture withName:(NSString*)name viewer:(ViewerController *)new2DViewer
{
	long annotCopy,clutBarsCopy;
	NSString *sopuid = nil;
	BOOL modalityAsSource = NO;
	long width, height, spp, bpp;
	float cwl, cww;
	float o[ 9];
	BOOL isSigned;
	int offset;
	
	if( screenCapture)
	{
		annotCopy		= [[NSUserDefaults standardUserDefaults] integerForKey: @"ANNOTATIONS"];
		clutBarsCopy	= [[NSUserDefaults standardUserDefaults] integerForKey: @"CLUTBARS"];
		
		[DCMView setCLUTBARS: barHide ANNOTATIONS: annotGraphics];
	}
	
	BOOL force8bits = YES;
	
	switch( screenCapture)
	{
		case 0: /*memory data*/		force8bits = NO;	modalityAsSource = YES;		break; // 16-bit
		case 1: /*screen capture*/	force8bits = YES;	break;
		case 2: /*screen capture*/	force8bits = NO;	modalityAsSource = YES;		break; // 16-bit
	}
	
	unsigned char *data = nil;
	
	float imOrigin[ 3], imSpacing[ 2];
    
	data = [[new2DViewer imageView] getRawPixelsWidth:&width height:&height spp:&spp bpp:&bpp screenCapture:screenCapture force8bits:force8bits removeGraphical:YES squarePixels:YES allTiles:[[NSUserDefaults standardUserDefaults] boolForKey:@"includeAllTiledViews"] allowSmartCropping:YES origin: imOrigin spacing: imSpacing offset: &offset isSigned: &isSigned];
	
	NSString *f = nil;
	
	if( data)
	{
		if( exportDCM == nil) exportDCM = [[DICOMExport alloc] init];
		
		NSMutableArray *dcmList = [new2DViewer fileList];
		
		[exportDCM setSourceFile: [[dcmList objectAtIndex:[[new2DViewer imageView] curImage]] valueForKey:@"completePath"]];
        
		[[new2DViewer imageView] getWLWW:&cwl :&cww];
		
		[exportDCM setDefaultWWWL: cww :cwl];
		
		float thickness, location;
		
		[[new2DViewer imageView] getThickSlabThickness:&thickness location:&location];
		[exportDCM setSliceThickness: thickness];
		[exportDCM setSlicePosition: location];
		
		[[new2DViewer imageView] orientationCorrectedToView: o];
		//		if( screenCapture) [imageView orientationCorrectedToView: o];	// <- Because we do screen capture !!!!! We need to apply the rotation of the image
		//		else [curPix orientation: o];
		
		[exportDCM setOrientation: o];
		
		[exportDCM setPosition: imOrigin];
		[exportDCM setPixelSpacing: imSpacing[ 0] :imSpacing[ 1]];
		
		[exportDCM setPixelData: data samplesPerPixel:spp bitsPerSample:bpp width: width height: height];
		[exportDCM setSigned: isSigned];
		[exportDCM setOffset: offset];
		[exportDCM setModalityAsSource: modalityAsSource];
		
		f = [exportDCM writeDCMFile: nil withExportDCM: [[new2DViewer imageView] dcmExportPlugin]];
		//		if( f == nil) NSRunCriticalAlertPanel( NSLocalizedString(@"Error", nil),  NSLocalizedString(@"Error during the creation of the DICOM File!", nil), NSLocalizedString(@"OK", nil), nil, nil);
		//		else sopuid = [exportDCM SOPInstanceUID];
		
		free( data);
	}
	else NSLog( @"No Data");
	
	if( screenCapture)
	{
		[DCMView setCLUTBARS: clutBarsCopy ANNOTATIONS: annotCopy];
	}
	
	return [NSDictionary dictionaryWithObjectsAndKeys: f, @"file", sopuid, @"SOPInstanceUID", nil];
}

- (void)startCalculation:(UMMPROIRec*)tissueROI andAlgorithmTag:(int)tag
{
    NSLog(@"%s You have to override this method!", __PRETTY_FUNCTION__);
}

- (void)startMapCalculation
{
    NSLog(@"%s You have to override this method!", __PRETTY_FUNCTION__);
}
- (void)startMapCalculation:(int)tag
{
    NSLog(@"%s You have to override this method!", __PRETTY_FUNCTION__);
}

- (BOOL)checkUserInput
{
    NSLog(@"%s You have to override this method!", __PRETTY_FUNCTION__);
    return NO;
}

- (void)saveInputParameter:(UMMPROIRec*)tissueROI andAlgorithmName:(NSString*)algorithm
{
    NSLog(@"%s You have to override this method!", __PRETTY_FUNCTION__);
}

- (void)savePresetParameter:(int)tag
{
    NSLog(@"%s You have to override this method!", __PRETTY_FUNCTION__);
}

- (void)saveOutputParameter:(int)tag
{
    NSLog(@"%s You have to override this method!", __PRETTY_FUNCTION__);
}
@end
