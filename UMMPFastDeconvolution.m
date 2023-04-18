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

#import "UMMPFastDeconvolution.h"
#import "SVDcmp.h"
#import "math.h"


@implementation UMMPFastDeconvolution

+(int)fd:(int)n :(int) height :(int) width :(double *)p :(float *)aif :(double *)time :(int )tracer :(int) bl :(double) htc :(double) regParam :(float *)pf :(float *)vd :(float *)mt :(int)timepointsOfStartSlider {
	
	int i, j, k;
	int m;
	int imageSize = height * width;
	int interpol = 0;
	
	double sum;
	double min;
	double max;
	double temp;
	double deltaT;
	double maxSV;
	
	double pfValue;
	double vdValue;
	double mtValue;
	double htcDifference = 1-htc;
	
	double *p1 = 0;
	double *sv = 0;
	double *v1 = 0;
	
	float *_aif;
	float *aifRegr = 0;
	double *timeRegr = 0;
	double *pol = 0;
	
	double **v = 0;
	double **matrix = 0;
	
	_aif = (float*)calloc(n, sizeof(float));
	for (i=0; i<n; i++)
		_aif[i] = aif[i];
	
	[self lmuEnhancement:_aif :n :bl :tracer];
    
	if (htcDifference == 0)
		htcDifference = 1.0 - 0.45;
	
	for (i = 0; i < n; i++)
		_aif[i] /= htcDifference;
	
	[self lmuEnhancementP:p :n :imageSize :bl :tracer];
    
	[self calculateDeltaT:n :time :&deltaT :&min :&max :timepointsOfStartSlider];
	
	// condition for interpolation
	if (!(((max-min)/min) < 0.01)) {
		
		interpol = 1;
		
		// n = 1+floor(time[n-1]/dt) - idl
		m = 1 + floor(time[n-1]/min);
		
		// time_regr = dt*dindgen(n) - idl
		timeRegr = (double*)calloc(m, sizeof(double));
		for (i = 0; i < m; i++) {
			//timeRegr[i] = time[i];
			timeRegr[i] = i * min;
		}
		
		aifRegr = (float*)calloc(m, sizeof(float));
		[self aifRegrid:_aif :time :n :aifRegr :timeRegr :m];
        
		pol = (double*)calloc(imageSize*m, sizeof(double));
		[self interpol2D:time :n :timeRegr :m :p :pol :imageSize];
		
		_aif = aifRegr;
		
		p = pol;
		n = m;
		
		if (timeRegr) free(timeRegr);
	}
	
	matrix = (double**)calloc(n, sizeof(double*));
	for (i = 0; i < n; i++)
		matrix[i] = (double*)calloc(n, sizeof(double));
    
	[self convolutionMatrix:_aif :matrix :n :deltaT];
	
	if (aifRegr) free(aifRegr);
	
	sv = (double*)calloc(n, sizeof(double));
	v = (double**)calloc(n, sizeof(double*));
	for (i = 0; i < n; i++) {
		v[i] = (double*)calloc(n, sizeof(double));
	}
	
	[SVDcmp svdcmp:matrix :n :n :sv :v];
	
	//* transpose X = u ****************************************************
	for (i = 0; i < n; i++) {
		for (j = i + 1; j < n; j++) {
			temp = matrix[i][j];
			matrix[i][j] = matrix[j][i];
			matrix[j][i] = temp;
		}
	}
	
	//*max of q ************************************************************
	
	maxSV = sv[0];
	
	for (i = 1; i < n; i++) {
		if (sv[i] > maxSV)
			maxSV = sv[i];
	}
	
	maxSV *= regParam;
    
	for (i = 0; i < n; i++) {
		if (sv[i] > maxSV)
			sv[i] = 1/sv[i];
		else
			sv[i] = 0.0;
	}
	
	//x[*,i] = D[i]*X[*,i] - idl
	for (i = 0; i < n; i++)
		for (j = 0; j < n; j++)
			matrix[j][i] = sv[j] * matrix[j][i];
	
	//* Matrix multiplication **********************************************
	v1 = (double*)calloc(n*n, sizeof(double));
	
	for (i = 0; i < n; i++) {
		for (j = 0; j < n; j++) {
			sum = 0.0;
			for (k = 0; k < n; k++)
				sum = sum + v[i][k]*matrix[k][j];
			v1[i*n+j] = sum;
		}
	}
	
	// free v
	if (v) {
		for (i = 0; i < n; i++) {
			if (v[i])
				free(v[i]);
		}
		free(v);
	}
	// free matrix
	if (matrix) {
		for (i = 0; i < n; i++) {
			if (matrix[i])
				free(matrix[i]);
		}
		free(matrix);
	}
    
	p1 = (double*)calloc(n*imageSize, sizeof(double));
	
	for (i = 0; i < imageSize; i++) {
		for (j = 0; j < n; j++) {
			sum = 0.0;
			for (k = 0; k < n; k++)
				sum = sum + p[n*i+k]*v1[n*j+k];
			p1[n*i+j] = sum;
		}
	}
	
	if (pol) free(pol);
	
	for (i = 0; i < imageSize; i++) {
		
		max = p1[i*n];
		sum = 0.0;
		
		for (j = 0; j < n; j++) {
			sum = sum + p1[i*n+j];
			if (p1[i*n+j] > max) {
				max = p1[i*n+j];
			}
		}
        
		pfValue = (float)max;
		vdValue = (float)sum*deltaT;
		
		if (pfValue != 0) mtValue = (float) (vdValue/pfValue);
		else mtValue = 0.0;
		
		if (pfValue < 0.0) pf[i] = 0.0;
		else pf[i] = pfValue*6000.0;
		
		if (vdValue < 0.0) vd[i] = 0.0;
		else vd[i] =  vdValue*100.0;
		
		if (mtValue < 0.0) mt[i] = 0.0;
		else mt[i] = mtValue;
	}
	
	// Free Memory
	if (sv)	free(sv);
	if (v1)	free(v1);
	if (p1) free(p1);
	
	return interpol;
}


+(void)lmuEnhancement:(float *)aif :(int)n :(int)bl :(int)tracer {
	int i;
	float sum = 0.0;
	
	for (i = 0; i < bl; i++)
		sum += aif[i];
	sum /= bl;
    
	if (tracer == 0) {
		// Relative Signal Enhancement (T1-DCE)
		for (i = 0; i < n; i++) {
			aif[i] -= sum;
			aif[i] /= sum;
		}
	} else if (tracer == 1) {
        // Signal Enhancement (T1-DCE)
		for (i = 0; i < n; i++)
			aif[i] -= sum;
	} else if (tracer == 2) {
        // Relative Signal Enhancement (T2*-DSC)
        for (i = 0; i < n; i++) {
            aif[i] = -1*log(aif[i]/sum);
        }
    }
}


+(void)lmuEnhancementP:(double *)p :(int)n :(int)imageSize :(int)bl :(int)tracer {
	
	int i, j;
	double *refImage = (double*)calloc(imageSize, sizeof(double));
	
	for (i = 0; i < bl; i++)
		for (j = 0; j < imageSize; j++)
			refImage[j] += p[n*j+i];
	
	for (i = 0; i < imageSize; i++)
		refImage[i] /= bl;
    
	if (tracer == 0) {
		// Relative Signal Enhancement (T1-DCE)
		for (i = 0; i < n; i++) {
			for (j = 0; j < imageSize; j++) {
				
				if (ABS(refImage[j]) < DBL_EPSILON)
					p[j*n+i] = -1.0;
				else
					p[j*n+i] = (p[j*n+i]/refImage[j]) - 1.0;
			}
		}
		
	} else if (tracer == 1) {
		// Signal Enhancement (T1-DCE)
		for (i=0; i < n; i++)
			for (j=0; j < imageSize; j++)
				p[j*n+i] = p[j*n+i]-refImage[j];
	} else if (tracer == 2) {
        // Relative Signal Enhancement (T2*-DSC)
        for (i=0; i < n; i++)
			for (j=0; j < imageSize; j++)
				p[j*n+i] = -1*log(p[j*n+i]/refImage[j]);
    }
	
	if(refImage) free(refImage);
}


+(void)convolutionMatrix:(float *)aif :(double **)matrix :(int )n :(double )deltaT {
	
	int i, j;
	
	for (i = 1; i < n; i++) {
		//mat[i,i] = 2*c[0] + c[1] - idl
		matrix[i][i] = 2.0 * aif[0] + aif[1];
		
		for (j = 1; j < i; j++) {
			//mat[i-j,i] = c[j-1]+4*c[j]+c[j+1]- idl
			matrix[i][i-j] = aif[j-1] + 4.0 * aif[j] + aif[j+1];
		}
		
		//mat[0,i] = c[i-1] + 2*c[i] - idl
		matrix[i][0] = aif[i-1] + 2.0 * aif[i];
	}
	
	for (i = 0; i < n; i++) {
		for (j = 0; j < n; j++) {
			matrix[i][j] /= 6.0;
			matrix[i][j] *= deltaT;
		}
	}
}


+(void)calculateDeltaT:(int)n :(double *)time :(double *)deltaT :(double *)min :(double *)max :(int)timepointsOfStartSlider{
	
	int i;
	int size = n-1;
	
	double *dTime = (double*)calloc(size, sizeof(double));
	
	// dtime = time[1:n-1]-time[0:n-2] - idl
	for (i = 1; i <= size; i++)
	{
		
		if (i==1) dTime[i-1] = (time[i] - time[i-1])/(timepointsOfStartSlider+1);
		else dTime[i-1] = (time[i] - time[i-1]);
	}
	
	*min = dTime[0];
	*max = dTime[0];
	//NSLog(@"1. in calculateDeltaT in FD.m: n: %d, deltaT: %lf, min: %lf, max: %lf", n, *deltaT, *min, *max);
	
	for (i = 1; i < size; i++) {
		// dt = min(dtime,max=mdt) - idl
		if (dTime[i] < *min)
			*min = dTime[i];
		if (dTime[i] > *max)
			*max = dTime[i];
		//NSLog(@"dTime[i]: %lf", dTime[i]);
	}
	
	if (*min == 0.0)
		*min = 1.0;
    
	*deltaT = *min;
	
	//NSLog(@"2. in calculateDeltaT in FD.m: n: %d, deltaT: %lf, min: %lf, max: %lf", n, *deltaT,  *min, *max);
	
	if (dTime) free(dTime);
}


+(void)aifRegrid:(float *)aif :(double *)time :(int)n  :(float *)aifRegr :(double *)timeRegr :(int)m {
    
	int i, j;
	int position;
	int *index;
	float diffAif;
	
	// s = VALUE_LOCATE(x, xout) > 0L < (m-2) ;Subscript intervals. - idl
	index = (int*)calloc(m, sizeof(int));
	
	for (i = 0; i < m; i++) {
		for (j = 0; j < n; j++) {
			if (timeRegr[i] < time[0]) {
				index[i] = -1;
				break;
			} else if (timeRegr[i] <= time[j]) {
				if (j == 0)
					index[i] = 0;
				else
					index[i] = j-1;
				break;
			}
		}
	}
	
	for (i = 0; i < m; i++) {
		
		// diff = v[s+1] - v[s] - idl
		position = index[i];
		diffAif = aif[position+1] - aif[position];
		
		// p = (xout-x[s]) *diff/(x[s+1] - x[s]) + v[s] - idl
		aifRegr[i] = (timeRegr[i]-time[position]) * diffAif / (time[position+1]-time[position]) + aif[position];
	}
	
	if (index) free(index);
}


+(void)interpol2D:(double *)time :(int)n :(double *)timeRegr :(int)m :(double *)p :(double *)pol :(int)imageSize {
    
	int i, j;
	int i0, i1;
	int sumBelow;
	
	BOOL outside;
	
	double x0, x1;
	double pitch;
	
	double *y0 = (double*)calloc(imageSize, sizeof(double));
	double *y1 = (double*)calloc(imageSize, sizeof(double));
    
	// for i=0L,ni-1 do begin - idl
	for (i = 0; i < m; i++) {
		
		sumBelow = 0;
		
		// outside = (Xi[i] lt X[0]) or (Xi[i] ge X[n-1]) - idl
		outside = (timeRegr[i] < time[0] || timeRegr[i] >= time[n-1]);
		
		// if outside then begin
		if (outside) {
			
			// if Xi[i] lt X[0] then begin - idl
			if (timeRegr[i] < time[0]) {
				i0 = 0;
				i1 = 1;
			}
			
			// if Xi[i] ge X[n-1] then begin - idl
			if (timeRegr[i] >= time[n-1]) {
				i0 = n-2;
				i1 = n-1;
			}
		} else {
			// cnt = total(X le Xi[i]) - idl
			for (j = 0; j < n; j++) {
				if (time[j] <= timeRegr[i])
					sumBelow++;
			}
			// sum = array-index - idl
			i0 = sumBelow-1;
			i1 = sumBelow;
		}
        
		// X0 = X[I0] & Y0 = reform(Y[*,I0],/overwrite) - idl
		// X1 = X[I1] & Y1 = reform(Y[*,I1],/overwrite) - idl
		x0 = time[i0];
		x1 = time[i1];
        
		for (j = 0; j < imageSize; j++) {
			y0[j] = p[i0+n*j];
			y1[j] = p[i1+n*j];
		}
		
		// A = (Xi[i]-X0)/(X1-X0) - idl
		pitch = floor(abs(timeRegr[i]-x0)/(x1-x0)+0.5);
		
		// Yi[*,i] = Y0*(1-A) + Y1*A - idl
		for (j = 0; j < imageSize; j++)
			pol[i+m*j] = ( y0[j] * (1-pitch)) + (y1[j] * pitch);
	}
	
	if (y0) free(y0);
	if (y1) free(y1);
}

@end
