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


// This is an implementation of HSIC, the Hilbert-Schmidt Independence Criterion.
//
// For more information, see
//
// [1] Gretton, A., K. Fukumizu, C. H. Teo, L. Song, B. Schölkopf and A. J. Smola:
// A Kernel Statistical Test of Independence. Advances in Neural Information 
// Processing Systems 20: Proceedings of the 2007 Conference, 585-592. (Eds.) 
// Platt, J. C., D. Koller, Y. Singer, S. Roweis, Curran, Red Hook, NY, USA (09 2008)
//
// [2] Song, L., A. J. Smola, A. Gretton, K. M. Borgwardt and J. Bedo:
// Supervised Feature Selection via Dependence Estimation. Proceedings of the
// 24th Annual International Conference on Machine Learning (ICML 2007),
// 823-830. (Eds.) Ghahramani, Z. ACM Press, New York, NY, USA (06 2007)


#ifndef HSIC_H
#define HSIC_H


#include <vector>
#include <algorithm>


// Given a matrix data of size N*dims, calculates an N*N matrix result
// with entry (i,j) being equal to the l2-norm of data(i,:) - data(j,:)
void get_norm( double *data, size_t N, size_t dims, std::vector<double> &result );


// Returns the square root of half of the median of the vector norm
double get_sigma( const std::vector<double> & norm, size_t N );


// Data structure containing the return values of calcHSIC
struct HSICresult {
    double hsic;         // empirical HSIC estimate
    double p_value;      // p-value for independence test (small p-value means independence is unlikely)
    double prob0;        // probability density of this HSIC estimate under approximated gamma distribution assuming independence
    double hsic0_mean;   // mean of HSIC under approximated gamma distribution assuming independence
    double hsic0_var;    // variance of HSIC under approximated gamma distribution assuming independence
};


// Calculates the Hilbert-Schmidt Independence Criterion between X and Y using RBF kernels
//
// N = number of data points
// dx = dimensionality of X
// dy = dimensionality of Y
// x = points to N*dx matrix containing X
// y = points to N*dy matrix containing Y
// sigma_x = bandwidth of RBF kernel for X (0.0 means chosen by a heuristic)
// sigma_y = bandwidth of RBF kernel for Y (0.0 means chosen by a heuristic)
// nrperm = number of permutations in permutation test 
//   <  0:  use unbiased HSIC (only calculates fields hsic, p_value as output), see [2]
//   == 0:  use approximated gamma distribution instead of permutation test, see [1]
//   >  0:  use biased HSIC (only calculates fields hsic, p_value as output), see [1]
//
// Time complexity:   O(N^2 * nrperm) for the permutation test, O(N^2) for the gamma approximation
// Memory complexity: O(N^2)
HSICresult calcHSIC( size_t N, size_t dx, size_t dy, double *x, double *y, double sigma_x = 0.0, double sigma_y = 0.0, int nrperm = 0 );


#endif
