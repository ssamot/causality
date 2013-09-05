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


// This is an implementation of some of the algorithms in [Ste03] for dealing
// with Directed Acyclic Graphs (DAGs).
//
// [Ste03] B. Steinsky, Efficient coding of labeled directed acyclic graphs,
// Soft Computing 7 (2003) 350-356.


#ifndef DAGS_H
#define DAGS_H


#include <bitset>
#include <vector>


#define BITS 10
#define MAX(x,y) (((x)<(y))?(y):(x))
#define MIN(x,y) (((x)<(y))?(x):(y))


typedef std::vector<std::bitset<BITS> > DAGcode;
typedef std::vector<std::bitset<BITS> > DAGparents;
typedef std::vector<bool>               DAGmatrix;
typedef std::vector<unsigned>           DAGcausalorder;


// returns n! / (k! (n-k)!)
size_t nchoosek( size_t n, size_t k );

// returns the i'th subset of set
std::bitset<BITS> Sub( size_t i, std::bitset<BITS> set );

// returns the i'th subset with size k of set
std::bitset<BITS> KSub( size_t r, size_t k, std::bitset<BITS> set );

// converts a DAG code to an adjacency matrix
// (algorithm 2 in [Ste03])
DAGmatrix Code2Dag( const DAGcode & code );

// converts a DAG code to a vector of parent sets
// (based on algorithm 2 in [Ste03])
DAGparents Code2Parents( const DAGcode & code );

// returns a causal ordering compatible with a DAG
DAGcausalorder CausalOrder( const DAGparents & pa );

// returns true if c1 is a super DAG of c2
// i.e. each arrow in c2 is also in c1
bool isSuperDAG( const DAGcode &c1, const DAGcode &c2 );

// recursively enumerates over all DAG codes
// algorithm 5 in [Ste03]
template <class Functor>
class EnumDagCodes {
    private:
        size_t n;
        Functor &f;         // should have operator()( const DAGcode & ) defined
        DAGcode A;

        void recurse( std::bitset<BITS> un, size_t s ) {
            size_t nr_un = un.count();
            if( nr_un == s )
                return;
            if( s <= n - 1 ) {
                std::bitset<BITS> un_comp((1 << n) - 1);
                un_comp ^= un;
                size_t max_i = 1 << nr_un;
                for( size_t i = 0; i < max_i; i++ ) {
                    std::bitset<BITS> X = Sub( i, un );
                    for( size_t k = 0; k < n - nr_un; k++ ) {
                        size_t max_j = nchoosek( n - nr_un, k );
                        for( size_t j = 0; j < max_j; j++ ) {
                            A[s-1] = X | KSub( j, k, un_comp );
                            recurse( un | A[s-1], s + 1 );
                        }
                    }

                }
            } else
                f( A );
        }

    public:
        EnumDagCodes( size_t _n, Functor & _f ) : n(_n), f(_f), A(_n-1) {}
        void run() { 
            recurse( std::bitset<BITS>(), 1 );
        }
};


#endif
