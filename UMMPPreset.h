//
//  UMMPPresets.h
//  UMMPerfusion
//
//  Created by Sven Kaiser on 02.11.11.
//  Copyright (c) 2012, Marcel Reich & Sven Kaiser & Markus Daab & Patrick Schülein & Engin Aslan
//  All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UMMPPreset : NSObject <NSCoding> {
    NSString *name;
    NSInteger presetTag;
    NSMutableDictionary *algorithms;
}

@property (retain) NSString *name;
@property (readonly) NSInteger presetTag;
@property (readonly) NSMutableDictionary *algorithms;

- (NSMutableArray *)createCompartmentParameters;
- (NSMutableArray *)createExchangeParameters;
- (NSMutableArray *)createFiltrationParameters;
- (NSMutableArray *)createUptakeParameters;
- (NSMutableArray *)createToftsParameters;
- (NSMutableArray *)createDoubleInletUptakeParameters;

@end



@interface UMMPParameter : NSObject <NSCoding> {
@private
    NSString *name;
    NSString *toolTip;
    double pValue;
    BOOL fixed;
    BOOL limitedHigh;
    BOOL limitedLow;
    double high;
    double low;
}

@property (readonly) NSString *name;
@property (readonly) double pValue;
@property (readonly) BOOL fixed;
@property (readonly) BOOL limitedHigh;
@property (readonly) BOOL limitedLow;
@property (readonly) double high;
@property (readonly) double low;

- (id)initWithName:(NSString *)aName
        andToolTip:(NSString *)aToolTip
          andValue:(double)aValue
           isFixed:(BOOL)isFixed
     isLimitedHigh:(BOOL)isLimitedHigh
      isLimitedLow:(BOOL)isLimitedLow
       higherLimit:(double)higherLimit
        lowerLimit:(double)lowerLimit;

@end
