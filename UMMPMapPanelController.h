//
//  UMMPMapPanelController.h
//  UMMPerfusion
//
//  Created by Marcel Reich on 21.09.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OsiriXAPI/ViewerController.h>

@class UMMPPanelController;
@class ViewerController;


@interface UMMPMapPanelController : NSWindowController {
    
    IBOutlet UMMPPanelController *panelController;
    
    IBOutlet NSView *_compartmentView;
    IBOutlet NSView *_exchangeView;
    IBOutlet NSView *_uptakeView;
    IBOutlet NSView *_toftsView;
	
	ViewerController *_viewer;
}

@property (readonly) NSView *compartmentView;
@property (readonly) NSView *exchangeView;
@property (readonly) NSView *uptakeView;
@property (readonly) NSView *toftsView;

- (IBAction)pushOKButton:(id)sender;

@end
