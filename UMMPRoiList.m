//
//  UMMPRoiList.m
//  UMMPerfusion
//
//  Created by Sven Kaiser on 05.10.11.
//  Copyright (c) 2012, Marcel Reich & Sven Kaiser & Markus Daab & Patrick Schülein & Engin Aslan
//  All rights reserved.
//

#import "UMMPRoiList.h"
#import "UMMPPanelController.h"

#import <OsiriXAPI/Notifications.h>
#import <OsiriXAPI/ROI.h>

#import "GRDataSet.h"
#import "GRLineDataSet.h"

@implementation UMMPROIRec

@synthesize roi;
@synthesize viewerController;
@synthesize slice;
@synthesize timePoint;
@synthesize tag;
@synthesize meanDataSet;
@synthesize activated;

- (id)init:(ROI *)aRoi withViewerController:(ViewerController *)aViewerController onSlice:(NSInteger)aSlice atTimePoint:(NSInteger)aTimePoint withDataSet:(GRLineDataSet *)aDataSet
{
	self = [super init];
	
	roi = [aRoi retain];
    viewerController = [aViewerController retain];
	
	activated = [[NSNumber alloc] initWithBool:NO];
	
    slice = aSlice;
    timePoint = aTimePoint;
	
	tag = [[NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]] integerValue] + rand() % 100 + 1;
	
	meanDataSet = aDataSet;
	
	return self;
}


- (void)dealloc
{
    [meanDataSet release]; meanDataSet = NULL;
	
	[roi release]; roi = NULL;
	[activated release]; activated=nil;
    [viewerController release]; viewerController = NULL;
	[super dealloc];
}

- (void)computeMeanValue:(float*)mean forImageIndex:(NSInteger)index
{
    int maxMovieIndex = [viewerController maxMovieIndex];
    
    if (maxMovieIndex == 1) {
        [[[viewerController pixList] objectAtIndex:index] computeROI:roi :mean :NULL :NULL :NULL :NULL];
    } else {
        [[[viewerController pixList:index] objectAtIndex:slice] computeROI:roi :mean :NULL :NULL :NULL :NULL];        
    }
    
}

@end




@implementation UMMPRoiList

@synthesize records;
@synthesize recordsForAllRoisAlgorithm;
@synthesize externalRoiRecTag;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)awakeFromNib
{
    records = [[NSMutableArray alloc] init];
    recordsForAllRoisAlgorithm = [[NSMutableArray alloc] init];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(roiChange:) name:OsirixROIChangeNotification object:NULL];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeROI:) name:OsirixRemoveROINotification object:NULL];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[records release]; records = nil;
    [recordsForAllRoisAlgorithm release]; recordsForAllRoisAlgorithm = nil;
	[super dealloc];
}

- (void)loadViewerROIs
{
	unsigned i, j, k;
	
    ViewerController *viewerController = [controller viewerController];
        
    for (i=0; i<[viewerController maxMovieIndex]; i++) {
        
        NSArray *roiTimeList = [[controller viewerController] roiList:i];
        
        for (j=0; j<[roiTimeList count]; j++) {
            
            NSArray *roiList = [roiTimeList objectAtIndex:j];
            
            for (k=0; k< [roiList count]; k++) {
                ROI *roi = [roiList objectAtIndex:k];
                [self createRoiRecForRoi:roi withSlice:j andTimePoint:i];
            }
        }
    }
}

- (UMMPROIRec *)createRoiRecForRoi:(ROI*)roi
{
    NSInteger slice = [[[controller viewerController] imageView] curImage];
    NSInteger timePoint = [[controller viewerController] curMovieIndex];
    return [self createRoiRecForRoi:roi withSlice:slice andTimePoint:timePoint];
}

- (UMMPROIRec *)createRoiRecForRoi:(ROI*)roi withSlice:(NSInteger)slice andTimePoint:(NSInteger)timePoint
{
    ViewerController *vc = [self viewerControllerForRoi:roi];
    GRLineDataSet *dataSet = [[[controller chart] createOwnedLineDataSet] retain];
    
    UMMPROIRec *roiRec = [[UMMPROIRec alloc] init:roi withViewerController:vc onSlice:slice atTimePoint:timePoint withDataSet:dataSet];
    
    // checks if the current added ROIRec is from an external file. If this is the case --> save the tag of it
    if ([[controller prefController] extROI] == YES) {
        externalRoiRecTag = [roiRec tag];
    }
    
    if (externalRoiRecTag == [roiRec tag]) {
        [records addObject:roiRec];
        
    } else {
        [records addObject:roiRec];
        [recordsForAllRoisAlgorithm addObject:roiRec];
    }
    
    [[controller chart] addDataSet:dataSet loadData:YES];
    [[controller chart] refresh:roiRec];
	
    return roiRec;
}

- (void)roiChange:(NSNotification *)notification
{
    ROI *roi = [notification object];
    
    // rois from other viewers are not allowed
    if (![self isInViewer:roi])
        return;
	
    // can't get roiArea from roi painted with brush
    if ([[[controller viewerController] imageView] currentTool] != 20) {
        // Eliminate ROIs which have no area
        if (![roi roiArea])
            return;
    }
    
    UMMPROIRec *roiRec = [self findRecordByROI:roi];
    
    // new ROI
    if (!roiRec) {
        roiRec = [self createRoiRecForRoi:roi];
        // inform algorithmController about new ROI
        [[controller algorithmController] addROIRec:roiRec];
        // rename roi, existing roi	
    } else {
        [[controller algorithmController] changeROIRec:roiRec];
    }
    
	[[controller chart] refresh:roiRec];
}


- (UMMPROIRec *)findRecordByROI:(ROI *)roi
{
	unsigned i;
	
	for (i = 0; i < [records count]; i++) {
		UMMPROIRec * roiRec = [records objectAtIndex:i];
		if ([roiRec roi] == roi)
			return roiRec;
	}
	
	return NULL;
}


- (UMMPROIRec *)findRecordByTag:(NSInteger)tag
{
	unsigned i;
	
	for (i = 0; i < [records count]; i++) {
		UMMPROIRec * roiRec = [records objectAtIndex:i];
		if ([roiRec tag] == tag)
			return roiRec;
	}
	
	return NULL;
}


- (UMMPROIRec *)findRecordByDataSet:(GRDataSet *)dataSet
{
	unsigned i;
	
	for (i = 0; i < [records count]; i++) {
		UMMPROIRec * roiRec = [records objectAtIndex:i];
		if ([roiRec meanDataSet] == dataSet)
			return roiRec;
	}
	
	return NULL;
}

- (void)removeROI:(NSNotification *)notification
{	
	ROI *roi = [notification object];
	UMMPROIRec *roiRec = [self findRecordByROI:roi];
	
	if (roiRec) {
        [[controller chart] removeDataSet:[roiRec meanDataSet]];
		[records removeObject:roiRec];
        [recordsForAllRoisAlgorithm removeObject:roiRec];
		[[controller algorithmController] removeROIRec:roiRec];
	}
}

- (void)removeExternalRoi:(ROI *)artROI {
    ROI *roi = artROI;
	UMMPROIRec *roiRec = [self findRecordByROI:roi];
	
	if (roiRec) {
        [[controller chart] removeDataSet:[roiRec meanDataSet]];
		[records removeObject:roiRec];
		[[controller algorithmController] removeExternalROIRec:roiRec];
	}
}

- (BOOL)isInViewer:(ROI *)roi
{
	return [self isRoi:roi inViewer:[controller viewerController]];
}

- (BOOL)isRoi:(ROI *)roi inViewer:(ViewerController *)viewerController
{
    unsigned i, j;
    
    for (i=0; i<[viewerController maxMovieIndex]; i++) {
        
        NSArray *roiTimeList = [viewerController roiList:i];
        
        for (j=0; j<[roiTimeList count]; j++) {
            
            NSArray *roiList = [roiTimeList objectAtIndex:j];
            if ([roiList containsObject:roi])
                return YES;
        }
    }
	
	return NO;
}

- (ViewerController *)viewerControllerForRoi:(ROI *)roi
{
    NSMutableArray *viewerControllerList = [ViewerController get2DViewers];
    for (ViewerController *vc in viewerControllerList) {
        if ([self isRoi:roi inViewer:vc])
            return vc;
    }
    return nil;
}

@end
