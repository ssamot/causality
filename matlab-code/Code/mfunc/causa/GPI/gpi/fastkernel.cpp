/*  Copyright (c) 2010  Oliver Stegle, Joris Mooij
 *  All rights reserved.  See the file COPYING for license terms.
*/


#include "mex.h"
#include <cmath>
#include <vector>


using namespace std;


// Input Arguments

#define X_IN       prhs[0]
#define E_IN       prhs[1]
#define LX_IN      prhs[2]
#define LE_IN      prhs[3]
#define SF2_IN     prhs[4]
#define MODE_IN    prhs[5]
#define X2_IN      prhs[6]
#define E2_IN      prhs[7]
#define NR_IN      6
#define NR_IN_OPT  2


// Output Arguments

#define K_OUT      plhs[0]
#define NR_OUT     1
#define NR_OUT_OPT 0


void calcKernel( double *K, size_t N, const double *X, const double *E, double l_X, double l_E, double sf2, int mode, size_t N2, const double *X2, const double *E2 ) {
    double cX = -0.5 / (l_X * l_X);
    double cE = -0.5 / (l_E * l_E);
    double cE2 = -1.0 / (l_E * l_E);
    double log_sf2 = log( sf2 );
    for( size_t i = 0; i < N; i++ ) {
        double Xi = X[i];
        double Ei = E[i];
        for( size_t j = 0; j < N2; j++ ) {
            double E_dist = (Ei - E2[j]);
            double X_dist2 = (Xi - X2[j]) * (Xi - X2[j]);
            double E_dist2 = E_dist * E_dist;
            double k = exp( log_sf2 + cX * X_dist2 + cE * E_dist2 );
            if( mode == 0 )
                K[j*N+i] = k;
            else
                K[j*N+i] = k * E_dist * cE2;
        }
    }
}


void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[] ) { 
    if( ((nrhs < NR_IN) || (nrhs > NR_IN + NR_IN_OPT)) || ((nlhs < NR_OUT) || (nlhs > NR_OUT + NR_OUT_OPT)) ) { 
        mexErrMsgTxt("Usage: [A] = fastkernel(X,E,l_X,l_E,sf2,mode,X2,E2)\n\n"
        "\n"
        "Calculates a kernel matrix which is the product of two RBF kernels,\n"
        "or the derivative matrix d/de1 k((x1,e1),(x2,e2)).\n"
        "\n"
        "  K = sf2 * exp(-sq_dist(X'/l_X,X2'/l_X) / 2) .* exp(-sq_dist(E'/l_E,E2'/l_E) / 2);\n"
        "  dKde = -K .* (dist(E,E2) / (l_E * l_E));\n"
        "\n"
        "INPUT:    X      = Nx1 vector of doubles\n"
        "          E      = Nx1 vector of doubles\n"
        "          l_X    = length scale for X\n"
        "          l_E    = length scale for E\n"
        "          sf2    = magnitude squared\n"
        "          mode   = 0 or 1\n"
        "          X2     = N2x1 vector of doubles (optional; default = X)\n"
        "          E2     = N2x1 vector of doubles (optional; default = E)\n"
        "\n"
        "OUTPUT:   A      = NxN matrix (K if mode == 0, dKde if mode == 1)\n"
        "\n"
        "Copyright (c) 2010  Joris Mooij  [joris.mooij@tuebingen.mpg.de]\n"
        "All rights reserved.  See the file COPYING for the license terms.\n"
        );
    } 

    if( !mxIsDouble(X_IN) )
        mexErrMsgTxt("X should be a dense matrix, with entries of type double\n");
    size_t N = mxGetM(X_IN);
    if( N <= 1 || mxGetN(X_IN) != 1 )
        mexErrMsgTxt("X should have size Nx1 with N >= 1\n");
    if( !mxIsDouble(E_IN) || (mxGetM(E_IN) != N) || (mxGetN(E_IN) != 1) )
        mexErrMsgTxt("E should have the same size as X, and entries of type double\n");
    double *X = (double *)mxGetPr(X_IN);
    double *E = (double *)mxGetPr(E_IN);

    if( !mxIsDouble(LX_IN) || (mxGetM(LX_IN) != 1) || (mxGetN(LX_IN) != 1) )
        mexErrMsgTxt("l_X should be a double scalar\n");
    double l_X = *((double *)mxGetPr(LX_IN));

    if( !mxIsDouble(LE_IN) || (mxGetM(LE_IN) != 1) || (mxGetN(LE_IN) != 1) )
        mexErrMsgTxt("l_E should be a double scalar\n");
    double l_E = *((double *)mxGetPr(LE_IN));

    if( !mxIsDouble(SF2_IN) || (mxGetM(SF2_IN) != 1) || (mxGetN(SF2_IN) != 1) )
        mexErrMsgTxt("sf2 should be a double scalar\n");
    double sf2 = *((double *)mxGetPr(SF2_IN));

    if( (mxGetM(MODE_IN) != 1) || (mxGetN(MODE_IN) != 1) )
        mexErrMsgTxt("mode should be a scalar");
    int mode = (int)round(*((double *)mxGetPr(MODE_IN)));

    double *X2 = X;
    double *E2 = E;
    size_t N2 = N;
    if( nrhs > NR_IN ) {
        if( nrhs != NR_IN + NR_IN_OPT )
            mexErrMsgTxt("If the optional argument X2 is provided, E2 should also be provided\n");
        if( !mxIsDouble(X2_IN) )
            mexErrMsgTxt("X2 should be a dense matrix, with entries of type double\n");
        N2 = mxGetM(X2_IN);
        if( N2 <= 1 || mxGetN(X2_IN) != 1 )
            mexErrMsgTxt("X2 should have size N2x1 with N2 >= 1\n");
        if( !mxIsDouble(E2_IN) || (mxGetM(E2_IN) != N2) || (mxGetN(E2_IN) != 1) )
            mexErrMsgTxt("E2 should have the same size as X2, and entries of type double\n");
        X2 = (double *)mxGetPr(X2_IN);
        E2 = (double *)mxGetPr(E2_IN);
    }

    K_OUT = mxCreateDoubleMatrix(N,N2,mxREAL);
    calcKernel( mxGetPr(K_OUT), N, X, E, l_X, l_E, sf2, mode, N2, X2, E2 );

    return;
}
