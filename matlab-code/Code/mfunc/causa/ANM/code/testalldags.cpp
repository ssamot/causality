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
#include "dags.h"
#include <iostream>
#include <fstream>
#include <vector>
#include <cstring>
#include <cstdlib>
#include <boost/numeric/ublas/matrix.hpp>
#include <boost/numeric/ublas/symmetric.hpp>


using namespace std;
using namespace boost::numeric;


/* Input Arguments */

#define N_IN          prhs[0]
#define RES_IN        prhs[1]
#define THRESHOLD_IN  prhs[2]
#define TOPLIST_IN    prhs[3]
#define FILENAME_IN   prhs[4]
#define NR_IN         5


/* Output Arguments */

#define NR_OUT     0


// Output a vector
template<class T>
std::ostream& operator << (std::ostream& os, const std::vector<T> & x) {
    os << "(";
    for( typename std::vector<T>::const_iterator it = x.begin(); it != x.end(); it++ )
        os << (it != x.begin() ? ", " : "") << *it;
    os << ")";
    return os;
}


struct solution {
    DAGcode  code;
    double   score1;
    double   score2;

    solution() {}
    solution( const DAGcode & _code, double _score1, double _score2 ) : code(_code), score1(_score1), score2(_score2) {}
    bool operator< ( const solution& a ) const { return( score1 > a.score1 ); }
};



class TestAllDags {
    private:
        size_t n;
        size_t nrDataPoints;
        double *res;
        double alpha;
        size_t ToplistSize;
        ostream &os;

        size_t counter;
        ublas::symmetric_matrix<double> hsic_pvalues;
        ublas::symmetric_matrix<double> hsic_probs;
        std::vector<solution> toplist;
        
    public:
        TestAllDags( size_t _n, size_t _nrDataPoints, double *_res, double _alpha, size_t _ToplistSize, ostream& _os ) : n(_n), nrDataPoints(_nrDataPoints), res(_res), alpha(_alpha), ToplistSize(_ToplistSize), counter(0), hsic_pvalues(), hsic_probs(), toplist(), os(_os) {}
        void operator()( const DAGcode & code );
        std::pair<double,double> HSIC( size_t index1, size_t index2 );

        void run() {
            hsic_pvalues.resize( n * (1 << n), false );
            hsic_probs.resize( n * (1 << n), false );
            for( size_t i = 0; i < hsic_pvalues.size1(); ++i )
                for( size_t j = 0; j <= i; ++j ) {
                    hsic_pvalues(i,j) = -1.0;
                    hsic_probs(i,j) = -1.0;
                }

            EnumDagCodes<TestAllDags> edc( n, *this );
            edc.run();
            
            cout << "Tested " << counter << " DAGS, of which " << toplist.size() << " are consistent with the data:" << endl;
            for( std::vector<solution>::const_iterator top = toplist.begin(); top != toplist.end(); top++ )
                cout << top->code << ": " << top->score1 << " " << top->score2 << endl;

            for( long i = 0; i < toplist.size(); i++ )
                for( long j = 0; j < toplist.size(); j++ ) {
                    if( toplist[i].code != toplist[j].code && isSuperDAG( toplist[j].code, toplist[i].code ) ) {
                        toplist.erase( toplist.begin() + j );
                        if( i >= j )
                            i--;
                        j--;
                    }
                }

            cout << "After applying Occam's razor (throwing away supergraphs), the following " << toplist.size() << " DAGs remain:" << endl;
            for( std::vector<solution>::const_iterator top = toplist.begin(); top != toplist.end(); top++ ) {
                cout << top->code << ": " << top->score1 << " " << top->score2 << endl;
                os << top->code << ": " << top->score1 << " " << top->score2 << endl;
            }
        }
};


std::pair<double,double> TestAllDags::HSIC( size_t index1, size_t index2 ) {
    double p_value;
    double prob;
    if( hsic_pvalues(index1,index2) < 0.0 ) {
        HSICresult result = calcHSIC( nrDataPoints, 1, 1, res + nrDataPoints * index1, res + nrDataPoints * index2 );
        hsic_pvalues(index1,index2) = result.p_value;
        hsic_probs(index1,index2) = result.prob0;
        p_value = result.p_value;
        prob = result.prob0;
    } else {
        p_value = hsic_pvalues(index1,index2);
        prob = hsic_probs(index1,index2);
    }
    return std::pair<double,double>(p_value,prob);
}


void TestAllDags::operator()( const DAGcode & code ) {
    if( ((++counter) % 100000) == 0 ) {
        cout << "Tested " << counter << " DAGs, current toplist has size " << toplist.size();
        if( toplist.size() > 0 )
           cout << " and scores between (" << toplist.back().score1 << ", " << toplist.back().score2 << ") and (" << toplist.front().score1 << ", " << toplist.front().score2 << ")" << endl;
        cout << endl;
    }
    DAGparents pa = Code2Parents( code );
    DAGcausalorder co = CausalOrder( pa );

    size_t verbose = 0;

    if( verbose )
        cout << "Testing " << code << ", parents " << pa << ", causal order " << co << endl;

    bool rejected = false;
    double score1 = 1.0;
    double score2 = 1.0;
    for( DAGcausalorder::const_iterator t = co.begin(); t != co.end(); t++ ) {
        size_t index_t = (*t) * (1 << n) + pa[*t].to_ulong();
        for( DAGcausalorder::const_iterator r = co.begin(); r != t; r++ ) {
            size_t index_r = (*r) * (1 << n) + pa[*r].to_ulong();
            std::pair<double,double> result = HSIC(index_r, index_t);
            double pvalue = result.first;
            double prob = result.second;
            score1 *= pvalue;
            score2 *= prob;
            if( verbose )
                cout << "  HSIC(co[" << *t << "],co[" << *r << "]) yields " << pvalue << ", new score1 = " << score1 << ", new score2 = " << score2 << endl;
            if( alpha == 0.0 ) {
                if( score1 == 0.0 ) {
                    rejected = true;
                    break;
                }
            } else {
                if( pvalue < alpha ) {
                    rejected = true;
                    break;
                }
            }
        }
        if( rejected )
            break;
    }
    if( verbose ) {
        if( rejected )
            cout << "  rejected." << endl;
        else
            cout << "  accepted." << endl;
    }

    if( !rejected ) {
        solution sol(code, score1, score2);
        if( (toplist.size() < ToplistSize) || (sol < toplist.back()) ) {
            toplist.push_back( solution( code, score1, score2 ) );
            sort( toplist.begin(), toplist.end() );
            if( toplist.size() > ToplistSize )
                toplist.resize( ToplistSize );
            if( verbose ) {
                for( std::vector<solution>::const_iterator top = toplist.begin(); top != toplist.end(); top++ )
                    cout << top->code << ": " << top->score1 << " " << top->score2 << endl;
            }
        }
    }
}


void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[] ) { 
    /* Check for proper number of arguments */
    if( (nrhs != NR_IN) || (nlhs != NR_OUT) ) { 
        mexErrMsgTxt("Usage: testalldags(n,res,alpha,toplist,filename)\n\n"
        "\n"
        "INPUT:  n         = Number of variables\n"
        "        res       = matrix of residuals, where each column corresponds to a\n"
        "                    pair (i, pa_i) with i the variable number and pa_i the\n"
        "                    parent set of i; thus the width of res should be n * 2^n.\n"
        "        alpha     = threshold for each independence test (e.g. 0.05);\n"
        "                    if threshold==0.0 then calculate score of model obtained by\n"
        "                    multiplying the p-values together; the DAG is rejected if score==0.\n"
        "        toplist   = number of entries in the top models list (e.g. 20).\n"
        "        filename  = filename to which the toplist will be written.\n"
        "\n"
        "Copyright (c) 2008-2010  Joris Mooij  [joris.mooij@tuebingen.mpg.de]\n"
        "All rights reserved.  See the file COPYING for the license terms\n"
        );
    } 

    if( !mxIsDouble( N_IN ) || (mxGetM( N_IN ) != 1) || (mxGetN( N_IN ) != 1) )
        mexErrMsgTxt("n should be an integer scalar.\n" );
    size_t n = (size_t)*((double *)mxGetPr( N_IN ));
    
    if( !mxIsDouble(RES_IN) || mxGetN(RES_IN) != (n * (1 << n)) )
        mexErrMsgTxt("res should be a dense matrix, with entries of type double.\n");
    double *res = (double *)mxGetPr(RES_IN);
    size_t nrDataPoints = mxGetM(RES_IN);

    if( !mxIsDouble( THRESHOLD_IN ) || (mxGetM( THRESHOLD_IN ) != 1) || (mxGetN( THRESHOLD_IN ) != 1) )
        mexErrMsgTxt("alpha should be a scalar.\n" );
    double alpha = *((double *)mxGetPr( THRESHOLD_IN ));
    
    if( !mxIsDouble( TOPLIST_IN ) || (mxGetM( TOPLIST_IN ) != 1) || (mxGetN( TOPLIST_IN ) != 1) )
        mexErrMsgTxt("toplist should be an integer scalar.\n" );
    size_t toplist = (size_t)*((double *)mxGetPr( TOPLIST_IN ));
    
    if( !mxIsChar( FILENAME_IN ) )
        mexErrMsgTxt("filename should be a string.\n" );
    size_t len = mxGetNumberOfElements(FILENAME_IN) + 1;
    char *filename = (char *)mxCalloc(len, sizeof(char));
    if( mxGetString( FILENAME_IN, filename, len ) != 0 )
        mexErrMsgTxt("Could not convert string data.");

    ofstream out;
    out.open( filename );
    if( !out.is_open() ) {
        char msg[100 + strlen(filename)];
        sprintf(msg, "Cannot open %s for writing!\n", filename);
        mexErrMsgTxt(msg);
    }
    TestAllDags dothework( n, nrDataPoints, res, alpha, toplist, out );
    dothework.run();
    out.close();

    return;
}
