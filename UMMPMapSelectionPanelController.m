//
//  UMMPMapSelectionPanelController.m
//  UMMPerfusion
//
//  Created by Sven Kaiser on 20.02.12.
//  Copyright (c) 2012, Marcel Reich & Sven Kaiser & Markus Daab & Patrick Schülein & Engin Aslan
//  All rights reserved.
//

#import "UMMPMapSelectionPanelController.h"
#import "UMMPPanelController.h"

@implementation UMMPMapSelectionPanelController


- (void)awakeFromNib
{
    [self refreshStatusOfMapSelection];
	
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
    [self refreshStatusOfMapSelection];
}


- (IBAction)pushOKButton:(id)sender
{
       
    BOOL isOK = NO;
    
    switch ([[controller algorithmPopUpButton] selectedTag]) {
        case 7:
            if ([compartmentMapPF state] || [compartmentMapPMTT state] || [compartmentMapPV state] || [compartmentMapAFE state] || [compartmentMapCS state]) {
                
                [[self window] close];
                
                // Compartment view
                [[controller userDefaults] setInt:[compartmentMapPF state]  forKey:@"UMMPcompartmentMapPF"];
                [[controller userDefaults] setInt:[compartmentMapPMTT state] forKey:@"UMMPcompartmentMapPMTT"];
                [[controller userDefaults] setInt:[compartmentMapPV state] forKey:@"UMMPcompartmentMapPV"];
                [[controller userDefaults] setInt:[compartmentMapAFE state] forKey:@"UMMPcompartmentMapAFE"];
                [[controller userDefaults] setInt:[compartmentMapCS state] forKey:@"UMMPcompartmentMapCS"];
                
                isOK = YES;
            }
            break;
        case 8:
            if ([exchangeMapPF state] || [exchangeMapPMTT state] || [exchangeMapPV state] || [exchangeMapIMTT state] || [exchangeMapIV state] || [exchangeMapEF state] || [exchangeMapPSAP state] || [exchangeMapAFE state] || [exchangeMapCS state]) {
                
                [[self window] close];
                
                
                //exchange view
                [[controller userDefaults] setInt:[exchangeMapPF state]  forKey:@"UMMPexchangeMapPF"];
                [[controller userDefaults] setInt:[exchangeMapPMTT state] forKey:@"UMMPexchangeMapPMTT"];
                [[controller userDefaults] setInt:[exchangeMapPV state] forKey:@"UMMPexchangeMapPV"];
                [[controller userDefaults] setInt:[exchangeMapIMTT state] forKey:@"UMMPexchangeMapIMTT"];
                [[controller userDefaults] setInt:[exchangeMapIV state] forKey:@"UMMPexchangeMapIV"];
                [[controller userDefaults] setInt:[exchangeMapEF state] forKey:@"UMMPexchangeMapEF"];
                [[controller userDefaults] setInt:[exchangeMapPSAP state] forKey:@"UMMPexchangeMapPSAP"];
                [[controller userDefaults] setInt:[exchangeMapAFE state] forKey:@"UMMPexchangeMapAFE"];
                [[controller userDefaults] setInt:[exchangeMapCS state] forKey:@"UMMPexchangeMapCS"];
                
                isOK = YES;
            }
            break;
        case 9:
            if ([filtrationMapPF state] || [filtrationMapPMTT state] || [filtrationMapPV state] || [filtrationMapIMTT state] || [filtrationMapEF state] || [exchangeMapPSAP state] || [exchangeMapAFE state] || [exchangeMapCS state]) {
                
                [[self window] close];
                
                
                //filtration view
                [[controller userDefaults] setInt:[filtrationMapPF state]  forKey:@"UMMPfiltrationMapPF"];
                [[controller userDefaults] setInt:[filtrationMapPMTT state] forKey:@"UMMPfiltrationMapPMTT"];
                [[controller userDefaults] setInt:[filtrationMapPV state] forKey:@"UMMPfiltrationMapPV"];
                [[controller userDefaults] setInt:[filtrationMapIMTT state] forKey:@"UMMPfiltrationMapIMTT"];
                [[controller userDefaults] setInt:[filtrationMapEF state] forKey:@"UMMPfiltrationMapEF"];
                [[controller userDefaults] setInt:[filtrationMapPSAP state] forKey:@"UMMPfiltrationMapPSAP"];
                [[controller userDefaults] setInt:[filtrationMapAFE state] forKey:@"UMMPfiltrationMapAFE"];
                [[controller userDefaults] setInt:[filtrationMapCS state] forKey:@"UMMPfiltrationMapCS"];
                
                isOK = YES;
                
            }
            break;
        case 10:
            if ([uptakeMapPF state] || [uptakeMapPMTT state] || [uptakeMapPV state] || [uptakeMapEF state] || [uptakeMapPSAP state]|| [exchangeMapAFE state] || [exchangeMapCS state]) {
                
                [[self window] close];
                
                
                //uptake view
                [[controller userDefaults] setInt:[uptakeMapPF state]  forKey:@"UMMPuptakeMapPF"];
                [[controller userDefaults] setInt:[uptakeMapPMTT state] forKey:@"UMMPuptakeMapPMTT"];
                [[controller userDefaults] setInt:[uptakeMapPV state] forKey:@"UMMPuptakeMapPV"];
                [[controller userDefaults] setInt:[uptakeMapEF state] forKey:@"UMMPuptakeMapEF"];
                [[controller userDefaults] setInt:[uptakeMapPSAP state] forKey:@"UMMPuptakeMapPSAP"];
                [[controller userDefaults] setInt:[uptakeMapAFE state] forKey:@"UMMPuptakeMapAFE"];
                [[controller userDefaults] setInt:[uptakeMapCS state] forKey:@"UMMPuptakeMapCS"];
                
                isOK = YES;
            
            }
            break;
        case 11:
            if ([toftsMapPV state] || [toftsMapIMTT state] || [toftsMapIV state] || [toftsMapPSAP state] || [toftsMapAFE state] || [exchangeMapCS state]) {
                
                [[self window] close];
                
                //modified tofts view
                [[controller userDefaults] setInt:[toftsMapPV state]  forKey:@"UMMPtoftsMapPV"];
                [[controller userDefaults] setInt:[toftsMapIMTT state] forKey:@"UMMPtoftsMapIMTT"];
                [[controller userDefaults] setInt:[toftsMapIV state] forKey:@"UMMPtoftsMapIV"];
                [[controller userDefaults] setInt:[toftsMapPSAP state] forKey:@"UMMPtoftsMapPSAP"];
                [[controller userDefaults] setInt:[toftsMapAFE state] forKey:@"UMMPtoftsMapAFE"];
                [[controller userDefaults] setInt:[toftsMapCS state] forKey:@"UMMPtoftsMapCS"];
                
                isOK = YES;
                
            }
            break;
            
        case 16:
            if ([twoC2InletUptakeMapAF state] || [twoC2InletUptakeMapVF state] || [twoC2InletUptakeMapEV state] || [twoC2InletUptakeMapEMTT state] || [twoC2InletUptakeMapIUR state] || [twoC2InletUptakeMapADT state] || [twoC2InletUptakeMapVDT state] || [twoC2InletUptakeMapAFF state] || [twoC2InletUptakeMapHUF state] || [twoC2InletUptakeMapCAIC state] || [twoC2InletUptakeMapCS state]){
                
                [[self window] close];
                
                //2C 2Inlet Uptake view
                [[controller userDefaults] setInt:[twoC2InletUptakeMapAF state]  forKey:@"UMMPtwoC2InletUptakeMapAF"];
                [[controller userDefaults] setInt:[twoC2InletUptakeMapVF state] forKey:@"UMMPtwoC2InletUptakeMapVF"];
                [[controller userDefaults] setInt:[twoC2InletUptakeMapEV state] forKey:@"UMMPtwoC2InletUptakeMapEV"];
                [[controller userDefaults] setInt:[twoC2InletUptakeMapEMTT state] forKey:@"UMMPtwoC2InletUptakeMapEMTT"];
                [[controller userDefaults] setInt:[twoC2InletUptakeMapIUR state] forKey:@"UMMPtwoC2InletUptakeMapIUR"];
                [[controller userDefaults] setInt:[twoC2InletUptakeMapADT state] forKey:@"UMMPtwoC2InletUptakeMapADT"];
                [[controller userDefaults] setInt:[twoC2InletUptakeMapVDT state] forKey:@"UMMPtwoC2InletUptakeMapVDT"];
                [[controller userDefaults] setInt:[twoC2InletUptakeMapAFF state] forKey:@"UMMPtwoC2InletUptakeMapAFF"];
                [[controller userDefaults] setInt:[twoC2InletUptakeMapHUF state] forKey:@"UMMPtwoC2InletUptakeMapHUF"];
                [[controller userDefaults] setInt:[twoC2InletUptakeMapCAIC state] forKey:@"UMMPtwoC2InletUptakeMapCAIC"];
                [[controller userDefaults] setInt:[twoC2InletUptakeMapCS state] forKey:@"UMMPtwoC2InletUptakeMapCS"];
                
                isOK = YES;
                
            }
            break;
            
            
        default:
            break;
    }
   	
    
    if (isOK) {	
		[[controller algorithmController] startMapCalculation];
		
	}
	else {
        NSRunAlertPanel(@"Invalid Selection", @"Please select at least one map.", @"OK",nil,nil);
	}

	
}

- (void)refreshStatusOfMapSelection
{
    //Compartment view
	[compartmentMapPF setState:[[controller userDefaults] bool:@"UMMPcompartmentMapPF" otherwise:NO]];
	[compartmentMapPMTT setState:[[controller userDefaults] bool:@"UMMPcompartmentMapPMTT" otherwise:NO]];
	[compartmentMapPV setState:[[controller userDefaults] bool:@"UMMPcompartmentMapPV" otherwise:NO]];
	[compartmentMapAFE setState:[[controller userDefaults] bool:@"UMMPcompartmentMapAFE" otherwise:NO]];
	[compartmentMapCS setState:[[controller userDefaults] bool:@"UMMPcompartmentMapCS" otherwise:NO]];
	
	//Exchange view
	[exchangeMapPF setState:[[controller userDefaults] bool:@"UMMPexchangeMapPF" otherwise:NO]];
	[exchangeMapPMTT setState:[[controller userDefaults] bool:@"UMMPexchangeMapPMTT" otherwise:NO]];
	[exchangeMapPV setState:[[controller userDefaults] bool:@"UMMPexchangeMapPV" otherwise:NO]];
	[exchangeMapIMTT setState:[[controller userDefaults] bool:@"UMMPexchangeMapIMTT" otherwise:NO]];
	[exchangeMapIV setState:[[controller userDefaults] bool:@"UMMPexchangeMapIV" otherwise:NO]];
	[exchangeMapEF setState:[[controller userDefaults] bool:@"UMMPexchangeMapEF" otherwise:NO]];
	[exchangeMapPSAP setState:[[controller userDefaults] bool:@"UMMPexchangeMapPSAP" otherwise:NO]];
	[exchangeMapAFE setState:[[controller userDefaults] bool:@"UMMPexchangeMapAFE" otherwise:NO]];
	[exchangeMapCS setState:[[controller userDefaults] bool:@"UMMPexchangeMapCS" otherwise:NO]];
	
	//Filtration view
	[filtrationMapPF setState:[[controller userDefaults] bool:@"UMMPfiltrationMapPF" otherwise:NO]];
	[filtrationMapPMTT setState:[[controller userDefaults] bool:@"UMMPfiltrationMapPMTT" otherwise:NO]];
	[filtrationMapPV setState:[[controller userDefaults] bool:@"UMMPfiltrationMapPV" otherwise:NO]];
	[filtrationMapIMTT setState:[[controller userDefaults] bool:@"UMMPfiltrationMapIMTT" otherwise:NO]];
	[filtrationMapEF setState:[[controller userDefaults] bool:@"UMMPfiltrationMapEF" otherwise:NO]];
	[filtrationMapPSAP setState:[[controller userDefaults] bool:@"UMMPfiltrationMapPSAP" otherwise:NO]];
	[filtrationMapAFE setState:[[controller userDefaults] bool:@"UMMPfiltrationMapAFE" otherwise:NO]];
	[filtrationMapCS setState:[[controller userDefaults] bool:@"UMMPfiltrationMapCS" otherwise:NO]];
	
	//uptake view
	[uptakeMapPF setState:[[controller userDefaults] bool:@"UMMPuptakeMapPF" otherwise:NO]];
	[uptakeMapPMTT setState:[[controller userDefaults] bool:@"UMMPuptakeMapPMTT" otherwise:NO]];
	[uptakeMapPV setState:[[controller userDefaults] bool:@"UMMPuptakeMapPV" otherwise:NO]];
	[uptakeMapEF setState:[[controller userDefaults] bool:@"UMMPuptakeMapEF" otherwise:NO]];
	[uptakeMapPSAP setState:[[controller userDefaults] bool:@"UMMPuptakeMapPSAP" otherwise:NO]];
	[uptakeMapAFE setState:[[controller userDefaults] bool:@"UMMPuptakeMapAFE" otherwise:NO]];
	[uptakeMapCS setState:[[controller userDefaults] bool:@"UMMPuptakeMapCS" otherwise:NO]];
	
	//modified tots view
	[toftsMapPV setState:[[controller userDefaults] bool:@"UMMPtoftsMapPV" otherwise:NO]];
	[toftsMapIMTT setState:[[controller userDefaults] bool:@"UMMPtoftsMapIMTT" otherwise:NO]];
	[toftsMapIV setState:[[controller userDefaults] bool:@"UMMPtoftsMapIV" otherwise:NO]];
	[toftsMapPSAP setState:[[controller userDefaults] bool:@"UMMPtoftsMapPSAP" otherwise:NO]];
	[toftsMapAFE setState:[[controller userDefaults] bool:@"UMMPtoftsMapAFE" otherwise:NO]];
	[toftsMapCS setState:[[controller userDefaults] bool:@"UMMPtoftsMapCS" otherwise:NO]];
    
    //2C 2Inlet Uptake view
	[twoC2InletUptakeMapAF setState:[[controller userDefaults] bool:@"UMMPtwoC2InletUptakeMapAF" otherwise:NO]];
	[twoC2InletUptakeMapVF setState:[[controller userDefaults] bool:@"UMMPtwoC2InletUptakeMapVF" otherwise:NO]];
	[twoC2InletUptakeMapEV setState:[[controller userDefaults] bool:@"UMMPtwoC2InletUptakeMapEV" otherwise:NO]];
	[twoC2InletUptakeMapEMTT setState:[[controller userDefaults] bool:@"UMMPtwoC2InletUptakeMapEMTT" otherwise:NO]];
	[twoC2InletUptakeMapIUR setState:[[controller userDefaults] bool:@"UMMPtwoC2InletUptakeMapIUR" otherwise:NO]];
	[twoC2InletUptakeMapADT setState:[[controller userDefaults] bool:@"UMMPtwoC2InletUptakeMapADT" otherwise:NO]];
	[twoC2InletUptakeMapVDT setState:[[controller userDefaults] bool:@"UMMPtwoC2InletUptakeMapVDT" otherwise:NO]];
	[twoC2InletUptakeMapAFF setState:[[controller userDefaults] bool:@"UMMPtwoC2InletUptakeMapAFF" otherwise:NO]];
	[twoC2InletUptakeMapHUF setState:[[controller userDefaults] bool:@"UMMPtwoC2InletUptakeMapHUF" otherwise:NO]];
    [twoC2InletUptakeMapCAIC setState:[[controller userDefaults] bool:@"UMMPtwoC2InletUptakeMapCAIC" otherwise:NO]];
	[twoC2InletUptakeMapCS setState:[[controller userDefaults] bool:@"UMMPtwoC2InletUptakeMapCS" otherwise:NO]];
}

@end
