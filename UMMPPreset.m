//
//  UMMPPresets.m
//  UMMPerfusion
//
//  Created by Sven Kaiser on 02.11.11.
//  Copyright (c) 2012, Marcel Reich & Sven Kaiser & Markus Daab & Patrick Schülein & Engin Aslan
//  All rights reserved.
//

#import "UMMPPreset.h"

@implementation UMMPPreset

@synthesize name;
@synthesize presetTag;
@synthesize algorithms;

- (id)init {
    self = [super init];
    if (self) {
        name = @"Default";
        presetTag = [[NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]] integerValue] + rand() % 100 + 1;
        algorithms = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                      [self createCompartmentParameters], @"Compartment",
                      [self createExchangeParameters], @"2C Exchange",
					  [self createFiltrationParameters], @"2C Filtration",
                      [self createUptakeParameters], @"2C Uptake",
                      [self createToftsParameters], @"Modified Tofts",
                      [self createDoubleInletUptakeParameters], @"2Inlet 2C Uptake",
                      nil];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{    
    self = [super init];
    if (self) {
        name = [[aDecoder decodeObjectForKey:@"PresetName"] retain];
        presetTag = [aDecoder decodeIntegerForKey:@"PresetTag"];
        NSDictionary *dict = [aDecoder decodeObjectForKey:@"PresetAlgorithms"];
        algorithms = [[NSMutableDictionary dictionaryWithDictionary:dict] retain];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:name forKey:@"PresetName"];
    [aCoder encodeInteger:presetTag forKey:@"PresetTag"];
    [aCoder encodeObject:algorithms forKey:@"PresetAlgorithms"];
}

- (NSMutableArray *)createCompartmentParameters
{
    NSMutableArray *array = [NSMutableArray array];
    UMMPParameter *parameterItem;
    parameterItem = [[UMMPParameter alloc] initWithName:@"V"
                                             andToolTip:@"Volume"
                                               andValue:0.3
                                                isFixed:NO
                                          isLimitedHigh:YES
                                           isLimitedLow:YES
                                            higherLimit:1.0
                                             lowerLimit:0.0];
    [array addObject: parameterItem];
    [parameterItem release];
    
    parameterItem = [[UMMPParameter alloc] initWithName:@"F"
                                             andToolTip:@"Flow"
                                               andValue:120.0/6000.0
                                                isFixed:NO
                                          isLimitedHigh:YES
                                           isLimitedLow:YES
                                            higherLimit:1.0
                                             lowerLimit:0.0];
    [array addObject: parameterItem];
    [parameterItem release];
    
    return array;
}


- (NSMutableArray *)createExchangeParameters
{
    NSMutableArray *array = [NSMutableArray array];
    UMMPParameter *parameterItem;
    parameterItem = [[UMMPParameter alloc] initWithName:@"VP+VE"
                                             andToolTip:@"Volume"
                                               andValue:0.3
                                                isFixed:NO
                                          isLimitedHigh:NO
                                           isLimitedLow:YES
                                            higherLimit:1.0
                                             lowerLimit:0.0];
    [array addObject: parameterItem];
    [parameterItem release];
    
    parameterItem = [[UMMPParameter alloc] initWithName:@"FP"
                                             andToolTip:@"Plasma Flow"
                                               andValue:0.02
                                                isFixed:NO
                                          isLimitedHigh:NO
                                           isLimitedLow:NO
                                            higherLimit:1.0
                                             lowerLimit:0.0];
    [array addObject: parameterItem];
    [parameterItem release];
    
    parameterItem = [[UMMPParameter alloc] initWithName:@"VE/(VP+VE)"
                                             andToolTip:@"Volume Fraction"
                                               andValue:2.0/3.0
                                                isFixed:NO
                                          isLimitedHigh:NO
                                           isLimitedLow:YES
                                            higherLimit:1.0
                                             lowerLimit:0.0];
    [array addObject: parameterItem];
    [parameterItem release];
    
    parameterItem = [[UMMPParameter alloc] initWithName:@"PS/(FP+PS)"
                                             andToolTip:@"Extraction Fraction/Flow"
                                               andValue:0.1
                                                isFixed:NO
                                          isLimitedHigh:NO
                                           isLimitedLow:YES
                                            higherLimit:1.0
                                             lowerLimit:0.0];
    [array addObject: parameterItem];
    [parameterItem release];
    
    return array;
}


- (NSMutableArray *)createFiltrationParameters
{
    NSMutableArray *array = [NSMutableArray array];
    UMMPParameter *parameterItem;
    parameterItem = [[UMMPParameter alloc] initWithName:@"VP+VE"
                                             andToolTip:@"Volume"
                                               andValue:0.3
                                                isFixed:NO
                                          isLimitedHigh:NO
                                           isLimitedLow:YES
                                            higherLimit:1.0
                                             lowerLimit:0.0];
    [array addObject: parameterItem];
    [parameterItem release];
    
    parameterItem = [[UMMPParameter alloc] initWithName:@"FP"
                                             andToolTip:@"Plasma Flow"
                                               andValue:0.02
                                                isFixed:NO
                                          isLimitedHigh:NO
                                           isLimitedLow:NO
                                            higherLimit:1.0
                                             lowerLimit:0.0];
    [array addObject: parameterItem];
    [parameterItem release];
    
    parameterItem = [[UMMPParameter alloc] initWithName:@"VE/(VP+VE)"
                                             andToolTip:@"Volume Fraction"
                                               andValue:2.0/3.0
                                                isFixed:NO
                                          isLimitedHigh:NO
                                           isLimitedLow:YES
                                            higherLimit:1.0
                                             lowerLimit:0.0];
    [array addObject: parameterItem];
    [parameterItem release];
    
    parameterItem = [[UMMPParameter alloc] initWithName:@"PS/(FP+PS)"
                                             andToolTip:@"Extraction Fraction/Flow"
                                               andValue:0.09
                                                isFixed:NO
                                          isLimitedHigh:NO
                                           isLimitedLow:YES
                                            higherLimit:1.0
                                             lowerLimit:0.0];
    [array addObject: parameterItem];
    [parameterItem release];
    
    return array;
}


- (NSMutableArray *)createUptakeParameters
{
    NSMutableArray *array = [NSMutableArray array];
    UMMPParameter *parameterItem;
    parameterItem = [[UMMPParameter alloc] initWithName:@"VP"
                                             andToolTip:@"Plasma Volume"
                                               andValue:0.3
                                                isFixed:NO
                                          isLimitedHigh:NO
                                           isLimitedLow:YES
                                            higherLimit:1.0
                                             lowerLimit:0.0];
    [array addObject: parameterItem];
    [parameterItem release];
    
    parameterItem = [[UMMPParameter alloc] initWithName:@"FP"
                                             andToolTip:@"Plasma Flow"
                                               andValue:120.0/6000.0
                                                isFixed:NO
                                          isLimitedHigh:NO
                                           isLimitedLow:NO
                                            higherLimit:1.0
                                             lowerLimit:0.0];
    [array addObject: parameterItem];
    [parameterItem release];
    
    parameterItem = [[UMMPParameter alloc] initWithName:@"PS/(FP+PS)"
                                             andToolTip:@"Extraction Fraction"
                                               andValue:12.0/132.0
                                                isFixed:NO
                                          isLimitedHigh:NO
                                           isLimitedLow:YES
											higherLimit:1.0
                                             lowerLimit:0.0];
    [array addObject: parameterItem];
    [parameterItem release];
    
    return array;
}

- (NSMutableArray *)createToftsParameters
{
    NSMutableArray *array = [NSMutableArray array];
    UMMPParameter *parameterItem;
    parameterItem = [[UMMPParameter alloc] initWithName:@"VP+VE"
                                             andToolTip:@"Volume"
                                               andValue:0.3
                                                isFixed:NO
                                          isLimitedHigh:NO
                                           isLimitedLow:YES
                                            higherLimit:1.0
                                             lowerLimit:0.0];
    [array addObject: parameterItem];
    [parameterItem release];
    
    parameterItem = [[UMMPParameter alloc] initWithName:@"VE/(VP+VE)"
                                             andToolTip:@"Volume Fraction"
                                               andValue:2.0/3.0
                                                isFixed:NO
                                          isLimitedHigh:NO
                                           isLimitedLow:YES
                                            higherLimit:1.0
                                             lowerLimit:0.0];
    [array addObject: parameterItem];
    [parameterItem release];
    
    parameterItem = [[UMMPParameter alloc] initWithName:@"PS"
                                             andToolTip:@"Extraction Fraction/Flow"
                                               andValue:12.0/6000.0
                                                isFixed:NO
                                          isLimitedHigh:NO
                                           isLimitedLow:NO
											higherLimit:1.0
                                             lowerLimit:0.0];
    [array addObject: parameterItem];
    [parameterItem release];
    
    return array;
}
                      
- (NSMutableArray *)createDoubleInletUptakeParameters
        {
            NSMutableArray *array = [NSMutableArray array];
            UMMPParameter *parameterItem;
            parameterItem = [[UMMPParameter alloc] initWithName:@"VE"
                                                     andToolTip:@"Volume"
                                                       andValue:0.16
                                                        isFixed:NO
                                                  isLimitedHigh:NO
                                                   isLimitedLow:YES
                                                    higherLimit:1.0
                                                     lowerLimit:0.0];
            [array addObject: parameterItem];
            [parameterItem release];
            
            parameterItem = [[UMMPParameter alloc] initWithName:@"FA"
                                                     andToolTip:@"Arterial Plasma Flow"
                                                       andValue:0.0012
                                                        isFixed:NO
                                                  isLimitedHigh:NO
                                                   isLimitedLow:YES
                                                    higherLimit:1.0
                                                     lowerLimit:0.0];
            [array addObject: parameterItem];
            [parameterItem release];
            
            parameterItem = [[UMMPParameter alloc] initWithName:@"FV"
                                                     andToolTip:@"Venous Plasma Flow"
                                                       andValue:0.0067
                                                        isFixed:NO
                                                  isLimitedHigh:NO
                                                   isLimitedLow:YES
                                                    higherLimit:1.0
                                                     lowerLimit:0.0];
            [array addObject: parameterItem];
            [parameterItem release];
            
            parameterItem = [[UMMPParameter alloc] initWithName:@"KI"
                                                     andToolTip:@"Intracellular Uptake Rate"
                                                       andValue:0.05
                                                        isFixed:NO
                                                  isLimitedHigh:YES
                                                   isLimitedLow:YES
                                                    higherLimit:1.0
                                                     lowerLimit:0.0];
            [array addObject: parameterItem];
            [parameterItem release];
            
            parameterItem = [[UMMPParameter alloc] initWithName:@"TA"
                                                     andToolTip:@"Arterial Delay Time"
                                                       andValue:0.0
                                                        isFixed:NO
                                                  isLimitedHigh:NO
                                                   isLimitedLow:NO
                                                    higherLimit:1.0
                                                     lowerLimit:0.0];
            [array addObject: parameterItem];
            [parameterItem release];
            
            parameterItem = [[UMMPParameter alloc] initWithName:@"TV"
                                                     andToolTip:@"Venous Delay Time"
                                                       andValue:0.0
                                                        isFixed:NO
                                                  isLimitedHigh:NO
                                                   isLimitedLow:NO
                                                    higherLimit:1.0
                                                     lowerLimit:0.0];
            [array addObject: parameterItem];
            [parameterItem release];
            
            return array;
        }

@end



@implementation UMMPParameter

@synthesize name;
@synthesize fixed;
@synthesize limitedHigh;
@synthesize limitedLow;
@synthesize high;
@synthesize low;
@synthesize pValue;

- (id)initWithName:(NSString *)aName
        andToolTip:(NSString *)aToolTip
          andValue:(double)aValue
           isFixed:(BOOL)isFixed
         isLimitedHigh:(BOOL)isLimitedHigh
         isLimitedLow:(BOOL)isLimitedLow
       higherLimit:(double)higherLimit
        lowerLimit:(double)lowerLimit
{
    self = [super init];
    if (self) {
        name = aName;
        toolTip = aToolTip;
        pValue = aValue;
        fixed = isFixed;
        limitedLow = isLimitedLow;
        limitedHigh = isLimitedHigh;
        high = higherLimit;
        low = lowerLimit;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{    
    self = [super init];
    if (self) {
        name = [[aDecoder decodeObjectForKey:@"ParameterName"] retain];
        toolTip = [[aDecoder decodeObjectForKey:@"ParameterToolTip"] retain];
        pValue = [aDecoder decodeDoubleForKey:@"ParameterValue"];
        fixed = [aDecoder decodeBoolForKey:@"ParameterFixed"];
        limitedHigh = [aDecoder decodeBoolForKey:@"ParameterLimitedHigh"];
        limitedLow = [aDecoder decodeBoolForKey:@"ParameterLimitedLow"];
        high = [aDecoder decodeDoubleForKey:@"ParameterHigh"];
        low = [aDecoder decodeDoubleForKey:@"ParameterLow"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{    
    [aCoder encodeObject:name forKey:@"ParameterName"];
    [aCoder encodeObject:toolTip forKey:@"ParameterToolTip"];
    [aCoder encodeDouble:pValue forKey:@"ParameterValue"];
    [aCoder encodeBool:fixed forKey:@"ParameterFixed"];
    [aCoder encodeBool:limitedHigh forKey:@"ParameterLimitedHigh"];
    [aCoder encodeBool:limitedLow forKey:@"ParameterLimitedLow"];
    [aCoder encodeDouble:high forKey:@"ParameterHigh"];
    [aCoder encodeDouble:low forKey:@"ParameterLow"];
    
}

@end
