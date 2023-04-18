//
//  UMMPFastDeconvolutionController.m
//  UMMPerfusion
//
//  Created by Marcel Reich on 04.10.11.
//  Copyright (c) 2012, Marcel Reich & Sven Kaiser & Markus Daab & Patrick Schülein & Engin Aslan
//  All rights reserved.
//

#import "UMMPFastDeconvolutionController.h"
#import "UMMPPanelController.h"
#import "UMMPFastDeconvolution.h"
#import "UMMPUserDefaults.h"

#import "GRDataSet.h"
#import "GRLineDataSet.h"

#import "DCMObject.h"

@implementation UMMPFastDeconvolutionController

@synthesize userDefaults;
- (id)init
{
	self = [super init];
	interpolation = NO;
    prefController= [[UMMPPrefController alloc] init];
    userDefaults = [[UMMPUserDefaults alloc] init];
	return self;
}

- (void)dealloc
{
	//interpolation = NO;
    [userDefaults release]; userDefaults = nil;
	[super dealloc];
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
        [[controller prefController] setExtROI:NO];
    } else {
        [menuItem setTitle:[NSString stringWithFormat:@"%@   SL:%ld   TP:%ld", [[roiRec roi] name], (long)[roiRec slice]+1, (long)[roiRec timePoint]+1]];
        [menuItem setTag:[roiRec tag]];
        
        [[arterialButton menu] addItem:menuItem];
    }
	
	BOOL recordsExist = [[arterialButton menu] numberOfItems] > 0;
	
	if (recordsExist) {
		[arterialButton setEnabled:YES];
		[self drawSelectedROIRecs];
		[[controller drawer] open];
	}
}


- (void)changeROIRec:(UMMPROIRec *)roiRec
{
	NSMenuItem *menuItem = [[arterialButton menu] itemWithTag:[roiRec tag]];
    [menuItem setTitle:[NSString stringWithFormat:@"%@   SL:%ld   TP:%ld", [[roiRec roi] name], (long)[roiRec slice]+1, (long)[roiRec timePoint]+1]];
}


- (void)loadROIRecs:(NSMutableArray *)roiRecords
{
	[arterialButton removeAllItems];
	
	for (UMMPROIRec *roiRec in roiRecords)
		[self addROIRec:roiRec withName:[[roiRec roi] name]];
}


- (void)removeROIRec:(UMMPROIRec *)roiRec
{
	NSMenuItem *menuItem = [[arterialButton menu] itemWithTag:[roiRec tag]];
	[[arterialButton menu] removeItem:menuItem];
	[self drawSelectedROIRecs];
	
	BOOL recordsExist = [[arterialButton menu] numberOfItems] > 0;
	if (!recordsExist) {
		[arterialButton setEnabled:NO];
		[[controller drawer] close];
	}
}


- (void)drawSelectedROIRecs
{
	NSMutableArray *records = [[controller roiList] records];
	
	for (UMMPROIRec *roiRec in records) {
        
        // check which ROIRec in the RoiRec records is selected
		if ([roiRec tag] == [[arterialButton selectedItem] tag] || (([roiRec tag] == [[controller roiList] externalRoiRecTag]) && ([[arterialButton selectedItem] tag] == externalROITag))) {
            
            // draw ROIRec
			[[roiRec meanDataSet] setProperty:[NSNumber numberWithBool:NO] forKey:GRDataSetHidden];
        } else
			[[roiRec meanDataSet] setProperty:[NSNumber numberWithBool:YES] forKey:GRDataSetHidden];
        
        [[controller chart] refresh:roiRec];
	}
	
    [[controller chart] setNeedsDisplay:YES];
}

- (BOOL)checkUserInput
{
    if (![arterialButton selectedItem]) {
        /* No ROI selected */
        NSRunAlertPanel(@"Invalid ROI", @"Please select a ROI.", @"OK",nil,nil);
        return NO;
	} else if ([baseLineLength intValue] <= 0 || [baseLineLength intValue] > [endSlider intValue]-[startSlider intValue]) {
		/* baseLineLength <= 0 */
        NSRunAlertPanel(@"Invalid Length of Baseline", [NSString stringWithFormat:@"Please use Baseline length between %d and %d.", 1 ,[endSlider intValue]-[startSlider intValue]], @"OK",nil,nil);
        return NO;
	} else if ([hematocrit doubleValue] <= 0.0 || [hematocrit doubleValue] >= 1.0) {
		/* hematocrit <= 0 || >= 1 */
        NSRunAlertPanel(@"Invalid Hematocrit", @"Please use correct Hematocrit.", @"OK",nil,nil);
        return NO;
	} else if ([regularizationParameter doubleValue] <= 0.0) {
        /* regularizationParameter <= 0 */
        NSRunAlertPanel(@"Invalid Regularization parameter", @"Please use correct Regularization parameter.", @"OK",nil,nil);
        return NO;
	}
   
    return YES;
}

- (void)saveInputParameter:(UMMPROIRec *)tissueROI andAlgorithmName:(NSString *)algorithm
{
	ViewerController *viewer = [controller viewerController];
	
	NSCalendarDate *curDate = [NSCalendarDate calendarDate];
	[curDate setCalendarFormat:@"%Y-%m-%d %H:%M:%S"];
	
	UMMPROIRec *arterialROIRec = [[controller roiList] findRecordByTag:[arterialButton selectedTag]];
    
	NSString *arterialRoi = @"";
    NSString *csvFilePath = @"";

    if ([arterialButton selectedTag] == externalROITag) {
        csvFilePath = [[controller prefController] extROIFilePathForReport];
        arterialRoi = [NSString stringWithFormat:@"External ROI  Filepath: %@", csvFilePath];
        
    } else {
        arterialRoi = [NSString stringWithFormat:@"%@   slice: %ld   timepoint: %ld", [[arterialROIRec roi] name], (long)[arterialROIRec slice]+1, (long)[arterialROIRec timePoint]+1];
        
        if (!arterialRoi)
            arterialRoi = @"n.a.";
    }
	
	NSString *trim = [NSString stringWithFormat:@"%d - %d", [startSlider intValue]+1, [endSlider intValue]+1];
    if (!trim)
        trim = @"n.a.";
	
	NSString * z_trim = [NSString stringWithFormat:@"%d - %d", [startSliceSlider intValue], [endSliceSlider intValue]];
	if(!z_trim)
		z_trim=@"n.a";
	
	// Read DICOM-Tags from DCMObject
	NSString *filePath = [[[viewer pixList:0] objectAtIndex:0] sourceFile];
	DCMObject *dcmObject = [DCMObject objectWithContentsOfFile:filePath decodingPixelData:NO];
	NSString *patientIDTag = [NSString stringWithFormat:@"%04X,%04X", 0X0010, 0X0020];
	NSString *patientNameTag = [NSString stringWithFormat:@"%04X,%04X", 0X0010, 0X0010];
	NSString *aquisitionDateTag = [NSString stringWithFormat:@"%04X,%04X", 0X0008, 0X0022];
	NSString *seriesNumberTag = [NSString stringWithFormat:@"%04X,%04X", 0X0020, 0X0011];
	NSString *patientName = [dcmObject attributeValueForKey:patientNameTag];
    if (!patientName)
        patientName = @"n.a.";
	NSString *patientID = [dcmObject attributeValueForKey:patientIDTag];
    if (!patientID)
        patientID = @"n.a.";
    NSCalendarDate *calendarDate = [dcmObject attributeValueForKey:aquisitionDateTag];
    NSString *aquisitionDate = [calendarDate descriptionWithCalendarFormat:@"%Y-%m-%d"];
	if (!aquisitionDate)
        aquisitionDate = @"n.a.";
    NSString *seriesNumber = [dcmObject attributeValueForKey:seriesNumberTag];
    if (!seriesNumber)
        seriesNumber = @"n.a.";
	
	// Save values as NSMutableDictionary to inputParameter
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:patientName forKey:@"Patient Name:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:patientID forKey:@"Patient ID:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:aquisitionDate forKey:@"Aquisition Date:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:seriesNumber forKey:@"Series Number:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:@" " forKey:@" "]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:[[[NSBundle bundleForClass:[self class]] infoDictionary] valueForKey:@"CFBundleShortVersionString"] forKey:@"Plugin Version:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:@"Fast Deconvolution" forKey:@"Algorithm:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@", curDate] forKey:@"Creation Date:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:arterialRoi forKey:@"Arterial ROI:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:[tracerButton titleOfSelectedItem] forKey:@"Appr. Tracer Concentration:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:[baseLineLength stringValue] forKey:@"Baseline:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"%1.2f (‰)", [hematocrit floatValue]] forKey:@"Hematocrit:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"%1.2f", [regularizationParameter floatValue]] forKey:@"Regularization:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:trim forKey:@"Time Index:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:z_trim forKey:@"Slice Index:"]];
		
	// Print method for inputParameter
//	NSLog(@"");
//	NSLog(@"inputParameter");
//	for (NSMutableDictionary *tmpDict in inputParameter) {
//		for (NSString *key in tmpDict)
//			NSLog(@"%@ %@", key, [tmpDict valueForKey:key]);
//	}

}

- (void)savePresetParameter:(int)tag
{
	// there are no presets for a model free algorithm
}

- (void)saveOutputParameter:(int)tag
{
	// add interpolation bool to export array
	[outputParameter addObject:[NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@", (interpolation==YES)? @"YES" : @"NO"] forKey:@"Interpolation:"]];
	
	// Print method for outputParameter
	NSLog(@"");
	NSLog(@"outputParameter");
	for (NSMutableDictionary *tmpDict in outputParameter) {
		for (NSString *key in tmpDict)
			NSLog(@"%@ %@", key, [tmpDict valueForKey:key]);
	}
}

- (void)drawReportView
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
}

- (void)startCalculation:(UMMPROIRec *)tissueROI andAlgorithmTag:(int)tag
{
	// hides the ROI information before taking the screenshot for the UMMPerfusion report
    [[NSUserDefaults standardUserDefaults] setBool: YES forKey: @"ROITEXTIFSELECTED"];
    [controller deselectAllRois];
    
    ViewerController *vc = [controller viewerController];
	UMMPerfusionFilter *filter = [controller filter];
	id waitWindow = [vc startWaitWindow: @"Calculating..."];

	int i;
	int n, slices;
	int start, stop;
	int startSli, stopSli;
	
	int bl, tracer;

	float mean;

	double htc;
	double regPara;

	float *aif = 0;
	double *time = 0;
	BOOL interpol;

	DCMPix *tmpPix;

	//ROI *roi = [roiRec roi];
	NSInteger roiTag = [arterialButton selectedTag];
    NSMutableArray *roiData = [[NSMutableArray alloc] init];
    UMMPROIRec *roiRec = [[controller roiList] findRecordByTag: roiTag];
	ROI *roi = [roiRec roi];
    
	start = [startSlider intValue];
	stop = [endSlider intValue]+1;
	slices = [[vc pixList] count];
	
	startSli = [startSliceSlider intValue];
	stopSli = [endSliceSlider intValue];
	
 	bl = [baseLineLength intValue];
	tracer = [tracerButton indexOfSelectedItem];
	htc = [hematocrit doubleValue];
	regPara = [regularizationParameter doubleValue];
	//	//n = [_viewer maxMovieIndex];
	n = stop-start;
    
	aif = (float*)calloc(n, sizeof(float));
	time = (double*)calloc(n, sizeof(double));
    
    if ([arterialButton selectedTag] == externalROITag) {
        for (i=0; i<n; i++) {
            
            // get the aif values of the imported csv file
            mean = [[controller prefController] getAifValue:i];
            
            aif[i] = mean;
            [roiData addObject:[NSNumber numberWithFloat:mean]];
        }
        
    } else {
        for (i=0; i<n; i++) {
            //tmpPix = [[vc pixList: i+start] objectAtIndex:[vc imageIndexOfROI:roi]];
            tmpPix = [[vc pixList:i+start] objectAtIndex:[roiRec slice]];
            [tmpPix computeROI:roi :&mean :NULL :NULL :NULL :NULL];
            aif[i] = mean;
            
            [roiData addObject:[NSNumber numberWithFloat:mean]];
        }
    }
    
	//  [self calculateDeltaTime:_viewer time:time start:start stop:stop];
	double *viewerTime = [controller time];
	// the time array has to start with the value 0, correction with time[i+1]
	for (i=0; i<n-1; i++)
		time[i+1] = viewerTime[i+start];

	NSString *name = @"Fast Deconvolution";
	
	ViewerController *pfViewer = [filter duplicateViewer: vc deleteROIs: NO];
	ViewerController *vdViewer = [filter duplicateViewer: vc deleteROIs: NO];
	ViewerController *mtViewer = [filter duplicateViewer: vc deleteROIs: NO];
		
	[[[pfViewer pixList] objectAtIndex:0] setGeneratedName:@"Plasma Flow (ml/100ml/min)"];
	[[[vdViewer pixList] objectAtIndex:0] setGeneratedName:@"Volume of Distribution (ml/100ml)"];
	[[[mtViewer pixList] objectAtIndex:0] setGeneratedName:@"Mean Transit Time (sec)"];

	// Add all created viewers to our viewer management
	UMMPViewerList *viewerList = [controller viewerList];
	[viewerList addViewer:pfViewer name:[NSString stringWithFormat:@"%@ - Plasma Flow (ml/100ml/min)", name]];
	[viewerList addViewer:vdViewer name:[NSString stringWithFormat:@"%@ - Volume of Distribution (ml/100ml)", name]];
	[viewerList addViewer:mtViewer name:[NSString stringWithFormat:@"%@ - Mean Transit Time (sec)", name]];

	// Add all viewers to NotificationCenter to catch the right OsirixCloseViewerNotification
	[[NSNotificationCenter defaultCenter] addObserver: viewerList selector: @selector(removeViewer:) name: OsirixCloseViewerNotification object: pfViewer];
	[[NSNotificationCenter defaultCenter] addObserver: viewerList selector: @selector(removeViewer:) name: OsirixCloseViewerNotification object: vdViewer];
	[[NSNotificationCenter defaultCenter] addObserver: viewerList selector: @selector(removeViewer:) name: OsirixCloseViewerNotification object: mtViewer];

	NSDate *startTime = [NSDate date];
    
#ifdef __LP64__
	// 64-bit code
	
	NSLog(@"UMMPerfusion - FastDeconvolution 64-bit");
	if ((interpol=[controller interpolation])) {
		NSLog(@"UMMPerfusion - Dataset needs interpolation!");
	}
	
	
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
	
	dispatch_apply(slices, queue, ^(size_t sli) {
	//	dispatch_apply(slices, queue, ^(size_t sli) {
		
		NSLog(@"FD slice: %lu", sli);
			
#else
		// 32-bit code
		
		NSLog(@"UMMPerfusion - FastDeconvolution 32-bit");
		if ((interpol=[controller interpolation])) {
			NSLog(@"UMMPerfusion - Dataset needs interpolation!");
		}

		int sli;
		for (sli=0; sli < slices; sli++) {
			NSLog(@"FD slice: %d", sli);
				
#endif
			
			int i, j, k;
			float *fImage = 0;
			double *p = 0;
			
			DCMPix *curPix = [[vc pixList:0] objectAtIndex:sli];
			int m_img = curPix.pheight;
			int n_img = curPix.pwidth;
			
			p = (double*)calloc((m_img*n_img*n), sizeof(double));
			
			// change origin from top left to bottom left
			for (i=0; i<n; i++) {
				fImage = [[[vc pixList:i+start] objectAtIndex:sli] fImage];
				for (j = m_img; j>0; j--) {
					for (k = 0; k<n_img; k++) {
						p[((m_img-j)*n_img+k)*n+i] = fImage[((j-1)*n_img)+k];
					}
				}
			}
									
			float *pffImage = [[[pfViewer pixList] objectAtIndex:sli] fImage];
			float *vdfImage = [[[vdViewer pixList] objectAtIndex:sli] fImage];
			float *mtfImage = [[[mtViewer pixList] objectAtIndex:sli] fImage];
			
			if ((sli < (startSli-1)) || (sli > (stopSli-1))) {
				
				
				for (i=0; i<n_img*m_img; i++) {
					pffImage[i] = -1;				
					vdfImage[i] = -1;
					mtfImage[i] = -1;
				}
			} 
			else 
			{
				float *pf = (float*)calloc(n_img*m_img, sizeof(float));
				float *vd = (float*)calloc(n_img*m_img, sizeof(float));
				float *mt = (float*)calloc(n_img*m_img, sizeof(float));
				
				interpolation = [UMMPFastDeconvolution fd:n :m_img :n_img :p :aif :time :tracer :bl :htc :regPara :pf :vd :mt :[startSlider intValue]];
												
				for (j = m_img; j>0; j--) {
					for (k = 0; k<n_img; k++) {
						pffImage[((j-1)*n_img)+k]= pf[(m_img-j)*n_img+k];
						vdfImage[((j-1)*n_img)+k]= vd[(m_img-j)*n_img+k];
						mtfImage[((j-1)*n_img)+k]= mt[(m_img-j)*n_img+k];
						
					}
				}
				
				if (pf) free(pf);
				if (vd) free(vd);
				if (mt) free(mt);
				
			}
            
			if (p) free(p);
			
			[pfViewer needsDisplayUpdate];
			[vdViewer needsDisplayUpdate];
			[mtViewer needsDisplayUpdate];
			
			
			
#ifdef __LP64__
			// 64-bit code
			// dispatch_queue_t end
		});
#else
		// 32-bit code
		// for loop end
	}
#endif
				   
				   
    NSDate *endTime = [NSDate date];
    NSLog(@"UMMPerfusion - FastDeconvolution total term: %lf", [endTime timeIntervalSinceDate:startTime]);
				   
    [self drawReportWithAif:roiData];
    [roiData release];
                   
    // free memory
    if (aif) free(aif);
    if (time) free(time);
                   
    [vc endWaitWindow: waitWindow];
                   
    // Start export if enabled
//    if ([autosaveCheckButton state]) {
//            [controller pushExportButton:nil];
//    }
                   
}

@end
