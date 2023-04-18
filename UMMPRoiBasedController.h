//
//  UMMPRoiBasedController.h
//  UMMPerfusion
//
//  Created by Markus Daab & Patrick Schülein on 21.06.12.
//  Copyright (c) 2012, Marcel Reich & Sven Kaiser & Markus Daab & Patrick Schülein & Engin Aslan
//  All rights reserved.
//

#import "UMMPAlgorithmController.h"
#import "UMMPPanelController.h"
#import "UMMPCMPanelController.h"
#import "UMMPPreset.h"
#import "MPCurveFit.h"
#import "DCMObject.h"


/**
 derived from UMMPAlgorithmController
 a controller which includes all ROI based algorithms:
 
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
 */

@interface UMMPRoiBasedController : UMMPAlgorithmController {
    
	NSMutableDictionary *dict;          //!< a dictionary where the output parameters can be saved as dicionarys
}

@end
