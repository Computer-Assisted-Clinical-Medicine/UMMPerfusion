//
//  UMMPAFAllMapsController.m
//  UMMPerfusion
//
//  Created by Markus Daab on 20.07.12.
//  Copyright (c) 2012, Marcel Reich & Sven Kaiser & Markus Daab & Patrick Schülein & Engin Aslan
//  All rights reserved.
//

#import "UMMPAFAllMapsController.h"


@implementation UMMPAFAllMapsController


//@synthesize tissueROITableView;


- (id)init
{
	self = [super init];
	dict = [[NSMutableDictionary alloc] init];
	return self;
}

- (void)dealloc
{	
	[dict release]; dict = NULL;
	[super dealloc];
}



- (void)addROIRec:(UMMPROIRec *)roiRec
{
	
	[self addROIRec:roiRec withName:@"unnamed"];	
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
        [[tissueButton menu] addItem:[menuItem copy]];
    };
	
	BOOL recordsExist = [[arterialButton menu] numberOfItems] > 0;	
	if (recordsExist) {
		[arterialButton setEnabled:YES];
		[tissueButton setEnabled:YES];
		[self drawSelectedROIRecs];
		[[controller drawer] open];
	}
}

- (void)changeROIRec:(UMMPROIRec *)roiRec
{
	NSMenuItem *arterialMenuItem = [[arterialButton menu] itemWithTag:[roiRec tag]];
	//UMMPROIRec *arterialROIRec = [[controller roiList] findRecordByTag:[arterialButton selectedTag]];
	[arterialMenuItem setTitle:[NSString stringWithFormat:@"%@   SL:%ld   TP:%ld", [[roiRec roi] name], (long)[roiRec slice]+1, (long)[roiRec timePoint]+1]];
	
	NSMenuItem *tissueMenuItem = [[tissueButton menu] itemWithTag:[roiRec tag]];
	[tissueMenuItem setTitle:[NSString stringWithFormat:@"%@   SL:%ld   TP:%ld", [[roiRec roi] name], (long)[roiRec slice]+1, (long)[roiRec timePoint]+1]];
	
}

- (void)removeROIRec:(UMMPROIRec *)roiRec
{
	NSMenuItem *arterialMenuItem = [[arterialButton menu] itemWithTag:[roiRec tag]];
	NSMenuItem *tissueMenuItem	 = [[tissueButton menu] itemWithTag:[roiRec tag]];
	
	[[arterialButton menu] removeItem:arterialMenuItem];
	[[tissueButton menu] removeItem:tissueMenuItem];
    
	
	[self drawSelectedROIRecs];
	
	BOOL recordsExist = [[arterialButton menu] numberOfItems] > 0;
	if (!recordsExist) {
		[arterialButton setEnabled:NO];
		[tissueButton setEnabled:NO];
		[[controller drawer] close];
	}
}

- (void)drawSelectedROIRecs
{
	NSMutableArray *records = [[controller roiList] records];
	
	for (UMMPROIRec *roiRec in records) {
		
		// check which ROIRec in the RoiRec records is selected
		if ([roiRec tag] == [[arterialButton selectedItem] tag] || [roiRec tag] == [[tissueButton selectedItem] tag] || (([roiRec tag] == [[controller roiList] externalRoiRecTag]) && ([[arterialButton selectedItem] tag] == externalROITag))) {
            
            // draw ROIRec
			[[roiRec meanDataSet] setProperty:[NSNumber numberWithBool:NO] forKey:GRDataSetHidden];
        } else {
			[[roiRec meanDataSet] setProperty:[NSNumber numberWithBool:YES] forKey:GRDataSetHidden];
        }
        
        [[controller chart] refresh:roiRec];
	}
    
    [[controller chart] setNeedsDisplay:YES];
}

#pragma mark - 
#pragma mark Overridden methods of algorithm controller

-(BOOL) checkUserInput
{
    UMMPROIRec *tissueRoiRec = [[controller roiList] findRecordByTag:[tissueButton selectedTag]];
    
    if (![arterialButton selectedItem]) {
        /* No ROI selected */
        NSRunAlertPanel(@"Invalid ROI", @"Please select an arterial ROI.", @"OK",nil,nil);
        return NO;
	} else if (![tissueButton selectedItem]) {
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
	
    return YES;}

/* saveInputParameter method is the same for all pixel based algorithms */
- (void)saveInputParameter:(UMMPROIRec *)tissueROI andAlgorithmName:(NSString *)algorithm
{    
    ViewerController *viewer = [controller viewerController];
	NSLog(@"algorithm name:%@", algorithm);
    NSLog(@"controller name:%@", [controller algorithmController]);
	NSCalendarDate *curDate = [NSCalendarDate calendarDate];
	[curDate setCalendarFormat:@"%Y-%m-%d %H:%M:%S"];
	
	UMMPROIRec *arterialROIRec = [[controller roiList] findRecordByTag:[arterialButton selectedTag]];
	UMMPROIRec *tissueROIRec = [[controller roiList] findRecordByTag:[tissueButton selectedTag]];
    
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
    [inputParameter addObject:[NSMutableDictionary dictionaryWithObject:algorithm forKey:@"Algorithm:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@", curDate] forKey:@"Creation Date:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:arterialRoi forKey:@"Arterial ROI:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:tissueRoi forKey:@"Tissue ROI:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:[presetButton titleOfSelectedItem] forKey:@"Preset:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:[tracerButton titleOfSelectedItem] forKey:@"Appr. Tracer Concentration:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:[baseLineLength stringValue] forKey:@"Baseline:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"%1.2f (‰)", [hematocrit floatValue]] forKey:@"Hematocrit:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:trim forKey:@"Time Index:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:z_trim forKey:@"Slice Index:"]];
	
    
}


/* savePresetParameters for advancedFeatures */ 
- (void)savePresetParameter:(int)tag
{
    NSMutableArray *parameters = nil;
    switch (tag) {
        case 0:
            parameters = [[controller prefController] findParametersByTag:[presetButton selectedTag] forAlgorithm:@"Compartment"];
            break;
        case 1:
            parameters = [[controller prefController] findParametersByTag:[presetButton selectedTag] forAlgorithm:@"2C Exchange"];            
            break;
        case 2:
            parameters = [[controller prefController] findParametersByTag:[presetButton selectedTag] forAlgorithm:@"2C Filtration"];            
            break;
        case 3:
            parameters = [[controller prefController] findParametersByTag:[presetButton selectedTag] forAlgorithm:@"2C Uptake"];            
            break;
        case 4:
            parameters = [[controller prefController] findParametersByTag:[presetButton selectedTag] forAlgorithm:@"Modified Tofts"];
            break;            
        default:
            break;
    }
    
    if (parameters) {
        int i;
        for (i=0; i<[parameters count]; i++) {
            [presetParameter addObject:[NSMutableDictionary 
                                        dictionaryWithObject:[[parameters objectAtIndex:i] name] 
                                        forKey:[NSString stringWithFormat:@"Parameter Name %d",i]]];
        }
        double v;
        
        // pValue
        NSString *pValue = nil;
        for (i = 0; i<[parameters count]; i++) {
            v = [[parameters objectAtIndex:i] pValue];
            pValue = [[NSNumber numberWithDouble:v] stringValue];
            [presetParameter addObject:[NSMutableDictionary dictionaryWithObject:pValue forKey:[NSString stringWithFormat:@"Value %d",i]]];
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

/* start calculation for advancedFeatures */
- (void)startCalculation:(UMMPROIRec *)tissueROI andAlgorithmTag:(int)tag
{
   
    // tag = 0: Compartment
    // tag = 1: 2C Exchange
    // tag = 2: 2C Filtration
    // tag = 3: 2C Uptake
    // tag = 4: Modified Tofts
    
    BOOL isOK = NO;

        switch (tag) {
            case 0:
                if ([[controller userDefaults]int:@"UMMPcompartmentMapPF" otherwise:YES] || [[controller userDefaults]int:@"UMMPcompartmentMapPMTT" otherwise:YES] || [[controller userDefaults]int:@"UMMPcompartmentMapPV" otherwise:YES] || [[controller userDefaults]int:@"UMMPcompartmentMapAFE" otherwise:YES] || [[controller userDefaults]int:@"UMMPcompartmentMapCS" otherwise:YES]) {
                    isOK = YES;
                }
                break;
            case 1:
                if ([[controller userDefaults] int:@"UMMPexchangeMapPF" otherwise:YES] || [[controller userDefaults]int:@"UMMPexchangeMapPMTT" otherwise:YES] || [[controller userDefaults] int:@"UMMPexchangeMapPV" otherwise:YES] || [[controller userDefaults]int:@"UMMPexchangeMapIMTT" otherwise:YES] || [[controller userDefaults]int:@"UMMPexchangeMapIV" otherwise:YES] || [[controller userDefaults]int:@"UMMPexchangeMapEF"otherwise:YES] || [[controller userDefaults]int:@"UMMPexchangeMapPSAP"otherwise:YES] || [[controller userDefaults]int:@"UMMPexchangeMapAFE" otherwise:YES] || [[controller userDefaults]int:@"UMMPexchangeMapCS" otherwise:YES]) {
                    isOK = YES;
                }
                break;
            case 2:
                if ([[controller userDefaults] int:@"UMMPfiltrationMapPF" otherwise:YES] || [[controller userDefaults] int:@"UMMPfiltrationMapPMTT" otherwise:YES] || [[controller userDefaults] int:@"UMMPfiltrationMapPV" otherwise:YES] || [[controller userDefaults] int:@"UMMPfiltrationMapIMTT" otherwise:YES] || [[controller userDefaults] int:@"UMMPfiltrationMapEF" otherwise:YES] || [[controller userDefaults] int:@"UMMPfiltrationMapPSAP"otherwise:YES] || [[controller userDefaults] int:@"UMMPfiltrationMapAFE"otherwise:YES] || [[controller userDefaults] int:@"UMMPfiltrationMapCS" otherwise:YES]) {
                     isOK = YES;
                    
                }
                break;
            case 3:
                if ([[controller userDefaults] int:@"UMMPuptakeMapPF" otherwise:YES] || [[controller userDefaults] int:@"UMMPuptakeMapPMTT"otherwise:YES] || [[controller userDefaults] int:@"UMMPuptakeMapPV"otherwise:YES] || [[controller userDefaults] int:@"UMMPuptakeMapEF"otherwise:YES] || [[controller userDefaults] int:@"UMMPuptakeMapPSAP"otherwise:YES]|| [[controller userDefaults] int:@"UMMPuptakeMapAFE"otherwise:YES] || [[controller userDefaults] int:@"UMMPuptakeMapCS"otherwise:YES]) {
                    isOK = YES;
                }
                break;
            case 4:
                if ([[controller userDefaults] int:@"UMMPtoftsMapPV"otherwise:YES] || [[controller userDefaults] int:@"UMMPtoftsMapIMTT"otherwise:YES] || [[controller userDefaults] int:@"UMMPtoftsMapIV" otherwise:YES] || [[controller userDefaults] int:@"UMMPtoftsMapPSAP"otherwise:YES] || [[controller userDefaults] int:@"UMMPtoftsMapAFE"otherwise:YES] || [[controller userDefaults] int:@"UMMPexchangeMapCS"otherwise:YES]) {
                    isOK = YES;
                    
                }
                break;
                
            default:
                break;
        }
    
        if (isOK) {	
            [self startMapCalculation:tag];
        }
        else {
            NSRunAlertPanel(@"Invalid Selection", @"Please select at least one map.", @"OK",nil,nil);
        }
        
       
}
    


/* saveOutputParameters for advancedFeatures */
-(void)saveOutputParameter:(int)tag
{
   // not needed for this controller
    
}


-(void)startMapCalculation:(int)tag
{
    
    // hides the ROI information before taking the screenshot for the UMMPerfusion report
    [[NSUserDefaults standardUserDefaults] setBool: YES forKey: @"ROITEXTIFSELECTED"];
    [controller deselectAllRois];
    
    // wait window
    ViewerController *vc = [controller viewerController];
    UMMPerfusionFilter *filter = [controller filter];
    //id waitWindow = [vc startWaitWindow: @"Calculating..."];
    
    
    int i;
	int n, slices;
	int start, stop;
	int startSli, stopSli;
	
	int bl, tracer;
    
	float meanAif;
	
	double htc;
	
	float *aif;
	double *time, *timeOld;
	
    DCMPix *curPix;
    
    
    NSInteger aifRoiTag = [arterialButton selectedTag];
    NSInteger tissueRoiTag = [tissueButton selectedTag];
    UMMPROIRec *aifRoiRec = [[controller roiList] findRecordByTag: aifRoiTag];
    ROI *aifRoi = [[[controller roiList] findRecordByTag: aifRoiTag] roi];
    //NSArray *aifPoints = [aifRoi points];
//    MyPoint *point1 = [aifPoints objectAtIndex:0];
//    MyPoint *point2 = [aifPoints objectAtIndex:1];
//    MyPoint *point4 = [aifPoints objectAtIndex:2];
//	  MyPoint *point3 = [aifPoints objectAtIndex:3];
//    NSLog(@"Werte[1x] : %f", point1.x);
//    NSLog(@"Werte[1y] : %f",point1.y);
//    NSLog(@"Werte[2x] : %f",point2.x);
//    NSLog(@"Werte[2y] : %f",point2.y);
//    NSLog(@"Werte[3x] : %f",point3.x);
//    NSLog(@"Werte[3y] : %f",point3.y);
//    NSLog(@"Werte[4x] : %f",point4.x);
//    NSLog(@"Werte[4y] : %f", point4.y);
    
    
    
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
	//m_img = curPix.pheight;
	//n_img = curPix.pwidth;
	
	aif = (float*)calloc(n, sizeof(float));
	time = (double*)calloc(n, sizeof(double));
	timeOld = (double*)calloc(n, sizeof(double));
    
    NSMutableArray *aifRoiData = [[NSMutableArray alloc] init];
    
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
    
    //    [self calculateDeltaTime:vc time:time start:start stop:stop];
    double *viewerTime = [controller time];
    // the time array has to start with the value 0, correction with time[i+1]
    for (i=0; i<n-1; i++)
        time[i+1] = viewerTime[i+start];
    
    ViewerController *pfViewer = nil;
	ViewerController *vdViewer = nil;
	ViewerController *mtViewer = nil;
	ViewerController *itmtViewer = nil;
	ViewerController *itvdViewer = nil;
	ViewerController *efViewer = nil;
	ViewerController *perViewer = nil;
	ViewerController *akViewer = nil;
	ViewerController *csViewer = nil;
    
    UMMPViewerList *viewerList = [controller viewerList];
    
    NSString *name = nil;
    NSString *selector = nil;
    
    // sets the algorithm and selector names for initialization 
    switch (tag) {
        case 0: //Compartment
            name = @"Compartment";
            selector = @"compartment";
            break;
        case 1: //2C Exchange
            name = @"2C Exchange";
            selector = @"exchange";
            break;
        case 2: //2C Filtration
            name = @"2C Filtration";
            selector = @"filtration";
            break;
        case 3: //2C Uptake
            name = @"2C Uptake";
            selector = @"uptake";
            break;
        case 4: //Modified Tofts
            name = @"Modified Tofts";
            selector = @"tofts";
            break;            
        default:
            break;
    }    
	
    // checks if the user wants the parameter to be displayed and if so it generates the viewer 
	if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapPF",selector] otherwise:NO]) {
		pfViewer = [filter duplicateViewer:vc deleteROIs:NO];
		[[[pfViewer pixList] objectAtIndex:0] setGeneratedName:@"Plasma Flow (ml/100ml/min)"];
		[viewerList addViewer:pfViewer name:[NSString stringWithFormat:@"%@ - Plasma Flow (ml/100ml/min)", name]];
		[[NSNotificationCenter defaultCenter] addObserver:viewerList selector:@selector(removeViewer:) name:OsirixCloseViewerNotification object:pfViewer];
	}
    if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapPMTT",selector] otherwise:NO]) {
		mtViewer = [filter duplicateViewer:vc deleteROIs:NO];
		[[[mtViewer pixList] objectAtIndex:0] setGeneratedName:@"Plasma MTT (sec)"];
		[viewerList addViewer:mtViewer name:[NSString stringWithFormat:@"%@ - Plasma MTT (sec)", name]];
		[[NSNotificationCenter defaultCenter] addObserver:viewerList selector:@selector(removeViewer:) name:OsirixCloseViewerNotification object:mtViewer];
	}
	if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapPV",selector] otherwise:NO]) {
		vdViewer = [filter duplicateViewer:vc deleteROIs:NO];
		[[[vdViewer pixList] objectAtIndex:0] setGeneratedName:@"Plasma Volume (ml/100ml)"];
		[viewerList addViewer:vdViewer name:[NSString stringWithFormat:@"%@ - Plasma Volume (ml/100ml)", name]];
		[[NSNotificationCenter defaultCenter] addObserver:viewerList selector:@selector(removeViewer:) name:OsirixCloseViewerNotification object:vdViewer];
	}
	if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapIMTT",selector] otherwise:NO]) {
		itmtViewer = [filter duplicateViewer:vc deleteROIs:NO];
        if ([selector isEqualToString:@"filtration"]) {
            [[[itmtViewer pixList] objectAtIndex:0] setGeneratedName:@"Tubular MTT (sec)"];
            [viewerList addViewer:itmtViewer name:[NSString stringWithFormat:@"%@ - Tubular MTT (sec)", name]];
        } 
        else {
            [[[itmtViewer pixList] objectAtIndex:0] setGeneratedName:@"Interstitial MTT (sec)"];
            [viewerList addViewer:itmtViewer name:[NSString stringWithFormat:@"%@ - Interstitial MTT (sec)", name]];
        }
        [[NSNotificationCenter defaultCenter] addObserver:viewerList selector:@selector(removeViewer:) name:OsirixCloseViewerNotification object:itmtViewer];
		
	}
	if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapIV",selector] otherwise:NO]) {
		itvdViewer = [filter duplicateViewer:vc deleteROIs:NO];
		[[[itvdViewer pixList] objectAtIndex:0] setGeneratedName:@"Interstitial Volume (ml/100ml)"];
		[viewerList addViewer:itvdViewer name:[NSString stringWithFormat:@"%@ - Interstitial Volume (ml/100ml)", name]];
		[[NSNotificationCenter defaultCenter] addObserver:viewerList selector:@selector(removeViewer:) name:OsirixCloseViewerNotification object:itvdViewer];
	}
	if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapEF",selector] otherwise:NO]) {
		efViewer = [filter duplicateViewer:vc deleteROIs:NO];
		[[[efViewer pixList] objectAtIndex:0] setGeneratedName:@"Extraction Fraction (%)"];
//hier verändert (%)
		[viewerList addViewer:efViewer name:[NSString stringWithFormat:@"%@ - Extraction Fraction (%%)", name]];
		[[NSNotificationCenter defaultCenter] addObserver:viewerList selector:@selector(removeViewer:) name:OsirixCloseViewerNotification object:efViewer];
	}
	if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapPSAP",selector] otherwise:NO]) {
		perViewer = [filter duplicateViewer:vc deleteROIs:NO];
		if([selector isEqualToString:@"exchange"]||[selector isEqualToString:@"uptake"]){
            [[[perViewer pixList] objectAtIndex:0] setGeneratedName:@"Perm.-surf. area product (ml/100ml/min)"];
            [viewerList addViewer:perViewer name:[NSString stringWithFormat:@"%@ - Perm.-surf. area product (ml/100ml/min)", name]];
            [perViewer resetImage:perViewer];
        }
        else if([selector isEqualToString:@"filtration"]){
            [[[perViewer pixList] objectAtIndex:0] setGeneratedName:@"Tubular Flow (ml/100ml/min)"];
            [viewerList addViewer:perViewer name:[NSString stringWithFormat:@"%@ - Tubular Flow (ml/100ml/min)", name]];
            [perViewer resetImage:perViewer];
        }
        else if([selector isEqualToString:@"tofts"]){
            [[[perViewer pixList] objectAtIndex:0] setGeneratedName:@"Ktrans (ml/100ml/min)"];
            [viewerList addViewer:perViewer name:[NSString stringWithFormat:@"%@ - Ktrans (ml/100ml/min)", name]];
            [perViewer resetImage:perViewer];
        }
		[[NSNotificationCenter defaultCenter] addObserver:viewerList selector:@selector(removeViewer:) name:OsirixCloseViewerNotification object:perViewer];
	}
	if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapAFE",selector] otherwise:NO]) {
		akViewer = [filter duplicateViewer:vc deleteROIs:NO];
		[[[akViewer pixList] objectAtIndex:0] setGeneratedName:@"Corr. Akaike Information Crit."];
		[viewerList addViewer:akViewer name:[NSString stringWithFormat:@"%@ - Corr. Akaike Information Crit.", name]];
		[[NSNotificationCenter defaultCenter] addObserver:viewerList selector:@selector(removeViewer:) name:OsirixCloseViewerNotification object:akViewer];
	}
	if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapCS",selector] otherwise:NO]) {
		csViewer = [filter duplicateViewer:vc deleteROIs:NO];
		[[[csViewer pixList] objectAtIndex:0] setGeneratedName:@"Final Chi Square"];
		[viewerList addViewer:csViewer name:[NSString stringWithFormat:@"%@ - Final Chi Square", name]];
		[[NSNotificationCenter defaultCenter] addObserver:viewerList selector:@selector(removeViewer:) name:OsirixCloseViewerNotification object:csViewer];
	}
	NSDate *startTime = [NSDate date];
	
	lmuEnhancement(aif, n, bl, tracer);
	
	// Adapt AIF to Hematocrit
	double htcDifference = 1-htc;
	
	for (i = 0; i < n; i++) {
		aif[i] /= htcDifference;
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
            
            int m_img=[[[vc pixList:0]objectAtIndex:sli] pheight];
            int n_img=[[[vc pixList:0]objectAtIndex:sli] pwidth];
            
            int i, j, k;
            
            float *tissue;
            float *fImage;
            float *pffImage, *vdfImage, *mtfImage, *itmtfImage, *itvdfImage, *effImage, *perfImage, *akfImage, *csfImage;
            double **p;
            
            // saves the pixel values of the current slice into a float array
            if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapPF",selector] otherwise:NO])
                pffImage = [[[pfViewer pixList] objectAtIndex:sli] fImage];
            if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapPV",selector] otherwise:NO])	
                vdfImage = [[[vdViewer pixList] objectAtIndex:sli] fImage];
            if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapPMTT",selector] otherwise:NO])
                mtfImage = [[[mtViewer pixList] objectAtIndex:sli] fImage];
            if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapIMTT",selector] otherwise:NO])
                itmtfImage = [[[itmtViewer pixList] objectAtIndex:sli] fImage];	
            if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapIV",selector] otherwise:NO])
                itvdfImage = [[[itvdViewer pixList] objectAtIndex:sli] fImage];
            if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapEF",selector] otherwise:NO])
                effImage = [[[efViewer pixList] objectAtIndex:sli] fImage];
            if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapPSAP",selector] otherwise:NO])
                perfImage = [[[perViewer pixList] objectAtIndex:sli] fImage];
            if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapAFE",selector] otherwise:NO])
                akfImage = [[[akViewer pixList] objectAtIndex:sli] fImage];
            if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapCS",selector] otherwise:NO])
                csfImage = [[[csViewer pixList] objectAtIndex:sli] fImage];
			
            // if the current slice "sli" is placed on an "unused slice" the whole slice is set to value -1
			if ((sli < (startSli-1)) || (sli > (stopSli-1))) {
				
				for(i=0; i<(n_img*m_img); i++) {
					if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapPF",selector] otherwise:NO])
						pffImage[i] = -1.0;
					if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapPV",selector] otherwise:NO])
						vdfImage[i] = -1.0;
					if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapPMTT",selector] otherwise:NO])
						mtfImage[i] = -1.0;
					if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapIMTT",selector] otherwise:NO])
						itmtfImage[i] = -1.0;
					if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapIV",selector] otherwise:NO])
						itvdfImage[i] = -1.0;
					if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapEF",selector] otherwise:NO])
						effImage[i] = -1.0;
					if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapPSAP",selector] otherwise:NO])
						perfImage[i] = -1.0;
					if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapAFE",selector] otherwise:NO])
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
						
						double pf, vd, mt, imt, iv, ef, per, correctedAkaikeError, chiSquare = 0.0;
						
                        int fixedSize;
                        int limitedSize;
                        int limitsSize;
                        int paraSize;
                        int *fixed = NULL;
                        int *limited = NULL;
                        double *limits = NULL;
                        double *para = NULL;
                        
                        // determination of the array sizes (fixed, limited, limits, para)
                        switch (tag) {
                            case 0:
                                fixedSize = 2;
                                limitedSize = 4;
                                limitsSize = 4;
                                paraSize = 2;
                                break;
                            case 1:
                                fixedSize = 4;
                                limitedSize = 8;
                                limitsSize = 8;
                                paraSize = 4;
                                break;
                            case 2:
                                fixedSize = 4;
                                limitedSize = 8;
                                limitsSize = 8;
                                paraSize = 4;
                                break;
                            case 3:
                                fixedSize = 3;
                                limitedSize = 6;
                                limitsSize = 6;
                                paraSize = 3;
                                break;
                            case 4:
                                fixedSize = 3;
                                limitedSize = 6;
                                limitsSize = 6;
                                paraSize = 3;
                                break;
                                
                            default:
                                fixedSize = 0;
                                limitedSize = 0;
                                limitsSize = 0;
                                paraSize = 0;
                                break;
                        }
                        
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
                        switch (tag) {
                            case 0: //Compartment
                                fitSingleInletCompartment(n, para, fixed, limited, limits, maxiterations, maxFunctionEvaluation, time, aif, tissue, curveFit, &pf, &vd, &mt, &correctedAkaikeError, &chiSquare, nil);
                                break;
                            case 1: //2C Exchange
                                fitSingleInletExchange(n, para, fixed, limited, limits, maxiterations, maxFunctionEvaluation, time, aif, tissue, curveFit, &pf, &vd, &mt, &imt, &iv, &ef, &per, &correctedAkaikeError, &chiSquare,nil);
                                break;
                            case 2: //2C Filtration
                                fitSingleInletFiltration(n, para, fixed, limited, limits, maxiterations, maxFunctionEvaluation, time, aif, tissue, curveFit, &pf, &vd, &mt, &imt, &iv, &ef, &per, &correctedAkaikeError, &chiSquare,nil);
                                break;
                            case 3: //2C Uptake
                                fitSingleInletUptake(n, para, fixed, limited, limits, maxiterations, maxFunctionEvaluation, time, aif, tissue, curveFit, &pf, &vd, &mt, &ef, &per, &correctedAkaikeError, &chiSquare,nil);
                                break;
                            case 4: //Modified Tofts
                                fitSingleInletModifiedTofts(n, para, fixed, limited, limits, maxiterations, maxFunctionEvaluation, time, aif, tissue, curveFit, &vd, &imt, &iv, &per, &correctedAkaikeError, &chiSquare,nil);
                                break;
                                
                            default:
                                break;
                        }				
                        
						                        
						if(curveFit) free(curveFit);
						
						//if (pf > 1000)
						//	pf = -1.0;
						if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapPF",selector] otherwise:NO])
							pffImage[i] = pf;
						if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapPV",selector] otherwise:NO])
							vdfImage[i] = vd;
						if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapPMTT",selector] otherwise:NO])
							mtfImage[i] = mt;
						if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapIMTT",selector] otherwise:NO])
							itmtfImage[i] = imt;
						if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapIV",selector] otherwise:NO])
							itvdfImage[i] = iv;
						if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapEF",selector] otherwise:NO])
							effImage[i] = ef;
						if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapPSAP",selector] otherwise:NO])
							perfImage[i] = per;
						if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapAFE",selector] otherwise:NO])	
							akfImage[i] = correctedAkaikeError;
						if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapCS",selector] otherwise:NO])	
							csfImage[i] = chiSquare;
						
					}
                    // sets the values outside the rectangular ROI to -1
                    else {
						if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapPF",selector] otherwise:NO])
							pffImage[i] = -1.0;
						if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapPV",selector] otherwise:NO])
							vdfImage[i] = -1.0;
						if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapPMTT",selector] otherwise:NO])
							mtfImage[i] = -1.0;
						if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapIMTT",selector] otherwise:NO])
							itmtfImage[i] = -1.0;
						if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapIV",selector] otherwise:NO])
							itvdfImage[i] = -1.0;
						if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapEF",selector] otherwise:NO])
							effImage[i] = -1.0;
						if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapPSAP",selector] otherwise:NO])
							perfImage[i] = -1.0;
						if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapAFE",selector] otherwise:NO])
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
           if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapPF",selector] otherwise:NO])
           [pfViewer needsDisplayUpdate];
           if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapPV",selector] otherwise:NO])
           [vdViewer needsDisplayUpdate];
           if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapPMTT",selector] otherwise:NO])
           [mtViewer needsDisplayUpdate];
           if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapIMTT",selector] otherwise:NO])
           [itmtViewer needsDisplayUpdate];
           if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapIV",selector] otherwise:NO])
           [itvdViewer needsDisplayUpdate];
           if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapEF",selector] otherwise:NO])
           [efViewer needsDisplayUpdate];
           if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapPSAP",selector] otherwise:NO])
           [perViewer needsDisplayUpdate];
           if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapAFE",selector] otherwise:NO])
           [akViewer needsDisplayUpdate];
           if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapCS",selector] otherwise:NO])
           [csViewer needsDisplayUpdate];
           
           NSDate *endTime = [NSDate date];
           NSLog(@"UMMPerfusion - %@Map totalterm : %lf", name, [endTime timeIntervalSinceDate:startTime]);
           
                   [[controller viewerController] resetImage:[controller viewerController]];
                   if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapPV",selector] otherwise:NO])	
                   [vdViewer resetImage:vdViewer];
                   if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapPMTT",selector] otherwise:NO])
                   [mtViewer resetImage:mtViewer];
                   if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapIMTT",selector] otherwise:NO])
                   [itmtViewer resetImage:itmtViewer];
                   if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapIV",selector] otherwise:NO])
                   [itvdViewer resetImage:itvdViewer];
                   if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapEF",selector] otherwise:NO])
                   [efViewer resetImage:efViewer];
                   if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapPSAP",selector] otherwise:NO])
                   [perViewer resetImage:perViewer];
                   if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapAFE",selector] otherwise:NO])
                   [akViewer resetImage:akViewer];
                   if ([[controller userDefaults] int:[NSString stringWithFormat:@"UMMP%@MapCS",selector] otherwise:NO])
                   [csViewer resetImage:csViewer];

                   
           [self drawReportWithAif:aifRoiData];
           
           // free memory
           if (aif) free(aif);
           if (time) free(time);
           if (timeOld) free(timeOld);
           
           [aifRoiData release];
           
//           [vc endWaitWindow: waitWindow];
           
//           // Start export if enabled
//           if ([autosaveCheckButton state])
//           [controller pushExportButton:nil];
                   
                   
}
                   
                   
                 

@end
