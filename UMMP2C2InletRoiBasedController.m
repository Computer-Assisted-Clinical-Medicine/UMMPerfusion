//
//  UMMP2C2InletRoiBasedController.m
//  UMMPerfusion
//
//  Created by Student on 18.05.16.
//
//

#import "UMMP2C2InletRoiBasedController.h"

@implementation UMMP2C2InletRoiBasedController

- (id)init
{
	self = [super init];
	dict = [[NSMutableDictionary alloc] init];
	return self;
}

- (void)dealloc
{
	[dict dealloc]; dict = NULL;
	[super dealloc];
}

- (BOOL)checkUserInput
{
    if (![arterialButton selectedItem]) {
        /* No ROI selected */
        NSRunAlertPanel(@"Invalid ROI", @"Please select an arterial ROI.", @"OK",nil,nil);
        return NO;
	}
    else if (![venousButton selectedItem]) {
        /* No ROI selected */
        NSRunAlertPanel(@"Invalid ROI", @"Please select the venous ROI.", @"OK",nil,nil);
        return NO;
    }
    else if (![tissueButton selectedItem]) {
        /* No ROI selected */
        NSRunAlertPanel(@"Invalid ROI", @"Please select a tissue ROI.", @"OK",nil,nil);
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
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:@"2Inlet 2C Uptake" forKey:@"Algorithm:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@", curDate] forKey:@"Creation Date:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:arterialRoi forKey:@"Arterial ROI:"]];
    [inputParameter addObject:[NSMutableDictionary dictionaryWithObject:venousRoi forKey:@"Venous ROI:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:tissueRoi forKey:@"Tissue ROI:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:[presetButton titleOfSelectedItem] forKey:@"Preset:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:[tracerButton titleOfSelectedItem] forKey:@"Appr. Tracer Concentration:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:[baseLineLength stringValue] forKey:@"Baseline:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"%1.2f (‰)", [hematocrit floatValue]] forKey:@"Hematocrit:"]];
	[inputParameter addObject:[NSMutableDictionary dictionaryWithObject:trim forKey:@"Image Index:"]];
	
}

-(void)savePresetParameter:(int)tag
{
    NSMutableArray *parameters = nil;
    
    // gets the parameter for the 2C 2Inlet Uptake algorithm
    parameters = [[controller prefController] findParametersByTag:[presetButton selectedTag] forAlgorithm:@"2Inlet 2C Uptake"];
    
    
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
                [presetParameter addObject:[NSMutableDictionary dictionaryWithObject:higherLimitRow forKey:
                                            [NSString stringWithFormat:@"Limited High in Row %d",i]]];
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
    //Muss noch für 2C 2Inlet Uptake angepasst werden
    int selectedAlgorithmTag = [[controller algorithmPopUpButton] selectedTag];
    
    if (selectedAlgorithmTag == compartmentRoiTag || selectedAlgorithmTag == exchangeRoiTag || selectedAlgorithmTag == filtrationRoiTag || selectedAlgorithmTag == uptakeRoiTag) {
        NSString *key1 = [NSString stringWithFormat:@"%@:", [dict objectForKey:@"para1"]];
        NSString *value1 = [NSString stringWithFormat:@"%1.3f %@", [[dict objectForKey:@"value1"] floatValue], [dict objectForKey:@"unit1"]];
        NSMutableDictionary *dict1 = [NSMutableDictionary dictionaryWithObject:value1 forKey:key1];
        [outputParameter addObject:dict1];
    }
    
    if (selectedAlgorithmTag == compartmentRoiTag || selectedAlgorithmTag == exchangeRoiTag || selectedAlgorithmTag == filtrationRoiTag || selectedAlgorithmTag == uptakeRoiTag) {
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
    
    if (selectedAlgorithmTag == exchangeRoiTag || selectedAlgorithmTag == filtrationRoiTag || selectedAlgorithmTag == modifiedToftsRoiTag ) {
        NSString *key4 = [NSString stringWithFormat:@"%@:", [dict objectForKey:@"para4"]];
        NSString *value4 = [NSString stringWithFormat:@"%1.3f %@", [[dict objectForKey:@"value4"] floatValue], [dict objectForKey:@"unit4"]];
        NSMutableDictionary *dict4 = [NSMutableDictionary dictionaryWithObject:value4 forKey:key4];
        [outputParameter addObject:dict4];
    }
    
    if (selectedAlgorithmTag == exchangeRoiTag || selectedAlgorithmTag == modifiedToftsRoiTag ) {
        NSString *key5 = [NSString stringWithFormat:@"%@:", [dict objectForKey:@"para5"]];
        NSString *value5 = [NSString stringWithFormat:@"%1.3f %@", [[dict objectForKey:@"value5"] floatValue], [dict objectForKey:@"unit5"]];
        NSMutableDictionary *dict5 = [NSMutableDictionary dictionaryWithObject:value5 forKey:key5];
        [outputParameter addObject:dict5];
    }
    
    if (selectedAlgorithmTag == exchangeRoiTag || selectedAlgorithmTag == filtrationRoiTag || selectedAlgorithmTag == uptakeRoiTag) {
        NSString *key6 = [NSString stringWithFormat:@"%@:", [dict objectForKey:@"para6"]];
        NSString *value6 = [NSString stringWithFormat:@"%1.3f %@", [[dict objectForKey:@"value6"] floatValue], [dict objectForKey:@"unit6"]];
        NSMutableDictionary *dict6 = [NSMutableDictionary dictionaryWithObject:value6 forKey:key6];
        [outputParameter addObject:dict6];
    }
    
    if (selectedAlgorithmTag == exchangeRoiTag || selectedAlgorithmTag == filtrationRoiTag || selectedAlgorithmTag == uptakeRoiTag || selectedAlgorithmTag == modifiedToftsRoiTag) {
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

- (void)startCalculation:(UMMPROIRec *)tissueROI andAlgorithmTag:(int)tag
{
    
    ViewerController *vc = [controller viewerController];
    id waitWindow = [vc startWaitWindow: @"Calculating..."];
    
    int i, n;
    int start, stop;
	
    int bl, tracer;
    
    float meanAif;
    float meanVif;
    float meanTissue;
	
    double htc;
	
    float *aif;    // pixelvalues for aif roi
    float *vif;    // pixelvalues for vif roi
    float *tissue; // pixelvalues for tissue roi
    double *time;  // time vector generated during start of plugin
    
    int *fixed;
    int *limited;
    double *limits;
    double *p;  // initial parameters for model
    
    DCMPix *curPix; // aktuelle Pixeliste
    
    NSInteger aifRoiTag = [arterialButton selectedTag];
    NSInteger vifRoiTag = [venousButton selectedTag];
    NSInteger tissueRoiTag = [tissueButton selectedTag];
    UMMPROIRec *aifRoiRec = [[controller roiList] findRecordByTag: aifRoiTag];
    UMMPROIRec *vifRoiRec = [[controller roiList] findRecordByTag: vifRoiTag];
    UMMPROIRec *tissueRoiRec = [[controller roiList] findRecordByTag: tissueRoiTag];
    ROI *aifRoi = [[[controller roiList] findRecordByTag: aifRoiTag] roi];
    ROI *vifRoi = [[[controller roiList] findRecordByTag: vifRoiTag] roi];
    ROI *tissueRoi = [[[controller roiList] findRecordByTag: tissueRoiTag] roi];
    
	start = [startSlider intValue];
	stop = [endSlider intValue]+1;
	
	bl = [baseLineLength intValue];
	tracer = [tracerButton indexOfSelectedItem];
	htc = [hematocrit doubleValue];
	n = stop-start;
	
	aif      =  (float*)    calloc(n, sizeof(float));
    vif      =  (float*)    calloc(n, sizeof(float));
	tissue  =  (float*)    calloc(n, sizeof(float));
	time    =  (double*) calloc(n, sizeof(double));
    
    NSMutableArray *aifRoiData = [[NSMutableArray alloc] init];
    NSMutableArray *vifRoiData = [[NSMutableArray alloc] init];
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
            curPix = [[vc pixList:i+start] objectAtIndex:[vifRoiRec slice]];
            [curPix computeROI:vifRoi :&meanVif :NULL :NULL :NULL :NULL];
            vif[i] = meanVif;
            [vifRoiData addObject:[NSNumber numberWithFloat:meanVif]];
        }
    }
	
    for (i=0; i<n; i++) {
        curPix = [[vc pixList:i+start] objectAtIndex:[tissueRoiRec slice]];
        [curPix computeROI:tissueRoi :&meanTissue :NULL :NULL :NULL :NULL];
        tissue[i] = meanTissue;
        [tissueRoiData addObject:[NSNumber numberWithFloat:meanTissue]];
    }
    
    // Get time from UMMPPanelController
    //    double *viewerTime = [controller time];
    
    // Get timeArray from UMMPPanelController
    NSMutableArray *viewerTimeArray = [controller timeArray];   // 2D TimeArray from UMMPPanelController
    
    //// Test Output
    //    int arrayCounter = [viewerTimeArray count];
    //    NSLog(@"viewerTimeArray counter = %d",arrayCounter);
    //   int slices = [tissueRoiRec slice];
    //   NSLog(@"slice Value (tissueRoiRec slice ) = %d", slices);
    //    for(int i=0; i<arrayCounter; i++){
    //        for(int k=0; k<slices; k++){
    //            NSLog(@"given timeArray[%d][%d]= %lf",i ,k ,[viewerTimeArray[i][k] doubleValue] );
    //        }
    //    }
    
    // Conserve Time using the Old Implementation when Not in Shuttle Mode
    /*
     if([controller isShuttleMode]){
     //// New implementation using 2D viewerTimeArray
     int slice = [tissueRoiRec slice];
     for(i=0; i<n-1; i++){
     
     time[i+1] = [viewerTimeArray[i+start][slice] doubleValue];
     NSLog(@"given timeArray[%d][%d]= %lf",i+start ,slice ,[viewerTimeArray[i+start][slice] doubleValue] );
     }
     }else{
     // Previous Implementation using normal time variable
     for (i=0; i<n-1; i++){
     time[i+1] = viewerTime[i+start];
     }
     }
     */
    
    // Test if its viable to always use 2D TimeArray for calculation ( remember to rename Method Calls in UMMPPanelController to the old one if not )
    //// New implementation using 2D viewerTimeArray
    int slice = [tissueRoiRec slice];
    NSLog(@"UMMP2C2InletRoiBasedController: written in 1D timeArray[%d]= %lf",0 ,time[0]);
    for(i=0; i<n-1; i++){
        
        time[i+1] = [viewerTimeArray[i+start][slice] doubleValue];
        NSLog(@"UMMP2C2InletRoiBasedController: given timeArray[%d][%d]= %lf",i+start ,slice ,[viewerTimeArray[i+start][slice] doubleValue] );
        NSLog(@"UMMP2C2InletRoiBasedController: written in 1D timeArray[%d]= %lf",i+1 ,time[i+1]);
        
    }
    
    NSDate *startTime = [NSDate date];
	
    double curveFit[n];
	
    // Enhancement of AIF and TISSUE
    lmuEnhancement(aif, n, bl, tracer);
    lmuEnhancement(vif, n, bl, tracer);
    lmuEnhancement(tissue, n, bl, tracer);
	
    // Adapt AIF and VIF to Hematocrit
    double htcDifference = 1-htc;
    
	
    for (i = 0; i < n; i++){
        aif[i] /= htcDifference;
        vif[i] /= htcDifference;
        
    }
    
    double af, vf, ve, ki, ta, tv, chiSquare =0.0, correctedAkaikeError = 0.0, xError = 0.0;
    double fi, fa, te;
    
    NSString * algoTitleOnChart = nil, *algoNameSelectForPresets = nil;
    
    
    algoTitleOnChart = @"2-Inlet 2-Compartment Uptake";
    algoNameSelectForPresets = @"2Inlet 2C Uptake";
    
    
    NSMutableArray *parameters = [[controller prefController] findParametersByTag:[presetButton selectedTag] forAlgorithm:algoNameSelectForPresets];
    int paramCount = [parameters count];
    
    fixed        = (int*)        calloc(paramCount, sizeof(int));
    limited    = (int*)         calloc(paramCount*2, sizeof(int));
    limits      = (double*) calloc(paramCount*2, sizeof(double));
    p              = (double*) calloc(paramCount, sizeof(double));
    
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
	
    
    //calls the fit method of MPCurvefit
    fitDoubleInletUptake(n, p, fixed, limited, limits, maxiterations, maxFunctionEvaluation, time, aif, vif, tissue, curveFit, &af, &vf, &ve, &ki, &ta, &tv, &fi, &fa, &te, &correctedAkaikeError, &chiSquare, &xError);
    
    
    
	// TEST (Returns results of fitted values)
    int counter;
    if([[controller userDefaults] int:@"printPresetsToConsole" otherwise:NO]) {
        NSLog(@"p[] - fit parameter values");
        for(counter=0; counter < [parameters count]; counter++){
            NSLog(@"%lf", p[counter]);
        }
        NSLog(@"xError: %lf", xError);
    }
	//end of TEST
    
	NSMutableArray *tissueData = [[NSMutableArray alloc] init];
	NSMutableArray *fitData = [[NSMutableArray alloc] init];
    // array for the captured images
    NSMutableArray *timeData = [[NSMutableArray alloc] init];
    
	
	for (i=0; i<n; i++) {
		[tissueData addObject:[NSNumber numberWithFloat:tissue[i]]];
		[fitData addObject:[NSNumber numberWithFloat:curveFit[i]]];
        // array with time in seconds per captured image
        [timeData addObject:[NSNumber numberWithFloat:time[i]]];
	}
    
	UMMPCMPanelController *cmController = [[UMMPCMPanelController alloc] initWithViewer:vc withMainController:controller andAifRoiData:[NSArray arrayWithArray:aifRoiData] andTissueRoiRec:nil andTissueRoiData:[NSArray arrayWithArray:tissueRoiData] andTissue:[NSArray arrayWithArray:tissueData] andFit:[NSArray arrayWithArray:fitData] andTime:[NSArray arrayWithArray:timeData] andAlgorithmTag:-1];
    
	// clean up dict from previous calculations
	[dict removeAllObjects];
	
    
    [dict setObject:algoTitleOnChart forKey:@"name"];
    [dict setObject:[tracerButton titleOfSelectedItem] forKey:@"tracer"];
    
    
    [dict setObject:@"Extracellular Volume" forKey:@"para1"];
    [dict setObject:[NSNumber numberWithDouble:ve] forKey:@"value1"];
    [dict setObject:@"(ml/100ml)" forKey:@"unit1"];
    
    
    [dict setObject:@"Arterial Flow" forKey:@"para2"];
    [dict setObject:[NSNumber numberWithDouble:af] forKey:@"value2"];
    [dict setObject:@"ml/100ml/min" forKey:@"unit2"];
    
    
    [dict setObject:@"Venous Flow" forKey:@"para3"];
    [dict setObject:[NSNumber numberWithDouble:vf] forKey:@"value3"];
    [dict setObject:@"(ml/100ml/min)" forKey:@"unit3"];
    
    [dict setObject:@"Intracellular Uptake Rate" forKey:@"para4"];
    [dict setObject:[NSNumber numberWithDouble:ki] forKey:@"value4"];
    [dict setObject:@"1/min" forKey:@"unit4"];
    
    [dict setObject:@"Arterial Delay Time" forKey:@"para4"];
    [dict setObject:[NSNumber numberWithDouble:ta] forKey:@"value4"];
    [dict setObject:@"(sec)" forKey:@"unit4"];
    
    [dict setObject:@"Venous Delay Time" forKey:@"para5"];
    [dict setObject:[NSNumber numberWithDouble:tv] forKey:@"value5"];
    [dict setObject:@"(sec)" forKey:@"unit5"];
    
    
    [dict setObject:@"Extracellular MTT" forKey:@"para6"];
    [dict setObject:[NSNumber numberWithDouble:te] forKey:@"value6"];
    [dict setObject:@"(sec)" forKey:@"unit6"];
    
    
    [dict setObject:@"Arterial Flow Fraction" forKey:@"para7"];
    [dict setObject:[NSNumber numberWithDouble:fa] forKey:@"value7"];
    [dict setObject:@"(%)" forKey:@"unit7"];
    
    [dict setObject:@"Hepatic Uptake Fraction" forKey:@"para8"];
    [dict setObject:[NSNumber numberWithDouble:fi] forKey:@"value8"];
    [dict setObject:@"(%)" forKey:@"unit8"];
    
    // is always used
    [dict setObject:@"Corr. Akaike Information Crit." forKey:@"para9"];
    [dict setObject:[NSNumber numberWithDouble:correctedAkaikeError] forKey:@"value9"];
    // is always used
    [dict setObject:@"Final Chi Square" forKey:@"para10"];
    [dict setObject:[NSNumber numberWithDouble:chiSquare] forKey:@"value10"];
 	
	
	
    [cmController setResults:dict];
    [cmController setInputParameter: inputParameter];
    [cmController setPresetParameter:presetParameter];
    [self saveOutputParameter:-1];
    [cmController setOutputParameter: outputParameter];
    
    [[controller cmControllerList] addObject:cmController];
	
	NSDate *endTime = [NSDate date];
	NSLog(@"UMMPerfusion - MPCurveFit total term: %lf ", [endTime timeIntervalSinceDate:startTime]);
	
	// free memory
	if (aif)         free(aif);
    if (vif)         free(vif);
	if (tissue)     free(tissue);
	if (time)       free(time);
	
    [aifRoiData release];
    [vifRoiData release];
    [tissueRoiData release];
	[tissueData release];
	[fitData release];
    
    [vc endWaitWindow: waitWindow];
    
    if ([autosaveCheckButton state]) {
        [cmController pushExportButton:nil];
    }
}


@end
