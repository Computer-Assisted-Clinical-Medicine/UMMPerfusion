//
//  UMMP2C2InletUptakePixelBasedMapController.m
//  UMMPerfusion
//
//  Created by Student on 03.08.16.
//
//

#import "UMMP2C2InletUptakePixelBasedMapController.h"


@implementation UMMP2C2InletUptakePixelBasedMapController

- (id)init
{
    self = [super init];
    return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (BOOL)checkUserInput
{
    UMMPROIRec *tissueRoiRec = [[controller roiList] findRecordByTag:[tissueButton selectedTag]];
    
    if (![arterialButton selectedItem]) {
        /* No ROI selected */
        NSRunAlertPanel(@"Invalid ROI", @"Please select an arterial ROI.", @"OK",nil,nil);
        return NO;
	}else if (![venousButton selectedItem]) {
        /* No ROI selected */
        NSRunAlertPanel(@"Invalid ROI", @"Please select a venous ROI.", @"OK",nil,nil);
        return NO;
    }else if (![tissueButton selectedItem]) {
        /* No ROI selected */
        NSRunAlertPanel(@"Invalid ROI", @"Please select a tissue ROI.", @"OK",nil,nil);
        return NO;
    } else if ([[tissueRoiRec roi] type] != 6) {
        // only rectangular ROIs allowed
        NSRunAlertPanel(@"Invalid ROI type", @"Only rectangular ROIs for tissue allowed.", @"OK",nil,nil);
        return NO;
    } else if ([baseLineLength intValue] <= 0 || [baseLineLength intValue] > [endSlider intValue]-[startSlider intValue]) {
		/* baseLineLength <= 0 */
        NSRunAlertPanel(@"Invalid Length of Baseline", [NSString stringWithFormat:@"Please use Baseline length between %d and %d.", 1 ,[endSlider intValue]-[startSlider intValue]], @"OK",nil,nil);
        return NO;
	} else if ([hematocrit doubleValue] <= 0.0 || [hematocrit doubleValue] >= 1.0) {
		/* hematocrit <= 0 || >= 1 */
        NSRunAlertPanel(@"Invalid Hematocrit", @"Please use correct Hematocrit.", @"OK",nil,nil);
        return NO;
	} else if (([tissueRoiRec slice] < [startSliceSlider intValue]-1) || ([tissueRoiRec slice] > [endSliceSlider intValue]-1)) {
		// tissue ROI is placed on an unused slice
        NSRunAlertPanel(@"ROI placement", @"selected tissue ROI is placed on an unused slice!", @"OK", nil, nil);
		return NO;
	}
	
    return YES;
    
}

/* saveInputParameter method is the same for all pixel based algorithms */
- (void)saveInputParameter:(UMMPROIRec *)tissueROI andAlgorithmName:(NSString *)algorithm
{
    ViewerController *viewer = [controller viewerController];
	
	NSCalendarDate *curDate = [NSCalendarDate calendarDate];
	[curDate setCalendarFormat:@"%Y-%m-%d %H:%M:%S"];
	
	UMMPROIRec *arterialROIRec = [[controller roiList] findRecordByTag:[arterialButton selectedTag]];
    UMMPROIRec *venousROIRec = [[controller roiList] findRecordByTag:[venousButton selectedTag]];
	UMMPROIRec *tissueROIRec = [[controller roiList] findRecordByTag:[tissueButton selectedTag]];
    
	NSString *arterialRoi = @"";
    NSString *venousRoi = @"";
    NSString *csvFilePath = @"";
    
    if ([arterialButton selectedTag] == externalROITag) {
        csvFilePath = [[controller prefController] extROIFilePathForReport];
        arterialRoi = [NSString stringWithFormat:@"External ROI  Filepath: %@", csvFilePath];
        
    } else {
        arterialRoi = [NSString stringWithFormat:@"%@   slice: %ld   timepoint: %ld", [[arterialROIRec roi] name], (long)[arterialROIRec slice]+1, (long)[arterialROIRec timePoint]+1];
        
        if (!arterialRoi)
            arterialRoi = @"n.a.";
    }
    
    if ([venousButton selectedTag] == externalROITag) {
        csvFilePath = [[controller prefController] extROIFilePathForReport];
        venousRoi = [NSString stringWithFormat:@"External ROI  Filepath: %@", csvFilePath];
        
    } else {
        venousRoi = [NSString stringWithFormat:@"%@   slice: %ld   timepoint: %ld", [[venousROIRec roi] name], (long)[venousROIRec slice]+1, (long)[venousROIRec timePoint]+1];
        
        if (!venousRoi)
            venousRoi = @"n.a.";
    }
    
	NSString *tissueRoi = [NSString stringWithFormat:@"%@   slice: %ld   timepoint: %ld", [[tissueROIRec roi] name], (long)[tissueROIRec slice]+1, (long)[tissueROIRec timePoint]+1];
    if (!tissueRoi)
        tissueRoi = @"n.a.";
	
	NSString *trim = [NSString stringWithFormat:@"%d - %d", [startSlider intValue]+1, [endSlider intValue]+1];
    if (!trim)
        trim = @"n.a.";
	
	NSString *z_trim = [NSString stringWithFormat:@"%d - %d", [startSliceSlider intValue], [endSliceSlider intValue]];
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
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:[[[NSBundle bundleForClass:[self class]] infoDictionary] valueForKey:@"CFBundleShortVersionString"]
                                                                 forKey:@"Plugin Version:"]];
    [inputParameter addObject:[NSMutableDictionary dictionaryWithObject:[[controller algorithmPopUpButton] titleOfSelectedItem] forKey:@"Algorithm:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@", curDate] forKey:@"Creation Date:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:arterialRoi forKey:@"Arterial ROI:"]];
    [inputParameter addObject:[NSMutableDictionary dictionaryWithObject:venousRoi forKey:@"Venous ROI:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:tissueRoi forKey:@"Tissue ROI:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:[presetButton titleOfSelectedItem] forKey:@"Preset:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:[tracerButton titleOfSelectedItem] forKey:@"Appr. Tracer Concentration:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:[baseLineLength stringValue] forKey:@"Baseline:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"%1.2f (‰)", [hematocrit floatValue]] forKey:@"Hematocrit:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:trim forKey:@"Time Index:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:z_trim forKey:@"Slice Index:"]];
	
    
}

- (void)savePresetParameter:(int)tag
{
    NSMutableArray *parameters = nil;
    double v;
    int i;
    
    // gets the parameter for the 2C 2Inlet Uptake algorithm
    parameters = [[controller prefController] findParametersByTag:[presetButton selectedTag] forAlgorithm:@"2Inlet 2C Uptake"];
    
    if (parameters) {
        
        // parameter names
        for (i=0; i<[parameters count]; i++) {
            [presetParameter addObject:[NSMutableDictionary dictionaryWithObject:[[parameters objectAtIndex:i] name]
                                                                          forKey:[NSString stringWithFormat:@"Parameter Name %d",i]]];
        }
        
        // pValue
        NSString *pValue = nil;
        for (i = 0; i<[parameters count]; i++) {
            v = [[parameters objectAtIndex:i] pValue];
            pValue = [[NSNumber numberWithDouble:v] stringValue];
            [presetParameter addObject:[NSMutableDictionary dictionaryWithObject:pValue
                                                                          forKey:[NSString stringWithFormat:@"Value %d",i]]];
        }
        
        // limited high
        NSString *higherLimitRow = nil;
        for (i = 0; i<[parameters count]; i++) {
            if ([[parameters objectAtIndex:i] limitedHigh]) {
                v = [[parameters objectAtIndex:i] high];
                higherLimitRow = [[NSNumber numberWithDouble:v] stringValue];
                [presetParameter addObject:[NSMutableDictionary dictionaryWithObject:higherLimitRow
                                                                              forKey:[NSString stringWithFormat:@"Limited High in Row %d",i]]];
            }
            else {
                [presetParameter addObject:[NSMutableDictionary dictionaryWithObject:@" not used"
                                                                              forKey:[NSString stringWithFormat:@"Limit High in Row %d",i]]];
            }
        }
        
        // limited low
        NSString *lowerLimitRow = nil;
        for (i = 0; i < [parameters count]; i++) {
            if ([[parameters objectAtIndex:i] limitedLow]) {
                v = [[parameters objectAtIndex:0] low];
                lowerLimitRow = [[NSNumber numberWithDouble:v] stringValue];
                [presetParameter addObject:[NSMutableDictionary dictionaryWithObject:lowerLimitRow
                                                                              forKey:[NSString stringWithFormat:@"Limit Low in Row %d",i]]];
            }
            else {
                [presetParameter addObject:[NSMutableDictionary dictionaryWithObject:@" not used"
                                                                              forKey:[NSString stringWithFormat:@"Limit Low in Row %d",i]]];
            }
        }
    }
}

- (void)saveOutputParameter:(int)tag
{
    // Not needed
}

// selects the 2C 2Inlet Uptake map selection view to be displayed
- (void)startCalculation:(UMMPROIRec *)tissueROI andAlgorithmTag:(int)tag
{
    if (![mapSelectionPanel isVisible])
    {
        [self resizeWindowOnSpotWithView: twoComp2InletUptakeMapView];
        [mapSelectionPanel setContentView: twoComp2InletUptakeMapView];

        
        [[controller mapSelectionPanelController] refreshStatusOfMapSelection];
        [mapSelectionPanel makeKeyAndOrderFront:mapSelectionPanel];
    }
}

- (void)startMapCalculation
{
    // hides the ROI information before taking the screenshot for the UMMPerfusion report
    [[NSUserDefaults standardUserDefaults] setBool: YES forKey: @"ROITEXTIFSELECTED"];
    [controller deselectAllRois];
    
    // wait window
    ViewerController *vc = [controller viewerController];
    UMMPerfusionFilter *filter = [controller filter];
    id waitWindow = [vc startWaitWindow: @"Calculating..."];
    
    
    int i;
	int n, slices;
	int start, stop;
	int startSli, stopSli;
	//int usedSlices;
	
	//int m_img;
	//int n_img;
	
    int bl, tracer;
    
	float meanAif;
    float meanVif;
	
	double htc;
	
	float *aif;
    float *vif;
	double *time, *timeOld;
	
    DCMPix *curPix;
    
    NSInteger aifRoiTag = [arterialButton selectedTag];
    NSInteger vifRoiTag = [venousButton selectedTag];
    NSInteger tissueRoiTag = [tissueButton selectedTag];
    UMMPROIRec *aifRoiRec = [[controller roiList] findRecordByTag: aifRoiTag];
    UMMPROIRec *vifRoiRec = [[controller roiList] findRecordByTag: vifRoiTag];
    ROI *aifRoi = [[[controller roiList] findRecordByTag: aifRoiTag] roi];
    ROI *vifRoi = [[[controller roiList] findRecordByTag: vifRoiTag] roi];
    //NSArray *aifPoints = [aifRoi points];
    //MyPoint *point1 = [aifPoints objectAtIndex:0];
	//MyPoint *point2 = [aifPoints objectAtIndex:1];
    //MyPoint *point4 = [aifPoints objectAtIndex:2];
	//MyPoint *point3 = [aifPoints objectAtIndex:3];
    //    NSLog(@"Werte[1x] : %f", point1.x);
    //    NSLog(@"Werte[1y] : %f",point1.y);
    //    NSLog(@"Werte[2x] : %f",point2.x);
    //    NSLog(@"Werte[2y] : %f",point2.y);
    //    NSLog(@"Werte[3x] : %f",point3.x);
    //    NSLog(@"Werte[3y] : %f",point3.y);
    //    NSLog(@"Werte[4x] : %f",point4.x);
    //    NSLog(@"Werte[4y] : %f", point4.y);
    //
    
    
	ROI *tissueRoi = [[[controller roiList] findRecordByTag: tissueRoiTag] roi];
    
    start = [startSlider intValue];
	stop = [endSlider intValue]+1;
	
	startSli = [startSliceSlider intValue];
	stopSli = [endSliceSlider intValue];
	slices = [[vc pixList] count];
    
	bl = [baseLineLength intValue];
	tracer = [tracerButton indexOfSelectedItem];
	htc = [hematocrit doubleValue];
	//n = [_viewer maxMovieIndex];
	n = stop-start;
	
	//curPix = [[vc pixList:0] objectAtIndex:0];
	//m_img = curPix.pheight;  //will be calculated for each individual slice
	//n_img = curPix.pwidth;
	
	aif = (float*)calloc(n, sizeof(float));
    vif = (float*)calloc(n, sizeof(float));
	time = (double*)calloc(n, sizeof(double));
	timeOld = (double*)calloc(n, sizeof(double));
    
    NSMutableArray *aifRoiData = [[NSMutableArray alloc] init];
    NSMutableArray *vifRoiData = [[NSMutableArray alloc] init];
    
    // if the selected ROI for the arterialButton is an external ROI, then take the loaded values
    if ([arterialButton selectedTag] == externalROITag) {
        for (i=0; i<n; i++) {
            
            // get the aif values of the imported csv file
            meanAif = [[controller prefController] getAifValue:i];
            
            aif[i] = meanAif;
            [aifRoiData addObject:[NSNumber numberWithFloat:meanAif]];
        }
    } else {
        
        for (i=0; i<n; i++) {
            //curPix = [[vc pixList:i+start] objectAtIndex:[vc imageIndexOfROI:aifRoi]];
            curPix = [[vc pixList:i+start] objectAtIndex:[aifRoiRec slice]];
            [curPix computeROI:aifRoi :&meanAif :NULL :NULL :NULL :NULL];
            aif[i] = meanAif;
            [aifRoiData addObject:[NSNumber numberWithFloat:meanAif]];
        }
    }
    
    // if the selected ROI for the venousButton is an external ROI, then take the loaded values
    if ([venousButton selectedTag] == externalROITag) {
        for (i=0; i<n; i++) {
            
            // get the vif values of the imported csv file
            meanVif = [[controller prefController] getAifValue:i];
            
            vif[i] = meanVif;
            [vifRoiData addObject:[NSNumber numberWithFloat:meanVif]];
        }
    } else {
        
        for (i=0; i<n; i++) {
            //curPix = [[vc pixList:i+start] objectAtIndex:[vc imageIndexOfROI:vifRoi]];
            curPix = [[vc pixList:i+start] objectAtIndex:[vifRoiRec slice]];
            [curPix computeROI:vifRoi :&meanVif :NULL :NULL :NULL :NULL];
            vif[i] = meanVif;
            [vifRoiData addObject:[NSNumber numberWithFloat:meanVif]];
        }
    }
    
    
    //    [self calculateDeltaTime:vc time:time start:start stop:stop];
    
    // Get Time Variable from UMMPPanelController
    // double *viewerTime = [controller time];
    
    // Get 2D TimeArray from UMMPPanelController
    NSMutableArray *viewerTimeArray = [controller timeArray];
    
    /*
     // is now done inside the Queue , to make use of Slice Iteration
     // new implementation of Array filling ( iterates over all Timepoints on currentSlice )
     UMMPROIRec *tissueROIRec = [[controller roiList] findRecordByTag:[tissueButton selectedTag]];
     int currSlice = [tissueROIRec slice];
     for(i=0; i<n-1; i++){
     time[i+1] = [viewerTimeArray[i+start][currSlice] doubleValue];
     }
     */
    
    
    // the time array has to start with the value 0, correction with time[i+1]
    // for (i=0; i<n-1; i++)
    //    time[i+1] = viewerTime[i+start];
    
    //	if (interpol) {
    //
    //		// n = 1+floor(time[n-1]/dt) - idl
    //		m = 1 + floor(time[n-1]/min);
    //
    //        aifRegr = (float*)calloc(m, sizeof(float));
    //
    //		// time_regr = dt*dindgen(n) - idl
    //		timeRegr = (double*)calloc(m, sizeof(double));
    //		for (i = 0; i < m; i++) {
    //			//timeRegr[i] = time[i];
    //			timeRegr[i] = i * min;
    //		}
    //
    //		[FastDeconvolution aifRegrid:aif :time :n :aifRegr :timeRegr :m];
    //
    //        for (i=0; i<n; i++) {
    //            timeOld[i] = time[i];
    //        }
    //
    //        if (aif) free(aif);
    //        if (time) free(time);
    //		aif = aifRegr;
    //        time = timeRegr;
    //
    //		n = m;
    //	}
	
    ViewerController *afViewer = nil;
	ViewerController *vfViewer = nil;
	ViewerController *evViewer = nil;
	ViewerController *emttViewer = nil;
	ViewerController *iurViewer = nil;
	ViewerController *adtViewer = nil;
	ViewerController *vdtViewer = nil;
    ViewerController *affViewer = nil;
	ViewerController *hufViewer = nil;
	ViewerController *akViewer = nil;
	ViewerController *csViewer = nil;
    
    UMMPViewerList *viewerList = [controller viewerList];
    
    NSString *name = nil;
    NSString *selector = nil;
    
    // sets the algorithm and selector name for initialization
    name = @"2Inlet 2C Uptake";
    selector = @"twoC2InletUptake";
	
    // checks if the user wants the parameter to be displayed and if so it generates the viewer
	if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapAF",selector] otherwise:NO]) {
		afViewer = [filter duplicateViewer:vc deleteROIs:NO];
		[[[afViewer pixList] objectAtIndex:0] setGeneratedName:@"Arterial Flow (ml/100ml/min)"];
		[viewerList addViewer:afViewer name:[NSString stringWithFormat:@"%@ - Arterial Flow (ml/100ml/min)", name]];
        
        // resizes the image before taking the screenshot
        [afViewer resetImage:afViewer];
		[[NSNotificationCenter defaultCenter] addObserver:viewerList selector:@selector(removeViewer:) name:OsirixCloseViewerNotification object:afViewer];
	}
    if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapEMTT",selector] otherwise:NO]) {
		emttViewer = [filter duplicateViewer:vc deleteROIs:NO];
		[[[emttViewer pixList] objectAtIndex:0] setGeneratedName:@"Extracellular MTT (sec)"];
		[viewerList addViewer:emttViewer name:[NSString stringWithFormat:@"%@ - Extracellular MTT (sec)", name]];
        [emttViewer resetImage:emttViewer];
		[[NSNotificationCenter defaultCenter] addObserver:viewerList selector:@selector(removeViewer:) name:OsirixCloseViewerNotification object:emttViewer];
	}
	if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapEV",selector] otherwise:NO]) {
		evViewer = [filter duplicateViewer:vc deleteROIs:NO];
		[[[evViewer pixList] objectAtIndex:0] setGeneratedName:@"Extracellular Volume (ml/100ml)"];
		[viewerList addViewer:evViewer name:[NSString stringWithFormat:@"%@ - Extracellular Volume (ml/100ml)", name]];
        [evViewer resetImage:evViewer];
		[[NSNotificationCenter defaultCenter] addObserver:viewerList selector:@selector(removeViewer:) name:OsirixCloseViewerNotification object:evViewer];
	}
	if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapVF",selector] otherwise:NO]) {
		vfViewer = [filter duplicateViewer:vc deleteROIs:NO];
		[[[vfViewer pixList] objectAtIndex:0] setGeneratedName:@"Venous Flow (ml/100ml/min)"];
		[viewerList addViewer:vfViewer name:[NSString stringWithFormat:@"%@ - Venous Flow (ml/100ml/min)", name]];
        [vfViewer resetImage:vfViewer];
		[[NSNotificationCenter defaultCenter] addObserver:viewerList selector:@selector(removeViewer:) name:OsirixCloseViewerNotification object:vfViewer];
	}
	if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapIUR",selector] otherwise:NO]) {
		iurViewer = [filter duplicateViewer:vc deleteROIs:NO];
		[[[iurViewer pixList] objectAtIndex:0] setGeneratedName:@"Intracellular Uptake Rate (1/min)"];
        [viewerList addViewer:iurViewer name:[NSString stringWithFormat:@"%@ - Intracellular Uptake Rate (1/min)", name]];
        [iurViewer resetImage:iurViewer];
		[[NSNotificationCenter defaultCenter] addObserver:viewerList selector:@selector(removeViewer:) name:OsirixCloseViewerNotification object:iurViewer];
	}
    if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapADT",selector] otherwise:NO]) {
		adtViewer = [filter duplicateViewer:vc deleteROIs:NO];
		[[[adtViewer pixList] objectAtIndex:0] setGeneratedName:@"Arterial Delay Time (sec)"];
        [viewerList addViewer:adtViewer name:[NSString stringWithFormat:@"%@ - Arterial Delay Time (sec)", name]];
        [adtViewer resetImage:adtViewer];
		[[NSNotificationCenter defaultCenter] addObserver:viewerList selector:@selector(removeViewer:) name:OsirixCloseViewerNotification object:adtViewer];
	}
    if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapVDT",selector] otherwise:NO]) {
		vdtViewer = [filter duplicateViewer:vc deleteROIs:NO];
		[[[vdtViewer pixList] objectAtIndex:0] setGeneratedName:@"Venous Delay Time (sec)"];
        [viewerList addViewer:vdtViewer name:[NSString stringWithFormat:@"%@ - Venous Delay Time (sec)", name]];
        [vdtViewer resetImage:vdtViewer];
		[[NSNotificationCenter defaultCenter] addObserver:viewerList selector:@selector(removeViewer:) name:OsirixCloseViewerNotification object:vdtViewer];
	}
    if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapAFF",selector] otherwise:NO]) {
		affViewer = [filter duplicateViewer:vc deleteROIs:NO];
		[[[affViewer pixList] objectAtIndex:0] setGeneratedName:@"Arterial Flow Fraction (%)"];
        [viewerList addViewer:affViewer name:[NSString stringWithFormat:@"%@ - Arterial Flow Fraction (Percent)", name]];
        [affViewer resetImage:affViewer];
		[[NSNotificationCenter defaultCenter] addObserver:viewerList selector:@selector(removeViewer:) name:OsirixCloseViewerNotification object:affViewer];
	}
    if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapHUF",selector] otherwise:NO]) {
		hufViewer = [filter duplicateViewer:vc deleteROIs:NO];
		[[[hufViewer pixList] objectAtIndex:0] setGeneratedName:@"Hepatic Uptake Fraction (%)"];
        [viewerList addViewer:hufViewer name:[NSString stringWithFormat:@"%@ - Hepatic Uptake Fraction (Percent)", name]];
        [hufViewer resetImage:hufViewer];
		[[NSNotificationCenter defaultCenter] addObserver:viewerList selector:@selector(removeViewer:) name:OsirixCloseViewerNotification object:hufViewer];
	}
	if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapCAIC",selector] otherwise:NO]) {
		akViewer = [filter duplicateViewer:vc deleteROIs:NO];
		[[[akViewer pixList] objectAtIndex:0] setGeneratedName:@"Corr. Akaike Information Crit."];
		[viewerList addViewer:akViewer name:[NSString stringWithFormat:@"%@ - Corr. Akaike Information Crit.", name]];
        [akViewer resetImage:nil];
		[[NSNotificationCenter defaultCenter] addObserver:viewerList selector:@selector(removeViewer:) name:OsirixCloseViewerNotification object:akViewer];
	}
	if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapCS",selector] otherwise:NO]) {
		csViewer = [filter duplicateViewer:vc deleteROIs:NO];
		[[[csViewer pixList] objectAtIndex:0] setGeneratedName:@"Final Chi Square"];
		[viewerList addViewer:csViewer name:[NSString stringWithFormat:@"%@ - Final Chi Square", name]];
        [csViewer resetImage:nil];
		[[NSNotificationCenter defaultCenter] addObserver:viewerList selector:@selector(removeViewer:) name:OsirixCloseViewerNotification object:csViewer];
	}
	NSDate *startTime = [NSDate date];
	
	lmuEnhancement(aif, n, bl, tracer);
    lmuEnhancement(vif, n, bl, tracer);
	
	// Adapt AIF and VIF to Hematocrit
	double htcDifference = 1-htc;
	
	for (i = 0; i < n; i++) {
		aif[i] /= htcDifference;
        vif[i] /= htcDifference;
	}
	
    NSArray *points = [tissueRoi points];
    
    //	MyPoint *point1 = [points objectAtIndex:0];
    //	MyPoint *point2 = [points objectAtIndex:1];
    //	MyPoint *point3 = [points objectAtIndex:3];
    MyPoint *point1 = [points objectAtIndex:0];
    MyPoint *point2 = [points objectAtIndex:1];
    MyPoint *point3 = [points objectAtIndex:3];
    
	// Start for slices
    
#ifdef __LP64__
	// 64-bit code
	NSLog(@"UMMPerfusion - %@Map 64-bit",name);
	
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
	
	dispatch_apply(slices, queue, ^(size_t sli) {
		
        NSLog(@"%@Map-Pixel slice: %lu START",name, sli);
		
#else
		// 32-bit code
		NSLog(@"UMMPerfusion - %@Map 64-bit",selector);
		
		int sli;
		for (sli=0; sli<slices; sli++) {
			NSLog(@"%@Map-Pixel slice: %d START",name, sli);
			
#endif
            
            
            // use Queue to write timepoints from current Slice into time[]
            for(int j=0; j < [viewerTimeArray count]; j++){
                time[j+1] = [viewerTimeArray[j+start][sli] doubleValue];
                // Test Output
                //    NSLog(@"UMMP inQueue timeArray[%d] = %f",(j+start), time[j+1] );
                // Test Output end
            }
            
            int m_img=[[[vc pixList:0]objectAtIndex:sli] pheight];
            int n_img=[[[vc pixList:0]objectAtIndex:sli] pwidth];
            
            
            int i, j, k;
            
            float *tissue;
            float *fImage;
            float *afImage, *vfImage, *emttImage, *evImage, *iurImage, *adtImage, *vdtImage, *affImage, *hufImage, *akfImage, *csfImage;
            double **p;
            
            // saves the pixel values of the current slice into a float array
            if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapAF",selector] otherwise:NO])
                afImage = [[[afViewer pixList] objectAtIndex:sli] fImage];
            if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapVF",selector] otherwise:NO])
                vfImage = [[[vfViewer pixList] objectAtIndex:sli] fImage];
            if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapEMTT",selector] otherwise:NO])
                emttImage = [[[emttViewer pixList] objectAtIndex:sli] fImage];
            if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapEV",selector] otherwise:NO])
                evImage = [[[evViewer pixList] objectAtIndex:sli] fImage];
            if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapIUR",selector] otherwise:NO])
                iurImage = [[[iurViewer pixList] objectAtIndex:sli] fImage];
            if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapADT",selector] otherwise:NO])
                adtImage = [[[adtViewer pixList] objectAtIndex:sli] fImage];
            if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapVDT",selector] otherwise:NO])
                vdtImage = [[[vdtViewer pixList] objectAtIndex:sli] fImage];
            if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapAFF",selector] otherwise:NO])
                affImage = [[[affViewer pixList] objectAtIndex:sli] fImage];
            if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapHUF",selector] otherwise:NO])
                hufImage = [[[hufViewer pixList] objectAtIndex:sli] fImage];
            if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapCAIC",selector] otherwise:NO])
                akfImage = [[[akViewer pixList] objectAtIndex:sli] fImage];
            if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapCS",selector] otherwise:NO])
                csfImage = [[[csViewer pixList] objectAtIndex:sli] fImage];
			
            // if the current slice "sli" is placed on an "unused slice" the whole slice is set to vaue -1
			if ((sli < (startSli-1)) || (sli > (stopSli-1))) {
				
				for(i=0; i<(n_img*m_img); i++) {
					if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapAF",selector] otherwise:NO])
						afImage[i] = -1.0;
					if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapVF",selector] otherwise:NO])
						vfImage[i] = -1.0;
					if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapEMTT",selector] otherwise:NO])
						emttImage[i] = -1.0;
					if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapEV",selector] otherwise:NO])
						evImage[i] = -1.0;
					if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapIUR",selector] otherwise:NO])
						iurImage[i] = -1.0;
					if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapADT",selector] otherwise:NO])
						adtImage[i] = -1.0;
					if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapVDT",selector] otherwise:NO])
						vdtImage[i] = -1.0;
                    if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapAFF",selector] otherwise:NO])
						affImage[i] = -1.0;
					if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapHUF",selector] otherwise:NO])
						hufImage[i] = -1.0;
					if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapCAIC",selector] otherwise:NO])
						akfImage[i] = -1.0;
					if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapCS",selector] otherwise:NO])
						csfImage[i] = -1.0;
				}
			}
            // if the current slice "sli" is placed on a "used slice" the values are calculated
			else
			{
                if ([tissueRoi type]==tROI) {
					
					p = (double**)calloc(n, sizeof(double*));
					for (i=0; i<n; i++)
						p[i] = (double*)calloc(m_img*n_img, sizeof(double));
					
					for (i=0; i<n; i++) {
						fImage = [[[vc pixList:i+start] objectAtIndex:sli] fImage];
						for (j=0; j<m_img; j++) {
							for (k=0; k<n_img; k++) {
								if (k>=(int)(point1.x+0.5) && k<=(int)(point3.x+0.5) && j>=(int)(point1.y+0.5) && j<=(int)(point2.y+0.5)) {
                                    p[i][j*n_img+k] = fImage[j*n_img+k];
                                } else {
                                    p[i][j*n_img+k] = -1.0;
                                }
							}
						}
					}
				}
				
				for (i=0; i<n_img*m_img; i++) {
					
					tissue = (float*)calloc(n, sizeof(float));
					
					if (p[0][i] != -1.0) {
						
						for (j=0; j<n; j++) {
							tissue[j] = p[j][i];
						}
						
						double *curveFit = (double *)calloc(n, sizeof(double));
						
						// Enhancement TISSUE
						lmuEnhancement(tissue, n, bl, tracer);
						
						double af, vf, te, ve, ki, ta, tv, fi, fa, correctedAkaikeError, chiSquare = 0.0;
						
                        int fixedSize;
                        int limitedSize;
                        int limitsSize;
                        int paraSize;
                        int *fixed = NULL;
                        int *limited = NULL;
                        double *limits = NULL;
                        double *para = NULL;
                        
                        // determination of the array sizes (fixed, limited, limits, para)
                        fixedSize = 6;
                        limitedSize = 12;
                        limitsSize = 12;
                        paraSize = 6;
                        
                        // allocation of the arrays for parameter values
						fixed = (int*)calloc(fixedSize, sizeof(int));
						limited = (int*)calloc(limitedSize, sizeof(int));
						limits  = (double*)calloc(limitsSize, sizeof(double));
						para = (double*)calloc(paraSize, sizeof(double));
						
						// Read parameters from preference window and transfer them to arrays for MPCurveFit
						NSMutableArray *parameters = [[controller prefController] findParametersByTag:[presetButton selectedTag] forAlgorithm:name];
						
                        int counter;
                        for (counter = 0; counter < [parameters count]; counter++) {
                            para[counter] = [[parameters objectAtIndex:counter] pValue];
                            fixed[counter] = [[parameters objectAtIndex:counter] fixed];
                            limited[(counter*2)] = [[parameters objectAtIndex:counter] limitedLow];         /* e.g. limited[0] = limitedLow at position 0 */
                            limited[(counter*2)+1] = [[parameters objectAtIndex:counter] limitedHigh];      /*      limited[1] = limitedHigh at position 0*/
                            limits[(counter*2)] = [[parameters objectAtIndex:counter] low];                 /*      limited[2] = limitedLow at position 1*/
                            limits[(counter*2)+1] = [[parameters objectAtIndex:counter] high];              /*      limited[3] = limitedHigh at position 1*/
                        }
                        
						int maxiterations = [[[controller userDefaults] string:@"UMMPMaxIterations" otherwise:@"200"] intValue];
						int maxFunctionEvaluation = [[[controller userDefaults] string:@"UMMPMaxFunctionEvaluation" otherwise:@"1000"] intValue];
                        
                        // calls the fitSingleInlet methods of MPCurveFit
                        fitDoubleInletUptake(n, para, fixed, limited, limits, maxiterations, maxFunctionEvaluation, time, aif, vif, tissue, curveFit, &af, &vf, &ve, &ki, &ta, &tv, &fi, &fa, &te, &correctedAkaikeError, &chiSquare, nil);
						
                        //                        NSLog(@"maxiter: %d", maxiterations);
                        //                        NSLog(@"maxfev: %d", maxFunctionEvaluation);
                        
						if(curveFit) free(curveFit);
						
						//if (pf > 1000)
						//	pf = -1.0;
						if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapAF",selector] otherwise:NO])
							afImage[i] = af;
						if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapVF",selector] otherwise:NO])
							vfImage[i] = vf;
						if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapEMTT",selector] otherwise:NO])
							emttImage[i] = te;
						if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapEV",selector] otherwise:NO])
							evImage[i] = ve;
						if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapIUR",selector] otherwise:NO])
							iurImage[i] = ki;
						if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapADT",selector] otherwise:NO])
							adtImage[i] = ta;
						if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapVDT",selector] otherwise:NO])
							vdtImage[i] = tv;
                        if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapAFF",selector] otherwise:NO])
							affImage[i] = fa;
						if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapHUF",selector] otherwise:NO])
							hufImage[i] = fi;
						if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapCAIC",selector] otherwise:NO])
							akfImage[i] = correctedAkaikeError;
						if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapCS",selector] otherwise:NO])
							csfImage[i] = chiSquare;
						
					}
                    // sets the values outside the rectangular ROI to -1
                    else {
						if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapAF",selector] otherwise:NO])
							afImage[i] = -1.0;
						if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapVF",selector] otherwise:NO])
							vfImage[i] = -1.0;
						if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapEMTT",selector] otherwise:NO])
							emttImage[i] = -1.0;
						if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapEV",selector] otherwise:NO])
							evImage[i] = -1.0;
						if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapIUR",selector] otherwise:NO])
							iurImage[i] = -1.0;
						if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapADT",selector] otherwise:NO])
							adtImage[i] = -1.0;
						if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapVDT",selector] otherwise:NO])
							vdtImage[i] = -1.0;
                        if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapAFF",selector] otherwise:NO])
							affImage[i] = -1.0;
						if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapHUF",selector] otherwise:NO])
							hufImage[i] = -1.0;
						if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapCAIC",selector] otherwise:NO])
							akfImage[i] = -1.0;
						if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapCS",selector] otherwise:NO])
							csfImage[i] = -1.0;
					}
					if (tissue) free(tissue);
				}
				
				if (p) {
					for (i=0; i<n; i++)
						free(p[i]);
					free(p);
				}
				
			}
            
            
            
#ifdef __LP64__
            // 64-bit code
            // dispatch_queue_t end
            NSLog(@"%@Map-Pixel slice : %lu END", name, sli);
        });
#else
        // 32-bit code
        // for loop end
        NSLog(@"%@Map-Pixel slice : %d END", name, sli);
	}
#endif
                   
                   // End for slices
                   if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapAF",selector] otherwise:NO]){
                       [afViewer resetImage:afViewer];
                       [afViewer needsDisplayUpdate];
                   }
                   if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapVF",selector] otherwise:NO])
                   [vfViewer needsDisplayUpdate];
                   if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapEMTT",selector] otherwise:NO])
                   [emttViewer needsDisplayUpdate];
                   if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapEV",selector] otherwise:NO])
                   [evViewer needsDisplayUpdate];
                   if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapIUR",selector] otherwise:NO])
                   [iurViewer needsDisplayUpdate];
                   if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapADT",selector] otherwise:NO])
                   [adtViewer needsDisplayUpdate];
                   if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapVDT",selector] otherwise:NO])
                   [vdtViewer needsDisplayUpdate];
                   if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapAFF",selector] otherwise:NO])
                   [affViewer needsDisplayUpdate];
                   if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapHUF",selector] otherwise:NO])
                   [hufViewer needsDisplayUpdate];
                   if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapCAIC",selector] otherwise:NO])
                   [akViewer needsDisplayUpdate];
                   if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapCS",selector] otherwise:NO])
                   [csViewer needsDisplayUpdate];
                   
                   NSDate *endTime = [NSDate date];
                   NSLog(@"UMMPerfusion - %@Map totalterm : %lf", name, [endTime timeIntervalSinceDate:startTime]);
                   
                   [self drawReportWithAif:aifRoiData];
                   
                   // free memory
                   if (aif) free(aif);
                   if (vif) free(vif);
                   if (time) free(time);
                   if (timeOld) free(timeOld);
                   
                   [aifRoiData release];
                   [vifRoiData release];
                   
                   [vc endWaitWindow: waitWindow];
				   
                   // Start export if enabled
                   if ([autosaveCheckButton state])
                   [controller pushExportButton:nil];
                   
                   if([[controller userDefaults] int:@"soundOnMapsCalcEnd" otherwise:NO]){
                       NSSpeechSynthesizer *mySpeechSynth = [[NSSpeechSynthesizer alloc] initWithVoice:nil];
                       [mySpeechSynth startSpeakingString:@"Map calculation has been completed."];
                       [mySpeechSynth release];
                   }
                   
                   
                   [[controller viewerController] resetImage:[controller viewerController]];
                   if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapVF",selector] otherwise:NO])
                   [vfViewer resetImage:vfViewer];
                   if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapEMTT",selector] otherwise:NO])
                   [emttViewer resetImage:emttViewer];
                   if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapEV",selector] otherwise:NO])
                   [evViewer resetImage:evViewer];
                   if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapIUR",selector] otherwise:NO])
                   [iurViewer resetImage:iurViewer];
                   if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapADT",selector] otherwise:NO])
                   [adtViewer resetImage:adtViewer];
                   if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapVDT",selector] otherwise:NO])
                   [vdtViewer resetImage:vdtViewer];
                   if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapAFF",selector] otherwise:NO])
                   [affViewer resetImage:affViewer];
                   if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapHUF",selector] otherwise:NO])
                   [hufViewer resetImage:hufViewer];
                   if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapCAIC",selector] otherwise:NO])
                   [akViewer resetImage:akViewer];
                   if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapCS",selector] otherwise:NO])
                   [csViewer resetImage:csViewer];
                   }


@end
