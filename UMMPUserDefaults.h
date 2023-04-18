//
//  UMMPUserDefaults.h
//  UMMPerfusion
//
//  Created by UMMPerfusion on 06.06.12.
//  Copyright (c) 2012, Marcel Reich & Sven Kaiser & Markus Daab & Patrick Schülein & Engin Aslan
//  All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface UMMPUserDefaults : NSObject {
	NSMutableDictionary* _dictionary;
   // NSUserDefaults* _osirixDefaults;
		
}

-(id)init;
-(void)save;
-(BOOL)keyExists:(NSString*)key;
-(BOOL)bool:(NSString*)key otherwise:(BOOL)otherwise;
-(void)setBool:(BOOL)value forKey:(NSString*)key;
-(int)int:(NSString*)key otherwise:(int)otherwise;
-(void)setInt:(int)value forKey:(NSString*)key;
-(float)float:(NSString*)key otherwise:(float)otherwise;
-(void)setFloat:(float)value forKey:(NSString*)key;
-(void)setString:(NSString*)string forKey:(NSString*)key;
-(NSString*)string:(NSString*)key otherwise:(NSString*)otherwise;
-(id)obj:(NSString*)key otherwise:(id)otherwise;
-(void)setObj:(id)data forKey:(NSString*)key;

@end
