//
//  UMMPMapSelectionPanelController.h
//  UMMPerfusion
//
//  Created by Sven Kaiser on 20.02.12.
//  Copyright (c) 2012, Marcel Reich & Sven Kaiser & Markus Daab & Patrick Schülein & Engin Aslan
//  All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UMMPUserDefaults.h"

@class UMMPPanelController;

@interface UMMPMapSelectionPanelController : NSWindowController < NSWindowDelegate > {
    
    IBOutlet UMMPPanelController *controller;           //!< the map seletion panel controller knows the UMMPPanelController
    
     //!< IBOutlets for the NSButtons on the map selection views
    
    // Compartmentview
	IBOutlet NSButton *compartmentMapPF;           
    IBOutlet NSButton *compartmentMapPMTT;
    IBOutlet NSButton *compartmentMapPV;
    IBOutlet NSButton *compartmentMapAFE;
    IBOutlet NSButton *compartmentMapCS;
	
    // 2C Exchangeview
    IBOutlet NSButton *exchangeMapPF;
    IBOutlet NSButton *exchangeMapPMTT;
    IBOutlet NSButton *exchangeMapPV;
    IBOutlet NSButton *exchangeMapIMTT;
    IBOutlet NSButton *exchangeMapIV;
    IBOutlet NSButton *exchangeMapEF;
    IBOutlet NSButton *exchangeMapPSAP;
    IBOutlet NSButton *exchangeMapAFE;
    IBOutlet NSButton *exchangeMapCS;
			
	// 2C Filtrationview
	IBOutlet NSButton *filtrationMapPF;
    IBOutlet NSButton *filtrationMapPMTT;
    IBOutlet NSButton *filtrationMapPV;
    IBOutlet NSButton *filtrationMapIMTT;
    IBOutlet NSButton *filtrationMapEF;
    IBOutlet NSButton *filtrationMapPSAP;
    IBOutlet NSButton *filtrationMapAFE;
    IBOutlet NSButton *filtrationMapCS;	
    
	// 2C Uptakeview
	IBOutlet NSButton *uptakeMapPF;
    IBOutlet NSButton *uptakeMapPMTT;
    IBOutlet NSButton *uptakeMapPV;
    IBOutlet NSButton *uptakeMapEF;
    IBOutlet NSButton *uptakeMapPSAP;
    IBOutlet NSButton *uptakeMapAFE;
    IBOutlet NSButton *uptakeMapCS;
    
    // Modified Toftsview
	IBOutlet NSButton *toftsMapPV;
    IBOutlet NSButton *toftsMapIMTT;
    IBOutlet NSButton *toftsMapIV;
    IBOutlet NSButton *toftsMapPSAP;
    IBOutlet NSButton *toftsMapAFE;
    IBOutlet NSButton *toftsMapCS;
    
    // 2C 2Inlet Uptakeview
	IBOutlet NSButton *twoC2InletUptakeMapAF;
    IBOutlet NSButton *twoC2InletUptakeMapVF;
    IBOutlet NSButton *twoC2InletUptakeMapEMTT;
    IBOutlet NSButton *twoC2InletUptakeMapEV;
    IBOutlet NSButton *twoC2InletUptakeMapIUR;
    IBOutlet NSButton *twoC2InletUptakeMapADT;
    IBOutlet NSButton *twoC2InletUptakeMapVDT;
    IBOutlet NSButton *twoC2InletUptakeMapAFF;
    IBOutlet NSButton *twoC2InletUptakeMapHUF;
    IBOutlet NSButton *twoC2InletUptakeMapCAIC;
    IBOutlet NSButton *twoC2InletUptakeMapCS;
    
    
}

/**
 an IBAction which is called when pushing the OK button of the different mapSelectionViews.
 the functions saves the status of the buttons into the pList and calls startMapCalculation
 @param sender the id of the OK button
 */
- (IBAction)pushOKButton:(id)sender;
/**
 a function to refresh the status of the mapSelection buttons 
 the data are taken from the pList
 */
- (void)refreshStatusOfMapSelection;

@end
