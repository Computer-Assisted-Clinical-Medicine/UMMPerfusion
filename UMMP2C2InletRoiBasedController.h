//
//  UMMP2C2InletRoiBasedController.h
//  UMMPerfusion
//
//  Created by Student on 18.05.16.
//
//

#import "UMMPAlgorithmController.h"
#import "UMMPPanelController.h"
#import "UMMPCMPanelController.h"
#import "UMMPPreset.h"
#import "MPCurveFit.h"
#import "DCMObject.h"


/**
 derived from UMMPAlgorithmController
 a controller which includes the 2 Compartment 2 Inlet Uptake ROI based algorithm
 
 reimplements:
 - checkUserImport
 - saveInputParameter:andAlgorithmName
 - savePresetParameter:
 - saveOutputParameter:
 - startCalculation:andAlgorithmTag
 */

@interface UMMP2C2InletRoiBasedController : UMMPAlgorithmController {
    
	NSMutableDictionary *dict;          //!< a dictionary where the output parameters can be saved as dicionarys
}

@end