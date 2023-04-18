//
//  UMMPPrefController.h
//  UMMPerfusion
//
//  Created by Sven Kaiser on 02.11.11.
//  Copyright (c) 2012, Marcel Reich & Sven Kaiser & Markus Daab & Patrick Schülein & Engin Aslan
//  All rights reserved.
//

#import <AppKit/AppKit.h>
#import "UMMPAlgorithmController.h"

@class UMMPPanelController;
@class UMMPPreset;

@interface UMMPPrefController : NSWindowController < NSTableViewDelegate, NSTableViewDataSource, NSWindowDelegate > {
    
    ROI *externalROI;
    
    // variable to check if the added ROI is external
    BOOL extROI;
    
    // variable to check if at least one external ROI already exists
    BOOL extROIExists;
    
    // variable for the name of the external ROI
    NSString *extROIFilename;
    
    NSMutableString *extROIFilePathForReport;
    
    NSMutableArray *presets;
    
    // array for the imported aif values
    NSMutableArray *aifExportData;
    
    UMMPPanelController *panelController;      //!< the prefController knows the UMMPPanelController
    
    IBOutlet NSTableView *presetsTableView;             //!< the left NSTableView to select the presets
    IBOutlet NSTableView *parametersTableView;          //!< the right NSTableView to show the parameters of the selected presets
    IBOutlet NSPopUpButton *selectedAlgorithm;          //!< a popup button to select which algorithm's parameters will be shown
    IBOutlet NSButton *removeButton;                    //!< a button to delete the selected preset
    
    // IBOutlets for MPFit window
    IBOutlet NSTextField *maxIterations;                //!< a text field to show the max Iterations value for MPFit
    IBOutlet NSTextField *maxFunctionEvaluation;        //!< a txt field to show the max function evaluation value for mpfit
    
    // IBOutlets for General
    IBOutlet NSButton *playSound;
    IBOutlet NSButton *playSoundAllMaps;
    IBOutlet NSButton *printFitToConsole;
    
    /*+++++++++++++++++++++++ */
    // IBOutlets for MapSelection
    /*+++++++++++++++++++++++ */
    
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
    
    IBOutlet NSToolbar *_toolbar;
    
    IBOutlet NSView *_general;
    IBOutlet NSView *_presetValues;
    IBOutlet NSView *_mapSelections;
    IBOutlet NSView *_mpFit;
    IBOutlet NSView *_aifImport;

    
    IBOutlet NSButton *soundOnMapsCalcEnd;
    IBOutlet NSButton *soundOnAllMapsCalcEnd;
    IBOutlet NSButton *printPresetsToConsole;
    
    // IBOutlet for aif import window
    IBOutlet NSBox *AifImportPanel;
    
    NSMutableDictionary *importedAifValues;
}

@property (readonly) NSMutableArray *presets;
@property (readonly) NSTextField *maxIterations;
@property (readonly) NSTextField *maxFunctionEvaluation;
@property (readonly) NSString *extROIFilename;
@property (readwrite) BOOL extROI;
@property (readonly) BOOL extROIExists;
@property (readonly) NSMutableString *extROIFilePathForReport;

- (id)initWithPanelController:(UMMPPanelController *)givenPanelController;

/**
 a function to load the presets and maxIterations value from the UMMPerfusion.pList
 if there are none, it generates the standard preset values
 */
-(void)initValues;

/**
 an IBAction which is called when pushing the + button at the bottom of the presets table view on the left.
 it adds a new set of default parameters which can be eddited and renamed
 @param sender the id of the + button
 */
- (IBAction)addPresetItem:(id)sender;
/**
 an IBAction which is called when pushing the - btton at the bottom of the presets table view on the left.
 It removes the selected presets
 @param sender the id of the - button
 */
- (IBAction)removePresetItem:(id)sender;

/**
 an IBaction which is called when pushing the export option in the popup menu next to the +/- buttons.
 the function saves the selected presets to your hard drive
 @param sender the id of the export option in the popup menu
 */
- (IBAction)exportPreset:(id)sender;

/**
 an IBAction which is called when pushing the import option in the popup menu next to the +/- buttons.
 the function imports the selected presets and displays them in the table views
 @param sender the id of the import option in the popup menu
 */
- (IBAction)importPreset:(id)sender;

/**
 an IBAction which is called when pushing the algorithm popup button and makes the table view reload it's data
 @param sender the id of the algorithm button
 */
- (IBAction)pushAlgorithmButton:(id)sender;

/**
 not used anymore.....
 */
- (IBAction)pushSelectAllButton:(id)sender;
- (IBAction)pushDeselectAllButton:(id)sender;
- (IBAction)pushSetDefaultMPFitButton:(id)sender;
#pragma mark -
- (IBAction)changeView:(id)sender;

/**
 a function which is called when a new UMMPerfusion version has new preset parameters and the user wants old values to be removed. called in UMMPPanelController
 */
- (void)removeAllPresetItems;

/**
 a function which is called when a new UMMPerfusion version has new preset parameters and the user wants new preset values. called in UMMPPanelController
 */
- (void)addPresetItemForNewVersion;

/**
 a function which enables/disables the - button
 */
- (void)setRemoveButtonState;

/**
 a function which is used to get the right parameters when they are needed. (startCalculation: methods)
 @param tag the tag of selected preset
 @param algorithm the name of the algorithm
 @return NSMutableArray* an array with the parameters of the selected algorithm
 */
- (NSMutableArray*)findParametersByTag:(NSInteger)tag forAlgorithm:(NSString*)algorithm;

/**
 a function to set the preference view to general,mpfit or others
 it also adjusts the size of the window
 @param aTag the tag to determine which view shall be displayed
 */
- (void)changeViewForTag:(NSInteger)preferences;

/**
 an IBAction to write the state of the current mapSelection buttons into the pList
 @param sender the object, the action came from
 */
-(IBAction)pushMapSelButtonState:(id)sender;

/**
 an IBAction to write the values of the current mpfit view into the pList
 @param the object the action came from
 */
-(IBAction)changeMPFitValues:(id)sender;

/**
 a function to refresh the status of the mapSelection buttons 
 the data are taken from the pList
 */
-(void)refreshStatusOfMapSelection;

/**
 funtion to import an external ROI from csv file
 */
-(void)loadExternalAIF;

/**
 function to delete the loaded external ROI
 */
-(void)deleteExternalAIF;

/**
 function to get the aif values from the imported csv file
 */
-(float)getAifValue:(int)i;

@end
