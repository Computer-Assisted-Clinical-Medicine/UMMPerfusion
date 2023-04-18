//
//  UMMPRoiList.h
//  UMMPerfusion
//
//  Created by Sven Kaiser on 05.10.11.
//  Copyright (c) 2012, Marcel Reich & Sven Kaiser & Markus Daab & Patrick Schülein & Engin Aslan
//  All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OsiriXAPI/ROI.h>

@class UMMPPanelController;
@class ViewerController;
@class GRDataSet, GRLineDataSet;

/**
 a self written class to have a better ROI handling than provided by OsiriX
 */

@interface UMMPROIRec : NSObject {
	ROI *roi;                           //!< a pointer to the instance of the OsiriX ROI class which includes all informations like type and location
	NSNumber *activated;                //!< a NSNumber object to determine whether or not the ROI is checked in advanced features Controllers
    ViewerController *viewerController; //!< the viewerController in which the ROI is located
	NSInteger slice;                    //!< the slice the ROI is loacted at
	NSInteger timePoint;                //!< the timePoint the ROI is located at    
	NSInteger tag;                      //!< a generated unique tag
	GRLineDataSet *meanDataSet;         //!< each UMMPROIRec object knows it's own GRLineDataSet
}

@property (readonly) ROI *roi;
@property (readonly) ViewerController *viewerController;
@property (readonly) NSInteger tag;
@property (readwrite) NSInteger slice;
@property (readwrite) NSInteger timePoint;
@property (readonly) GRLineDataSet *meanDataSet;
@property (assign) NSNumber *activated;

/**
 an init method with all needed informations
 @param aViewerController the viewerController in which the ROI is loacted
 @param aSlice the slice on which the ROI is loacted
 @param aTimePoint the timePoint on which the ROI is loacted
 @param aDataSet the DataSet
 */
- (id)init:(ROI *)aRoi withViewerController:(ViewerController *)aViewerController onSlice:(NSInteger)aSlice atTimePoint:(NSInteger)aTimePoint withDataSet:(GRLineDataSet *)aDataSet;

/**
 a method to compute the mean value of the given ROI at the given imageIndex
 @param mean a float array where the mean value is stored into
 @param index 
 */
- (void)computeMeanValue:(float*)mean forImageIndex:(NSInteger)index;

@end

/**
 a wrapper class which saves UMMPROIRecs and provides some useful functions
 */

@interface UMMPRoiList : NSObject {
    
    NSMutableArray *records;                    //!< an array to store the UMMPROIRecs into
    
    /**
     an array to store the UMMPROIRecs without the external ROIRec. which is needed for the tissue list 
     in the allROIs function. External ROI can only used for arterial input function 
     */
    NSMutableArray *recordsForAllRoisAlgorithm;

    IBOutlet UMMPPanelController *controller;   //!< the UMMPRoiList object knows the UMMPPanelController
    
    NSInteger externalRoiRecTag;
}

@property (readonly) NSMutableArray *records;
@property (readonly) NSInteger externalRoiRecTag;
@property (readonly) NSMutableArray *recordsForAllRoisAlgorithm;

- (void)loadViewerROIs;
- (UMMPROIRec *)createRoiRecForRoi:(ROI*)roi;
- (UMMPROIRec *)createRoiRecForRoi:(ROI*)roi withSlice:(NSInteger)slice andTimePoint:(NSInteger)timePoint;
- (void)roiChange:(NSNotification *)notification;
- (void)removeROI:(NSNotification *)notification;
- (BOOL)isInViewer:(ROI *)roi;
- (BOOL)isRoi:(ROI *)roi inViewer:(ViewerController *)viewerController;
- (UMMPROIRec *)findRecordByROI:(ROI *)roi;
- (UMMPROIRec *)findRecordByTag:(NSInteger)tag;
- (UMMPROIRec *)findRecordByDataSet:(GRDataSet *)dataSet;
- (ViewerController *)viewerControllerForRoi:(ROI *)roi;

/**
 funtion to remove the external ROIrec from the record list
 */
- (void)removeExternalRoi:(ROI *)artROI;

@end
