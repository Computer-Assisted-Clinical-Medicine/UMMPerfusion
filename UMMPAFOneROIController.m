//
//  UMMPAdvancedFeauresController.m
//  UMMPerfusion
//
//  Created by Markus Daab on 11.06.12.
//  Copyright (c) 2012, Marcel Reich & Sven Kaiser & Markus Daab & Patrick Schülein & Engin Aslan
//  All rights reserved.
//

#import "UMMPAFOneROIController.h"


@implementation UMMPAFOneROIController


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
    }
	
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
	if (![arterialButton selectedItem]) {
        /* No ROI selected */
        NSRunAlertPanel(@"Invalid ROI", @"Please select an arterial ROI.", @"OK",nil,nil);
        return NO;
	} else if (![tissueButton selectedItem]) {
		/* baseLineLength <= 0 */
		NSRunAlertPanel(@"Invalid ROI", @"Please select an arterial ROI.", @"OK",nil,nil);
        return NO;
	} else if ([baseLineLength intValue] <= 0 || [baseLineLength intValue] > [endSlider intValue]-[startSlider intValue]) {
		/* baseLineLength <= 0 */
        NSRunAlertPanel(@"Invalid Length of Baseline", [NSString stringWithFormat:@"Please use Baseline length between %d and %d.", 1 ,[endSlider intValue]-[startSlider intValue]], @"OK",nil,nil);
        return NO;
	} else if ([hematocrit doubleValue] <= 0.0 || [hematocrit doubleValue] >= 1.0) {
		/* hematocrit <= 0 || >= 1 */
        NSRunAlertPanel(@"Invalid Hematocrit", @"Please use correct Hematocrit.", @"OK",nil,nil);
        return NO;
	}
	
	return YES;
}

-(void)saveInputParameter:(UMMPROIRec*)tissueROI andAlgorithmName:(NSString*)algorithm
{
	ViewerController *viewer = [controller viewerController];
	
	NSCalendarDate *curDate = [NSCalendarDate calendarDate];
	[curDate setCalendarFormat:@"%Y-%m-%d %H:%M:%S"];
	
	UMMPROIRec *arterialROIRec = [[controller roiList] findRecordByTag:[arterialButton selectedTag]];
	//NSMutableArray *ROIListAF =  [[controller roiList] records];//tissueROITableView
	
	//UMMPROIRec *tissueROIRec = [[controller roiList] findRecordByTag:[tissueButton selectedTag]];
    
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
    
	NSString *tissueRoi = [NSString stringWithFormat:@"%@   slice: %ld   timepoint: %ld", [[tissueROI roi] name], (long)[tissueROI slice]+1, (long)[tissueROI timePoint]+1];
    if (!tissueRoi)
        tissueRoi = @"n.a.";
	
	NSString *trim = [NSString stringWithFormat:@"%d - %d", [startSlider intValue]+1, [endSlider intValue]+1];
    if (!trim)
        trim = @"n.a.";
	
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
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:algorithm  forKey:@"Algorithm:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@", curDate] forKey:@"Creation Date:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:arterialRoi forKey:@"Arterial ROI:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:tissueRoi forKey:@"Tissue ROI:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:[presetButton titleOfSelectedItem] forKey:@"Preset:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:[tracerButton titleOfSelectedItem] forKey:@"Appr. Tracer Concentration:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:[baseLineLength stringValue] forKey:@"Baseline:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"%1.2f (‰)", [hematocrit floatValue]] forKey:@"Hematocrit:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:trim forKey:@"Image Index:"]];
	
	// Print method for inputParameter
	//	NSLog(@"");
	//	NSLog(@"inputParameter");
	//	for (NSMutableDictionary *tmpDict in inputParameter) {
	//		for (NSString *key in tmpDict)
	//			NSLog(@"%@ %@", key, [tmpDict valueForKey:key]);
	//	}
	
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
- (void)startCalculation:(UMMPROIRec*)tissueROI andAlgorithmTag:(int)tag
{
    
    // tag = 0: Compartment
    // tag = 1: 2C Exchange
    // tag = 2: 2C Filtration
    // tag = 3: 2C Uptake
    // tag = 4: Modified Tofts
    
    
    ViewerController *vc = [controller viewerController];
    id waitWindow = [vc startWaitWindow: @"Calculating..."];
    
    int i, n;
    int start, stop;
	
    int bl, tracer;
    
    float meanAif;
    float meanTissue;
	
    double htc;
	
    float *aif;
    float *tissue;
    double *time;
    
    int *fixed;
    int *limited;
    double *limits;
    double *p;
    
    DCMPix *curPix;
    
    NSInteger aifRoiTag = [arterialButton selectedTag];
    //NSInteger tissueRoiTag = [tissueButton selectedTag];
    UMMPROIRec *aifRoiRec = [[controller roiList] findRecordByTag: aifRoiTag];
    //UMMPROIRec *tissueRoiRec = [[controller roiList] findRecordByTag: tissueRoiTag];
    ROI *aifRoi = [aifRoiRec roi];
	ROI *tissueRoi = [tissueROI roi];    
	start = [startSlider intValue];
	stop = [endSlider intValue]+1;
	
	bl = [baseLineLength intValue];
	tracer = [tracerButton indexOfSelectedItem];
	htc = [hematocrit doubleValue];
	n = stop-start;
	
	aif      =  (float*)    calloc(n, sizeof(float));
	tissue  =  (float*)    calloc(n, sizeof(float));	
	time    =  (double*) calloc(n, sizeof(double));
    
    NSMutableArray *aifRoiData = [[NSMutableArray alloc] init];
    NSMutableArray *tissueRoiData = [[NSMutableArray alloc] init];
	
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
	
    for (i=0; i<n; i++) {
        curPix = [[vc pixList:i+start] objectAtIndex:[tissueROI slice]];
        [curPix computeROI:tissueRoi :&meanTissue :NULL :NULL :NULL :NULL];
        tissue[i] = meanTissue;
        [tissueRoiData addObject:[NSNumber numberWithFloat:meanTissue]];
    }
    
    double *viewerTime = [controller time];
    for (i=0; i<n-1; i++)
        time[i+1] = viewerTime[i+start];
   	
    NSDate *startTime = [NSDate date];
	
    double curveFit[n];
	
    // Enhancement of AIF and TISSUE
    lmuEnhancement(aif, n, bl, tracer);
    lmuEnhancement(tissue, n, bl, tracer);
	
    // Adapt AIF to Hematocrit
    double htcDifference = 1-htc;
	
    for (i = 0; i < n; i++) 
        aif[i] /= htcDifference;
    
    double pf, pv, mt, chiSquare =0.0, correctedAkaikeError = 0.0, xError = 0.0;
    double imt, iv, ef, per = 0.0;
    
    
    NSString * algoTitleOnChart = nil, *algoNameSelectForPresets = nil;
    switch (tag) {
        case 0:
            algoTitleOnChart = @"Compartment Model";
            algoNameSelectForPresets = @"Compartment";
            break;
        case 1:
            algoTitleOnChart = @"2-Compartment Exchange";
            algoNameSelectForPresets = @"2C Exchange";
            break;
        case 2:
            algoTitleOnChart = @"2-Compartment Filtration";
            algoNameSelectForPresets = @"2C Filtration";
            break;
        case 3:
            algoTitleOnChart = @"2-Compartment Uptake";
            algoNameSelectForPresets = @"2C Uptake";
            break;
        case 4:
            algoTitleOnChart = @"Modified Tofts";
            algoNameSelectForPresets = @"Modified Tofts";
            break;
        default:
            break;
    }     
    
    NSMutableArray *parameters = [[controller prefController] findParametersByTag:[presetButton selectedTag] forAlgorithm:algoNameSelectForPresets];
    int paramCount = [parameters count];
    
    fixed   = (int*)    calloc(paramCount,   sizeof(int));
    limited = (int*)    calloc(paramCount*2, sizeof(int));
    limits  = (double*) calloc(paramCount*2, sizeof(double));
    p       = (double*) calloc(paramCount,   sizeof(double));
    
    for(i = 0; i < [parameters count]; i++){
        
        p[i] = [[parameters objectAtIndex:i] pValue];
        
        fixed[i] = (int)[[parameters objectAtIndex:i] fixed];
        limited[i*2] = [[parameters objectAtIndex:i] limitedLow];
        limited[(i*2)+1] = [[parameters objectAtIndex:i] limitedHigh];
        limits[i*2] = [[parameters objectAtIndex:i] low];
        limits[(i*2)+1] = [[parameters objectAtIndex:i] high];
    }
    
    int maxiterations = [[[controller userDefaults] string:@"UMMPMaxIterations" otherwise:@"200"] intValue];
	int maxFunctionEvaluation = [[[controller userDefaults] string:@"UMMPMaxFunctionEvaluation" otherwise:@"1000"] intValue];
    
    switch (tag) {
        case 0:
            fitSingleInletCompartment(n, p, fixed, limited, limits, maxiterations, maxFunctionEvaluation, time, aif, tissue, curveFit, &pf, &pv, &mt, &correctedAkaikeError, &chiSquare, &xError); //&pv == &vd
            break;
        case 1:
            fitSingleInletExchange(n, p, fixed, limited, limits, maxiterations, maxFunctionEvaluation, time, aif, tissue, curveFit, &pf, &pv, &mt, &imt, &iv, &ef, &per, &correctedAkaikeError, &chiSquare, &xError);
            break;
        case 2:
            fitSingleInletFiltration(n, p, fixed, limited, limits, maxiterations, maxFunctionEvaluation, time, aif, tissue, curveFit, &pf, &pv, &mt, &imt, &iv, &ef, &per, &correctedAkaikeError, &chiSquare, &xError);
            break;
        case 3:
            fitSingleInletUptake(n, p, fixed, limited, limits, maxiterations, maxFunctionEvaluation, time, aif, tissue, curveFit, &pf, &pv, &mt, &ef, &per, &correctedAkaikeError, &chiSquare, &xError);
            break;
        case 4:
            fitSingleInletModifiedTofts(n, p, fixed, limited, limits, maxiterations, maxFunctionEvaluation, time, aif, tissue, curveFit, &pv, &imt, &iv, &per, &correctedAkaikeError, &chiSquare, &xError);
            break;
        default:
            break;       
    }
    
    
	// TEST (Returns results of fitted values)
    int counter;
    if([[controller userDefaults] int:@"printPresetsToConsole" otherwise:NO]) {
        NSLog(@"p[] - fit parameter values");
        for(counter=0; counter < [parameters count]; counter++) NSLog(@"%lf", p[counter]);
        NSLog(@"xError: %lf", xError);
    }        
	//end of TEST
    
	NSMutableArray *tissueData = [[NSMutableArray alloc] init];
	NSMutableArray *fitData = [[NSMutableArray alloc] init];
    NSMutableArray *timeData = [[NSMutableArray alloc] init];
	
	for (i=0; i<n; i++) {
		[tissueData addObject:[NSNumber numberWithFloat:tissue[i]]];
		[fitData addObject:[NSNumber numberWithFloat:curveFit[i]]];
        [timeData addObject:[NSNumber numberWithFloat:time[i]]];
	}
	
	UMMPCMPanelController *cmController = [[UMMPCMPanelController alloc] initWithViewer:vc withMainController:controller andAifRoiData:[NSArray arrayWithArray:aifRoiData] andTissueRoiRec:tissueROI andTissueRoiData:[NSArray arrayWithArray:tissueRoiData] andTissue:[NSArray arrayWithArray:tissueData] andFit:[NSArray arrayWithArray:fitData] andTime:[NSArray arrayWithArray:timeData] andAlgorithmTag:tag];
    
	// clean up dict from previous calculations
	[dict removeAllObjects];
	        
    [dict setObject:algoTitleOnChart forKey:@"name"];
    [dict setObject:[tracerButton titleOfSelectedItem] forKey:@"tracer"];
    
    
    if (tag == 0 || tag ==1 || tag == 2 || tag == 3) {
        [dict setObject:@"Plasma Flow" forKey:@"para1"];
        [dict setObject:[NSNumber numberWithDouble:pf] forKey:@"value1"];
        [dict setObject:@"(ml/100ml/min)" forKey:@"unit1"];
    }
    
    if (tag == 0 || tag ==1 || tag == 2 || tag == 3) {
        [dict setObject:@"Plasma MTT" forKey:@"para2"];
        [dict setObject:[NSNumber numberWithDouble:mt] forKey:@"value2"];
        [dict setObject:@"(sec)" forKey:@"unit2"];
    }
    
    // is always used
    [dict setObject:@"Plasma Volume" forKey:@"para3"];
    [dict setObject:[NSNumber numberWithDouble:pv] forKey:@"value3"];
    [dict setObject:@"(ml/100ml)" forKey:@"unit3"];
    
    if (tag == 1 || tag ==4 ) {
        [dict setObject:@"Interstitial MTT" forKey:@"para4"];
        [dict setObject:[NSNumber numberWithDouble:imt] forKey:@"value4"];
        [dict setObject:@"(sec)" forKey:@"unit4"];
    }
    
    if (tag == 2 ) {
        [dict setObject:@"Tubular MTT" forKey:@"para4"];
        [dict setObject:[NSNumber numberWithDouble:imt] forKey:@"value4"];
        [dict setObject:@"(sec)" forKey:@"unit4"];
    }
    
    if (tag == 1 || tag ==4 ) {
        [dict setObject:@"Interstitial Volume" forKey:@"para5"];
        [dict setObject:[NSNumber numberWithDouble:iv] forKey:@"value5"];
        [dict setObject:@"(ml/100ml)" forKey:@"unit5"];
    }
    
    if (tag ==1 || tag == 2 || tag == 3) {    
        [dict setObject:@"Extraction Fraction" forKey:@"para6"];
        [dict setObject:[NSNumber numberWithDouble:ef] forKey:@"value6"];
        [dict setObject:@"(%)" forKey:@"unit6"];
    }
    
    //next 3 if()'s all concern Permeable surface area product,(mathematically the same), just the displayed names differ
    if (tag ==1 || tag == 3) {
        [dict setObject:@"Perm.-surf. area product" forKey:@"para7"];
        [dict setObject:[NSNumber numberWithDouble:per] forKey:@"value7"];
        [dict setObject:@"(ml/100ml/min)" forKey:@"unit7"];
    }
    if (tag == 2) {
        [dict setObject:@"Tubular Flow" forKey:@"para7"];
        [dict setObject:[NSNumber numberWithDouble:per] forKey:@"value7"];
        [dict setObject:@"(ml/100ml/min)" forKey:@"unit7"];
    }
    if (tag == 4) {
        [dict setObject:@"Ktrans" forKey:@"para7"];
        [dict setObject:[NSNumber numberWithDouble:per] forKey:@"value7"];
        [dict setObject:@"(ml/100ml/min)" forKey:@"unit7"];
    }

    // is always used
    [dict setObject:@"Corr. Akaike Information Crit." forKey:@"para8"];
    [dict setObject:[NSNumber numberWithDouble:correctedAkaikeError] forKey:@"value8"];
    // is always used
    [dict setObject:@"Final Chi Square" forKey:@"para9"];
    [dict setObject:[NSNumber numberWithDouble:chiSquare] forKey:@"value9"];
 	
	
	
    [cmController setResults:dict];
    [cmController setInputParameter: inputParameter];
	[cmController setPresetParameter:presetParameter];
    [self saveOutputParameter:tag];
    [cmController setOutputParameter: outputParameter];
    
    [[controller cmControllerList] addObject:cmController];
	
	NSDate *endTime = [NSDate date];
	NSLog(@"UMMPerfusion - MPCurveFit total term: %lf ", [endTime timeIntervalSinceDate:startTime]);
	
	// free memory
	if (aif)        free(aif);
	if (tissue)     free(tissue);
	if (time)       free(time);
	
    [aifRoiData release];
    [tissueRoiData release];
	[tissueData release];
	[fitData release];
    
    [vc endWaitWindow: waitWindow];
    
//    if ([autosaveCheckButton state]) {
//        [cmController pushExportButton:nil];
//    }

}

/* saveOutputParameters for advancedFeatures */
-(void)saveOutputParameter:(int)tag
{
    // tag = 0: Compartment
    // tag = 1: 2C Exchange
    // tag = 2: 2C Filtration
    // tag = 3: 2C Uptake
    // tag = 4: Modified Tofts    
       
    if (tag == 0 || tag ==1 || tag == 2 || tag == 3) {
        NSString *key1 = [NSString stringWithFormat:@"%@:", [dict objectForKey:@"para1"]];
        NSString *value1 = [NSString stringWithFormat:@"%1.3f %@", [[dict objectForKey:@"value1"] floatValue], [dict objectForKey:@"unit1"]];
        NSMutableDictionary *dict1 = [NSMutableDictionary dictionaryWithObject:value1 forKey:key1];
        [outputParameter addObject:dict1];
    }
    
    if (tag == 0 || tag ==1 || tag == 2 || tag == 3) {
        NSString *key2 = [NSString stringWithFormat:@"%@:", [dict objectForKey:@"para2"]];
        NSString *value2 = [NSString stringWithFormat:@"%1.3f %@", [[dict objectForKey:@"value2"] floatValue], [dict objectForKey:@"unit2"]];
        NSMutableDictionary *dict2 = [NSMutableDictionary dictionaryWithObject:value2 forKey:key2];
        [outputParameter addObject:dict2];
    }
    
    // is always used
    NSString *key3 = [NSString stringWithFormat:@"%@:", [dict objectForKey:@"para3"]];
    NSString *value3 = [NSString stringWithFormat:@"%1.3f %@", [[dict objectForKey:@"value3"] floatValue], [dict objectForKey:@"unit3"]];
    NSMutableDictionary *dict3 = [NSMutableDictionary dictionaryWithObject:value3 forKey:key3];
    [outputParameter addObject:dict3];
    
    if (tag == 1 || tag == 2 || tag == 4 ) {
        NSString *key4 = [NSString stringWithFormat:@"%@:", [dict objectForKey:@"para4"]];
        NSString *value4 = [NSString stringWithFormat:@"%1.3f %@", [[dict objectForKey:@"value4"] floatValue], [dict objectForKey:@"unit4"]];
        NSMutableDictionary *dict4 = [NSMutableDictionary dictionaryWithObject:value4 forKey:key4];
        [outputParameter addObject:dict4];
    }
    
    if (tag == 1 || tag ==4 ) {
        NSString *key5 = [NSString stringWithFormat:@"%@:", [dict objectForKey:@"para5"]];
        NSString *value5 = [NSString stringWithFormat:@"%1.3f %@", [[dict objectForKey:@"value5"] floatValue], [dict objectForKey:@"unit5"]];
        NSMutableDictionary *dict5 = [NSMutableDictionary dictionaryWithObject:value5 forKey:key5];
        [outputParameter addObject:dict5];
    }
    
    if (tag ==1 || tag == 2 || tag == 3) {    
        NSString *key6 = [NSString stringWithFormat:@"%@:", [dict objectForKey:@"para6"]];
        NSString *value6 = [NSString stringWithFormat:@"%1.3f %@", [[dict objectForKey:@"value6"] floatValue], [dict objectForKey:@"unit6"]];
        NSMutableDictionary *dict6 = [NSMutableDictionary dictionaryWithObject:value6 forKey:key6];
        [outputParameter addObject:dict6];
    }
    
    if (tag ==1 || tag == 2 || tag == 3 || tag == 4) {
        NSString *key7 = [NSString stringWithFormat:@"%@:", [dict objectForKey:@"para7"]];
        NSString *value7 = [NSString stringWithFormat:@"%1.3f %@", [[dict objectForKey:@"value7"] floatValue], [dict objectForKey:@"unit7"]];
        NSMutableDictionary *dict7 = [NSMutableDictionary dictionaryWithObject:value7 forKey:key7];
        [outputParameter addObject:dict7];
    }
    
    // is always used
    NSString *key8 = [NSString stringWithFormat:@"%@:", [dict objectForKey:@"para8"]];
    NSString *value8 = [NSString stringWithFormat:@"%1.3f", [[dict objectForKey:@"value8"] floatValue]];
    NSMutableDictionary *dict8 = [NSMutableDictionary dictionaryWithObject:value8 forKey:key8];
    [outputParameter addObject:dict8];
    // is always used
    NSString *key9 = [NSString stringWithFormat:@"%@:", [dict objectForKey:@"para9"]];
    NSString *value9 = [NSString stringWithFormat:@"%1.3f", [[dict objectForKey:@"value9"] floatValue]];
    NSMutableDictionary *dict9 = [NSMutableDictionary dictionaryWithObject:value9 forKey:key9];
    [outputParameter addObject:dict9];
    
}

//-(void)startMapCalculation:(id) sender
//{
//    NSLog(@"Bin im allAlgorithm Controller gefangen");
//
//}
@end
