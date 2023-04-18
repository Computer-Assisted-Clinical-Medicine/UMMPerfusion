//
//  UMMPAdvancedFeauresController.h
//  UMMPerfusion
//
//  Created by Markus Daab on 11.06.12.
//  Copyright (c) 2012, Marcel Reich & Sven Kaiser & Markus Daab & Patrick Schülein & Engin Aslan
//  All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UMMPPanelController.h"
#import "UMMPAlgorithmController.h"

#import <OsiriXAPI/Wait.h>
#import <OsiriXAPI/BrowserController.h>
#import <OsiriXAPI/DICOMExport.h>

#import "UMMPPanelController.h"
#import "UMMPCMPanelController.h"
#import "UMMPPreset.h"

#import "MPCurveFit.h"

#import "DCMObject.h"

/**
 derived from UMMPAlgorithmController
 a controller which can calculate (ROI based) all selected ROIs for the the selected algorithm:
 
 - 1Compartment
 - 2C Exchange
 - 2C Filtration
 - 2C Uptake
 - Modified Tofts
 
 reimplements:
 - checkUserImport
 - saveInputParameter:andAlgorithmName
 - savePresetParameter:
 - saveOutputParameter:
 - startCalculation:andAlgorithmTag
 - addROIRec:
 - addROIRec:withName:
 - changeROIRec:
 - removeROIRec:
 - drawSelectedROIRecs:
 */

@interface UMMPAFOneAlgorithmController : UMMPAlgorithmController < NSTableViewDelegate, NSTableViewDataSource >  {

	
	IBOutlet NSTableView				*tissueROITableView;    //!< an IBOutlet to the table view where the ROIs can be selected
	
	IBOutlet NSButtonCell				*tissueButtonCell;      //!< an IBOutlet to the buttonCells to change their names and status
		
	
	NSMutableDictionary					*dict;                  //!< a dictionary where the output parameters can be saved as dicionarys
 
	}

@property (readwrite,retain) NSTableView *tissueROITableView;

//- (void)addROIRec:(UMMPROIRec *)roiRec;
//- (void)addROIRec:(UMMPROIRec *)roiRec withName:(NSString *)name;
//- (void)changeROIRec:(UMMPROIRec *)roiRec;
//- (void)removeROIRec:(UMMPROIRec *)roiRec;
//- (void)drawSelectedROIRecs;

@end
