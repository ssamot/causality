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


#include <cassert>
#include <dags.h>


using namespace std;


size_t nchoosek( size_t n, size_t k ) {
    double result = 1.0;
    assert( k <= n );
    if( k < n/2 )
        k = n - k;
    for( size_t t = k+1; t <= n; t++ ) {
        result *= t;
        result /= (t-k);
    }
    return (size_t)result;
}


bitset<BITS> Sub( size_t i, bitset<BITS> set ) {
    size_t n = set.count();
    assert( i < (1 << n) );
    bitset<BITS> result;
    size_t pos = 0;
    for( size_t j = 0; j < n; j++ ) {
        while( !set[pos] )
            pos++;
        if( (i >> j) & 1 )
            result.set( pos );
        pos++;
    }
    return result;
}


bitset<BITS> KSub( size_t r, size_t k, bitset<BITS> set ) {
    size_t n = set.count();

    size_t x = 1;
    bitset<BITS> result;

    size_t pos = 0;
    for( size_t i = 1; i <= k; i++ ) {
        size_t term = nchoosek( n - x, k - i );
        while( term <= r ) {
            r -= term;
            x++;
            while( !set[pos] )
                pos++;
            pos++;
            term = nchoosek( n - x, k - i );
        }
        while( !set[pos] )
            pos++;
        result.set( pos );
        pos++;
        x++;
    }

    return result;
}


DAGmatrix Code2Dag( const DAGcode & code ) {
    size_t n = code.size() + 1;
    bitset<BITS> S( (1 << n) - 1 );
    DAGmatrix E(n*n,false);
    for( size_t k = n-1; k >= 1; k-- ) {
        bitset<BITS> sbits = S;
        for( size_t i = 0; i < k; i++ )
            sbits &= ~code[i];
        size_t s = 0;
        for( ; s < BITS; s++ )
            if( sbits.test(s) )
                break;
        assert( s != BITS );
        for( size_t u = 0; u < BITS; u++ )
            if( code[k-1].test(u) )
                E[u*n+s] = true;
        S.reset(s);
    }
    return E;
}


DAGparents Code2Parents( const DAGcode & code ) {
    size_t n = code.size() + 1;
    bitset<BITS> S( (1 << n) - 1 );
    DAGparents pa(n);
    for( size_t k = n-1; k >= 1; k-- ) {
        bitset<BITS> sbits = S;
        for( size_t i = 0; i < k; i++ )
            sbits &= ~code[i];
        size_t s = 0;
        for( ; s < BITS; s++ )
            if( sbits.test(s) )
                break;
        assert( s != BITS );
        for( size_t u = 0; u < BITS; u++ )
            if( code[k-1].test(u) )
                pa[s].set( u );
        S.reset(s);
    }
    return pa;
}


DAGcausalorder CausalOrder( const DAGparents & pa ) {
    size_t n = pa.size();
    DAGcausalorder past;
    past.reserve( n );
    bitset<BITS> future( (1 << n) - 1 );

    while( future != 0 )
        for( size_t i = 0; i < BITS; i++ )
            if( future[i] )
                if( (pa[i] & future) == 0 ) {
                    past.push_back( i );
                    future.reset( i );
                }

    return past;
}


bool isSuperDAG( const DAGcode &c1, const DAGcode &c2 ) {
    assert( c1.size() == c2.size() );
    size_t n = c1.size() + 1;

    DAGmatrix A1 = Code2Dag( c1 );
    DAGmatrix A2 = Code2Dag( c2 );
    
    bool result = true;
    for( size_t i = 0; i < n*n; i++ )
        if( A2[i] == true && A1[i] == false ) {
            result = false;
            break;
        }

    return result;
}
