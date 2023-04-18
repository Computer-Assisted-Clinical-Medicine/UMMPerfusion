//
//  UMMP2C2InletUptakePixelBasedMapController.h
//  UMMPerfusion
//
//  Created by Student on 03.08.16.
//
//

#import "UMMPAlgorithmController.h"
#import "UMMPPanelController.h"
#import "UMMPPreset.h"


#import "MPCurveFit.h"

#import "DCMObject.h"

/**
 derived from UMMPAlgorithmController
 a controller which includes the following Pixel based algorithms:
 
 - 2-Compartment 2-Inlet Uptake
 
 reimplements:
 - checkUserImport
 - saveInputParameter:andAlgorithmName
 - savePresetParameter:
 - saveOutputParameter:
 - startCalculation:andAlgorithmTag
 - startMapCalculation
 */

@interface UMMP2C2InletUptakePixelBasedMapController : UMMPAlgorithmController {
    IBOutlet NSView *twoComp2InletUptakeMapView;            //!< the mapSelectionView for 2-C 2-Inlet Uptake algorithm
    
    
}

@end
