//
//  UMMPMapPanelController.m
//  UMMPerfusion
//
//  Created by Marcel Reich on 21.09.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "UMMPMapPanelController.h"
#import "UMMPPanelController.h"
#import "UMMPROIList.h"

#import <OsiriXAPI/Notifications.h>

@implementation UMMPMapPanelController

@synthesize compartmentView = _compartmentView;
@synthesize exchangeView = _exchangeView;
@synthesize uptakeView = _uptakeView;
@synthesize toftsView = _toftsView;

- (IBAction)pushOKButton:(id)sender
{
//	NSMutableDictionary *maps = [[[NSMutableDictionary alloc] init] autorelease];
//	[maps setObject:[NSNumber numberWithInteger:[_plasmaFlow state]] forKey:@"plasmaFlow"];
//	[maps setObject:[NSNumber numberWithInteger:[_plasmaMTT state]] forKey:@"plasmaMTT"];
//	[maps setObject:[NSNumber numberWithInteger:[_plasmaVolume state]] forKey:@"plasmaVolume"];
//	[maps setObject:[NSNumber numberWithInteger:[_interstitialMTT state]] forKey:@"interstitialMTT"];
//	[maps setObject:[NSNumber numberWithInteger:[_interstitialVolume state]] forKey:@"interstitialVolume"];
//	[maps setObject:[NSNumber numberWithInteger:[_extractionFraction state]] forKey:@"extractionFraction"];
//	[maps setObject:[NSNumber numberWithInteger:[_areaProduct state]] forKey:@"areaProduct"];
//	[maps setObject:[NSNumber numberWithInteger:[_chiSquare state]] forKey:@"chiSquare"];
//	[maps setObject:[NSNumber numberWithInteger:[_akaikeFitError state]] forKey:@"akaikeFitError"];
    
    NSLog(@"%d", [[NSUserDefaults standardUserDefaults] boolForKey:@"cmCS"]);

	[[self window] orderOut:nil];
//	[_mainController startAlgorithmForTag:_tag withMaps:maps];
	[[self window] close];
}

@end
