/*
 Copyright (c) 2012, Marcel Reich & Sven Kaiser & Patrick Schülein & Markus Daab & Engin Aslan
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

#include "mpfit.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

void expConvolute(int m, double k, double *time, float *aif, double *y, double *der);
void convolute(double *vector1, double *vector2, double *time, unsigned length, double *convolutedVector);
double getLinearInterpolatedAIFValueForTimepoint(float *aif, double *time, int length, double timepoint);
int singleInletCompartement(int m, int n, double *p, double *dy, double **dvec, void *vars);
int singleInletExchange(int m, int n, double *p, double *dy, double **dvec, void *vars);
int singleInletFiltration(int m, int n, double *p, double *dy, double **dvec, void *vars);
int singleInletUptake(int m, int n, double *p, double *dy, double **dvec, void *vars);
int singleInletModifiedTofts(int m, int n, double *p, double *dy, double **dvec, void *vars);
int fitSingleInletCompartment(int m, double  *p, int *fixed, int *limited, double *limits, int maxiterations, int maxFunctionEvaluation, double *time, float *aif, float *tissue, double *curveFit, double *pf, double *vd, double *mt, double *correctedAkaikeError, double *chiSquare, double *xError);
int fitSingleInletExchange(int m, double  *p, int *fixed, int *limited, double *limits, int maxiterations, int maxFunctionEvaluation, double *time, float *aif, float *tissue, double *curveFit, double *pf, double *pv, double *mt, double *imt, double *iv, double *ef, double *per, double *correctedAkaikeError, double *chiSquare, double *xError);
int fitSingleInletFiltration(int m, double  *p, int *fixed, int *limited, double *limits, int maxiterations, int maxFunctionEvaluation, double *time, float *aif, float *tissue, double *curveFit, double *pf, double *pv, double *mt, double *imt, double *iv, double *ef, double *per, double *correctedAkaikeError, double *chiSquare, double *xError);
int fitSingleInletUptake(int m, double  *p, int *fixed, int *limited, double *limits, int maxiterations, int maxFunctionEvaluation, double *time, float *aif, float *tissue, double *curveFit, double *pf, double *pv, double *mt, double *ef, double *per, double *correctedAkaikeError, double *chiSquare, double *xError);
int fitDoubleInletUptake(int m, double  *p, int *fixed, int *limited, double *limits, int maxiterations, int maxFunctionEvaluation, double *time, float *aif, float *vif, float *tissue, double *curveFit, double *af, double *vf, double *ve, double *ki, double *aDelayTime, double *vDelayTime, double *fi, double *fa, double *te, double *correctedAkaikeError, double *chiSquare, double *xError);
int fitSingleInletModifiedTofts(int m, double  *p, int *fixed, int *limited, double *limits, int maxiterations, int maxFunctionEvaluation, double *time, float *aif, float *tissue, double *curveFit, double *pv, double *imt, double *iv, double *per, double *akaikeError, double *chiSquare, double *xError);
void lmuEnhancement(float *aif, int n, int bl, int tracer);
void intVector(int n, double *x ,float *y, double *integral);

int calculateFitErrors(int m, float *tissue, double *curveFit, double *correctedAkaikeError, double *chiSquare, double *xError, int n_elements_pars, mp_result *result);
void configMethod(mp_config *config);