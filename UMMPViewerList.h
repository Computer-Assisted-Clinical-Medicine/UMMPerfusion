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

@class ViewerController;
@class UMMPPanelController;
@class UMMPViewerList;

/**
 * @class UMMPViewer
 *
 * @brief UMMPViewer is a wrapper object to store ViewerController and make them unique with a ID.
 */

@interface UMMPViewer: NSObject {
	
	UMMPViewerList *_viewerList; //!< Every UMMPViewer knows it is  in UMMPViewerList
	ViewerController *_viewer; //!< ViewerController object from OsiriX
	NSString *_name; //!< Name for different type of ViwerController (e.g. PF,VD)
	NSNumber *_uniqueID; //!< Unique id
}

@property (readonly) ViewerController *viewer;
@property (readonly) NSNumber *uniqueID;

- (id)init:(ViewerController *)viewer name:(NSString *)name forList:(UMMPViewerList *)_viewerList;
- (void)setName:(NSString *)name;
- (NSString *)name;

@end

// #############################################################################

/**
 * @class UMMPViewerList
 *
 * @brief UMMPViewerList manages and stores UMMPViewer.
 */

@interface UMMPViewerList : NSObject {
	
//	IBOutlet UMMPPanelController *_controller; //!< Connection to UMMPPanelController
	NSMutableArray *_viewers; //!< stores UMMPViewers
	int _counter; //!< Count of all sored viewers

}

@property (readonly) NSMutableArray *viewers;

/**
 * @brief Used to do some arrangements
 */
- (void)awakeFromNib;

/**
 * @brief Adds a new viewer to the UMMPViewerList
 *
 * Allocates and initializes a new UMMPViewer with the ViewerController object and a specific name.
 *
 * @param ViewerController object
 * @param Specific name
 */
- (void)addViewer:(ViewerController *)viewer name:(NSString *)name;

/**
 * @brief Afford the needed UMMPViewer to a specific ViewerController
 *
 * Runs over the NSMutableArray _viewers and returns the founded UMMPViewer by making a
 * comparison by the stored ViewerController and the passed ViewerController.
 *
 * @param ViewerController for needed UMMPViewer
 * @return ViewerController object
 */
- (UMMPViewer *)findViewerByObject:(ViewerController *)viewer;

/**
 * @brief Afford the needed UMMPViewer to a specific index
 *
 * Runs over the NSMutableArray _viewers and returns the UMMPViewer by the specific index.
 *
 * @param Index for needed UMMPViewer
 * @return ViewerController object
 */
- (UMMPViewer *)objectAtIndex:(int)index;

/**
 * @brief Check whether a ViewerController is in UMMPViewerList
 *
 * Runs over the NSMutableArray _viewers and check if a ViewerController is in the list by making a
 * comparison by the stored ViewerController and the passed ViewerController.
 *
 * @param ViewerController for checking
 * @return YES is in UMMPViewerList, NO otherwise
 */
- (BOOL)isInViewerList:(ViewerController *)viewer;

/**
 * @brief Afford the count of all sored viewers
 *
 * @return count of viewers
 */
- (int)count;

/**
 * @brief Removes the passed ViewerController from UMMPViewerList
 *
 * Runs over the NSMutableArray _viewers and check if a ViewerController is in the list by making a
 * comparison by the stored ViewerController and removes it.
 *
 * @param ViewerController that has to be removed
 */
- (void)removeViewer:(NSNotification *)notification;

/**
 * @brief Afford the index of the located ViewerController
 *
 * Runs over the NSMutableArray _viewers and check if a ViewerController is in the list by making a
 * comparison by the stored ViewerController and returns it located index.
 *
 * @param ViewerController for needed index
 * @return Index of ViewerController
 */
- (int)indexOfObject:(ViewerController *)viewer;


- (void)print;

@end
