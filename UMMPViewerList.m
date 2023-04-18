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

#import "UMMPViewerList.h"
#import "UMMPPanelController.h"
#import <OsiriXAPI/Notifications.h>

@implementation UMMPViewer

@synthesize viewer = _viewer;
@synthesize uniqueID = _uniqueID;

- (id)init:(ViewerController *)viewer name:(NSString *)name forList:(UMMPViewerList *)viewerList
{
	self = [super init];
	
	_viewer = [viewer retain];
	_name = [name retain];
	_uniqueID = [[NSNumber alloc] initWithInt:5300 + [[NSCalendarDate date] minuteOfHour] + [[NSCalendarDate date] secondOfMinute]];
	_viewerList = viewerList;
	
	return self;
}

- (void)dealloc
{
	[_name release]; _name = NULL;
	[_uniqueID release]; _uniqueID = NULL;
	[_viewer release]; _viewer = NULL;

	[super dealloc];
}


- (void)setName:(NSString *)name
{
	[name retain];
	[_name release];
	_name = name;
}


- (NSString *)name
{
	return _name;
}

@end



@implementation UMMPViewerList

@synthesize viewers=_viewers;

- (void)awakeFromNib
{
	_counter = 0;
	_viewers = [[NSMutableArray alloc] init];
}


- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[_viewers release]; _viewers = NULL;
	[super dealloc];
}


- (void)addViewer:(ViewerController *)viewer name:(NSString *)name
{
	if (![self isInViewerList:viewer]) {
		UMMPViewer *vc = [[UMMPViewer alloc] init:viewer name:name forList:self];
		[_viewers addObject:vc];
		_counter++;
	}
}


- (UMMPViewer *)findViewerByObject:(ViewerController *)viewer
{
	unsigned i;
	
	for (i = 0; i < [_viewers count]; i++) {
		UMMPViewer *vc = [_viewers objectAtIndex:i];
		
		if ([vc viewer] == viewer)
			return vc;
	}
	
	return NULL;
}


- (int)indexOfObject:(ViewerController *)viewer
{
	unsigned i;
	
	for (i = 0; i < [_viewers count]; i++) {
		UMMPViewer *vc = [_viewers objectAtIndex:i];
		
		if ([vc viewer] == viewer)
			return i;
	}
	
	return -1;
}


- (UMMPViewer *)objectAtIndex:(int)index
{
	return [_viewers objectAtIndex:index];
}


- (BOOL)isInViewerList:(ViewerController *)viewer
{
	unsigned i;
	
	for (i = 0; i < [_viewers count]; i++) {
		UMMPViewer *vc = [_viewers objectAtIndex:i];
		
		if ([vc viewer] == viewer)
			return YES;
	}
	
	return NO;
}


- (int)count
{
	return _counter;
}


- (void)removeViewer:(NSNotification *)notification
{
	ViewerController *vc = [notification object];
	
	if (!vc)
		return;
	
	if ([self isInViewerList:vc]) {
		[_viewers removeObjectAtIndex:[self indexOfObject:vc]];
		_counter--;
	}
}

- (void)print
{
	unsigned i;
	for (i = 0; i < [_viewers count]; i++)
		NSLog(@"[%d] = %@", i, [[_viewers objectAtIndex:i] name]);
}

@end