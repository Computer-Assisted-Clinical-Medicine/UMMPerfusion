//
//  UMMPerfusionFilter.h
//  UMMPerfusion
//
//  Copyright (c) 2012, Marcel Reich & Sven Kaiser & Markus Daab & Patrick Schülein & Engin Aslan
//  All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OsiriXAPI/PluginFilter.h>
@class UMMPPanelController;


/**
 this is the class which is createt when starting the plugin from the OsiriX menu
 the initPlugin method is called when OsiriX starts so you could do some adjustments there
 
 */

@interface UMMPerfusionFilter : PluginFilter {
    UMMPPanelController *panel;
}

/**
 this method is called when the Plugin starts. it does some initializtions and checks if the user is using
 the newest version
 @param menuName 
 */
- (long) filterImage:(NSString*) menuName;

/**
 this method is used to duplicate the current viewer.
 this is neccessary when using fastDeconvolution- or a pixelBased algorithm to generate new viewers where the results can be shown in
 @param vc the viewerController in which the plugin is started
 @param deleteROIs a BOOL variable to determine if the ROIs in the viewer shall be deleted after duplication
 */
- (ViewerController *) duplicateViewer:(ViewerController *)vc deleteROIs:(BOOL)deleteROIs;

@end
