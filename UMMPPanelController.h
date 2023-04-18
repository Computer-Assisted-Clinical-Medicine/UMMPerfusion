//
//  UMMPPanelController.h
//  UMMPerfusion
//
//  Created by Marcel Reich on 04.10.11.
//  Copyright (c) 2012, Marcel Reich & Sven Kaiser & Markus Daab & Patrick Schülein & Engin Aslan
//  All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UMMPerfusionFilter.h"
#import "UMMPAlgorithmController.h"
#import "UMMPCMPanelController.h"
#import "UMMPMapSelectionPanelController.h"
#import "UMMPPrefController.h"
#import "UMMPChart.h"
#import "UMMPUserDefaults.h"

@class UMMPRoiList;
@class UMMPViewerList;

@interface UMMPPanelController : NSWindowController {
    
    // is needed to enable and disable "LoadAIF" button
    BOOL algorithmIsChoosed;
    
	NSString							*currentPluginVersion;         //!< the current plugin version as a string
	
    UMMPerfusionFilter                  *filter;                       //!< the UMMPerfusionFilter which was given by the initWithFilter method
    UMMPerfusionFilter                  *pluginInit;
	ViewerController                    *viewerController;             //!< the viewerController which was given by the initWithFilter method
	UMMPAlgorithmController             *algorithmController;          //!< the UMMPAlgorithmController which is used
    
	UMMPUserDefaults					*userDefaults;                 //!< the UMMPUserDefaults which are used to create, load and write to our own .pList
	UMMPPrefController                  *prefController;               //!< the prefController to the prefWindow
    
    NSMutableArray                      *cmControllerList;             //!< an array which contains all instances of UMMPCMPanelController
    
    NSInteger                           selectedArterialRoiTag;        //!< the tag of the selected item the arterial popup button displays
    NSInteger                           selectedVenousRoiTag;        //!< the tag of the selected item the venous popup button displays
    NSInteger                           selectedTissueRoiTag;          //!< the tag of the selected item the tissue popup button displays
    NSInteger                           selectedPresetTag;             //!< the tag of the selected item the preset popup button displays
    
    
	NSSize								_panelSize;                    //!< the size of the panel
	
	BOOL								alreadyExported;               //!< a boolean whether or not the results have already been exported
	
	BOOL								interpolation;                 //!< a boolean whether or not the dataset needs interpolation
	BOOL								_32bitPipeline;                //!< a boolean whether or not the full32bitOpenGL pipeline is activated or not
	BOOL                                isShuttleMode;
    double                              deltaT, max, min;              //!< variables for isInterpolationNeeded method
    double                              *time, *dTime;                 //!< variables for isInterpolationNeeded method
    NSMutableArray                      *timeArray, *dTimeArray;
    
    NSString                            *adaptive4DSpiralValue;
    
    IBOutlet UMMPRoiList                *roiList;                      //!< an IBOutlet to an UMMPRoiList instance which contains all drawn ROIs
    IBOutlet UMMPViewerList             *viewerList;                   //!< an IBOutlet to an UMMPViewerList instance which contains all displayed viewers
    IBOutlet UMMPChart                  *chart;                        //!< an IBOutlet to an UMMPChart instance which contains the data of the displayed fit
    
    //    IBOutlet NSWindow                   *prefWindow;                   //!< an IBOutlet to the preference window
	
    IBOutlet NSView                     *pixelBasedMapView;            //!< to select pixel based view
	IBOutlet NSView                     *fastDeconvolutionView;        //!< to select fast Deconvolution view
	IBOutlet NSView						*afOneAlgorithmView;           //!< to select one algorithm x ROIs view
	IBOutlet NSView						*afOneROIView;                 //!< to select one ROI all algorithms view
    IBOutlet NSView                     *afAllMapsView;                 //!< to select all maps view
    IBOutlet NSView                     *roiBasedView;                  //!< to select Roi based view
    IBOutlet NSView                     *twoComp2InletUptakeRoiBasedView;         //!< to select 2C 2Inlet Uptake Roi based view
    IBOutlet NSView                     *twoComp2InletUptakePixelBasedView;       //!< to select 2C 2Inlet Uptake Pixel based view
    
	
    
    IBOutlet UMMPAlgorithmController    *pixelBasedMapController;      //!< to select the right controller to the view
	IBOutlet UMMPAlgorithmController    *fastDeconvolutionController;  //!< to select the right controller to the view
	IBOutlet UMMPAlgorithmController	*afOneAlgorithmController;     //!< to select the right controller to the view
	IBOutlet UMMPAlgorithmController	*afOneROIController;           //!< to select the right controller to the view
    IBOutlet UMMPAlgorithmController	*afAllMapsController;          //!< to select the right controller to the view
    IBOutlet UMMPAlgorithmController	*roiBasedController;           //!< to select the right controller to the view
    IBOutlet UMMPAlgorithmController	*twoComp2InletUptakeRoiBasedController;           //!< to select the right controller to the view
    IBOutlet UMMPAlgorithmController	*twoComp2InletUptakePixelBasedController;           //!< to select the right controller to the view
    
    IBOutlet UMMPMapSelectionPanelController    *mapSelectionPanelController;   //!< an IBOutlet to the mapSelectionPanelController
	
	IBOutlet NSDrawer                   *drawer;                       //!< IBOutlet for chart wich pops up when drawing a ROI
	
	IBOutlet NSPopUpButton              *algorithmPopUpButton;         //!< the popup button to select the algorithms
	
	IBOutlet NSMenuItem                 *menuItem1;                    //!< menuItem in algorithm popup button which can't be selected
	IBOutlet NSMenuItem                 *menuItem2;                    //!< menuItem in algorithm popup button which can't be selected
	IBOutlet NSMenuItem                 *menuItem3;                    //!< menuItem in algorithm popup button which can't be selected
    IBOutlet NSMenuItem                 *menuItem4;                    //!< menuItem in algorithm popup button which can't be selected
}

@property (readonly) ViewerController *viewerController;
@property (readonly) UMMPerfusionFilter *filter;
@property (readonly) UMMPAlgorithmController *algorithmController;
@property (assign)UMMPUserDefaults *userDefaults;
@property (readonly) UMMPPrefController *prefController;
@property (readonly) UMMPMapSelectionPanelController *mapSelectionPanelController;
@property (readonly) UMMPViewerList *viewerList;
@property (copy) NSMutableArray *cmControllerList;
@property (readonly) NSPopUpButton *algorithmPopUpButton;
@property (readonly) double *time;
@property (readonly) double *dTime;
@property (readonly) NSMutableArray *dTimeArray;
@property (readonly) NSMutableArray *timeArray;
@property (readonly) BOOL isShuttleMode;
@property (readonly) UMMPRoiList *roiList;
@property (readonly) UMMPChart *chart;
@property (readonly) NSDrawer *drawer;
@property (readwrite) BOOL interpolation;
@property (readwrite) double deltaT;
@property (readwrite) double max;
@property (readwrite) NSInteger selectedArterialRoiTag;
@property (readwrite) NSInteger selectedVenousRoiTag;
@property (readwrite) NSInteger selectedTissueRoiTag;
@property (readwrite) NSInteger selectedPresetTag;
@property (readwrite) BOOL algorithmIsChoosed;


enum {
    fastDeconvolutionTag = 1,
    compartmentRoiTag,
    exchangeRoiTag,
    filtrationRoiTag,
    uptakeRoiTag,
    modifiedToftsRoiTag,
    
    compartmentMapTag,
    exchangeMapTag,
    filtrationMapTag,
    uptakeMapTag,
    modifiedToftsMapTag,
    
    allROIsTag,
    allAlgorithmsTag,
    allMapsTag,
    
    //new 2C 2Inlet Uptake model
    twoComp2InletUptakeRoiTag,
    twoComp2InletUptakePixelTag
};

enum {
    externalROITag = 0
};

enum {
    deleteExternalAIF = 0
};

/**
 Panel is initiated with a selected Filter.
 @param aFilter A filter that has been selected
 @param aViewerController A pointer to the used ViewerController-Object
 @returns an initialized Panel with the selected Filter
 */
- (id)initWithFilter:(UMMPerfusionFilter*)aFilter andViewer:(ViewerController*)aViewerController;

// This method deselects all ROIs before taking screenshot for the report
- (void) deselectAllRois;
/**
 Changes the shown Item after Popup-Selection.
 @param sender The ID the item belongs to
 */
- (IBAction)viewChoicePopupAction:(id)sender;
/**
 Action for a "close all report windows" button
 @param sender The ID the item belongs to
 */
- (IBAction)pushCloseAllViewersButton:(id)sender;
/**
 Preferences window will become visible on click on Pref-Button.
 @param sender The ID the item belongs to
 */
- (IBAction)pushPrefButton:(id)sender;
/**
 Checks the UserInput and calls the startCalculation-method.
 Additionally saves parameters and checks whether export is needed.
 @param sender The ID the item belongs to
 */
- (IBAction)pushGenerateButton:(id)sender;
/**
 Checks the UserInput and calls the startCalculation-method.
 Additionally saves parameters exports all viewers without showing them first.
 @param sender The ID the item belongs to
 */
- (IBAction)pushGenerateAllMapsButton:(id)sender;
/**
 Checks the UserInput and calls the startCalculation-method for advanced features Controller
 all ROIs for one algorithm.
 Additionally saves parameters and checks whether export is needed.
 @param sender The ID the item belongs to
 */
-(IBAction)pushGenerateButtonOneAlgorithm:(id)sender;
/**
 Checks the UserInput and calls the startCalculation-method for advanced features Controller
 one ROI for all algorithms.
 Additionally saves parameters and checks whether export is needed.
 @param sender The ID the item belongs to
 */
-(IBAction)pushGenerateButtonOneROI:(id)sender;
/**
 Exports the calculated results if they haven't been exported before
 @param sender The ID the item belongs to
 */
- (IBAction)pushExportButton:(id)sender;
/**
 Exports all calculated results if they haven't been exported before
 @param sender The ID the item belongs to
 */
- (IBAction)pushExportAllButton:(id)sender;
/**
 Opens the Link to the current Wiki Version/ documentation.
 @param sender The ID the item belongs to
 */
- (IBAction)pushHelpButton:(id)sender;
/**
 Prints notifications to the Console.
 @param notification The name of the notification
 */
- (void)notificationOutput:(NSNotification *)notification;
/**
 Changes the panel's content according to the selected algorithm.
 @param whichViewTag Contains integer-values that have been assigned to each algorithm
 */
- (void)changeView:(NSInteger)wichViewTag;
/**
 Returns the value for the given DICOM Tag
 @param DICOM Tag as formated string using @"%04X,%04X"
 */
- (NSString *)getStringValueForDicomTag:(NSString *)dicomTag;
/**
 Calculates the delta T, time gap between each acquired picture.
 Checks if interpolation is needed. Differentiates between manufacturers.
 @returns a BOOL value whether dataset needs an interpolation
 */
- (BOOL)calculateTime;
/**
 Calculates the delta T, time gap between each acquired picture using acquisitionTime
 */
- (void)calculateTimeUsingAcquisitionTime;
/**
 Calculates the delta T, time gap between each acquired picture using acquisitionTime and a 2D Array containing all Timepoints in all Slices
 */
- (void)calculateTimeUsingAcquisitionTime2D;
/**
 Calculates the delta T, time gap between each acquired picture using triggerTime
 @param divisor to correct decimal position
 */
- (void)calculateTimeUsingTriggerTimeWithDecimalCorrection:(double)decimalCorrection;
/**
 Calculates min, max and deltaT for existing time array
 @param timepoint for calculation
 */
- (void)calculateMinMaxAndDeltaTforTimePoint:(int)timePoint;
/**
 Create array with contentTime from Philips Multiframe Dataset
 @return Array with contentTime for each timepoint
 */
- (NSArray *)getContentTimeArrayFromMultiframeData;
/**
 Calculates timeArray for given contentTimeArray
 @param Array with contentTime as String e.g. 184526.01342
 */
- (void)calculateTimeUsingContentTimeArray:(NSArray *)contentTimeArray;
/**
 calculates whether or not interpolation is needed
 @param min min value
 @param max max value
 @returns a boolean
 */
- (BOOL)isInterpolationNeeded:(double)min max:(double)max;

- (void)setContent:(NSNotification *)notification;


@end
