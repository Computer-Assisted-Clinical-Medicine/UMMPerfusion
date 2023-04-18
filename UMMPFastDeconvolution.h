//
//  UMMPFastDeconvolution.h
//  UMMPerfusion
//
//  Created by Sven Kaiser on 22.11.11
//  Modified by Markus Daab & Patrick Schülein & Engin Aslan
//  Copyright (c) 2012. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UMMPFastDeconvolution : NSObject

+(int)fd:(int)n :(int) height :(int) width :(double *)p :(float *)aif :(double *)time :(int )tracer :(int) bl :(double) htc :(double) regParam :(float *)pf :(float *)vd :(float *)mt :(int)timepointsOfStartSlider;
+(void)lmuEnhancement:(float *)aif :(int)n :(int)bl :(int)tracer;
+(void)lmuEnhancementP:(double *)p :(int )n :(int )imageSize :(int )bl :(int )tracer;
+(void)convolutionMatrix:(float *)aif :(double **)matrix :(int )n :(double )deltaT;
+(void)calculateDeltaT:(int)n :(double *)time :(double *)deltaT :(double *)min :(double *)max :(int)timepointsOfStartSlider;
+(void)aifRegrid:(float *)aif :(double *)time :(int)n  :(float *)aifRegr :(double *)timeRegr :(int)m;
+(void)interpol2D:(double *)time :(int)n :(double *)timeRegr :(int)m :(double *)p :(double *)pol :(int)imageSize;

@end
