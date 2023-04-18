//
//  UMMPFastDeconvolutionController.h
//  UMMPerfusion
//
//  Created by Marcel Reich on 04.10.11.
//  Copyright (c) 2012, Marcel Reich & Sven Kaiser & Markus Daab & Patrick Schülein & Engin Aslan
//  All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UMMPAlgorithmController.h"
#import "UMMPUserDefaults.h"
#import "UMMPPrefController.h"
#import "UMMPPanelController.h"

/**
 derived from UMMPAlgorithmController
 a controller which calculates the FastDeconvolution algorithm
  
 reimplements:
 - checkUserImport
 - saveInputParameter:andAlgorithmName
 - savePresetParameter:
 - saveOutputParameter:
 - startCalculation:andAlgorithmTag
 */


@interface UMMPFastDeconvolutionController : UMMPAlgorithmController {

	BOOL interpolation;         //!< to have a class wide variable whether or not interpolation is needed
    UMMPUserDefaults					*userDefaults;                 //!< the UMMPUserDefaults which are used to create, load and write to our own .pList
    UMMPPrefController                  *prefController;
    UMMPPanelController                 *panelController;
}
@property (assign)UMMPUserDefaults *userDefaults;
@end
