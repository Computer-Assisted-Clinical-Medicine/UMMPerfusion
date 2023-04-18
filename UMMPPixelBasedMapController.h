//
//  UMMPPixelBasedController.h
//  UMMPerfusion
//
//  Created by UMMPerfusion on 21.06.12.
//  Copyright (c) 2012, Marcel Reich & Sven Kaiser & Markus Daab & Patrick Schülein & Engin Aslan
//  All rights reserved.
//

#import "UMMPAlgorithmController.h"
#import "UMMPPanelController.h"
#import "UMMPPreset.h"


#import "MPCurveFit.h"

#import "DCMObject.h"

/**
 derived from UMMPAlgorithmController
 a controller which includes all Pixel based algorithms:
 
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
 - startMapCalculation
 */

@interface UMMPPixelBasedMapController : UMMPAlgorithmController {
    IBOutlet NSView *compartmentMapView;            //!< the mapSelectionView for Compartment algorithm 
    IBOutlet NSView *twoCExchangeView;              //!< the mapSelectionView for 2C Exchnage algorithm
    IBOutlet NSView *twoCFiltrationView;            //!< the mapSelectionView for 2C Filtration algorithm
    IBOutlet NSView *twoCUptakeView;                //!< the mapSelectionView for 2C Uptake algorithm
    IBOutlet NSView *modifiedToftsView;             //!< the mapSelectionView for Modified Tofts algorithm
    
    
}

@end
