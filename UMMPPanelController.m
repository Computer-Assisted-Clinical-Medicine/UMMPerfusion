 //
//  UMMPPanelController.m
//  UMMPerfusion
//
//  Created by Marcel Reich on 04.10.11.
//  Copyright (c) 2012, Marcel Reich & Sven Kaiser & Markus Daab & Patrick Schülein & Engin Aslan
//  All rights reserved.
//

#import "UMMPPanelController.h"
#import "UMMPRoiList.h"
#import "UMMPPrefController.h"
#import "UMMPFastDeconvolutionController.h"

#import <OsiriXAPI/Notifications.h>
#import <OsiriXAPI/Wait.h>
#import <OsiriXAPI/ViewerController.h>

#import "DCMObject.h"
#import "DCMCalendarDate.h"
#import "DCMSequenceAttribute.h"
#import "DCMAttributeTag.h"

@implementation UMMPPanelController

BOOL pluginClose = true;
@synthesize viewerController;
@synthesize filter;
@synthesize algorithmController;
@synthesize userDefaults;
@synthesize prefController;
@synthesize mapSelectionPanelController;
@synthesize viewerList;
@synthesize cmControllerList;
@synthesize algorithmPopUpButton;
@synthesize time;
@synthesize dTime;
@synthesize isShuttleMode;
@synthesize roiList;
@synthesize chart;
@synthesize drawer;
@synthesize interpolation;
@synthesize deltaT;
@synthesize max;
@synthesize selectedArterialRoiTag;
@synthesize selectedVenousRoiTag;
@synthesize selectedTissueRoiTag;
@synthesize selectedPresetTag;
@synthesize algorithmIsChoosed;
@synthesize timeArray;
@synthesize dTimeArray;

#define _PLUGIN_VERSION_ @"v1.5.3.1"

#pragma mark -
#pragma mark init and dealloc

- (id)initWithFilter:(UMMPerfusionFilter*)aFilter andViewer:(ViewerController*)aViewerController
{
    // opens the PlugIn only if the UMMPerfusion Panel is not already open
    if (pluginClose) {
        pluginClose = false;
        currentPluginVersion = _PLUGIN_VERSION_;
        filter = [aFilter retain];
        viewerController = [aViewerController retain];
        algorithmController = nil;
        userDefaults = [[UMMPUserDefaults alloc] init];
        cmControllerList = [[NSMutableArray alloc] init];
        prefController = [[UMMPPrefController alloc] initWithPanelController:[self retain]];
        selectedArterialRoiTag = -1;
        selectedVenousRoiTag = -1;
        selectedTissueRoiTag = -1;
        selectedPresetTag = -1;
        alreadyExported = NO;
        self = [super initWithWindowNibName:@"UMMPPanel"];
        //[self window];
        NSString *name = [[[NSBundle bundleForClass:[self class]] infoDictionary] valueForKey:@"CFBundleName"];
        NSString *version = [[[NSBundle bundleForClass:[self class]] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
        [[self window] setTitle:[NSString stringWithFormat:@"%@ %@", name, version]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setContent:) name:NSWindowWillCloseNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setContent:) name:OsirixCloseViewerNotification object:viewerController];
        
        // Notification when the Panel is closed
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:nil];
        
        // Sends a Notification to windowWillClose by clicking on Database in OsiriX
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewerWillClose:) name:OsirixCloseViewerNotification object:viewerController];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationOutput:) name:OsirixViewerDidChangeNotification object:nil];
        
        [roiList loadViewerROIs];
        time = (double*)calloc([viewerController maxMovieIndex]-1, sizeof(double));
        dTime = (double*)calloc([viewerController maxMovieIndex]-1, sizeof(double));
        interpolation = [self calculateTime];
        
        //check for presets or preferences in current version
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        /* ACHTUNG TEST */
        NSString* pluginVersionInList = [userDefaults string:@"UMMPPluginVersion" otherwise:nil];
        
        //NSString* pluginVersion = [defaults objectForKey:@"UMMPPluginVersion"];
        
        if (pluginVersionInList) {
            if (![pluginVersionInList isEqualToString:currentPluginVersion]) {
                int returnValue = NSRunAlertPanel(@"new Plugin Version", @"You are running a new Version of UMMPerfusion or installed it for the first time. In case you already had UMMPerfusion installed on your device, do you want to keep your old user presets?", @"change to new preset values", @"keep old preset values", nil);
                if (returnValue) {
                    [prefController removeAllPresetItems];
                    [prefController addPresetItemForNewVersion];
                } else {
                    int returnValue = NSRunAlertPanel(@"Final warning!!", @"You are using an old version of UMMPerfusion preset parameters. This may cause problems while calculating. To void this, please go to the preference window and add a new set of presets. For further information see this website: http://ikrsrv1.medma.uni-heidelberg.de/redmine/projects/ummperfusion/wiki", @"open website", @"OK", nil);
                    if (returnValue) {
                        [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:@"http://ikrsrv1.medma.uni-heidelberg.de/redmine/projects/ummperfusion/wiki"]];
                    }
                }
                
                [userDefaults setString:currentPluginVersion forKey:@"UMMPPluginVersion"];
                
                if ([defaults objectForKey:@"UMMPPluginVersion"])
                    [defaults removeObjectForKey:@"UMMPPluginVersion"];
                if ([defaults objectForKey:@"UMMPpresets"])
                    [defaults removeObjectForKey:@"UMMPpresets"];
                if ([defaults objectForKey:@"UMMPmaxIterations"])
                    [defaults removeObjectForKey:@"UMMPmaxIterations"];
                if ([defaults objectForKey:@"UMMPmapAK"])
                    [defaults removeObjectForKey:@"UMMPmapAK"];
                if ([defaults objectForKey:@"UMMPmapCS"])
                    [defaults removeObjectForKey:@"UMMPmapCS"];
                if ([defaults objectForKey:@"UMMPmapEF"])
                    [defaults removeObjectForKey:@"UMMPmapEF"];
                if ([defaults objectForKey:@"UMMPmapITT"])
                    [defaults removeObjectForKey:@"UMMPmapITT"];
                if ([defaults objectForKey:@"UMMPmapIV"])
                    [defaults removeObjectForKey:@"UMMPmapIV"];
                if ([defaults objectForKey:@"UMMPmapMTT"])
                    [defaults removeObjectForKey:@"UMMPmapMTT"];
                if ([defaults objectForKey:@"UMMPmapPF"])
                    [defaults removeObjectForKey:@"UMMPmapPF"];
                if ([defaults objectForKey:@"UMMPmapPSA"])
                    [defaults removeObjectForKey:@"UMMPmapPSA"];
                if ([defaults objectForKey:@"UMMPmapPV"])
                    [defaults removeObjectForKey:@"UMMPmapPV"];
                
            }
            
        } else {
            int returnValue = NSRunAlertPanel(@"new Plugin Version", @"You are running a new Version of UMMPerfusion or installed it for the first time. In case you already had UMMPerfusion installed on your device, do you want to keep your old user presets?", @"change to new preset values", @"keep old preset values", nil);
            if (returnValue) {
                [prefController removeAllPresetItems];
                [prefController addPresetItemForNewVersion];
            } else {
                int returnValue = NSRunAlertPanel(@"Final warning!!", @"You are using an old version of UMMPerfusion preset parameters. This may cause problems while calculating. To void this, please go to the preference window and add a new set of presets. For further information see this website: http://ikrsrv1.medma.uni-heidelberg.de/redmine/projects/ummperfusion/wiki", @"open website", @"OK", nil);
                if (returnValue) {
                    [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:@"http://ikrsrv1.medma.uni-heidelberg.de/redmine/projects/ummperfusion/wiki"]];
                }
                
            }
            
            [userDefaults setString:currentPluginVersion forKey:@"UMMPPluginVersion"];
            
            if ([defaults objectForKey:@"UMMPPluginVersion"])
                [defaults removeObjectForKey:@"UMMPPluginVersion"];
            if ([defaults objectForKey:@"UMMPpresets"])
                [defaults removeObjectForKey:@"UMMPpresets"];
            if ([defaults objectForKey:@"UMMPmaxIterations"])
                [defaults removeObjectForKey:@"UMMPmaxIterations"];
            if ([defaults objectForKey:@"UMMPmapAK"])
                [defaults removeObjectForKey:@"UMMPmapAK"];
            if ([defaults objectForKey:@"UMMPmapCS"])
                [defaults removeObjectForKey:@"UMMPmapCS"];
            if ([defaults objectForKey:@"UMMPmapEF"])
                [defaults removeObjectForKey:@"UMMPmapEF"];
            if ([defaults objectForKey:@"UMMPmapITT"])
                [defaults removeObjectForKey:@"UMMPmapITT"];
            if ([defaults objectForKey:@"UMMPmapIV"])
                [defaults removeObjectForKey:@"UMMPmapIV"];
            if ([defaults objectForKey:@"UMMPmapMTT"])
                [defaults removeObjectForKey:@"UMMPmapMTT"];
            if ([defaults objectForKey:@"UMMPmapPF"])
                [defaults removeObjectForKey:@"UMMPmapPF"];
            if ([defaults objectForKey:@"UMMPmapPSA"])
                [defaults removeObjectForKey:@"UMMPmapPSA"];
            if ([defaults objectForKey:@"UMMPmapPV"])
                [defaults removeObjectForKey:@"UMMPmapPV"];
            
        }
        
        //check for 32bit pipeline
        _32bitPipeline = [[[NSUserDefaults standardUserDefaults] objectForKey:@"FULL32BITPIPELINE"] boolValue];
        
        if (_32bitPipeline) {
            int returnValue = NSRunAlertPanel(@"issue with 32bit pipeline", @"32bit pipeline is activated. To avoid circular artifacts you can turn it off ", @"turn off", @"keep settings", nil);
            if (returnValue) {
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"FULL32BITPIPELINE"];
                //NSLog(@"tried to set 32bit pipeline to NO");
            }
        }
        
        [prefController initValues];
        return self;
    }
    // Alert by trying to open another Panel when a Panel is already open
    NSRunAlertPanel(@"UMMPerfusion Panel already open", @"Only one Panel can be used at the same time", @"OK", nil, nil);
    return -1;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[filter release]; filter = NULL;
	[viewerController release]; viewerController = nil;
    [cmControllerList release]; self.cmControllerList = nil;
	[userDefaults release]; self.userDefaults = nil;
	if (currentPluginVersion) {
		[currentPluginVersion release]; self->currentPluginVersion=nil;
	}
    if (time) free(time);
    if (dTime) free(dTime);
	[[NSNotificationCenter defaultCenter] removeObserver:self];
  	[super dealloc];
}


- (void)awakeFromNib {
	// to hide headline in menu
	[menuItem1 setTarget:self];
	[menuItem2 setTarget:self];
	[menuItem3 setTarget:self];
    [menuItem4 setTarget:self];
}

#pragma mark -
#pragma mark Notifications

// method which close the UMMPanel plugin
- (void)windowWillClose:(NSNotification *)notification
{
    
    if ([notification object] == [self window]) {
        int i;
        int counter = [cmControllerList count];
        for (i=0; i<counter; i++)
        {
            [[[cmControllerList objectAtIndex:0] window] close];
        }
        
        [[algorithmController mapSelectionPanel] close];
        chart.stopDraw = YES;
        [[mapSelectionPanelController window] release];
        [mapSelectionPanelController release];
        [[prefController window] close];
        [[self window] release];
		[self release];
        
        pluginClose = true;
    }
}


// This method deselect all ROIs before taking screenshot for the report
- (void) deselectAllRois {
    
    unsigned i, j, k;
    
    for (i=0; i<[viewerController maxMovieIndex]; i++) {
        NSArray *roiTimeList = [[self viewerController] roiList:i];
        
        for (j=0; j<[roiTimeList count]; j++) {
            NSArray *roisList = [roiTimeList objectAtIndex:j];
            
            for (k=0; k< [roisList count]; k++) {
                ROI *roi = [roisList objectAtIndex:k];
                [roi setROIMode:ROI_sleep];
            }
        }
    }
}


- (void)notificationOutput:(NSNotification *)notification
{
    NSLog(@"%@", [notification object]);
}

- (void)viewerWillClose:(NSNotification *)notification
{
	[[self window] close];
}


#pragma mark -
#pragma mark IBActions


- (IBAction)pushCloseAllViewersButton:(id)sender
{
    int i;
    int counter = [viewerList count];
    for (i=0; i<counter; i++)
    {
        [[[[[viewerList viewers] objectAtIndex:0] viewer] window] orderOut:self];
        [[[[[viewerList viewers] objectAtIndex:0] viewer] window] close];
    }
    counter = [cmControllerList count];
    for (i=0; i<counter; i++)
    {
        [[[cmControllerList objectAtIndex:0] window] close];
    }
    
    [cmControllerList release]; cmControllerList = NULL;
    cmControllerList = [[NSMutableArray alloc] init];
    
}


- (IBAction)viewChoicePopupAction:(id)sender
{
    NSMenuItem *item = sender;
	[self changeView:[item tag]];
}


- (IBAction)pushPrefButton:(id)sender
{
    NSWindow *prefWindow = [prefController window];
    if (![prefWindow isVisible]) {
        [prefWindow makeKeyAndOrderFront:sender];
    }
}

- (IBAction)pushGenerateButton:(id)sender
{
	if ([algorithmController checkUserInput]) {
		alreadyExported = NO;
		[[algorithmController inputParameter] removeAllObjects];
		[[algorithmController outputParameter] removeAllObjects];
		[[algorithmController presetParameter] removeAllObjects];
		
		[algorithmController saveInputParameter:nil andAlgorithmName:nil];
		[algorithmController savePresetParameter:-1];
        
		[algorithmController startCalculation:nil andAlgorithmTag:-1];
        
		[algorithmController saveOutputParameter:-1];
		if ([[algorithmController autosaveCheckButton] state]) {
			if ([algorithmController class] == [UMMPFastDeconvolutionController class]) {
				[self pushExportButton:nil];
			}
		}
	}
}


-(IBAction)pushGenerateAllMapsButton:(id)sender
{
    if ([algorithmController checkUserInput]) {
        [self pushCloseAllViewersButton:nil];
        int taskCounter = 0, validationCounterForMapSel = 0;
        
        //Text for Information-Panel with content of selected maps (selected for calculation and export)
        NSMutableString *outputString =[NSMutableString stringWithString:@"The following maps will be calculated and exported:\n"];
        if([userDefaults int:@"UMMPcompartmentMapPF" otherwise:NO] || [userDefaults int:@"UMMPcompartmentMapPMTT" otherwise:NO] || [userDefaults int:@"UMMPcompartmentMapPV" otherwise:NO] || [userDefaults int:@"UMMPcompartmentMapAFE" otherwise:NO] || [ userDefaults int:@"UMMPcompartmentMapCS" otherwise:NO])
        {
            [outputString appendString:@"1-Compartment:\n"];
            validationCounterForMapSel++;
        }
        if([userDefaults int:@"UMMPcompartmentMapPF" otherwise:NO]) [outputString appendString:@"\tPlasma Flow\n"];
        if([userDefaults int:@"UMMPcompartmentMapPMTT" otherwise:NO]) [outputString appendString:@"\tPlasma Meant Transit Time\n"];
        if([userDefaults int:@"UMMPcompartmentMapPV" otherwise:NO]) [outputString appendString:@"\tPlasma Volume\n"];
        if([userDefaults int:@"UMMPcompartmentMapAFE" otherwise:NO]) [outputString appendString:@"\tCorrected Akaike Information Criterion\n"];
        if([userDefaults int:@"UMMPcompartmentMapCS" otherwise:NO]) [outputString appendString:@"\tChi Square\n"];
        if([ userDefaults int:@"UMMPexchangeMapPF" otherwise:NO] || [ userDefaults int:@"UMMPexchangeMapPMTT" otherwise:NO] || [ userDefaults int:@"UMMPexchangeMapPV" otherwise:NO] || [ userDefaults int:@"UMMPexchangeMapIMTT" otherwise:NO] || [ userDefaults int:@"UMMPexchangeMapIV" otherwise:NO] || [ userDefaults int:@"UMMPexchangeMapEF"otherwise:NO] || [ userDefaults int:@"UMMPexchangeMapPSAP"otherwise:NO] || [ userDefaults int:@"UMMPexchangeMapAFE" otherwise:NO] || [ userDefaults int:@"UMMPexchangeMapCS" otherwise:NO])
        {
            [outputString appendString:@"2-Compartment Exchange:\n"];
            validationCounterForMapSel++;
        }
        if([userDefaults int:@"UMMPexchangeMapPF" otherwise:NO]) [outputString appendString:@"\tPlasma Flow\n"];
        if([userDefaults int:@"UMMPexchangeMapPMTT" otherwise:NO]) [outputString appendString:@"\tPlasma Mean Transit Time\n"];
        if([userDefaults int:@"UMMPexchangeMapPV" otherwise:NO]) [outputString appendString:@"\tPlasma Volume\n"];
        if([userDefaults int:@"UMMPexchangeMapIMTT" otherwise:NO]) [outputString appendString:@"\tInterstitial Mean Transit Time\n"];
        if([userDefaults int:@"UMMPexchangeMapIV" otherwise:NO]) [outputString appendString:@"\tInterstitial Volume\n"];
        if([userDefaults int:@"UMMPexchangeMapEF" otherwise:NO]) [outputString appendString:@"\tExtraction Fraction\n"];
        if([userDefaults int:@"UMMPexchangeMapPSAP" otherwise:NO]) [outputString appendString:@"\tPermeable Surface Area Product\n"];
        if([userDefaults int:@"UMMPexchangeMapAFE" otherwise:NO]) [outputString appendString:@"\tCorrected Akaike Information Criterion\n"];
        if([userDefaults int:@"UMMPexchangeMapCS" otherwise:NO]) [outputString appendString:@"\tChi Square\n"];
        if ([ userDefaults int:@"UMMPfiltrationMapPF" otherwise:NO] || [ userDefaults int:@"UMMPfiltrationMapPMTT" otherwise:NO] || [ userDefaults int:@"UMMPfiltrationMapPV" otherwise:NO] || [ userDefaults int:@"UMMPfiltrationMapIMTT" otherwise:NO] || [ userDefaults int:@"UMMPfiltrationMapEF" otherwise:NO] || [ userDefaults int:@"UMMPfiltrationMapPSAP"otherwise:NO] || [ userDefaults int:@"UMMPfiltrationMapAFE"otherwise:NO] || [ userDefaults int:@"UMMPfiltrationMapCS" otherwise:NO])
        {
            [outputString appendString:@"2-Compartment Filtration:\n"];
            validationCounterForMapSel++;
        }
        if([userDefaults int:@"UMMPfiltrationMapPF" otherwise:NO]) [outputString appendString:@"\tPlasma Flow\n"];
        if([userDefaults int:@"UMMPfiltrationMapPMTT" otherwise:NO]) [outputString appendString:@"\tPlasma Mean Transit Time\n"];
        if([userDefaults int:@"UMMPfiltrationMapPV" otherwise:NO]) [outputString appendString:@"\tPlasma Volume\n"];
        if([userDefaults int:@"UMMPfiltrationMapIMTT" otherwise:NO]) [outputString appendString:@"\tInterstitial Mean Transit Time\n"];
        if([userDefaults int:@"UMMPfiltrationMapEF" otherwise:NO]) [outputString appendString:@"\tExtraction Fraction\n"];
        if([userDefaults int:@"UMMPfiltrationMapPSAP" otherwise:NO]) [outputString appendString:@"\tTubular Flow\n"];
        if([userDefaults int:@"UMMPfiltrationMapAFE" otherwise:NO]) [outputString appendString:@"\tCorrected Akaike Information Criterion\n"];
        if([userDefaults int:@"UMMPfiltrationMapCS" otherwise:NO]) [outputString appendString:@"\tChi Square\n"];
        if ([ userDefaults int:@"UMMPuptakeMapPF" otherwise:NO] || [ userDefaults int:@"UMMPuptakeMapPMTT"otherwise:NO] || [ userDefaults int:@"UMMPuptakeMapPV"otherwise:NO] || [ userDefaults int:@"UMMPuptakeMapEF"otherwise:NO] || [ userDefaults int:@"UMMPuptakeMapPSAP"otherwise:NO]|| [ userDefaults int:@"UMMPuptakeMapAFE"otherwise:NO] || [ userDefaults int:@"UMMPuptakeMapCS"otherwise:NO])
        {
            [outputString appendString:@"2-Compartment Uptake:\n"];
            validationCounterForMapSel++;
        }
        if([userDefaults int:@"UMMPuptakeMapPF" otherwise:NO]) [outputString appendString:@"\tPlasma Flow\n"];
        if([userDefaults int:@"UMMPuptakeMapPMTT" otherwise:NO]) [outputString appendString:@"\tPlasma Mean Transit Time\n"];
        if([userDefaults int:@"UMMPuptakeMapPV" otherwise:NO]) [outputString appendString:@"\tPlasma Volume\n"];
        if([userDefaults int:@"UMMPuptakeMapEF" otherwise:NO]) [outputString appendString:@"\tExtraction Fraction\n"];
        if([userDefaults int:@"UMMPuptakeMapPSAP" otherwise:NO]) [outputString appendString:@"\tPermeable Surface Area Product\n"];
        if([userDefaults int:@"UMMPuptakeMapAFE" otherwise:NO]) [outputString appendString:@"\tCorrected Akaike Information Criterion\n"];
        if([userDefaults int:@"UMMPuptakeMapCS" otherwise:NO]) [outputString appendString:@"\tChi Square\n"];
        if ([ userDefaults int:@"UMMPtoftsMapPV"otherwise:NO] || [ userDefaults int:@"UMMPtoftsMapIMTT"otherwise:NO] || [ userDefaults int:@"UMMPtoftsMapIV" otherwise:NO] || [ userDefaults int:@"UMMPtoftsMapPSAP"otherwise:NO] || [ userDefaults int:@"UMMPtoftsMapAFE"otherwise:NO] || [ userDefaults int:@"UMMPtoftsMapCS"otherwise:NO])
        {
            [outputString appendString:@"Modified Tofts:\n"];
            validationCounterForMapSel++;
        }
        if([userDefaults int:@"UMMPtoftsMapPV" otherwise:NO]) [outputString appendString:@"\tPlasma Volume\n"];
        if([userDefaults int:@"UMMPtoftsMapIMTT" otherwise:NO]) [outputString appendString:@"\tInterstitial Mean Transit Time\n"];
        if([userDefaults int:@"UMMPtoftsMapIV" otherwise:NO]) [outputString appendString:@"\tInterstitial Volume\n"];
        if([userDefaults int:@"UMMPexchangeMapEF" otherwise:NO]) [outputString appendString:@"\tExtraction Fraction\n"];
        if([userDefaults int:@"UMMPtoftsMapPSAP" otherwise:NO]) [outputString appendString:@"\tKtrans\n"];
        if([userDefaults int:@"UMMPtoftsMapAFE" otherwise:NO]) [outputString appendString:@"\tCorrected Akaike Information Criterion\n"];
        if([userDefaults int:@"UMMPtoftsMapCS" otherwise:NO]) [outputString appendString:@"\tChi Square\n"];
        [outputString appendString:@"\n\nRemember, you can change the map selection settings. Just click on the \"settings\"-menu on the top right corner of the plugin's main window."];
        
        if(validationCounterForMapSel){
            //will return to panel when hitting cancel
            int returnValue = NSRunInformationalAlertPanel(@"List of used maps", outputString, @"OK", @"Cancel", nil);
            if (!returnValue) {
                return;
            }
        }
        else {
            NSRunAlertPanel(@"No maps selected", @"No maps selected. You can change the map selection settings by clicking on the \"settings\"-menu on the top right corner of the plugin's main window.", @"Return to plugin", nil, nil);
            return;
        }
        
        
        
		Wait *splash =nil;
        splash = [[Wait alloc] initWithString:NSLocalizedString(@"Overall progress in map calculation", nil)];
        [splash showWindow:self];
        [[splash progress] setMaxValue:15];
        [splash setCancel: NO];
        
        [splash setElapsedString:@"calculating Maps" ];
        
		int i;
		NSInteger tissueRoiTag = [[algorithmController tissueButton] selectedTag];
		UMMPROIRec *roiRec = [roiList findRecordByTag:tissueRoiTag];
		for(i=0; i<5; i++)
		{
            BOOL isOK = NO;
            switch (i) {
                case 0:
                    if ([userDefaults int:@"UMMPcompartmentMapPF" otherwise:NO] || [userDefaults int:@"UMMPcompartmentMapPMTT" otherwise:NO] || [userDefaults int:@"UMMPcompartmentMapPV" otherwise:NO] || [userDefaults int:@"UMMPcompartmentMapAFE" otherwise:NO] || [ userDefaults int:@"UMMPcompartmentMapCS" otherwise:NO]) {
                        isOK = YES;
                    }
                    break;
                case 1:
                    if ([ userDefaults int:@"UMMPexchangeMapPF" otherwise:NO] || [ userDefaults int:@"UMMPexchangeMapPMTT" otherwise:NO] || [ userDefaults int:@"UMMPexchangeMapPV" otherwise:NO] || [ userDefaults int:@"UMMPexchangeMapIMTT" otherwise:NO] || [ userDefaults int:@"UMMPexchangeMapIV" otherwise:NO] || [ userDefaults int:@"UMMPexchangeMapEF"otherwise:NO] || [ userDefaults int:@"UMMPexchangeMapPSAP"otherwise:NO] || [ userDefaults int:@"UMMPexchangeMapAFE" otherwise:NO] || [ userDefaults int:@"UMMPexchangeMapCS" otherwise:NO]) {
                        isOK = YES;
                    }
                    break;
                case 2:
                    if ([ userDefaults int:@"UMMPfiltrationMapPF" otherwise:NO] || [ userDefaults int:@"UMMPfiltrationMapPMTT" otherwise:NO] || [ userDefaults int:@"UMMPfiltrationMapPV" otherwise:NO] || [ userDefaults int:@"UMMPfiltrationMapIMTT" otherwise:NO] || [ userDefaults int:@"UMMPfiltrationMapEF" otherwise:NO] || [ userDefaults int:@"UMMPfiltrationMapPSAP"otherwise:NO] || [ userDefaults int:@"UMMPfiltrationMapAFE"otherwise:NO] || [ userDefaults int:@"UMMPfiltrationMapCS" otherwise:NO]) {
                        isOK = YES;
                        
                    }
                    break;
                case 3:
                    if ([ userDefaults int:@"UMMPuptakeMapPF" otherwise:NO] || [ userDefaults int:@"UMMPuptakeMapPMTT"otherwise:NO] || [ userDefaults int:@"UMMPuptakeMapPV"otherwise:NO] || [ userDefaults int:@"UMMPuptakeMapEF"otherwise:NO] || [ userDefaults int:@"UMMPuptakeMapPSAP"otherwise:NO]|| [ userDefaults int:@"UMMPuptakeMapAFE"otherwise:NO] || [ userDefaults int:@"UMMPuptakeMapCS"otherwise:NO]) {
                        isOK = YES;
                    }
                    break;
                case 4:
                    if ([ userDefaults int:@"UMMPtoftsMapPV"otherwise:NO] || [ userDefaults int:@"UMMPtoftsMapIMTT"otherwise:NO] || [ userDefaults int:@"UMMPtoftsMapIV" otherwise:NO] || [ userDefaults int:@"UMMPtoftsMapPSAP"otherwise:NO] || [ userDefaults int:@"UMMPtoftsMapAFE"otherwise:NO] || [ userDefaults int:@"UMMPtoftsMapCS"otherwise:NO]) {
                        isOK = YES;
                        
                    }
                    break;
                    
                default:
                    break;
            }
            
			[[algorithmController inputParameter] removeAllObjects];
			[[algorithmController outputParameter] removeAllObjects];
			[[algorithmController presetParameter] removeAllObjects];
			
			switch (i) {
				case 0:
					[algorithmController saveInputParameter:roiRec andAlgorithmName:@"Compartment"];
                    [splash setElapsedString:@"calculating \"Compartment Maps\"" ];
                    break;
				case 1:
					[algorithmController saveInputParameter:roiRec andAlgorithmName:@"2C Exchange"];
                    [splash setElapsedString:@"calculating \"2-Compartment Exchange Maps\"" ];
                    break;
				case 2:
					[algorithmController saveInputParameter:roiRec andAlgorithmName:@"2C Filtration"];
                    [splash setElapsedString:@"calculating \"2-Compartment Filtration Maps\"" ];
                    break;
				case 3:
					[algorithmController saveInputParameter:roiRec andAlgorithmName:@"2C Uptake"];
                    [splash setElapsedString:@"calculating \"2-Compartment Uptake Maps\"" ];
                    break;
				case 4:
					[algorithmController saveInputParameter:roiRec andAlgorithmName:@"Modified Tofts"];
                    [splash setElapsedString:@"calculating \"Modified Tofts Maps\"" ];
                    break;
				default:
					break;
			}
            if (isOK) {
                taskCounter++;
                [algorithmController savePresetParameter:i];}
            [splash incrementBy:1];
            if (isOK) {[algorithmController startCalculation:roiRec andAlgorithmTag:i];}
            [splash incrementBy:1];
            alreadyExported = NO;
            //[viewerController resetImage:viewerController];
            
            if (isOK) {
                [self pushExportButton:nil];
            }
            
            [self pushCloseAllViewersButton:nil];
            //[viewerController resetImage:viewerController];
            [splash incrementBy:1];
		}
        
        [splash close];
        [splash release];
        
        if([userDefaults int:@"soundOnAllMapsCalcEnd" otherwise:NO]){
            if(taskCounter){
                NSSpeechSynthesizer *mySpeechSynth = [[NSSpeechSynthesizer alloc] initWithVoice:nil];
                [mySpeechSynth startSpeakingString:@"Calculation has been completed. All Maps have been exported."];
                [mySpeechSynth release];
            }
            else{
                NSSpeechSynthesizer *mySpeechSynth = [[NSSpeechSynthesizer alloc] initWithVoice:nil];
                [mySpeechSynth startSpeakingString:@"No tasks to perform. Select some maps first!"];
                [mySpeechSynth release];
                
            }
        }
	}
    
    
}

-(IBAction)pushGenerateButtonOneAlgorithm:(id)sender
{
	
	if ([algorithmController checkUserInput]) {
		alreadyExported = NO;
		
		NSMutableArray *records = [roiList records];
		
		for (UMMPROIRec *roiRec in records) {
			if ([[roiRec activated] boolValue]) {
				
				[[algorithmController inputParameter] removeAllObjects];
				[[algorithmController outputParameter] removeAllObjects];
				[[algorithmController presetParameter] removeAllObjects];
				
				[algorithmController saveInputParameter:roiRec andAlgorithmName:nil];
                [algorithmController savePresetParameter:-1];
                [algorithmController startCalculation:roiRec andAlgorithmTag:-1];
                [algorithmController saveOutputParameter:-1];
				
            }
        }
        
        if ([[algorithmController autosaveCheckButton] state]) {
            [self pushExportAllButton:nil];
        }
        
    }
}

-(IBAction)pushGenerateButtonOneROI:(id)sender
{
	if ([algorithmController checkUserInput]) {
		alreadyExported = NO;
        
		int i;
		NSInteger tissueRoiTag = [[algorithmController tissueButton] selectedTag];
		UMMPROIRec *roiRec = [roiList findRecordByTag:tissueRoiTag];
		for(i=0; i<6; i++)
		{
			[[algorithmController inputParameter] removeAllObjects];
			[[algorithmController outputParameter] removeAllObjects];
			[[algorithmController presetParameter] removeAllObjects];
			
			switch (i) {
				case 0:
					[algorithmController saveInputParameter:roiRec andAlgorithmName:@"Compartment"];
                    [algorithmController savePresetParameter:i];
                    [algorithmController startCalculation:roiRec andAlgorithmTag:i];
                    [algorithmController saveOutputParameter:i];
					break;
				case 1:
					[algorithmController saveInputParameter:roiRec andAlgorithmName:@"2C Exchange"];
                    [algorithmController savePresetParameter:i];
                    [algorithmController startCalculation:roiRec andAlgorithmTag:i];
                    [algorithmController saveOutputParameter:i];
					break;
				case 2:
					[algorithmController saveInputParameter:roiRec andAlgorithmName:@"2C Filtration"];
                    [algorithmController savePresetParameter:i];
                    [algorithmController startCalculation:roiRec andAlgorithmTag:i];
                    [algorithmController saveOutputParameter:i];
					break;
				case 3:
					[algorithmController saveInputParameter:roiRec andAlgorithmName:@"2C Uptake"];
                    [algorithmController savePresetParameter:i];
                    [algorithmController startCalculation:roiRec andAlgorithmTag:i];
                    [algorithmController saveOutputParameter:i];
					break;
				case 4:
					[algorithmController saveInputParameter:roiRec andAlgorithmName:@"Modified Tofts"];
                    [algorithmController savePresetParameter:i];
                    [algorithmController startCalculation:roiRec andAlgorithmTag:i];
                    [algorithmController saveOutputParameter:i];
					break;
                case 5:
					[algorithmController saveInputParameter:roiRec andAlgorithmName:@"2Inlet 2C Uptake"];
                    [algorithmController savePresetParameter:i];
                    [algorithmController startCalculation:roiRec andAlgorithmTag:i];
                    [algorithmController saveOutputParameter:i];
					break;
				default:
					break;
			}
            
		}
        if ([[algorithmController autosaveCheckButton] state]) {
            [self pushExportAllButton:nil];
        }
        
	}
	
	
}

- (IBAction)pushExportButton:(id)sender
{
	if (!alreadyExported) {
		[algorithmController exportResults];
		alreadyExported = YES;
	}
    
	else {
		NSRunAlertPanel(@"too many exports", @"Results have already been exported", @"OK", nil, nil);
	}
}

- (IBAction)pushExportAllButton:(id)sender{
    
    Wait *splash = nil;
    splash = [[Wait alloc] initWithString:NSLocalizedString(@"Saving all results...", nil)];
    [splash showWindow:self];
    [[splash progress] setMaxValue: [cmControllerList count]-1];
    [splash setCancel: NO];
    
    
    
    for (UMMPCMPanelController *cmc in cmControllerList) {
        [cmc pushExportButton:nil];
        [splash incrementBy: 1];
    }
    
    [splash close];
    [splash release];
    
}

- (IBAction)pushHelpButton:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:@"http://ikrsrv1.medma.uni-heidelberg.de/redmine/projects/ummperfusion/wiki"]];
}

#pragma mark -
#pragma mark other methods



- (void)changeView:(NSInteger)whichViewTag
{
	NSView *view;
	switch (whichViewTag) {
        case fastDeconvolutionTag:
			view = fastDeconvolutionView;
            algorithmController = fastDeconvolutionController;
			[algorithmPopUpButton setTitle:@"Fast Deconvolution"];
			_panelSize.width=255;
			_panelSize.height=430;
			break;
        case compartmentRoiTag:
            view = roiBasedView;
            algorithmController = roiBasedController;
            [algorithmPopUpButton setTitle:@"Compartment"];
			_panelSize.width=255;
			_panelSize.height=480;
            break;
        case exchangeRoiTag:
            view = roiBasedView;
            algorithmController = roiBasedController;
            [algorithmPopUpButton setTitle:@"2-C Exchange"];
			_panelSize.width=255;
			_panelSize.height=480;
            break;
        case filtrationRoiTag:
			view = roiBasedView;
            algorithmController = roiBasedController;
            [algorithmPopUpButton setTitle:@"2-C Filtration"];
			_panelSize.width=255;
			_panelSize.height=480;
			break;
        case uptakeRoiTag:
            view = roiBasedView;
            algorithmController = roiBasedController;
            [algorithmPopUpButton setTitle:@"2-C Uptake"];
			_panelSize.width=255;
			_panelSize.height=480;
            break;
        case modifiedToftsRoiTag:
			view = roiBasedView;
            algorithmController = roiBasedController;
            [algorithmPopUpButton setTitle:@"Modified Tofts"];
			_panelSize.width=255;
			_panelSize.height=480;
			break;
        case compartmentMapTag:
            view = pixelBasedMapView;
            algorithmController = pixelBasedMapController;
            [algorithmPopUpButton setTitle:@"Compartment"];
			_panelSize.width=255;
			_panelSize.height=480;
            break;
		case exchangeMapTag:
            view = pixelBasedMapView;
            algorithmController = pixelBasedMapController;
            [algorithmPopUpButton setTitle:@"2-C Exchange"];
			_panelSize.width=255;
			_panelSize.height=480;
            break;
        case filtrationMapTag:
			view = pixelBasedMapView;
            algorithmController = pixelBasedMapController;
            [algorithmPopUpButton setTitle:@"2-C Filtration"];
			_panelSize.width=255;
			_panelSize.height=480;
			break;
        case uptakeMapTag:
            view = pixelBasedMapView;
            algorithmController = pixelBasedMapController;
            [algorithmPopUpButton setTitle:@"2-C Uptake"];
			_panelSize.width=255;
			_panelSize.height=480;
            break;
        case modifiedToftsMapTag:
			view = pixelBasedMapView;
            algorithmController = pixelBasedMapController;
            [algorithmPopUpButton setTitle:@"Modified Tofts"];
			_panelSize.width=255;
			_panelSize.height=480;
			break;
       	case allROIsTag:
			view = afOneAlgorithmView;
			algorithmController = afOneAlgorithmController;
			[algorithmPopUpButton setTitle:@"all ROIs"];
			_panelSize.width=257;
			_panelSize.height=532;
			break;
		case allAlgorithmsTag:
			view = afOneROIView;
			algorithmController = afOneROIController;
			[algorithmPopUpButton setTitle:@"all algorithms"];
			_panelSize.width=257;
			_panelSize.height=461;
			break;
        case allMapsTag:
			view = afAllMapsView;
			algorithmController = afAllMapsController;
			[algorithmPopUpButton setTitle:@"all maps"];
			_panelSize.width=257;
			_panelSize.height=559;
            if ([ userDefaults bool:@"UMMPshowOldMapsWillBeClosedDialog" otherwise:YES ])
            {
                /* Alert for closing all windows */
                int ret = NSRunAlertPanel(@"Confirm action", @"Starting the \"all maps\"-algorithm will close all viewers except for the original viewer. \n ",@"OK",@"Don't show this message again",nil);
                if(ret == -1) NSLog(@"message returned 0");//[userDefaults setBool:YES forKey:@"UMMPshowOldMapsWillBeClosedDialog"];      //case: OK
                else if(ret == 0) [userDefaults setBool:NO forKey:@"UMMPshowOldMapsWillBeClosedDialog"];   //case: don't show this message again
            }
			break;
        case twoComp2InletUptakeRoiTag:
            view = twoComp2InletUptakeRoiBasedView;
            algorithmController = twoComp2InletUptakeRoiBasedController;
            [algorithmPopUpButton setTitle:@"2-C 2-Inlet Uptake Roi"];
			_panelSize.width=252;
			_panelSize.height=504;
            break;
        case twoComp2InletUptakePixelTag:
            view = twoComp2InletUptakePixelBasedView;
            algorithmController = twoComp2InletUptakePixelBasedController;
            [algorithmPopUpButton setTitle:@"2-C 2-Inlet Uptake Pixel"];
			_panelSize.width=255;
			_panelSize.height=510;
            break;
		default:
            view = nil;
            break;
            
	}
	[algorithmController loadROIRecs:[roiList records]];
    [algorithmController selectUserROIs];
    [algorithmController loadPresets:[prefController presets]];
    [algorithmController selectUserPreset];
	[[self window] setContentSize:_panelSize];
    [chart setNeedsDisplay:YES];
	[[self window] setContentView:[[[NSView alloc] initWithFrame:[view frame]] autorelease]];
	[[self window] setContentView:view];
    algorithmIsChoosed = YES;
    
    [algorithmController drawSelectedROIRecs];
}


- (NSString *)getStringValueForDicomTag:(NSString *)dicomTag
{
    return [self getStringValueForDicomTag:dicomTag atTimePoint:0];
}


- (NSString *)getStringValueForDicomTag:(NSString *)dicomTag atTimePoint:(int)timePoint
{
    NSString *filePath= [[[viewerController pixList:timePoint] objectAtIndex:0] sourceFile];
    DCMObject *dcmObject = [DCMObject objectWithContentsOfFile:filePath decodingPixelData:NO];
    
    DCMAttributeTag *dcmAttributeTag = [DCMAttributeTag tagWithTagString:dicomTag];
    if (dcmAttributeTag && dcmAttributeTag.group && dcmAttributeTag.element)
    {
        DCMAttribute *dcmAttribute = [dcmObject attributeForTag:dcmAttributeTag];
        return [[dcmAttribute value] description];
    }
    
    return nil;
}

- (NSString *)getStringValueForDicomTag:(NSString *)dicomTag atTimePoint:(int)timePoint atSlice:(int)slice
{
    NSString *filePath= [[[viewerController pixList:timePoint] objectAtIndex:slice] sourceFile];
    DCMObject *dcmObject = [DCMObject objectWithContentsOfFile:filePath decodingPixelData:NO];
    
    DCMAttributeTag *dcmAttributeTag = [DCMAttributeTag tagWithTagString:dicomTag];
    if (dcmAttributeTag && dcmAttributeTag.group && dcmAttributeTag.element)
    {
        DCMAttribute *dcmAttribute = [dcmObject attributeForTag:dcmAttributeTag];
        return [[dcmAttribute value] description];
    }
    
    return nil;
}

- (BOOL)calculateTime
{
    
    BOOL interpolate;
    
    NSString *manufacturerTag = [NSString stringWithFormat:@"%04X,%04X", 0X0008, 0X0070];
    NSString *manufacturerVal = [self getStringValueForDicomTag:manufacturerTag];
    NSString *modalityTag     = [NSString stringWithFormat:@"%04X,%04X", 0X0008, 0X0060];
    NSString *modalityVal     = [self getStringValueForDicomTag:modalityTag];
    
    if ([manufacturerVal isEqualToString:@"OsiriX"])
    {
        printf( "Manufacturer: OsiriX\n" );
        [self calculateTimeUsingAcquisitionTime2D];
    }
    
    else if ([manufacturerVal isEqualToString:@"SIEMENS"])
    {
        printf( "Manufacturer: SIEMENS\n" );
        if ([modalityVal isEqualToString:@"MR"])
        {
            [self calculateTimeUsingAcquisitionTime2D];
            printf( "Modality: SIEMENS - MRI\n" );
        }
        else if ([modalityVal isEqualToString:@"CT"])
        {
            //[self calculateTimeForShuttleMode]; // was commented out
            // DCMAttributeTag *scanOptionsTag = [DCMAttributeTag  tagWithTagString:@"%04X,%04X", 0X0018, 0X0022];
            NSString *filePath= [[[viewerController pixList:0] objectAtIndex:0] sourceFile];
            DCMObject *dcmObject = [DCMObject objectWithContentsOfFile:filePath decodingPixelData:NO];
            
            DCMSequenceAttribute *scanOptionsValue = (DCMSequenceAttribute *)[dcmObject attributeWithName:@"ScanOptions"];
            adaptive4DSpiralValue = scanOptionsValue.values[1] ;
            
            
            
            //######################################################--Adaptive-4D-Spiral--##########################################################//
            //  Part 1/3:
            //  This section defines necessary actions to consider individual time stamps for "Adaptive 4D Spiral". (Siemens Somatom Force Dual Source CT)
            
            
            
            if ([adaptive4DSpiralValue isEqualToString:@"A4DS"]){
                printf( "Modality: SIEMENS - DCE-CT, A4DS (shuttle mode)\n" );
                NSLog(@"Images were acquired with an Adaptive 4D Spiral (Shuttle Mode). Deconvolution is not supported for this type due to inhomogeneous temporal resolution.");
                // [self calculateTimeUsingAcquisitionTime]; // Original Calculation Method
                [self calculateTimeUsingAcquisitionTime2D]; // Calculation Method for 4D CT, via 2D Array
                //deltaT= -0.00;
                
            }
            
            // weitere To-Dos:
            // Erfassung der Zeitstempel jedes Bildes jeder Schicht:
            //
            //      - der Vektor/ das Array muss angepasst werden, dass nicht nur der Zeitverlauf EINER Schicht aufgenommen wird, sondern für jede Schicht einzeln.
            //        beispielsweise alles hintereinander weg in einem Vektor, oder separiert in Zeilen und Spalten eines Vektors.
            //        Hierzu die Methode  "saveAcquistionTimeToFile:(int)n " betrachten, mit der habe ich testweise die Zeiten ausgelesen
            //        und zur Untersuchung des Shuttle-Verhaltens in ein Excel-Sheet exportiert. Aufruf über:       [self saveAcquistionTimeToFile:n];
            //
            //      - @ Frank fragen: Passt die Anwendung der Modelle dann noch? oder müssen die Intensitätsverläufe interpoliert werden?
            //        wenn ja, mit welcher Methode/ mit welchem Verfahren? Auf welchen zeilichen Abstand einigt man sich?
            //
            //      - Wenn dann der Zeitvektor/-array und der dTime-Vektor/-array (Zeitspanne zwischen 2 Aufnahmen der gleichen Schicht) angepasst wurden,
            //        muss die Methode der Berechnung angepasst (UMMPRoiBasedController und UMMPPixelBasedMapController) werden, damit nicht nur die Zeiten der ersten Schicht ausgelesen werden.
            //        Außerdem ist beim Zugriff auf das Array der Zeitpunkte und dTime-Intervalle darauf zu achten, dass die Slider-Einstellungen
            //        (zeitlicher Trim oder Schicht-Trim) berücksichtigt werden.
            //
            //      - Abschließend ist der Sonderfall der A4DS-Nutzung im Report kenntlich zu machen. (UMMPReport).
            //
            //      - Wenn alle Punkte umgesetzt sind, dann die speziell mit   #--Adaptive-4D-Spiral--#   gekennzeichneten Kommentare entfernen.
            //
            
            
            //##################################################################################################################################//
            
            
            else
            {
                [self calculateTimeUsingAcquisitionTime2D];
                printf( "Modality: SIEMENS - DCE-CT\n" );
            }
            
        }
        else NSLog(@"Unknown modality: %@", modalityVal);
    }
    
    else if ([manufacturerVal isEqualToString:@"GE MEDICAL SYSTEMS"])
    {
        printf( "Manufacturer: GE MEDICAL SYSTEMS\n" );
        [self calculateTimeUsingTriggerTimeWithDecimalCorrection:1000.0];
    }
    
    else if ([manufacturerVal isEqualToString:@"Philips Medical Systems"])
    {
        NSLog(@"Manufacturer: Philips Medical Systems" );
        printf( "Manufacturer: Philips Medical Systems\n" );
        
        // DICOM Series without AcquisitionTime-Tag are Multiframed!
        NSString *acquisitionTimeTag = [NSString stringWithFormat:@"%04X,%04X", 0X0008, 0X0032];
        NSString *acquisitionTimeVal = [self getStringValueForDicomTag:acquisitionTimeTag];
        
        // Multiframed Data
        if (acquisitionTimeVal == nil)
        {
            NSLog(@"PHILIPS Multiframed Data!");
            NSArray *philipsContentTimeArray = [self getContentTimeArrayFromMultiframeData];
            [self calculateTimeUsingContentTimeArray:philipsContentTimeArray];
            
        }
        // Singleframed Data
        else
        {
            NSLog(@"PHILIPS Singleframed Data!");
            [self calculateTimeUsingAcquisitionTime2D];
            
            // If acquisitionTime does not change over time, use triggerTime
            if (max == 0.0) {
                [self calculateTimeUsingTriggerTimeWithDecimalCorrection:10.0];
            }
        }
    }
    
    
    else if ([manufacturerVal isEqualToString:@"Bruker BioSpin MRI GmbH"])
    {
        // needs to be validated !!
        // Bruker seems not to corectly put the timing information into the dicom header ??
        NSLog(@"Manufacturer: Bruker BioSpin MRI GmbH");
        //[self calculateTimeUsingAcquisitionTime];
        [self calculateTimeUsingTRAndImageNumber];
    }
    
    
    // Manufacturer not supported
    else
    {
        NSRunAlertPanel(@"Manufacturer not supported", @"The manufacturer of the DICOM Series is not supported", @"Close Plugin", nil, nil);
        [[self window] close];
    }
    //#####################################################--Adaptive-4D-Spiral###########################################################//
    //  Part 2/3:
    //  If Adaptive 4D-Spiral (A4DS) has been detected, this information is printed to log-file/ console.
    //  In that case, interpolation is suppressed.
    
    isShuttleMode = ([adaptive4DSpiralValue isEqual: @"A4DS"]);
    NSLog(@"Shuttle Mode detected: %d", isShuttleMode);
    if (!isShuttleMode){
        interpolate = [self isInterpolationNeeded:min max:max];
        return interpolate;
    }
    else{
        interpolate = NO;
        return interpolate;
    }
    
    //##########################################################################################################################################//
    
}


/*      Not Used    */
//- (void)calculateTimeUsingAcquisitionTimeCT
//{
//
//    // assume CT data is acquire in shuttle mode
//    // this means that AcquisitionTime stamp in dicom data records at the start of the stack the time
//    // here we need the acuisition time from the center of the stack
//
//
//    int i;
//
//    int n = [viewerController maxMovieIndex]-1;
//    printf( "_-_-_-_Expected maxMovieIndex: %d\n", [viewerController maxMovieIndex] );
//
//
//
//
//    NSString *acquisitionTimeTag;
//    NSDateFormatter *acquisitionTimeDateFormat;
//
//    NSString *acquisitionTime0Val;
//    NSString *acquisitionTime0DateString;
//    NSDate *acquisitionTime0Date;
//    int acquisitionTime0DateMicroseconds;
//
//
//    NSString *acquisitionTime1Val;
//    NSString *acquisitionTime1DateString;
//    NSDate *acquisitionTime1Date;
//    int acquisitionTime1DateMicroseconds;
//
//    NSString *acquisitionTime2Val;
//    NSString *acquisitionTime2DateString;
//    NSDate *acquisitionTime2Date;
//    int acquisitionTime2DateMicroseconds;
//
//    for (i = 0; i < n; i++) {
//
//        acquisitionTimeTag = [NSString stringWithFormat:@"%04X,%04X", 0X0008, 0X0032];
//        acquisitionTimeDateFormat = [[NSDateFormatter alloc] init];
//        [acquisitionTimeDateFormat setDateFormat:@"HHmmss"];
//
//        if (i == 0)
//        {
//            acquisitionTime0Val = [self getStringValueForDicomTag:acquisitionTimeTag atTimePoint:0];
//            acquisitionTime0DateString = [[acquisitionTime0Val componentsSeparatedByString:@"."] objectAtIndex:0];
//            acquisitionTime0Date = [acquisitionTimeDateFormat dateFromString:acquisitionTime0DateString];
//            acquisitionTime0DateMicroseconds = [[[acquisitionTime0Val componentsSeparatedByString:@"."] objectAtIndex:1] intValue];
//        }
//
//        acquisitionTime1Val = [self getStringValueForDicomTag:acquisitionTimeTag atTimePoint:i];
//        acquisitionTime1DateString = [[acquisitionTime1Val componentsSeparatedByString:@"."] objectAtIndex:0];
//        acquisitionTime1Date = [acquisitionTimeDateFormat dateFromString:acquisitionTime1DateString];
//        acquisitionTime1DateMicroseconds = [[[acquisitionTime1Val componentsSeparatedByString:@"."] objectAtIndex:1] intValue];
//
//
//        acquisitionTime2Val = [self getStringValueForDicomTag:acquisitionTimeTag atTimePoint:i+1];
//        acquisitionTime2DateString = [[acquisitionTime2Val componentsSeparatedByString:@"."] objectAtIndex:0];
//        acquisitionTime2Date = [acquisitionTimeDateFormat dateFromString:acquisitionTime2DateString];
//        acquisitionTime2DateMicroseconds = [[[acquisitionTime2Val componentsSeparatedByString:@"."] objectAtIndex:1] intValue];
//
//
//        time[i] = [acquisitionTime2Date timeIntervalSinceDate:acquisitionTime0Date] +
//        ((acquisitionTime2DateMicroseconds - acquisitionTime0DateMicroseconds) / 1000000.0);
//        NSLog(@"time[%d]= %lf", i, time[i] );
//
//        dTime[i] = [acquisitionTime2Date timeIntervalSinceDate:acquisitionTime1Date] +
//        ((acquisitionTime2DateMicroseconds - acquisitionTime1DateMicroseconds)/1000000.0);
//        printf( "dTime[%d]= %lf\n", i, dTime[i] );
//
//        [self calculateMinMaxAndDeltaTforTimePoint:i];
//    }
//
//
//
//}

- (void)calculateTimeUsingTRAndImageNumber
{
    
    // Hier wird die Acquisitiontime aus TR und die Anzahl der Zeilen im K Raum (Acquisitionmatrix) die aufgenommen wurde berechnet
    // hier nur für 2D, also eine Schicht ! Für den 3D Fall müsste man noch die Anzahl der Schichten betrachten....
    int i;
    
    int n = [viewerController maxMovieIndex]-1;
    printf( "_-_-_-_Expected maxMovieIndex: %d\n", [viewerController maxMovieIndex] );
    
    NSString *TrTag;
    NSString *NumberOfAcquisitions;
    NSString *TrTime1Val;
    NSString *NumberOfAcquisitionsTime2Val;
    
    
    NumberOfAcquisitions = [NSString stringWithFormat:@"%04X,%04X", 0X0018, 0X1310];
    TrTag = [NSString stringWithFormat:@"%04X,%04X", 0X0018, 0X0080];
    
    TrTime1Val = [self getStringValueForDicomTag:TrTag];
    
    
    NumberOfAcquisitionsTime2Val = [self getStringValueForDicomTag:NumberOfAcquisitions];
    
    NSLog(@"Phases=%@", NumberOfAcquisitionsTime2Val);
    
    for (i = 0; i < n; i++) {
        
        if(i==0)
        {
            time[i] = ([TrTime1Val intValue] * [NumberOfAcquisitionsTime2Val intValue]) / 1000.0;
            NSLog(@"time[%d]= %lf", i, time[i] );
            
        }
        
        time[i] = (time[i-1]) + ([TrTime1Val intValue] * [NumberOfAcquisitionsTime2Val intValue] / 1000.0);
        NSLog(@"time[%d]= %lf", i, time[i] );
        
        dTime[i] = (([TrTime1Val intValue] * [NumberOfAcquisitionsTime2Val intValue])/ 1000.0);
        // NSLog(@"dTime[%d]= %lf\n", i, dTime[i] );
        
        
        [self calculateMinMaxAndDeltaTforTimePoint:i];
    }
}


// Original Time Calculation Method, now outdated ( kept for reference and safety )
- (void)calculateTimeUsingAcquisitionTime
{
    int i;
	//int start = [[algorithmController startSlider] intValue];
	//int stop = [[algorithmController endSlider] intValue];
    //int n = stop-start;
    int n = [viewerController maxMovieIndex]-1;
    printf( "_-_-_-_Expected maxMovieIndex: %d\n", [viewerController maxMovieIndex] );
    
    NSString *acquisitionTimeTag;
    NSDateFormatter *acquisitionTimeDateFormat;
    
    NSString *acquisitionTime0Val;
    NSString *acquisitionTime0DateString;
    NSDate *acquisitionTime0Date;
    int acquisitionTime0DateMicroseconds;
    
    
    NSString *acquisitionTime1Val;
    NSString *acquisitionTime1DateString;
    NSDate *acquisitionTime1Date;
    int acquisitionTime1DateMicroseconds;
    
    NSString *acquisitionTime2Val;
    NSString *acquisitionTime2DateString;
    NSDate *acquisitionTime2Date;
    int acquisitionTime2DateMicroseconds;
    
    for (i = 0; i < n; i++) {
        
        acquisitionTimeTag = [NSString stringWithFormat:@"%04X,%04X", 0X0008, 0X0032];
        acquisitionTimeDateFormat = [[NSDateFormatter alloc] init];
        [acquisitionTimeDateFormat setDateFormat:@"HHmmss"];
        
        if (i == 0)
        {
            acquisitionTime0Val = [self getStringValueForDicomTag:acquisitionTimeTag atTimePoint:0];
            acquisitionTime0DateString = [[acquisitionTime0Val componentsSeparatedByString:@"."] objectAtIndex:0];
            acquisitionTime0Date = [acquisitionTimeDateFormat dateFromString:acquisitionTime0DateString];
            acquisitionTime0DateMicroseconds = [[[acquisitionTime0Val componentsSeparatedByString:@"."] objectAtIndex:1] intValue];
        }
        
        acquisitionTime1Val = [self getStringValueForDicomTag:acquisitionTimeTag atTimePoint:i];
        acquisitionTime1DateString = [[acquisitionTime1Val componentsSeparatedByString:@"."] objectAtIndex:0];
        acquisitionTime1Date = [acquisitionTimeDateFormat dateFromString:acquisitionTime1DateString];
        acquisitionTime1DateMicroseconds = [[[acquisitionTime1Val componentsSeparatedByString:@"."] objectAtIndex:1] intValue];
        
        
        acquisitionTime2Val = [self getStringValueForDicomTag:acquisitionTimeTag atTimePoint:i+1];
        acquisitionTime2DateString = [[acquisitionTime2Val componentsSeparatedByString:@"."] objectAtIndex:0];
        acquisitionTime2Date = [acquisitionTimeDateFormat dateFromString:acquisitionTime2DateString];
        acquisitionTime2DateMicroseconds = [[[acquisitionTime2Val componentsSeparatedByString:@"."] objectAtIndex:1] intValue];
        
        
        time[i] = [acquisitionTime2Date timeIntervalSinceDate:acquisitionTime0Date] +
        ((acquisitionTime2DateMicroseconds - acquisitionTime0DateMicroseconds) / 1000000.0);
        NSLog(@"time[%d]= %lf", i, time[i] );
        
        dTime[i] = [acquisitionTime2Date timeIntervalSinceDate:acquisitionTime1Date] +
        ((acquisitionTime2DateMicroseconds - acquisitionTime1DateMicroseconds)/1000000.0);
        printf( "dTime[%d]= %lf\n", i, dTime[i] );
        
        [self calculateMinMaxAndDeltaTforTimePoint:i];
    }
}


// ------------ new try for Implementation of TwoDimensional Timevector ------------ //
- (void) calculateTimeUsingAcquisitionTime2D {
    
    NSString *acquisitionTimeTag;
    NSDateFormatter *acquisitionTimeDateFormat;
    
    NSString *acquisitionTime0Val;
    NSString *acquisitionTime0DateString;
    NSDate *acquisitionTime0Date;
    int acquisitionTime0DateMicroseconds;
    
    NSString *acquisitionTime1Val;
    NSString *acquisitionTime1DateString;
    NSDate *acquisitionTime1Date;
    int acquisitionTime1DateMicroseconds;
    
    NSString *acquisitionTime2Val;
    NSString *acquisitionTime2DateString;
    NSDate *acquisitionTime2Date;
    int acquisitionTime2DateMicroseconds;
    
    int slices=0;
    int i =0, k=0, n=0;
    
    /* get Array Dimensions */
    n = [viewerController maxMovieIndex]-1;
    slices = [[viewerController pixList] count];
    
    
    //  ----    TEST OUTPUT ----    //
    NSLog(@"UMMP:n Value ( Number of Timepoints ) = %d", n);
    NSLog(@"UMMP: slices Value ( Number of Slices ) = %d", slices);
    //  ----    TEST OUTPUT END  ----    //
    
    // first Array Dimension n = Number of Timepoints
    timeArray = [[NSMutableArray alloc] initWithCapacity:n ];
    
    for(int t=0; t<n; t++){
        // 2nd Array Dimension slices = number of Slices per Timepoint
        NSMutableArray *sliceArray = [[NSMutableArray alloc] initWithCapacity:slices];
        [timeArray addObject:sliceArray];
    }
    
    // Same for dTime Array
    dTimeArray = [[NSMutableArray alloc] initWithCapacity:n];
    for(int t=0; t<n; t++){
        // 2nd Array Dimension slices = number of Slices per Timepoint
        NSMutableArray *sliceArray = [[NSMutableArray alloc] initWithCapacity:slices];
        [dTimeArray addObject:sliceArray];
    }
    
    
    for (i = 0; i < n; i++) {
        acquisitionTimeTag = [NSString stringWithFormat:@"%04X,%04X", 0X0008, 0X0032];
        acquisitionTimeDateFormat = [[NSDateFormatter alloc] init];
        [acquisitionTimeDateFormat setDateFormat:@"HHmmss"];
        [[viewerController pixList:i] objectAtIndex:0]  ;
        
        
        
        for (k=0; k<slices; k++){
            
            
            acquisitionTimeTag = [NSString stringWithFormat:@"%04X,%04X", 0X0008, 0X0032];
            acquisitionTimeDateFormat = [[NSDateFormatter alloc] init];
            [acquisitionTimeDateFormat setDateFormat:@"HHmmss"];
            
            if (i == 0)
            {
                acquisitionTime0Val = [self getStringValueForDicomTag:acquisitionTimeTag atTimePoint:0 atSlice:k];
                acquisitionTime0DateString = [[acquisitionTime0Val componentsSeparatedByString:@"."] objectAtIndex:0];
                acquisitionTime0Date = [acquisitionTimeDateFormat dateFromString:acquisitionTime0DateString];
                acquisitionTime0DateMicroseconds = [[[acquisitionTime0Val componentsSeparatedByString:@"."] objectAtIndex:1] intValue];
            }
            
            acquisitionTime1Val = [self getStringValueForDicomTag:acquisitionTimeTag atTimePoint:i atSlice:k];
            acquisitionTime1DateString = [[acquisitionTime1Val componentsSeparatedByString:@"."] objectAtIndex:0];
            acquisitionTime1Date = [acquisitionTimeDateFormat dateFromString:acquisitionTime1DateString];
            acquisitionTime1DateMicroseconds = [[[acquisitionTime1Val componentsSeparatedByString:@"."] objectAtIndex:1] intValue];
            
            
            acquisitionTime2Val = [self getStringValueForDicomTag:acquisitionTimeTag atTimePoint:i+1 atSlice:k];
            acquisitionTime2DateString = [[acquisitionTime2Val componentsSeparatedByString:@"."] objectAtIndex:0];
            acquisitionTime2Date = [acquisitionTimeDateFormat dateFromString:acquisitionTime2DateString];
            acquisitionTime2DateMicroseconds = [[[acquisitionTime2Val componentsSeparatedByString:@"."] objectAtIndex:1] intValue];
            
            // Need to wrap DoubleValue into NSNumber Object because NSMutableArray only holds Objects
            timeArray[i][k] = [NSNumber numberWithDouble: [acquisitionTime2Date timeIntervalSinceDate:acquisitionTime0Date] +
                               ((acquisitionTime2DateMicroseconds - acquisitionTime0DateMicroseconds) / 1000000.0)];
            // Test Output for timeArray contents
            //  NSLog(@"timeArray[%d][%d]= %lf",i ,k ,[timeArray[i][k] doubleValue] );
            
            
            dTimeArray[i][k] = [NSNumber numberWithDouble:[acquisitionTime2Date timeIntervalSinceDate:acquisitionTime1Date]+
                                ((acquisitionTime2DateMicroseconds - acquisitionTime1DateMicroseconds) / 1000000.0)];
            // Test Output for dTimeArray contents
            //  NSLog(@"dTimeArray[%d][%d]= %lf",i ,k ,[dTimeArray[i][k] doubleValue] );
            
            
            
            //  dTime[i] = [acquisitionTime2Date timeIntervalSinceDate:acquisitionTime1Date] +
            //  ((acquisitionTime2DateMicroseconds - acquisitionTime1DateMicroseconds)/1000000.0);
            //  printf( "dTime[%d]= %lf\n", i, dTime[i] );
            
            
            [self calculateMinMaxAndDeltaTforTimePoint:i andSlice:k];
        }
    }
}

- (void)calculateTimeUsingTriggerTimeWithDecimalCorrection:(double)decimalCorrection
{
    int i;
	//int start = [[algorithmController startSlider] intValue];
	//int stop = [[algorithmController endSlider] intValue];
    //int n = stop-start;
    int n = [viewerController maxMovieIndex]-1;
    printf( "_-_-_-_Expected maxMovieIndex: %d\n", [viewerController maxMovieIndex] );
    
    NSString *triggerTimeTag;
    
    NSString *triggerTime0Val;
    double triggerTime0Microseconds;
    
    NSString *triggerTime1Val;
    double triggerTime1Microseconds;
    
    NSString *triggerTime2Val;
    double triggerTime2Microseconds;
    
    for (i = 0; i < n; i++) {
        
        triggerTimeTag = [NSString stringWithFormat:@"%04X,%04X", 0X0018, 0X1060];
        
        if (i == 0)
        {
            triggerTime0Val = [self getStringValueForDicomTag:triggerTimeTag atTimePoint:0];
            triggerTime0Microseconds = [triggerTime0Val doubleValue]/decimalCorrection;
        }
        
        triggerTime1Val = [self getStringValueForDicomTag:triggerTimeTag atTimePoint:i];
        triggerTime1Microseconds = [triggerTime1Val doubleValue]/decimalCorrection;
        
        triggerTime2Val = [self getStringValueForDicomTag:triggerTimeTag atTimePoint:i+1];
        triggerTime2Microseconds = [triggerTime2Val doubleValue]/decimalCorrection;
        
        
        time[i] = triggerTime2Microseconds - triggerTime0Microseconds;
        //printf( "time[%d]= %lf\n", i, time[i] );
        
        dTime[i] = triggerTime2Microseconds - triggerTime1Microseconds;
        //printf( "dTime[%d]= %lf\n", i, dTime[i] );
        
        [self calculateMinMaxAndDeltaTforTimePoint:i];
    }
}


- (void)calculateMinMaxAndDeltaTforTimePoint:(int)timePoint
{
    double dt = dTime[timePoint];
    
    if (timePoint == 0) {
        /*
         * When Time-Trim is different from 0, dt would be the amount of time
         * between acquisition start and beginning of the first timepoint -->ERROR
         */
        max = dt/([[algorithmController startSlider] intValue]+1);
        
        /*
         * Dividing by the amount of timepoints will lead to the correct
         * result of an average dt between two timepoints.
         */
        min = dt/([[algorithmController startSlider] intValue]+1);
    }
    
    if (dt < min)
        min = dt;
    
    if (dt > max)
        max = dt;
    
    if (min == 0)
        min = 1.0;
    
    deltaT = min;
}

- (void)calculateMinMaxAndDeltaTforTimePoint:(int)timePoint andSlice:(int)slice
{
    int n = [viewerController maxMovieIndex]-1;
    double dt = dTime[(n-1)*slice + timePoint];
    
    if (timePoint == 0) {
        /*
         * When Time-Trim is different from 0, dt would be the amount of time
         * between acquisition start and beginning of the first timepoint -->ERROR
         */
        max = dt/([[algorithmController startSlider] intValue]+1);
        
        /*
         * Dividing by the amount of timepoints will lead to the correct
         * result of an average dt between two timepoints.
         */
        min = dt/([[algorithmController startSlider] intValue]+1);
    }
    //printf("MinMax at Timepoint %d andSlice %d", timePoint, slice);
    
    if (dt < min)
        min = dt;
    
    if (dt > max)
        max = dt;
    
    if (min == 0)
        min = 1.0;
    
    //########################################################--Adaptive-4D-Spiral--##################################################################//
    //  Part 3/4:
    //  set delta-T, which is also later displayed in the Chart. The value 0.00 should demonstrate,
    //  that a universally valid value for delta-T does not exist.
    //  (different delta-Ts f for each slice and acquisiton point in time.
    
    // IF min != max, then interpolation would be needed (and , unless it is using shuttle mode. THEN: deltaT= 0.00
    // deltaT = min;
    /*
     if(min != max){
     if(isShuttleMode){
     deltaT = min;
     }else{
     deltaT= 0.00;
     }
     }
     */
    deltaT = 0.00;
    
    // continue with part 4 in UMMPChart.m ...
    
    //##############################################################################################################################################//
    
    
}

- (NSArray *)getContentTimeArrayFromMultiframeData
{
    int i;
	//int start = [[algorithmController startSlider] intValue];
	//int stop = [[algorithmController endSlider] intValue];
    //int n = stop-start;
    int n = [viewerController maxMovieIndex]-1;
    
    NSMutableArray *contentTimeArray = [[NSMutableArray alloc] init];
    
    NSString *filePath= [[[viewerController pixList:0] objectAtIndex:0] sourceFile];
    DCMObject *dcmObject = [DCMObject objectWithContentsOfFile:filePath decodingPixelData:NO];
    
    DCMSequenceAttribute *functionalGroupsSequence = (DCMSequenceAttribute *)[dcmObject attributeWithName:@"Per-frameFunctionalGroupsSequence"];
    if (functionalGroupsSequence)
    {
        DCMObject *functionalGroupsItem = nil;
        for (i = 0; i < n; i++) {
            functionalGroupsItem = [functionalGroupsSequence.sequence objectAtIndex:i];
            
            NSString *contentTimeSeqTag = [NSString stringWithFormat:@"%04X,%04X", 0X2005, 0X140f];
            DCMAttributeTag *contentTimeSeqAttrTag = [DCMAttributeTag tagWithTagString:contentTimeSeqTag];
            DCMSequenceAttribute *contentTimeSequence = (DCMSequenceAttribute *)[functionalGroupsItem attributeForTag:contentTimeSeqAttrTag];
            
            if (contentTimeSequence) {
                
                DCMObject *contentTimeSequenceItem = [contentTimeSequence.sequence objectAtIndex:0];
                NSString *contentTimeTag = [NSString stringWithFormat:@"%04X,%04X", 0X0008, 0X0033];
                
                DCMAttributeTag *contentTimeAttrTag = [DCMAttributeTag tagWithTagString:contentTimeTag];
                NSString *contentTime = [[[contentTimeSequenceItem attributeForTag:contentTimeAttrTag] value] description];
                [contentTimeArray addObject:contentTime];
            }
        }
    }
    else
    {
        NSRunAlertPanel(@"Problem with Philips Multiframe", @"This type of Philips Multiframe Date is not supported", @"Close Plugin", nil, nil);
        [[self window] close];
    }
    
    return [contentTimeArray copy];
}


- (void)calculateTimeUsingContentTimeArray:(NSArray *)contentTimeArray
{
    int i;
	//int start = [[algorithmController startSlider] intValue];
	//int stop = [[algorithmController endSlider] intValue];
    //int n = stop-start;
    int n = [viewerController maxMovieIndex]-1;
    printf( "_-_-_-_Expected maxMovieIndex: %d\n", n+1 );
    
    NSString *contentTimeTag;
    NSDateFormatter *contentTimeDateFormat;
    
    NSString *contentTime0Val;
    NSString *contentTime0DateString;
    NSDate *contentTime0Date;
    int contentTime0DateMicroseconds;
    
    NSString *contentTime1Val;
    NSString *contentTime1DateString;
    NSDate *contentTime1Date;
    int contentTime1DateMicroseconds;
    
    NSString *contentTime2Val;
    NSString *contentTime2DateString;
    NSDate *contentTime2Date;
    int contentTime2DateMicroseconds;
    
    for (i = 0; i < [contentTimeArray count]-1; i++) {
        
        contentTimeTag = [NSString stringWithFormat:@"%04X,%04X", 0X0008, 0X0032];
        contentTimeDateFormat = [[NSDateFormatter alloc] init];
        [contentTimeDateFormat setDateFormat:@"HHmmss"];
        
        if (i == 0)
        {
            contentTime0Val = (NSString *)[contentTimeArray objectAtIndex:0];
            contentTime0DateString = [[contentTime0Val componentsSeparatedByString:@"."] objectAtIndex:0];
            contentTime0Date = [contentTimeDateFormat dateFromString:contentTime0DateString];
            contentTime0DateMicroseconds = [[[contentTime0Val componentsSeparatedByString:@"."] objectAtIndex:1] intValue];
        }
        
        contentTime1Val = (NSString *)[contentTimeArray objectAtIndex:i];
        contentTime1DateString = [[contentTime1Val componentsSeparatedByString:@"."] objectAtIndex:0];
        contentTime1Date = [contentTimeDateFormat dateFromString:contentTime1DateString];
        contentTime1DateMicroseconds = [[[contentTime1Val componentsSeparatedByString:@"."] objectAtIndex:1] intValue];
        
        contentTime2Val = (NSString *)[contentTimeArray objectAtIndex:i+1];
        contentTime2DateString = [[contentTime2Val componentsSeparatedByString:@"."] objectAtIndex:0];
        contentTime2Date = [contentTimeDateFormat dateFromString:contentTime2DateString];
        contentTime2DateMicroseconds = [[[contentTime2Val componentsSeparatedByString:@"."] objectAtIndex:1] intValue];
        
        time[i] = [contentTime2Date timeIntervalSinceDate:contentTime0Date] +
        ((contentTime2DateMicroseconds - contentTime0DateMicroseconds) / 1000000.0);
        //printf( "time[%d]= %lf\n", i, time[i] );
        
        dTime[i] = [contentTime2Date timeIntervalSinceDate:contentTime1Date] +
        ((contentTime2DateMicroseconds - contentTime1DateMicroseconds)/1000000.0);
        //printf( "dTime[%d]= %lf\n", i, dTime[i] );
        
        [self calculateMinMaxAndDeltaTforTimePoint:i];
    }
}


//- (void) calculateTimeForShuttleMode // deprecated, old try
//{
//    int i,k ;
//    NSString *instanceNumberTag = [NSString stringWithFormat:@"%04X,%04X", 0X0020, 0X0013];
//    NSString *instanceNumberVal       = [self getStringValueForDicomTag:instanceNumberTag];
//    NSString *acquisitionNumberTag = [NSString stringWithFormat:@"%04X,%04X", 0X0020, 0X0012];
//    NSString *acquisitionNumberVal       = [self getStringValueForDicomTag:acquisitionNumberTag];
//
//    int n = [viewerController maxMovieIndex]-1;
//    printf( "_-_-_-_Expected maxMovieIndex: %d\n", n+1 );
//    NSLog(@" ShuttleMode test-values: instanceNumber: %@, acquisitionNumber: %@", instanceNumberVal, acquisitionNumberVal);
//
//   // double deltaTimeAvgSum;
//
//    NSString *acquisitionTimeTag;
//    NSDateFormatter *acquisitionTimeDateFormat;
//
//    NSString *acquisitionTime0Val;
//    NSString *acquisitionTime0DateString;
//    NSDate *acquisitionTime0Date;
//    int acquisitionTime0DateMicroseconds;
//
//    NSString *acquisitionTime1Val;
//    NSString *acquisitionTime1DateString;
//    NSDate *acquisitionTime1Date;
//    int acquisitionTime1DateMicroseconds;
//
//    NSString *acquisitionTime2Val;
//    NSString *acquisitionTime2DateString;
//    NSDate *acquisitionTime2Date;
//    int acquisitionTime2DateMicroseconds;
//
//    for (i = 0; i < n; i++) {
//
//        int slices = [[viewerController pixList] count];
//        k= (slices/2)+0.5;
//
//
//        //
////        acquisitionTimeTag = [NSString stringWithFormat:@"%04X,%04X", 0X0008, 0X0032];
////        acquisitionTimeDateFormat = [[NSDateFormatter alloc] init];
////        [acquisitionTimeDateFormat setDateFormat:@"HHmmss"];
////
////        if (i == 0)
////        {
////            acquisitionTime0Val = [self getStringValueForDicomTag:acquisitionTimeTag atTimePoint:0];
////            acquisitionTime0DateString = [[acquisitionTime0Val componentsSeparatedByString:@"."] objectAtIndex:0];
////            acquisitionTime0Date = [acquisitionTimeDateFormat dateFromString:acquisitionTime0DateString];
////            acquisitionTime0DateMicroseconds = [[[acquisitionTime0Val componentsSeparatedByString:@"."] objectAtIndex:1] intValue];
////        }
////
////        acquisitionTime1Val = [self getStringValueForDicomTag:acquisitionTimeTag atTimePoint:i];
////        acquisitionTime1DateString = [[acquisitionTime1Val componentsSeparatedByString:@"."] objectAtIndex:0];
////        acquisitionTime1Date = [acquisitionTimeDateFormat dateFromString:acquisitionTime1DateString];
////        acquisitionTime1DateMicroseconds = [[[acquisitionTime1Val componentsSeparatedByString:@"."] objectAtIndex:1] intValue];
////
////
////        acquisitionTime2Val = [self getStringValueForDicomTag:acquisitionTimeTag atTimePoint:i+1];
////        acquisitionTime2DateString = [[acquisitionTime2Val componentsSeparatedByString:@"."] objectAtIndex:0];
////        acquisitionTime2Date = [acquisitionTimeDateFormat dateFromString:acquisitionTime2DateString];
////        acquisitionTime2DateMicroseconds = [[[acquisitionTime2Val componentsSeparatedByString:@"."] objectAtIndex:1] intValue];
////
////
////        time[i] = [acquisitionTime2Date timeIntervalSinceDate:acquisitionTime0Date] +
////        ((acquisitionTime2DateMicroseconds - acquisitionTime0DateMicroseconds) / 1000000.0);
////        printf( "time[%d]= %lf\n", i, time[i] );
////
////        dTime[i] = [acquisitionTime2Date timeIntervalSinceDate:acquisitionTime1Date] +
////        ((acquisitionTime2DateMicroseconds - acquisitionTime1DateMicroseconds)/1000000.0);
////        printf( "dTime[%d]= %lf\n", i, dTime[i] );
////
////
////    }
//        acquisitionTimeTag = [NSString stringWithFormat:@"%04X,%04X", 0X0008, 0X0032];
//        acquisitionTimeDateFormat = [[NSDateFormatter alloc] init];
//        [acquisitionTimeDateFormat setDateFormat:@"HHmmss"];
//
//        if (i == 0)
//        {
//            acquisitionTime0Val = [self getStringValueForDicomTag:acquisitionTimeTag
//                                                      atTimePoint:0
//                                                          atSlice:k];
//            acquisitionTime0DateString = [[acquisitionTime0Val componentsSeparatedByString:@"."] objectAtIndex:0];
//            acquisitionTime0Date = [acquisitionTimeDateFormat dateFromString:acquisitionTime0DateString];
//            acquisitionTime0DateMicroseconds = [[[acquisitionTime0Val componentsSeparatedByString:@"."] objectAtIndex:1] intValue];
//        }
//
//        acquisitionTime1Val = [self getStringValueForDicomTag:acquisitionTimeTag atTimePoint:i atSlice:k];
//        acquisitionTime1DateString = [[acquisitionTime1Val componentsSeparatedByString:@"."] objectAtIndex:0];
//        acquisitionTime1Date = [acquisitionTimeDateFormat dateFromString:acquisitionTime1DateString];
//        acquisitionTime1DateMicroseconds = [[[acquisitionTime1Val componentsSeparatedByString:@"."] objectAtIndex:1] intValue];
//
//
//        acquisitionTime2Val = [self getStringValueForDicomTag:acquisitionTimeTag atTimePoint:i+1 atSlice:k];
//        acquisitionTime2DateString = [[acquisitionTime2Val componentsSeparatedByString:@"."] objectAtIndex:0];
//        acquisitionTime2Date = [acquisitionTimeDateFormat dateFromString:acquisitionTime2DateString];
//        acquisitionTime2DateMicroseconds = [[[acquisitionTime2Val componentsSeparatedByString:@"."] objectAtIndex:1] intValue];
//
//
//        time[i] = [acquisitionTime2Date timeIntervalSinceDate:acquisitionTime0Date] +
//        ((acquisitionTime2DateMicroseconds - acquisitionTime0DateMicroseconds) / 1000000.0);
//        //printf( "time[%d]= %lf\n", i, time[i] );
//
//
//
//    }
//    //    deltaTimeAvgSum = 0;
//    //    for ( i=0; i<n; i++)
//    //        deltaTimeAvgSum += dTime[i];
//    //    deltaT = deltaTimeAvgSum /n-1;
//    //
//    deltaT=time[n-1]/(n-1);
//
//
//    [self saveAcquistionTimeToFile:n];
//
//
//    NSLog(@"end of Shuttle-mode delta T - calculation");
//}


- (void) saveAcquistionTimeToFile:(int)n  {
    //NSSavePanel *savePanel = nil;
    // Wait *splash = nil;
    NSString *myString = nil;
    int i=0,j=0, k=0, slices=0, counter=0;
    BOOL _txt = NO;
    BOOL _csv = YES;
    NSString *fileDirectory = nil;
    NSURL *fileDirectoryURL = nil;
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    
    slices = [[viewerController pixList] count];
    
    NSLog(@"UMMP: ermittelte Schicht-Zahl: %d", slices);
    
    
    
    //    [savePanel setTitle:@"saving acquisition times"];
    //    [savePanel setAllowedFileTypes:nil];
    //    [savePanel setCanSelectHiddenExtension:NO];
    //    if ((_txt = [[_mainController userDefaults] int:@"UMMPdotTxtCheckbox" otherwise:0])) {
    //        [_dotTxtCheckbox setState:_txt];
    //    }
    //    if ((_csv = [[_mainController userDefaults] int:@"UMMPdotCsvCheckbox" otherwise:0])) {
    //        [_dotCsvCheckbox setState:_csv];
    //    }
    //    [savePanel setAccessoryView:_savePanelView];
    
    NSInteger returnValue = [savePanel runModal];
    if (returnValue != NSFileHandlingPanelOKButton) {
        return;
    }
    
    //    _txt = [_dotTxtCheckbox state];
    //    _csv = [_dotCsvCheckbox state];
    if(_txt)counter++;
    if(_csv)counter++;
    
    if(!(_txt || _csv)) {
        //NSString*newString = [NSString stringWithFormat: @"",  ];
        NSRunAlertPanel(@"too few arguments",@"Please select at least one file extension.",  @"OK" ,nil,nil);
        
    }
    else
    {
        NSString *acquisitionTimeTag;
        NSDateFormatter *acquisitionTimeDateFormat;
        
        NSString *acquisitionTime0Val;
        NSString *acquisitionTime0DateString;
        NSDate *acquisitionTime0Date;
        int acquisitionTime0DateMicroseconds;
        
        NSString *acquisitionTime1Val;
        NSString *acquisitionTime1DateString;
        NSDate *acquisitionTime1Date;
        int acquisitionTime1DateMicroseconds;
        
        NSString *acquisitionTime2Val;
        NSString *acquisitionTime2DateString;
        NSDate *acquisitionTime2Date;
        int acquisitionTime2DateMicroseconds;
        
        //        splash = [[Wait alloc] initWithString:NSLocalizedString(@"Saving current acquistion times to file...", nil)];
        //        [splash showWindow:self];
        //        [[splash progress] setMaxValue:[n*counter]];
        //        [splash setCancel: NO];
        
        for (j=0; j<counter; j++){
            myString = [NSString stringWithFormat:@""];
            
            fileDirectoryURL = [savePanel URL];
            fileDirectory = [fileDirectoryURL absoluteString];
            
            if ((_txt)&&(j==0)) {
                fileDirectory =[NSString stringWithFormat:@"%@.txt", fileDirectory];
                myString = [NSString stringWithFormat:@"%@Acquistion Times\n\n", myString];
                //myString = [NSString stringWithFormat:@"%@time(sec)\ttimepoint\taif\t\ttissue\t\ttissue(nor)\tfit\n", myString];
                for (i = 0; i <= n; i++) {
                    acquisitionTimeTag = [NSString stringWithFormat:@"%04X,%04X", 0X0008, 0X0032];
                    acquisitionTimeDateFormat = [[NSDateFormatter alloc] init];
                    [acquisitionTimeDateFormat setDateFormat:@"HHmmss"];
                    [[viewerController pixList:i] objectAtIndex:0]  ;
                    
                    for (k=0; k<slices; k++){
                        
                        
                        acquisitionTimeTag = [NSString stringWithFormat:@"%04X,%04X", 0X0008, 0X0032];
                        acquisitionTimeDateFormat = [[NSDateFormatter alloc] init];
                        [acquisitionTimeDateFormat setDateFormat:@"HHmmss"];
                        
                        if (i == 0)
                        {
                            acquisitionTime0Val = [self getStringValueForDicomTag:acquisitionTimeTag atTimePoint:0 atSlice:k];
                            acquisitionTime0DateString = [[acquisitionTime0Val componentsSeparatedByString:@"."] objectAtIndex:0];
                            acquisitionTime0Date = [acquisitionTimeDateFormat dateFromString:acquisitionTime0DateString];
                            acquisitionTime0DateMicroseconds = [[[acquisitionTime0Val componentsSeparatedByString:@"."] objectAtIndex:1] intValue];
                        }
                        
                        acquisitionTime1Val = [self getStringValueForDicomTag:acquisitionTimeTag atTimePoint:i atSlice:k];
                        acquisitionTime1DateString = [[acquisitionTime1Val componentsSeparatedByString:@"."] objectAtIndex:0];
                        acquisitionTime1Date = [acquisitionTimeDateFormat dateFromString:acquisitionTime1DateString];
                        acquisitionTime1DateMicroseconds = [[[acquisitionTime1Val componentsSeparatedByString:@"."] objectAtIndex:1] intValue];
                        
                        
                        acquisitionTime2Val = [self getStringValueForDicomTag:acquisitionTimeTag atTimePoint:i+1 atSlice:k];
                        acquisitionTime2DateString = [[acquisitionTime2Val componentsSeparatedByString:@"."] objectAtIndex:0];
                        acquisitionTime2Date = [acquisitionTimeDateFormat dateFromString:acquisitionTime2DateString];
                        acquisitionTime2DateMicroseconds = [[[acquisitionTime2Val componentsSeparatedByString:@"."] objectAtIndex:1] intValue];
                        
                        
                        time[i] = [acquisitionTime2Date timeIntervalSinceDate:acquisitionTime0Date] +
                        ((acquisitionTime2DateMicroseconds - acquisitionTime0DateMicroseconds) / 1000000.0);
                        //printf( "time[%d]= %lf\n", i, time[i] );
                        myString = [NSString stringWithFormat:@"%@%0.3f\t\t", myString, time[i]*1000];
                    }
                    myString = [NSString stringWithFormat:@"%@ \t\n", myString];
                    char* tempAcqT = [myString UTF8String];
                    printf("AcqTime: %s", tempAcqT);
                    //                    [splash incrementBy:1];
                    //myString = [NSString stringWithFormat:@"%@%0.3f\t\t%d\t\t%0.3f\t\t%0.3f\t\t%0.3f\t\t%0.3lf \n", myString,[[_time objectAtIndex:i]floatValue],(i+1),[[_aifRoiData objectAtIndex:i]floatValue],[[_tissueRoiData objectAtIndex:i]floatValue],[[_tissue objectAtIndex:i]floatValue],[[_fit objectAtIndex:i] doubleValue]];
                }
                myString = [NSString stringWithFormat:@"%@eof\t\n", myString];
            }
            if (((_csv)&&(_txt)&&(j>0))||(((_csv)&&(!_txt))&&(j==0))) {
                fileDirectory =[NSString stringWithFormat:@"%@.csv", fileDirectory];
                myString = [NSString stringWithFormat:@"%@Acquisition Times\n", myString];
                for (i = 0; i <= n; i++) {
                    k=0;
                    acquisitionTimeTag = [NSString stringWithFormat:@"%04X,%04X", 0X0008, 0X0032];
                    acquisitionTimeDateFormat = [[NSDateFormatter alloc] init];
                    [acquisitionTimeDateFormat setDateFormat:@"HHmmss"];
                    [[viewerController pixList:i] objectAtIndex:0]  ;
                    
                    for (k=0; k<slices; k++){
                        
                        
                        acquisitionTimeTag = [NSString stringWithFormat:@"%04X,%04X", 0X0008, 0X0032];
                        acquisitionTimeDateFormat = [[NSDateFormatter alloc] init];
                        [acquisitionTimeDateFormat setDateFormat:@"HHmmss"];
                        
                        if (i == 0)
                        {
                            acquisitionTime0Val = [self getStringValueForDicomTag:acquisitionTimeTag
                                                                      atTimePoint:0
                                                                          atSlice:k];
                            acquisitionTime0DateString = [[acquisitionTime0Val componentsSeparatedByString:@"."] objectAtIndex:0];
                            acquisitionTime0Date = [acquisitionTimeDateFormat dateFromString:acquisitionTime0DateString];
                            acquisitionTime0DateMicroseconds = [[[acquisitionTime0Val componentsSeparatedByString:@"."] objectAtIndex:1] intValue];
                        }
                        
                        acquisitionTime1Val = [self getStringValueForDicomTag:acquisitionTimeTag atTimePoint:i atSlice:k];
                        acquisitionTime1DateString = [[acquisitionTime1Val componentsSeparatedByString:@"."] objectAtIndex:0];
                        acquisitionTime1Date = [acquisitionTimeDateFormat dateFromString:acquisitionTime1DateString];
                        acquisitionTime1DateMicroseconds = [[[acquisitionTime1Val componentsSeparatedByString:@"."] objectAtIndex:1] intValue];
                        
                        
                        acquisitionTime2Val = [self getStringValueForDicomTag:acquisitionTimeTag atTimePoint:i+1 atSlice:k];
                        acquisitionTime2DateString = [[acquisitionTime2Val componentsSeparatedByString:@"."] objectAtIndex:0];
                        acquisitionTime2Date = [acquisitionTimeDateFormat dateFromString:acquisitionTime2DateString];
                        acquisitionTime2DateMicroseconds = [[[acquisitionTime2Val componentsSeparatedByString:@"."] objectAtIndex:1] intValue];
                        
                        
                        time[i] = [acquisitionTime2Date timeIntervalSinceDate:acquisitionTime0Date] +
                        ((acquisitionTime2DateMicroseconds - acquisitionTime0DateMicroseconds) / 1000000.0);
                        //printf( "time[%d]= %lf\n", i, time[i] );
                        myString = [NSString stringWithFormat:@"%@%0.3f;", myString, time[i]*1000];
                    }
                    myString = [NSString stringWithFormat:@"%@;\n", myString];
                    char* tempAcqT = [myString UTF8String];
                    printf("AcqTime: %s", tempAcqT);
                }
                myString = [NSString stringWithFormat:@"%@eof;\n", myString];
            }
            
            fileDirectoryURL = [NSURL URLWithString:fileDirectory];
            NSLog(@"%@ <-- this file has just been saved.",fileDirectoryURL);
            [myString writeToURL:fileDirectoryURL
                      atomically:YES
                        encoding:NSUTF8StringEncoding
                           error: NULL];
        }
        
        //        [splash close];
        //        [splash release];
        
    }
    
}

- (void)setContent:(NSNotification *)notification {
    if ([notification object] == [self window]) {
        _panelSize.width = 0;
        _panelSize.height = 0;
        [[self window] setContentSize:_panelSize];
    }
}

- (BOOL)isInterpolationNeeded:(double)aMin max:(double)aMax
{
	BOOL interpol = NO;
    // condition for interpolation
	if (!(((aMax-aMin)/aMin) < 0.01)) {
		interpol = YES;
    }
	
	NSLog(@"isInterpolationNeeded in PanelController: aMin: %f, aMax: %f, interpol:%@ ", aMin, aMax, (interpol ? @"YES" : @"NO"));
	
	return interpol;
}


@end
