/*  Copyright (c) 2008-2010  Joris Mooij  [joris.mooij@tuebingen.mpg.de]
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are met:
 *
 *  - Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 *  - Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 *  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 *  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 *  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 *  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 *  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 *  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 *  POSSIBILITY OF SUCH DAMAGE.
*/


#include "mex.h"
#include "hsic.h"
#include <cmath>


/* Input Arguments */

#define X_IN       prhs[0]
#define Y_IN       prhs[1]
#define SX_IN      prhs[2]
#define SY_IN      prhs[3]
#define NRPERM_IN  prhs[4]
#define NR_IN      2
#define NR_IN_OPT  3


/* Output Arguments */

#define P_OUT      plhs[0]
#define HSIC_OUT   plhs[1]
#define PROB_OUT   plhs[2]
#define NR_OUT     0
#define NR_OUT_OPT 3


void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[] ) { 
    /* Check for proper number of arguments */
    if( ((nrhs < NR_IN) || (nrhs > NR_IN + NR_IN_OPT)) || ((nlhs < NR_OUT) || (nlhs > NR_OUT + NR_OUT_OPT)) ) { 
        mexErrMsgTxt("Usage: [p,hsic,prob] = fasthsic(x,y,[sx,sy,nrperm])\n\n"
        "\n"
        "Calculates the Hilbert-Schmidt Independence Criterion between x and y using RBF kernels\n"
        "\n"
        "INPUT:    x      = Nxd1 vector of doubles\n"
        "          y      = Nxd2 vector of doubles\n"
        "optional: sx     = kernel bandwidth for x (automatically chosen if equal to 0.0)\n"
        "          sy     = kernel bandwidth for y (automatically chosen if equal to 0.0)\n"
        "          nrperm = |nrperm| is the number of permutations used for estimating the p-value\n"
        "                   (if > 0,  use original biased HSIC estimator,\n"
        "                    if == 0, use gamma approximation,\n"
        "                    if < 0,  use unbiased HSIC estimator)\n"
        "\n"
        "OUTPUT:   p      = p-value of the HSIC\n"
        "                   (large p means independence, small p means dependence)\n"
        "          hsic   = Hilbert Schmidt Independence Criterion estimator for x and y\n"
        "          prob   = probability density of the HSIC\n"
        "\n"
        "Copyright (c) 2008-2010  Joris Mooij  [joris.mooij@tuebingen.mpg.de]\n"
        "All rights reserved.  See the file COPYING for the license terms\n"
        );
    } 

    if( !mxIsDouble(X_IN) )
        mexErrMsgTxt("x should be a dense matrix, with entries of type double\n");
    size_t N = mxGetM(X_IN);
    if( N <= 2 )
        mexErrMsgTxt("N (sample size) should be at least 2\n");
    size_t d1 = mxGetN(X_IN);
    if( !mxIsDouble(Y_IN) || (mxGetM(Y_IN) != N) )
        mexErrMsgTxt("y should have the same number of rows as x, and entries of type double\n");
    size_t d2 = mxGetN(Y_IN);
    double *x = (double *)mxGetPr(X_IN);
    double *y = (double *)mxGetPr(Y_IN);

    double sx = 0.0;
    double sy = 0.0;
    int nrperm = 0;
    if( nrhs > NR_IN ) {
        if( !mxIsDouble(SX_IN) || (mxGetM(SX_IN) != 1) || (mxGetN(SX_IN) != 1) )
            mexErrMsgTxt("sx should be a double scalar\n");
        sx = *((double *)mxGetPr(SX_IN));

        if( nrhs > NR_IN+1 ) {
            if( !mxIsDouble(SY_IN) || (mxGetM(SY_IN) != 1) || (mxGetN(SY_IN) != 1) )
                mexErrMsgTxt("sy should be a double scalar\n");
            sy = *((double *)mxGetPr(SY_IN));
        }

        if( nrhs > NR_IN+2 ) {
            if( (mxGetM(NRPERM_IN) != 1) || (mxGetN(NRPERM_IN) != 1) )
                mexErrMsgTxt("nrperm should be a scalar");
            nrperm = (int)round(*((double *)mxGetPr(NRPERM_IN)));
        }
    }

    HSICresult result = calcHSIC( N, d1, d2, x, y, sx, sy, nrperm );

    // Hand over results to MATLAB
    if( nlhs >= 1 ) {
        P_OUT = mxCreateDoubleMatrix(1,1,mxREAL);
        *(mxGetPr(P_OUT)) = result.p_value;
    }

    if( nlhs >= 2 ) {
        HSIC_OUT = mxCreateDoubleMatrix(1,1,mxREAL);
        *(mxGetPr(HSIC_OUT)) = result.hsic;
    }

    if( nlhs >= 3 ) {
        PROB_OUT = mxCreateDoubleMatrix(1,1,mxREAL);
        *(mxGetPr(PROB_OUT)) = result.prob0;
    }
    
    return;
}
