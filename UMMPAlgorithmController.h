//
//  UMMPAlgorithmController.h
//  UMMPerfusion
//
//  Created by Marcel Reich on 04.10.11.
//  Copyright (c) 2012, Marcel Reich & Sven Kaiser & Markus Daab & Patrick Schülein & Engin Aslan
//  All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UMMPRoiList.h"
#import "UMMPViewerList.h"
#import "UMMPReport.h"

#import <OsiriXAPI/Notifications.h>

@class UMMPPanelController;
@class UMMPBinding;
@class UMMPPreset;
@class DICOMExport;

@interface UMMPAlgorithmController : NSWindowController {
    
    DICOMExport *exportDCM;                             //!< an DICOMExport instance to export the generated viewers and reports
    UMMPReport *report;                                 //!< the generated UMMPReport
    NSMutableArray *inputParameter;                     //!< a mutableArray which contains all inputParameters after pushing the generate Button
	NSMutableArray *outputParameter;                    //!< a mutableArray which contains all outputParameters after pushing the generate Button
	NSMutableArray *presetParameter;                    //!< a mutableArray which contains all presetParameters after pushing the generate Button
		
	IBOutlet UMMPPanelController *controller;           //!< the UMMPPanelController instance which is used in the whole plugIn
    IBOutlet UMMPBinding *binding;                      //!< an IBOutlet to an UMMPBinding instance to check whether or not the inserted values are correct
    
    IBOutlet NSWindow *mapSelectionPanel;               //!< IBOutlet to the window of mapSelectionPanelController
	
	IBOutlet NSPopUpButton *algorithmButton;            //!< the algorithm popup Button for one Algorithm x ROIs controller
	IBOutlet NSPopUpButton *arterialButton;             //!< the arterial popup button for all controllers
    IBOutlet NSPopUpButton *venousButton;             //!< the venous popup button for all 2C 2Inlet Uptake controllers
	IBOutlet NSPopUpButton *tissueButton;               //!< the tissue popup button for all controllers
	IBOutlet NSPopUpButton *tracerButton;               //!< the tracer popup button for all controllers
    IBOutlet NSPopUpButton *presetButton;               //!< the preset popup button for all controllers
	IBOutlet NSTextField *baseLineLength;               //!< IBOutlet to all baseline lenght text Fields
	IBOutlet NSTextField *hematocrit;                   //!< IBOutlet to all hematocrit text Fields
	IBOutlet NSTextField *regularizationParameter;      //!< IBOutlet to all regularization text Fields
	IBOutlet NSSlider *startSlider;                     //!< the start slider for the time
	IBOutlet NSSlider *startSliceSlider;                //!< the start slider for the z_trimm
	IBOutlet NSSlider *endSliceSlider;                  //!< the end slider for the time
	IBOutlet NSSlider *endSlider;                       //!< the end slider for the z_trimm
	IBOutlet NSTextField *startField;                   //!< an IBOutlet to display the value adjusted to the sliders
	IBOutlet NSTextField *endField;                     //!< an IBOutlet to display the value adjusted to the sliders
	IBOutlet NSTextField *startSliceField;              //!< an IBOutlet to display the value adjusted to the sliders
	IBOutlet NSTextField *endSliceField;                //!< an IBOutlet to display the value adjusted to the sliders
	IBOutlet NSTextField *exportNameTextField;          //!< a text field to enter a custom name for export
	IBOutlet NSButton *autosaveCheckButton;             //!< a checkbox to choose between autosave state 
}

@property (readonly) UMMPPanelController *controller;
@property (copy) NSMutableArray *inputParameter;
@property (copy) NSMutableArray *outputParameter;
@property (copy) NSMutableArray *presetParameter;
@property (readonly) NSPopUpButton *algorithmButton;
@property (readonly) NSPopUpButton *arterialButton;
@property (readonly) NSPopUpButton *venousButton;
@property (readonly) NSPopUpButton *tissueButton;
@property (readonly) NSPopUpButton *tracerButton;
@property (readonly) NSPopUpButton *presetButton;
@property (readonly) NSTextField *baseLineLength;
@property (readonly) NSTextField *hematocrit;
@property (readonly) NSTextField *regularizationParameter;
@property (readonly) NSSlider *startSlider;
@property (readonly) NSSlider *endSlider;
@property (readonly) NSSlider *startSliceSlider;
@property (readonly) NSSlider *endSliceSlider;
@property (readonly) NSTextField *startField;
@property (readonly) NSTextField *endField;
@property (readonly) NSTextField *startSliceField;
@property (readonly) NSTextField *endSliceField;
@property (readonly) NSTextField *exportNameTextField;
@property (readonly) NSButton *autosaveCheckButton;
@property (readonly) NSWindow *mapSelectionPanel;

/**
 */
- (void)resizeWindowOnSpotWithRect:(NSRect)aRect;
/**
 */
- (void)resizeWindowOnSpotWithView:(NSView*)aView;
/**
 an IBAction to adjust settings and views for the new selected ROI
 @param sender
 */
- (IBAction)selectROIs:(id)sender;
/**
 an IBAction to change the selected presets
 @param sender
 */
- (IBAction)selectPreset:(id)sender;
/**
 an IBAction to adjust time start slider and time end slider as well
 @param sender
 */
- (IBAction)moveStartSlider:(id)sender;
/**
 an IBaction to adjust time end slider and time start slider as well
 @param sender
 */
- (IBAction)moveEndSlider:(id)sender;
/**
 an IBAction to adjust slice start slider and slice and slider as well
 @param sender
 */
- (IBAction)moveSliceStartSlider:(id)sender;
/**
 an IBAction to adjust slice end slider and slice start slider as well
 @param sender
 */
- (IBAction)moveSliceEndSlider:(id)sender;
/**
 */
- (void)searchDeltaT:(NSInteger)start end:(NSInteger)end;
/**
 a method which is called from UMMPRoiList after receiving an NSNotification to add a ROI without a name to the roiList of the controller instance
 @param roiRec the generated UMMPRoiRec instance
 */
- (void)addROIRec:(UMMPROIRec *)roiRec;
/**
 a method which is called from UMMPRoiList after receiving an NSNotification to add a ROI with a given name to the roiList of the controller instance
 @param roiRec the generated UMMPRoiRec instance
 @param name the name of the ROI
 */
- (void)addROIRec:(UMMPROIRec *)roiRec withName:(NSString *)name;
/**
 a method which is called from UMMPROIList after receiving an NSNotification in order to react to changes of the given ROI
 @param roiRec the instance which was modified
 */
- (void)changeROIRec:(UMMPROIRec *)roiRec;
/**
 a method which adds all ROIs to roiList of the controller instance variable when another algorithm is selected
 @param roiRecords mutable array with all UMMPROIRec instances
 */
- (void)loadROIRecs:(NSMutableArray *)roiRecords;
/**
 a method which is called from UMMPROIList after receiving a NSNotification in order to remove ROIs from the roiList of the controller instance variable
 @param roiRec the UMMPROIRec instance which will be deleted
 */
- (void)removeROIRec:(UMMPROIRec *)roiRec;
/**
 function to remove the external ROIRec
 */
- (void)removeExternalROIRec:(UMMPROIRec *)roiRec;
/**
 makes the selected ROIs visible on the chart --> calls [chart setNeedsDisplay:YES]
 */
- (void)drawSelectedROIRecs;
/**
 is called when the user changes the algorithm to display the same ROIs in arterial and tissue popUp button which were selected
 */
- (void)selectUserROIs;
/**
 is called when the user changes the algorithm to display the same preset in preset popUp button which was selected
 */
- (void)selectUserPreset;
/**
 gets called by loadPreset to add the existing presets to the popUp menu
 @param preset the UMMPPReset instance that will be added
 */
- (void)addPreset:(UMMPPreset *)preset;
/**
 a method to reload the preset data in the popUp menu --> calls addPreset
 @param presets an array with the data of the existing presets
 */
- (void)loadPresets:(NSMutableArray *)presets;
/**
 a method which is called when a name is written to the autosave Name textField --> selector of "NSControlTextDidChangeNotification"
 @param notification the notification which is thrown
 */
- (void)activateAutoSave:(NSNotification *)notification;
/**
 
 */
- (void)drawReportWithAif:(NSArray *)aif;
/**
 is called from UMMPPanelController if the user pushes to export button
 */
- (void)exportResults;
/**
 is called to export the self generated UMMPReport instance
 @param exReport the gernerated UMMPReport instance
 @param seriesDescription 
 @param seriesNumber
 @param backgroundColor
 @param filename
 */
- (void)exportReport:(UMMPReport*)exReport andSeriesDiscription:(NSString*)seriesDescription seriesNumber:(int)seriesNumber backgroundColor:(NSColor*)backgroundColor toFile:(NSString*)filename;
/**
 exports the generated and displayed viewers
 @param viewer the instance of UMMPViewer which will be exported
 */
- (void)exportViewer:(UMMPViewer *)viewer;
/**
 
 @param screenCapture chooses the way the viewers will be exported. as in memory, displayed or as rgb
 @param name the name of the viewer
 @param new2DViewer
 */
- (NSDictionary*) exportDICOMFileInt:(int)screenCapture withName:(NSString*)name viewer:(ViewerController *)new2DViewer;

// @Override
//  has to be overridden in Subclasses

/**
 in UMMPRoiBasedController this function is called to calculate the fits and initialize an UMMPPCMPanelController
 in UMMPPixelBasedController this function is called to display the right mapSelectionView
 in UMMPAFOneAlgorithmController this function is called to calculate the fits with the given UMMPROIRec
 in UMMPAFOneROIController this function is called to calculate the fits with the given UMMPROIRec and algorithmTag
 @param tissueROI the used UMMPROIRec for the calculation
 @param algorithm the used algorithm's tag, to make sure the right algorithm is used
 */
- (void)startCalculation:(UMMPROIRec*)tissueROI andAlgorithmTag:(int)tag;

/**
 this function is overriden in the UMMPPixelBasedController to calculate and display the new viewers with the calculated values. It gets called by the IBAction: pushOKButton of the UMMPMapSelectionPanelController
 */
- (void)startMapCalculation;
/**
 this function is overriden in the UMMPAFAllMapsController to calculate and export the new viewers with the calculated values. It gets called by the IBAction: pushOKButton of the UMMPAFAllMapsController
 */
- (void)startMapCalculation:(int)tag;

/**
 this function is called by the pushGenerateButton functions of the UMMPPanelController.
 It returns YES or NO whether or not the prerequisites are correct (arterail ROI selected.....)
 @return YES or NO whether or not the calculation can be started
 */
- (BOOL)checkUserInput;
/**
 this function stores the used input parameters like patient name etc. into the inputParameters array of UMMPAlgorithmController
 @param tisseROI the used UMMPROIRec for the advanced features controllers
 @param algorithm the name of the used algorithm for UMMPAFOneROIController
 */
- (void)saveInputParameter:(UMMPROIRec*)tissueROI andAlgorithmName:(NSString*)algorithm;
/**
 this function stores the used preset values into the presetParameters array of UMMPAlgorithmController
 @param tag the tag to determine which algorithm's preset values will be saved
 */
- (void)savePresetParameter:(int)tag;
/**
 this function stores the used or calculated output Parameters into the outputParameters array of UMMPAlgorithmController
 @param tag the tag to determine which algorithm's output values will be saved
 */
- (void)saveOutputParameter:(int)tag;

@end
