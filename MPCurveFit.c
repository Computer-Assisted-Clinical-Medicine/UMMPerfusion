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




#include "mpcurvefit.h"


struct fit_struct {
	float *tissue;
	double *time;
	float *aif;
    float *vif;
	double *fit;
};

void expConvolute(int m, double k, double *time, float *aif, double *y, double *der)
{
	int i;
	double *deltaT = calloc(m-1, sizeof(double));
	double *deltaA = calloc(m-1, sizeof(double));
	double *z = calloc(m-1, sizeof(double));
	double *e = calloc(m-1, sizeof(double));
	double *e0 = calloc(m-1, sizeof(double));
	double *e1 = calloc(m-1, sizeof(double));
	double *il = calloc(m-1, sizeof(double));
	double *e2 = calloc(m-1, sizeof(double));
	double *dil = calloc(m-1, sizeof(double));
	
	/*
	 DT = T[1:n-1]-T[0:n-2]
	 DA = A[1:n-1]-A[0:n-2]
	 */
	for (i = 0; i < m-1; i++) {
		deltaT[i] = time[i+1] - time[i];
		deltaA[i] = aif[i+1] - aif[i];
	}
	
	/*
	 Z = l*DT
	 E = exp(-Z)
	 E0 = 1-E
	 E1 = Z-E0
	 */
	for (i = 0; i < m-1; i++) {
		z[i] = k * deltaT[i];
		e[i] = exp(z[i]*(-1));
		e0[i] = 1 - e[i];
		e1[i] = z[i] - e0[i];
	}
    
	/*
	 Il = (A[0:n-2]*E0 + DA*E1/Z)/l
	 */
	for (i = 0; i < m-1; i++)
		il[i] = ( (aif[i] * e0[i]) + (deltaA[i] * e1[i])/z[i] )/k;
	
	/*
	 Y = dblarr(n)
	 */
	for (i = 0; i < m; i++)
		y[i] = 0;
	
	/*
	 for i=0L,n-2 do Y[i+1] = E[i]*Y[i] + Il[i]
	 */
	for (i = 0; i < m-1; i++)
		y[i+1] = e[i]*y[i] + il[i];
	
	/*
	 E2 = Z^2-2*E1
	 */
	for (i = 0; i < m-1; i++)
		e2[i] = pow(z[i], 2) - 2*e1[i];
	
	/*
	 DIl = -DT*Il + (A[0:n-2]*E1 + DA*E2/Z )/(l^2)
	 DIl = -E*DT*Y + DIl
	 */
	for (i = 0; i < m-1; i++)
		dil[i] = deltaT[i]*(-1)*il[i] + ( aif[i]*e1[i] + deltaA[i]*e2[i]/z[i]) / pow(k, 2);
	
	for (i = 0; i < m-1; i++)
		dil[i] = e[i]*(-1)*deltaT[i]*y[i] + dil[i];
	
	if (der != NULL) {
        /*
		 DY = dblarr(n)
		 */
		
		for (i = 0; i < m; i++)
			der[i] = 0;
		
		/*
		 for i=0L,n-2 do DY[i+1] = E[i]*DY[i] + DIl[i]
		 */
		for (i = 0; i < m-1; i++)
			der[i+1] = e[i]*der[i] + dil[i];
	}
	
	free(deltaT);
	free(deltaA);
	free(z);
	free(e);
	free(e0);
	free(e1);
	free(il);
	free(e2);
	free(dil);
}

//convolutes 2 vectors of the same length and saves the result in the convolutedVector vector of the same length
void convolute(double *vector1, double *vector2, double *time, unsigned length, double *convolutedVector)
{
    int i,j, jmin, jmax;
    double *deltaT = calloc(length,sizeof(double));
    double *result = calloc(2*length-1,sizeof(double));
    for(i=0;i<length-1;i++){
        deltaT[i] = time[i+1] - time[i];
    }
    deltaT[length-1] = deltaT[length-2];
    
    
    for(i=0;i<(2*length - 1);i++){
        j = 0;
        jmin = 0;
        jmax = 0;
        
        if(i >= (length - 1)){
            jmin = i - (length - 1);
        }
        else{
            jmin = 0;
        }
        
        if(i < (length - 1)){
            jmax = i;
        }
        else{
            jmax = length - 1;
        }
        
        for(j = jmin; j <= jmax;j++){
            result[i] += vector1[j] * vector2[i-j];
        }
        result[i] *= deltaT[i];
    }
    
    for(i=0;i<length;i++){
        convolutedVector[i] = result[i];
    }
    
    
    free(deltaT);
    free(result);
}


double getLinearInterpolatedAIFValueForTimepoint(float *aif, double *time, int length, double timepoint){
    double interpolatedValue = 0.0;
    double slope = 0.0;
    int i = 0;
    
    //if timepoint is negative
    if(timepoint < 0){
        slope =(aif[1] - aif[0]) / (time[1] - time[0]);
        interpolatedValue = aif[0] + (slope * timepoint);
    }
    //if timepoint is zero
    if(timepoint <= 0.0005 && timepoint >= -0.0005){
        interpolatedValue = aif[0];
    }
    
    //if timepoint is positive
    if(timepoint > 0.0){
        //if timepoint is out of the timearray
        if(timepoint > time[length-1]){
            slope =(aif[length-1] - aif[length-2]) / (time[length-1] - time[length-2]);
            interpolatedValue = aif[length-1] + (slope * (timepoint - time[length-1]));
        }
        //if timepoint is inside the time of the timearray
        else{
            //get the position of timepoint inside the time array
            while(time[i]<timepoint){
                i++;
            }
            //test if timepoint is identical with time in timearray
            if((time[i] <= (timepoint + 0.0005)) && (time[i] >= (timepoint - 0.0005))){
                interpolatedValue = aif[i];
            }
            //interpolate value for timepoint
            else{
                slope = (aif[i] - aif[i-1]) / (time[i] - time[i-1]);
                interpolatedValue = aif[i-1] + (slope * (timepoint - time[i-1]));
            }
        }
    }
    
    return interpolatedValue;

}

int singleInletCompartement(int m, int n, double *p, double *dy, double **dvec, void *vars)
{			
	int i;
	double k;
	struct fit_struct *v = (struct fit_struct *) vars;
	double *y = calloc(m, sizeof(double));
	
	double *time = v->time;
	float *aif = v->aif;
	float *tissue = v->tissue;
	double *fit = v->fit;
	
	// K = P[1]/P[0] ; F/V
	k = p[1]/p[0];
		
	// Conv = ExpConvolution(K,[time,input],Der=dConv)
	expConvolute(m, k, time, aif, y, NULL);
	
	// C = P[1]*Conv[ti]
	for (i = 0; i < m; i++) {
		dy[i] = p[1]*y[i];
		fit[i] = dy[i];
		dy[i] = (tissue[i] - dy[i])*1.0;
	}
	
	free(y);
	return 0;
}


int singleInletExchange(int m, int n, double *p, double *dy, double **dvec, void *vars)
{			
	int i;
	double a, b, am, km, kp, ta,  tm, tp, ts;
	struct fit_struct *v = (struct fit_struct *) vars;
	
	double *time = v->time;
	float *aif = v->aif;
	float *tissue = v->tissue;
	double *fit = v->fit;
	
	double *cp = calloc(m, sizeof(double));
	double *cm = calloc(m, sizeof(double));
    
    a = p[2]-p[2]*p[3]+p[3];
	b = p[2]*(1-p[2])*p[3]*(1-p[3]);
	
	ts = sqrt(1-4*b/pow(a, 2));
	ta = 0.5*a/p[3];
	
	tp = ta*(1+ts);
	tm = ta*(1-ts);
	
	kp = p[1]/(p[0]*tm);
	km = p[1]/(p[0]*tp);
	am = (1-tm)/(tp-tm);
	
	expConvolute(m, kp, time, aif, cp, NULL);
	expConvolute(m, km, time, aif, cm, NULL);
	
	for (i=0; i<m; i++) {
		dy[i] = p[1]*(1-am)*cp[i] + p[1]*am*cm[i];
		fit[i] = dy[i];
		dy[i] = (tissue[i] - dy[i])*1.0;
	}
    
    free(cp);
	free(cm);
	
	return 0;
}


//Since Version 1.5
/* Filtration Model by S. Sourbron ()
 
	C(t) = FP (1-A) exp(-tKP) * Ca(T) + FP A exp(-tKE)*Ca(t)
 
 Parameters: 
 P = [V, FP, v, E]
 
 V = VP+VE		(Total Extracellular Volume)
 FP				(Plasma Flow)
 v = VE/(VP+VE) (Extravascular Volume Fraction)
 E = FE /FP		(Extraction Fraction)
 
 Fit Parameters:
 
 FP, A, KP, KE
 
 KP = FP/VP = FP/(V (1-v))
 KE = FE/VE = E FP / (V v)
 A = 1/(1+(1/E - 1/v) */

int singleInletFiltration(int m, int n, double *p, double *dy, double **dvec, void *vars)
{			
	int i;
	double am,  ke, kp;
	struct fit_struct *v = (struct fit_struct *) vars;
	
	double *time = v->time;
	float *aif = v->aif;
	float *tissue = v->tissue;
	double *fit = v->fit;
	
	double *cp = calloc(m, sizeof(double));
	double *cm = calloc(m, sizeof(double));
    
// Fit parameters
	kp = p[1]/(p[0]*(1-p[2]));
	ke = p[3]*p[1]/(p[0]*p[2]);					
	am = 1/(1+1/p[3]-1/p[2]);
	
	expConvolute(m, kp, time, aif, cp, NULL);
	expConvolute(m, ke, time, aif, cm, NULL);
	
	for (i=0; i<m; i++) {
		dy[i] = p[1]*(1-am)*cp[i] + p[1]*am*cm[i];
		fit[i] = dy[i];
		dy[i] = (tissue[i] - dy[i])*1.0;
	}
    
    free(cp);
	free(cm);
	
	return 0;
}



int singleInletUptake(int m, int n, double *p, double *dy, double **dvec, void *vars)
{			
	int i;
    double k;
	struct fit_struct *v = (struct fit_struct *) vars;
	
	double *time = v->time;
	float *aif = v->aif;
	float *tissue = v->tissue;
	double *fit = v->fit;
    
    double *cp = calloc(m, sizeof(double));
    double *integral = calloc(m, sizeof(double));
    
    k = p[1]/(p[0]*(1-p[2]));
    
    expConvolute(m, k, time, aif, cp, NULL);
    intVector(m, time, aif, integral);
    
    for (i = 0; i < m; i++) {
		dy[i] = (1-p[2])*p[1]*cp[i]+p[2]*p[1]*integral[i];
		fit[i] = dy[i];
		dy[i] = (tissue[i] - dy[i])*1.0;
	}
    
    free(cp);
	free(integral);
    
	return 0;
}

int doubleInletUptake(int m, int n, double *p, double *dy, double **dvec, void *vars)
{
	int i;
	double ve, af, vf, ki, ta, tv,  fi, te;
	struct fit_struct *v = (struct fit_struct *) vars;
	
	double *time = v->time;
	float *aif = v->aif;
    float *vif = v->vif;
	float *tissue = v->tissue;
	double *fit = v->fit;
	
    double *aif_vif = calloc(m, sizeof(double));
    double *e_func = calloc(m, sizeof(double));
    double *part1 = calloc(m, sizeof(double));
    double *part2 = calloc(m, sizeof(double));
    double *result = calloc(m, sizeof(double));
    
    
    //Arrays mit 0.0 initialisieren
    for(i=0;i<m;i++) {
        aif_vif[i] = 0.0;
        e_func[i] = 0.0;
        part1[i] = 0.0;
        part2[i] = 0.0;
        fit[i] = 0.0;
        dy[i] = 0.0;
    }
    
    af = p[1];
    vf = p[2];
	ve = p[0];
	ki = p[3];
	ta = p[4];
	tv = p[5];
	fi = p[3]/(p[1]+p[2]+p[3]);
	te = p[0]/(p[1]+p[2]+p[3]);
    /*
     printf("\naf = %f\n",af);
     printf("vf = %f\n",vf);
     printf("ve = %f\n",ve);
     printf("ki = %f\n",ki);
     */
    for(i=0;i<m;i++){
        //aif_vif[i] = af*aif[i]+vf*vif[i];
        aif_vif[i] = af * getLinearInterpolatedAIFValueForTimepoint(aif, time, m, time[i] - ta) + vf * getLinearInterpolatedAIFValueForTimepoint(vif, time, m, time[i] - tv);
        e_func[i] = exp((double)(-time[i])/te)/te;
        part1[i] = fi/te;
        /*
         printf("\naif_vif[%d] = %f;",i,aif_vif[i]);
         printf("\ne_func[%d] = %f;",i,e_func[i]);
         printf("\npart1[%d] = %f;",i,part1[i]);
         printf("\ntime[%d] = %f;",i,time[i]);
         */
    }
	convolute(aif_vif, e_func, time, m, part2);
    convolute(part2, part1, time, m, result);
    
    for(i=0;i<m;i++){
        result[i] += part2[i];
        result[i] *= te;
    }
    
	
	for (i=0; i<m; i++) {
		fit[i] = result[i];
		dy[i] = (double)tissue[i] - fit[i];
        /*
         printf("\nfit(%d) = %f;",i,fit[i]);
         printf("\naif(%d) = %f;",i,aif[i]);
         printf("\nvif(%d) = %f;",i,vif[i]);
         */
	}
    
    
	free(aif_vif);
    free(e_func);
	free(part1);
    free(part2);
    free(result);
	return 0;
}

int singleInletModifiedTofts(int m, int n, double *p, double *dy, double **dvec, void *vars)
{
    int i;
    double k;
    
    struct fit_struct *v = (struct fit_struct *) vars;
	
	double *time = v->time;
	float *aif = v->aif;
	float *tissue = v->tissue;
	double *fit = v->fit;
    
    double *cp = calloc(m, sizeof(double));
    
    k = p[2]/(p[0]*p[1]);
    
    expConvolute(m, k, time, aif, cp, NULL);
    
    for (i=0; i<m; i++) {
		dy[i] = p[0]*(1-p[1])*aif[i] + p[2]*cp[i];
		fit[i] = dy[i];
		dy[i] = (tissue[i] - dy[i])*1.0;
	}
    
    free(cp);
    
    return 0;
}

//int fitSingleInletCompartment(int m, double *time, float *aif, float *tissue, double *curveFit, double *pf, double *vd, double *mt, double *akaikeError, double *chiSquare)
//{
//	int i;
//	double p[] = {0.1, 0.002};			/* Initial conditions */            
//	double perror[2];					/* Returned parameter errors */     
//	mp_par pars[2];						/* Parameter constraints */
//	int n_elements_pars = 2;
//	struct fit_struct v;
//	int status;
//	mp_result result;
//	
//	memset(&result,0,sizeof(result));	/* Zero results structure */
//	result.xerror = perror;
//	
//	memset(pars,0,sizeof(pars));		/* Initialize constraint structure */
//	pars[0].fixed = 0;					/* Fix parameters */
//	pars[1].fixed = 0;
//	
//	pars[0].limited[0] = 1;    
//	pars[0].limited[1] = 1;
//	pars[0].limits[0] = 0.0;
//	pars[0].limits[1] = 1.0;
//	
//	pars[1].limited[0] = 1;    
//	pars[1].limited[1] = 1;
//	pars[1].limits[0] = 0.0;
//	pars[1].limits[1] = 1.0;
//	
//	v.tissue = tissue;
//	v.time = time;
//	v.aif = aif;
//	v.fit = curveFit;
//    
//    status = mpfit(singleInletCompartement, m, n_elements_pars, p, pars, 0, (void *) &v, &result);
//	
//	*pf = p[1] * 6000.0;
//	*vd = 100.0 * p[0];
//	*mt = p[0]/p[1];
//    
//    // calc akaike Error
//	double sum = 0.0;
//	for (i=0; i<m; i++)
//		sum = sum + pow(tissue[i]-curveFit[i], 2);
//	
//	*akaikeError = m * log(sum/m) + 2.0*(1+n_elements_pars);
//	
//	if (chiSquare)
//		*chiSquare = result.bestnorm;
//	
//	return 0;
//}

int fitSingleInletCompartment(int m, double  *p, int *fixed, int *limited, double *limits, int maxiterations, int maxFunctionEvaluation, double *time, float *aif, float *tissue, double *curveFit, double *pf, double *vd, double *mt, double *akaikeError, double *chiSquare, double *xError)
{
	//double p[] = {0.3, 0.02};			/* Initial conditions */            
	double perror[2];					/* Returned parameter errors */     
	mp_par pars[2];						/* Parameter constraints */
	int n_elements_pars = 2;
	struct fit_struct v;
	//int status;
	mp_result result;
	mp_config config;
	
	
	memset(&result,0,sizeof(result));	/* Zero results structure */
	result.xerror = perror;

	memset(pars,0,sizeof(pars));		/* Initialize constraint structure */
//	pars[0].fixed = 0;					/* Fix parameters */
//	pars[1].fixed = 0;
    pars[0].fixed = fixed[0];           /* Parameter from preferences window */
    pars[1].fixed = fixed[1];
    
//	pars[0].limited[0] = 1;    
//	pars[0].limited[1] = 1;
//	pars[0].limits[0] = 0.0;
//	pars[0].limits[1] = 1.0;
    pars[0].limited[0] = limited[0];
	pars[0].limited[1] = limited[1];
	pars[0].limits[0] = limits[0];
	pars[0].limits[1] = limits[1];
	
//	pars[1].limited[0] = 1;    
//	pars[1].limited[1] = 1;
//	pars[1].limits[0] = 0.0;
//	pars[1].limits[1] = 1.0;
    pars[1].limited[0] = limited[2];
	pars[1].limited[1] = limited[3];
	pars[1].limits[0] = limits[2];
	pars[1].limits[1] = limits[3];

	v.tissue = tissue;
	v.time = time;
	v.aif = aif;
	v.fit = curveFit;
  
	
    configMethod(&config);
    config.maxiter = maxiterations;
    config.maxfev = maxFunctionEvaluation;
    
    mpfit(singleInletCompartement, m, n_elements_pars, p, pars, &config, (void *) &v, &result);
	
	*pf = p[1] * 6000.0;
	*vd = 100.0 * p[0];
	*mt = p[0]/p[1];
	
	if (calculateFitErrors(m, tissue, curveFit, akaikeError, chiSquare, xError, n_elements_pars, &result))
    {
        return 0;
    }
//else hinzugefügt
    else {
 	return -1;
        
    }
    
}

int fitSingleInletExchange(int m, double  *p, int *fixed, int *limited, double *limits, int maxiterations, int maxFunctionEvaluation, double *time, float *aif, float *tissue, double *curveFit, double *pf, double *pv, double *mt, double *imt, double *iv, double *ef, double *per, double *akaikeError, double *chiSquare, double *xError)
{
	//double p[] = {0.3, 0.02, 2.0/3, 0.1};	/* Initial conditions */            
	double perror[4];						/* Returned parameter errors */     
	mp_par pars[4];							/* Parameter constraints */
	int n_elements_pars = 4;
	struct fit_struct v;
	//int status;
	mp_result result;
	mp_config config;
	
	memset(&result,0,sizeof(result));       /* Zero results structure */
	result.xerror = perror;
	
	memset(pars,0,sizeof(pars));            /* Initialize constraint structure */
	//pars[0].fixed = 0;                    /* Fix parameters */
	//pars[1].fixed = 0;
	//pars[2].fixed = 0;
	//pars[3].fixed = 0;
    pars[0].fixed = fixed[0];               /* Parameter from preferences window */
	pars[1].fixed = fixed[1];
	pars[2].fixed = fixed[2];
	pars[3].fixed = fixed[3];
	
	//pars[0].limited[0] = 0;
	//pars[0].limited[1] = 1;
	//pars[0].limits[0] = 0.0;
	//pars[0].limits[1] = 1.0;
    pars[0].limited[0] = limited[0];
	pars[0].limited[1] = limited[1];
	pars[0].limits[0] = limits[0];
	pars[0].limits[1] = limits[1];
	
	//pars[1].limited[0] = 0;
	//pars[1].limited[1] = 0;
	//pars[1].limits[0] = 0.0;
	//pars[1].limits[1] = 1.0;
    pars[1].limited[0] = limited[2];
	pars[1].limited[1] = limited[3];
	pars[1].limits[0] = limits[2];
	pars[1].limits[1] = limits[3];

    //pars[2].limited[0] = 0;
	//pars[2].limited[1] = 1;
	//pars[2].limits[0] = 0.0;
	//pars[2].limits[1] = 1.0;
	pars[2].limited[0] = limited[4];
	pars[2].limited[1] = limited[5];
	pars[2].limits[0] = limits[4];
	pars[2].limits[1] = limits[5];
	
    //pars[3].limited[0] = 0;    
	//pars[3].limited[1] = 1;
	//pars[3].limits[0] = 0.0;
	//pars[3].limits[1] = 1.0;
	pars[3].limited[0] = limited[6];
	pars[3].limited[1] = limited[7];
	pars[3].limits[0] = limits[6];
	pars[3].limits[1] = limits[7];
	
	v.tissue = tissue;
	v.time = time;
	v.aif = aif;
	v.fit = curveFit;
	
	configMethod(&config);
	config.maxiter = maxiterations;
    config.maxfev = maxFunctionEvaluation;
    
    mpfit(singleInletExchange, m, n_elements_pars, p, pars, &config, (void *) &v, &result);
	
	*pf = p[1] * 6000.0;
	*mt = p[0]*(1-p[2])*(1-p[3])/p[1];
	*pv = 100*p[0]*(1-p[2]);
	*imt = (1-p[3])*p[0]*p[2]/(p[1]*p[3]);
	*iv = 100*p[0]*p[2];
	*ef = 100*p[3];
	*per = 6000*p[1]*p[3]/(1-p[3]);

	if (calculateFitErrors(m, tissue, curveFit, akaikeError, chiSquare, xError, n_elements_pars, &result))
    {
        return 0;
    }
 	
    else {
        return -1;
    }

}


int fitSingleInletFiltration(int m, double  *p, int *fixed, int *limited, double *limits, int maxiterations, int maxFunctionEvaluation, double *time, float *aif, float *tissue, double *curveFit, double *pf, double *pv, double *mt, double *imt, double *iv, double *ef, double *per, double *correctedAkaikeError, double *chiSquare, double *xError)
{
	
	
	//double p[] = {0.3, 120.0/6000, 2.0/3, 0.09};	/* Initial conditions */
	
	double perror[4];						/* Returned parameter errors */     
	mp_par pars[4];							/* Parameter constraints */
	int n_elements_pars = 4;
	struct fit_struct v;
	//int status;
	mp_result result;
	mp_config config;
	
	memset(&result,0,sizeof(result));       /* Zero results structure */
	result.xerror = perror;
	
	memset(pars,0,sizeof(pars));            /* Initialize constraint structure */
	//pars[0].fixed = 0;                    /* Fix parameters */
	//pars[1].fixed = 0;
	//pars[2].fixed = 0;
	//pars[3].fixed = 0;
    pars[0].fixed = fixed[0];               /* Parameter from preferences window */
	pars[1].fixed = fixed[1];
	pars[2].fixed = fixed[2];
	pars[3].fixed = fixed[3];
	
	//pars[0].limited[0] = 0;
	//pars[0].limited[1] = 1;
	//pars[0].limits[0] = 0.0;
	//pars[0].limits[1] = 1.0;
    pars[0].limited[0] = limited[0];
	pars[0].limited[1] = limited[1];
	pars[0].limits[0] = limits[0];
	pars[0].limits[1] = limits[1];
	
	//pars[1].limited[0] = 0;
	//pars[1].limited[1] = 0;
	//pars[1].limits[0] = 0.0;
	//pars[1].limits[1] = 1.0;
    pars[1].limited[0] = limited[2];
	pars[1].limited[1] = limited[3];
	pars[1].limits[0] = limits[2];
	pars[1].limits[1] = limits[3];
	
    //pars[2].limited[0] = 0;
	//pars[2].limited[1] = 1;
	//pars[2].limits[0] = 0.0;
	//pars[2].limits[1] = 1.0;
	pars[2].limited[0] = limited[4];
	pars[2].limited[1] = limited[5];
	pars[2].limits[0] = limits[4];
	pars[2].limits[1] = limits[5];
	
    //pars[3].limited[0] = 0;    
	//pars[3].limited[1] = 1;
	//pars[3].limits[0] = 0.0;
	//pars[3].limits[1] = 1.0;
	pars[3].limited[0] = limited[6];
	pars[3].limited[1] = limited[7];
	pars[3].limits[0] = limits[6];
	pars[3].limits[1] = limits[7];
	
	v.tissue = tissue;
	v.time = time;
	v.aif = aif;
	v.fit = curveFit;
	
    configMethod(&config);
	config.maxiter = maxiterations;
    config.maxfev = maxFunctionEvaluation;
    
    mpfit(singleInletFiltration, m, n_elements_pars, p, pars, &config, (void *) &v, &result);
	
	// hier gibt es kein *iv in diesem Modell, wie wird das gehandhabt?
	*pf = p[1]*6000.0;				// plasma flow [ml/100ml/min]
	*mt = 1.0*p[0]*(1-p[2])/p[1];	// plasma mtt [sec]
	*pv = 100.0*p[0]*(1-p[2]);		// plasma volume [ml/100ml]
	*imt =1.0*p[0]*p[2]/(p[1]*p[3]);// tubular mtt [sec]	
	*ef = 100.0*p[3];					// extraction fraction [%]
	*per = 6000*p[1]*p[3];			// tubular flow [ml/100ml/min]
	
	if (calculateFitErrors(m, tissue, curveFit, correctedAkaikeError, chiSquare, xError, n_elements_pars, &result))
    {
        return 0;
    }
 	
    else {
        return -1;
    }

}



int fitSingleInletUptake(int m, double  *p, int *fixed, int *limited, double *limits, int maxiterations, int maxFunctionEvaluation, double *time, float *aif, float *tissue, double *curveFit, double *pf, double *pv, double *mt, double *ef, double *per, double *correctedAkaikeError, double *chiSquare, double *xError)
{
	
    //double p[] = {0.1, 120.0/6000.0, 12.0/132.0};	/* Initial conditions */            
	double perror[3];                               /* Returned parameter errors */     
	mp_par pars[3];                                 /* Parameter constraints */
	int n_elements_pars = 3;
	struct fit_struct v;
	//int status;
	mp_result result;
	mp_config config;
	
	memset(&result,0,sizeof(result));               /* Zero results structure */
	result.xerror = perror;
	
	memset(pars,0,sizeof(pars));                    /* Initialize constraint structure */
	//pars[0].fixed = 0;                              /* Fix parameters */
	//pars[1].fixed = 0;
	//pars[2].fixed = 0;
    pars[0].fixed = fixed[0];                              /* Fix parameters */
	pars[1].fixed = fixed[1];
	pars[2].fixed = fixed[2];
	
	//pars[0].limited[0] = 0;    
	//pars[0].limited[1] = 1;
	//pars[0].limits[0] = 0.0;
	//pars[0].limits[1] = 1.0;
    pars[0].limited[0] = limited[0];
	pars[0].limited[1] = limited[1];
	pars[0].limits[0] = limits[0];
	pars[0].limits[1] = limits[1];

	//pars[1].limited[0] = 0;    
	//pars[1].limited[1] = 0;
	//pars[1].limits[0] = 0.0;
	//pars[1].limits[1] = 1.0;
    pars[1].limited[0] = limited[2];
	pars[1].limited[1] = limited[3];
	pars[1].limits[0] = limits[2];
	pars[1].limits[1] = limits[3];
	
	//pars[2].limited[0] = 0;    
	//pars[2].limited[1] = 1;
	//pars[2].limits[0] = 0.0;
	//pars[2].limits[1] = 1.0;
    pars[2].limited[0] = limited[4];    
	pars[2].limited[1] = limited[5];
	pars[2].limits[0] = limits[4];
	pars[2].limits[1] = limits[5];
	
	v.tissue = tissue;
	v.time = time;
	v.aif = aif;
	v.fit = curveFit;
   
    configMethod(&config);
    config.maxiter = maxiterations;
    config.maxfev = maxFunctionEvaluation;
    
    mpfit(singleInletUptake, m, n_elements_pars, p, pars, &config, (void *) &v, &result);
    		
    *pf = 6000.0*p[1];
    *mt = 1.0*p[0]*(1-p[2])/p[1];
    *pv = 100.0*p[0];
    *ef = 100.0*p[2];
    *per = 6000.0*p[1]*p[2]/(1-p[2]);
    
    if (calculateFitErrors(m, tissue, curveFit, correctedAkaikeError, chiSquare, xError, n_elements_pars, &result))
    {
        return 0;
    }
 	
    else {
        return -1;
    }
}

int fitDoubleInletUptake(int m, double  *p, int *fixed, int *limited, double *limits, int maxiterations, int maxFunctionEvaluation, double *time, float *aif, float *vif, float *tissue, double *curveFit, double *af, double *vf, double *ve, double *ki, double *aDelayTime, double *vDelayTime,double *fi, double *fa, double *te, double *correctedAkaikeError, double *chiSquare, double *xError)
{
    //double p[] = {0.3, 0.02, 2.0/3, 0.1};	/* Initial conditions */
	double perror[6];						/* Returned parameter errors */
	mp_par pars[6];							/* Parameter constraints */
	int n_elements_pars = 6;
	struct fit_struct v;
	//int status;
	mp_result result;
	mp_config config;
	
	memset(&result,0,sizeof(result));       /* Zero results structure */
	result.xerror = perror;
	
	memset(pars,0,sizeof(pars));            /* Initialize constraint structure */
    pars[0].fixed = fixed[0];               /* Parameter from preferences window */
	pars[1].fixed = fixed[1];
	pars[2].fixed = fixed[2];
	pars[3].fixed = fixed[3];
    pars[4].fixed = fixed[4];
	pars[5].fixed = fixed[5];
	

    pars[0].limited[0] = limited[0];
	pars[0].limited[1] = limited[1];
	pars[0].limits[0] = limits[0];
	pars[0].limits[1] = limits[1];
	

    pars[1].limited[0] = limited[2];
	pars[1].limited[1] = limited[3];
	pars[1].limits[0] = limits[2];
	pars[1].limits[1] = limits[3];
    

	pars[2].limited[0] = limited[4];
	pars[2].limited[1] = limited[5];
	pars[2].limits[0] = limits[4];
	pars[2].limits[1] = limits[5];
	

	pars[3].limited[0] = limited[6];
	pars[3].limited[1] = limited[7];
	pars[3].limits[0] = limits[6];
	pars[3].limits[1] = limits[7];
    
    
    pars[4].limited[0] = limited[8];
	pars[4].limited[1] = limited[9];
	pars[4].limits[0] = limits[8];
	pars[4].limits[1] = limits[9];
    
    pars[5].limited[0] = limited[10];
	pars[5].limited[1] = limited[11];
	pars[5].limits[0] = limits[10];
	pars[5].limits[1] = limits[11];
    
	
	v.tissue = tissue;
	v.time = time;
	v.aif = aif;
    v.vif = vif;
	v.fit = curveFit;
	
	configMethod(&config);
	config.maxiter = maxiterations;
    config.maxfev = maxFunctionEvaluation;
    
    mpfit(doubleInletUptake, m, n_elements_pars, p, pars, &config, (void *) &v, &result);
	
	*af = p[1] * 6000.0;
    *vf = p[2] * 6000.0;
	*ve = p[0] * 100.0;
	*ki = p[3];
	*aDelayTime = p[4];
	*vDelayTime = p[5];
	*fi = p[3]/(p[1]+p[2]+p[3]) * 100.0;
    *fa = p[1]/(p[1]+p[2]) * 100.0;
	*te = p[0]/(p[1]+p[2]+p[3]);
    
	if (calculateFitErrors(m, tissue, curveFit, correctedAkaikeError, chiSquare, xError, n_elements_pars, &result))
    {
        return 0;
    }
 	
    else {
        return -1;
    }

    
}

int fitSingleInletModifiedTofts(int m, double  *p, int *fixed, int *limited, double *limits, int maxiterations, int maxFunctionEvaluation, double *time, float *aif, float *tissue, double *curveFit, double *pv, double *imt, double *iv, double *per, double *akaikeError, double *chiSquare, double *xError)
{
	//double p[] = {0.3, 2.0/3, 12.0/6000};	/* Initial conditions */
	double perror[3];						/* Returned parameter errors */     
	mp_par pars[3];							/* Parameter constraints */
	int n_elements_pars = 3;
	struct fit_struct v;
	//int status;
	mp_result result;
	mp_config config;
	
	memset(&result,0,sizeof(result));       /* Zero results structure */
	result.xerror = perror;
    
	memset(pars,0,sizeof(pars));            /* Initialize constraint structure */
	//pars[0].fixed = 0;                      /* Fix parameters */
	//pars[1].fixed = 0;
	//pars[2].fixed = 0;
    pars[0].fixed = fixed[0];
	pars[1].fixed = fixed[1];
	pars[2].fixed = fixed[2];
    
	//pars[0].limited[0] = 0;    
	//pars[0].limited[1] = 1;
	//pars[0].limits[0] = 0.0;
	//pars[0].limits[1] = 1.0;
    pars[0].limited[0] = limited[0];
	pars[0].limited[1] = limited[1];
	pars[0].limits[0] = limits[0];
	pars[0].limits[1] = limits[1];
	
    //pars[1].limited[0] = 0;    
	//pars[1].limited[1] = 1;
	//pars[1].limits[0] = 0.0;
	//pars[1].limits[1] = 1.0;
	pars[1].limited[0] = limited[2];    
	pars[1].limited[1] = limited[3];
	pars[1].limits[0] = limits[2];
	pars[1].limits[1] = limits[3];
	
    //pars[2].limited[0] = 0;    
	//pars[2].limited[1] = 0;
	//pars[2].limits[0] = 0.0;
	//pars[2].limits[1] = 1.0;
	pars[2].limited[0] = limited[4];
	pars[2].limited[1] = limited[5];
	pars[2].limits[0] = limits[4];
	pars[2].limits[1] = limits[5];
	
	v.tissue = tissue;
	v.time = time;
	v.aif = aif;
	v.fit = curveFit;
	
	
	configMethod(&config);
    config.maxiter = maxiterations;
    config.maxfev = maxFunctionEvaluation;
    
    /* Call fitting function for 10 data points and 2 parameters (0
     parameters fixed) */
	mpfit(singleInletModifiedTofts, m, n_elements_pars, p, pars, &config, (void *) &v, &result);
    
    *pv = 100.0*p[0]*(1-p[1]);
    *imt = 1.0*p[0]*p[1]/p[2];
    *iv = 100.0*p[0]*p[1];
    *per = 6000.0*p[2];
		
    
    if (calculateFitErrors(m, tissue, curveFit, akaikeError, chiSquare, xError, n_elements_pars, &result))
    {
        return 0;
    }
 	
    else {
        return -1;
    }

}

void lmuEnhancement(float *aif, int n, int bl, int tracer)
{
	int i;
	float sum = 0.0;
	
	for (i = 0; i < bl; i++)	
		sum += aif[i];
	
	sum /= bl;
	
	if (tracer == 0) {
		// Relative Signal Enhancement
		for (i = 0; i < n; i++) {
			aif[i] -= sum;
			aif[i] /= sum;
		}
	} else if (tracer == 1) {
		// Signal Enhancement
		for (i = 0; i < n; i++)
			aif[i] -= sum;
	}
}

void intVector(int n, double *x ,float *y, double *integral)
{
    int i;
    double *z = calloc(n, sizeof(double));
    
    for (i=0; i<n-1; i++)
        z[i] = ((double)y[i+1]+(double)y[i])*(x[i+1]-x[i])/2;
    
    integral[1] = z[0];
    
    for (i=2; i<n; i++)
        integral[i] = integral[i-1] + z[i-1];
    
    free(z);
}


int calculateFitErrors(int m, float *tissue, double *curveFit, double *correctedAkaikeError, double *chiSquare, double *xError, int n_elements_pars, mp_result *result)
{
    int i;
    
	// calc akaike Error
	double sum = 0.0;
	double sum2 =0.0;
	for (i=0; i<m; i++)
	{
		sum += pow(((tissue[i]) - (curveFit[i])), 2);
		sum2 = (tissue[i]) / m;	//für ChiSquare
	}
    
   
	
	*correctedAkaikeError = m * log(sum/m) + 2.0*(1+n_elements_pars)+ 2.0*n_elements_pars*(n_elements_pars+1)/m-n_elements_pars-1;
   
    
    if (chiSquare)
	{
		double diff=0.0;
		sum=0.0;
		for (i=0; i<m;i++){
			diff+=pow(((tissue[i]) - sum2),2);
			sum = sum + pow((tissue[i]) - (curveFit[i]), 2)/(diff/(m-1));
		}
		// *chiSquare = result.bestnorm; /* by mpcurvefit */
		//*chiSquare = sum / (m-n_elements_pars-1) * (diff/(m-1));
		*chiSquare = sum / (m-n_elements_pars-1) ;
	}
	
	if(xError)
	{
		*xError = *result->xerror;
	}
    return 0;
}

void configMethod(mp_config *config)
{
    config->ftol = 1e-10;
	config->xtol = 1e-10;
	config->gtol = 1e-10;
	config->stepfactor = 100.0;
	config->nprint = 1;
	config->epsfcn = MP_MACHEP0;
	config->maxiter = 200;
	config->douserscale = 0;
	config->maxfev = 1000;
	config->covtol = 1e-14;
	config->nofinitecheck = 0;

}
