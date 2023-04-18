/*
 Copyright (c) 2012, Marcel Reich & Sven Kaiser & Markus Daab & Patrick Schülein & Engin Aslan
 
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 - Redistributions of source code must retain the above copyright notice,
 this list of conditions and the following disclaimer.
 - Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 - Neither the name of the Universitätsmedizin Mannheim nor the names of its
 contributors may be used to endorse or promote products derived from this
 software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 */


#import <Cocoa/Cocoa.h>

#import <OsiriXAPI/ViewerController.h>

#import "GRChartView.h"
#import "GRPieDataSet.h"
#import "GRXYDataSet.h"
#import "GRAreaDataSet.h"
#import "GRLineDataSet.h"
#import "GRColumnDataSet.h"
#import "GRAxes.h"

#import "UMMPPanelController.h"
#import "UMMPReport.h"

/**
 this class is used to display the fit results on a seperate window where you can export the results as well
 */

@interface UMMPCMPanelController : NSWindowController {

	IBOutlet	GRChartView * _chartView;               //!< connection to the chartView of the UMMPCMPanel.xib
	IBOutlet	NSView *_cmView;
    IBOutlet    NSView *_savePanelView;
    // NSTextField instances to display the fit results
    IBOutlet	NSTextField *_name;                     
	IBOutlet	NSTextField *_tracer;
	IBOutlet	NSTextField *_para1;
    IBOutlet    NSTextField *_value1;
    IBOutlet    NSTextField *_unit1;
    IBOutlet    NSTextField *_para2;
    IBOutlet    NSTextField *_value2;
    IBOutlet    NSTextField *_unit2;
    IBOutlet	NSTextField *_para3;
    IBOutlet    NSTextField *_value3;
    IBOutlet    NSTextField *_unit3;
    IBOutlet    NSTextField *_para4;
    IBOutlet    NSTextField *_value4;
    IBOutlet    NSTextField *_unit4;
    IBOutlet	NSTextField *_para5;
    IBOutlet    NSTextField *_value5;
    IBOutlet    NSTextField *_unit5;
    IBOutlet    NSTextField *_para6;
    IBOutlet    NSTextField *_value6;
    IBOutlet    NSTextField *_unit6;
    IBOutlet	NSTextField *_para7;
    IBOutlet    NSTextField *_value7;
    IBOutlet    NSTextField *_unit7;
    IBOutlet    NSTextField *_para8;
    IBOutlet    NSTextField *_value8;
    IBOutlet    NSTextField *_unit8;
	IBOutlet    NSTextField *_para9;
    IBOutlet    NSTextField *_value9;
    IBOutlet    NSTextField *_unit9;
	IBOutlet	NSColorWell *_tissueColorWell;
	IBOutlet	NSColorWell *_fitColorWell;
	IBOutlet	NSTextField *_exportName;
    
    IBOutlet    NSTextField *_fileName;
    IBOutlet    NSButton *_dotTxtCheckbox;
    IBOutlet    NSButton *_dotCsvCheckbox;
    
    IBOutlet    NSButton *_saveFitToFileButton;
    IBOutlet    NSButton *closeAllButton;
	
    NSArray *_aifRoiData;
  	NSArray *_tissueRoiData;
	NSArray *_tissue;
	NSArray *_fit;
    NSArray *_time;
	
    UMMPROIRec *_tissueROIRec;
    
	BOOL alreadyExported;                               //!< a boolean whether or not the results have been exported
	
	GRDataSet *tissueDataSet;                           //!< the GRDataSet of the tissue to display it on the window
	GRDataSet *fitDataSet;                              //!< the GRDataSet of the fit to display it on the window
	        
	ViewerController *_viewer;                          //!< the PrefController knows the ViewerController the plugin is started from
	
	UMMPPanelController *_mainController;               //!< pointer to the UMMPPanelController
	
	NSArray *inputParameter;                            //!< the inputParameters that were saved in the saveInputPrameters method of the roi-pixel-advanced and model free controllers
    NSArray *outputParameter;                           //!< the presetParameters that were saved in the savePresetPrameters method of the roi-pixel-advanced and model free controllers
	NSArray *presetParameter;                           //!< the outputParameters that were saved in the saveOutputPrameters method of the roi-pixel-advanced and model free controllers
    
}

@property (retain) UMMPPanelController *mainController;
@property (retain) NSView *cmView;
@property (retain) NSTextField *name;
@property (retain) NSTextField *tracer;
@property (retain) NSTextField *para1;
@property (retain) NSTextField *value1;
@property (retain) NSTextField *unit1;
@property (retain) NSTextField *para2;
@property (retain) NSTextField *value2;
@property (retain) NSTextField *unit2;
@property (retain) NSTextField *para3;
@property (retain) NSTextField *value3;
@property (retain) NSTextField *unit3;
@property (retain) NSTextField *para4;
@property (retain) NSTextField *value4;
@property (retain) NSTextField *unit4;
@property (retain) NSTextField *para5;
@property (retain) NSTextField *value5;
@property (retain) NSTextField *unit5;
@property (retain) NSTextField *para6;
@property (retain) NSTextField *value6;
@property (retain) NSTextField *unit6;
@property (retain) NSTextField *para7;
@property (retain) NSTextField *value7;
@property (retain) NSTextField *unit7;
@property (retain) NSTextField *para8;
@property (retain) NSTextField *value8;
@property (retain) NSTextField *unit8;
@property (retain) NSTextField *para9;
@property (retain) NSTextField *value9;
@property (retain) NSTextField *unit9;
@property (retain) NSTextField *para10;
@property (retain) NSTextField *value10;
@property (retain) NSTextField *unit10;
@property (copy) NSArray *inputParameter;
@property (copy) NSArray *outputParameter;
@property (copy) NSArray *presetParameter;

/**
 the init method of the UMMPCMPanelController
 @param viewer the viewer the plugin is displayed in
 @param mainController a pointer to the used UMMPPanelController instance
 @param aifRoiData an array with the values of the aif ROI
 @param tissueROI a pointer to the used tissue UMMPROIRec
 @param tissueRoiData an array with the values of the tissue ROI
 @param tissue
 @param fit an array with the values of the fit
 @param tag the tag of the selected algorithm in UMMPAFOneAlgorithmController from all other classes its -1
 */
- (id)initWithViewer:(ViewerController *)viewer withMainController:(UMMPPanelController *)mainController andAifRoiData:(NSArray*)aifRoiData andTissueRoiRec:(UMMPROIRec*)tissueROI andTissueRoiData:(NSArray*)tissueRoiData  andTissue:(NSArray *)tissue andFit:(NSArray *)fit andTime:(NSArray *)time andAlgorithmTag:(int)tag;
- (IBAction)pushExportButton:(id)sender;

- (IBAction)pushSaveFitToFileButton:(id)sender;

/**
 a short getter method to get the "class" of the dataSet
 @return the Class of the data set
 */
- (Class) dataSetClass;

/**
 a function to save the objects in the parameter dict into the member variables of the class
 @param dict the NSMutableDictionary with the names and results of the fit and roi based calculation
 */
- (void)setResults:(NSMutableDictionary *)dict;
/**
 gets called by the IBAction method pushExportButton to export the generated report
 @param report a pointer to the generated UMMPReport instance
 @param seriesDescription a NSString with name the serie will have after the export
 @param seriesNumber the id of the exported series
 @param backgroundColor the backgroundColor of the chartView
 @param filename the directory the report will be saved to
 */
- (void)exportReport:(UMMPReport*)report andSeriesDiscription:(NSString*)seriesDescription seriesNumber:(int)seriesNumber backgroundColor:(NSColor*)backgroundColor toFile:(NSString*)filename;
	
@end
