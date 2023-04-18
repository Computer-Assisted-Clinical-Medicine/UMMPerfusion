//
//  UMMPBinding.m
//  UMMPerfusion
//
//  Created by Sven Kaiser on 19.10.11.
//  Copyright (c) 2012, Marcel Reich & Sven Kaiser & Markus Daab & Patrick Schülein & Engin Aslan
//  All rights reserved.
//

#import "UMMPBinding.h"

@implementation UMMPBinding

- (id)init {
    self = [super init];
    if (self) {
        [self setValue:[NSNumber numberWithInteger:0] forKey:@"tracerIndex"];
        [self setValue:[NSNumber numberWithInteger:5] forKey:@"baselineLength"];
        [self setValue:[NSNumber numberWithDouble:0.45] forKey:@"htc"];
        [self setValue:[NSNumber numberWithDouble:0.15] forKey:@"regularization"];
    }
    return self;
}

-(BOOL)validateBaselineLength:(id *)ioValue error:(NSError **)outError
{
    if (*ioValue == nil)
        *ioValue = [NSNumber numberWithInteger:5];
    
    if ([*ioValue integerValue] <= 0) {
        NSString *errorString = NSLocalizedStringFromTable(@"Baseline must be greater than zero", @"baselineLength",
                                                           @"validation: negative baselineLength error");
        NSDictionary *userInfoDict = [NSDictionary dictionaryWithObject:errorString forKey:NSLocalizedDescriptionKey];
        
        NSError *error = [[[NSError alloc] initWithDomain:NSMachErrorDomain code:0 userInfo:userInfoDict] autorelease];
        if(outError != NULL) *outError = error;
        return NO;
    }
    
    if ([*ioValue integerValue] > stopSliderMax) {
        NSString *descritption = [NSString stringWithFormat:@"Baseline must be less or equal than %d", stopSliderMax];
        NSString *errorString = NSLocalizedStringFromTable(descritption, @"baselineLength",
                                                           @"validation: negative baselineLength error");
        NSDictionary *userInfoDict = [NSDictionary dictionaryWithObject:errorString forKey:NSLocalizedDescriptionKey];
        
        NSError *error = [[[NSError alloc] initWithDomain:NSMachErrorDomain code:0 userInfo:userInfoDict] autorelease];
        if(outError != NULL) *outError = error;
        return NO;
    }
   
    return YES;
}

-(BOOL)validateHtc:(id *)ioValue error:(NSError **)outError
{
    if (*ioValue == nil)
        *ioValue = [NSNumber numberWithDouble:0.45];
    
    if ([*ioValue doubleValue] <= 0.0) {
        NSString *errorString = NSLocalizedStringFromTable(@"Hematocrit must be greater than 0.0", @"htc",
                                                           @"validation: negative htc error");
        NSDictionary *userInfoDict = [NSDictionary dictionaryWithObject:errorString forKey:NSLocalizedDescriptionKey];
        
        NSError *error = [[[NSError alloc] initWithDomain:NSMachErrorDomain code:0 userInfo:userInfoDict] autorelease];
        if(outError != NULL) *outError = error;
        return NO;
    }
    
    if ([*ioValue doubleValue] > 1.0) {
        NSString *errorString = NSLocalizedStringFromTable(@"Hematocrit must be lower than 1.0", @"htc",
                                                           @"validation: forbidden htc error");
        NSDictionary *userInfoDict = [NSDictionary dictionaryWithObject:errorString forKey:NSLocalizedDescriptionKey];
        
        NSError *error = [[[NSError alloc] initWithDomain:NSMachErrorDomain code:0 userInfo:userInfoDict] autorelease];
        if(outError != NULL) *outError = error;
        return NO;
    }
    
    return YES;
}

-(BOOL)validateRegularization:(id *)ioValue error:(NSError **)outError
{
    if (*ioValue == nil)
        *ioValue = [NSNumber numberWithDouble:0.15];
    
    if ([*ioValue doubleValue] <= 0.0) {
        NSString *errorString = NSLocalizedStringFromTable(@"Regularization must be greater than 0.0", @"regularization",
                                                           @"validation: negative regularization error");
        NSDictionary *userInfoDict = [NSDictionary dictionaryWithObject:errorString forKey:NSLocalizedDescriptionKey];
        
        NSError *error = [[[NSError alloc] initWithDomain:NSMachErrorDomain code:0 userInfo:userInfoDict] autorelease];
        if(outError != NULL) *outError = error;
        return NO;
    }
    
    if ([*ioValue doubleValue] > 1.0) {
        NSString *errorString = NSLocalizedStringFromTable(@"Regularization must be lower than 1.0", @"regularization",
                                                           @"validation: forbidden regularization error");
        NSDictionary *userInfoDict = [NSDictionary dictionaryWithObject:errorString forKey:NSLocalizedDescriptionKey];
        
        NSError *error = [[[NSError alloc] initWithDomain:NSMachErrorDomain code:0 userInfo:userInfoDict] autorelease];
        if(outError != NULL) *outError = error;
        return NO;
    }
    
    return YES;
}

-(void)setNilValueForKey:(NSString *)theKey
{
	if ([theKey isEqualToString:@"tracerIndex"]) {
        [self setValue:[NSNumber numberWithInteger:0] forKey:@"tracerIndex"];
        
    } else if ([theKey isEqualToString:@"baselineLength"]) {
        [self setValue:[NSNumber numberWithInteger:5] forKey:@"baselineLength"];
        
	} else if ([theKey isEqualToString:@"htc"]) {
        [self setValue:[NSNumber numberWithDouble:0.45] forKey:@"htc"];
        
	} else if ([theKey isEqualToString:@"regularization"]) {
        [self setValue:[NSNumber numberWithDouble:0.15] forKey:@"regularization"];
        
	} else {
        [super setNilValueForKey:theKey];
	}
}

@end
