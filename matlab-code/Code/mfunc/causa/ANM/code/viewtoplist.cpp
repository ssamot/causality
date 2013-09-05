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


#include <dags.h>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iostream>
#include <vector>
#include <bitset>
#include <boost/numeric/ublas/symmetric.hpp>


using namespace std;
using namespace boost::numeric;


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
    DAGcode   code;
    double    score;

    solution() {}
    solution( const DAGcode & _code, double _score ) : code(_code), score(_score) {}
    bool operator< ( const solution& a ) const { return( score > a.score ); }
};


int main( int argc, char *argv[] ) {
    if( argc != 4 ) {
        cout << "Usage: " << argv[0] << " <toplist> <outdir> <showall>" << endl << endl;
        cout << "Visualizes a toplist (or only a summary if <showall>==0)." << endl;
        cout << endl;
        cout << "Copyright (c) 2008-2010  Joris Mooij  [joris.mooij@tuebingen.mpg.de]" << endl;
        cout << "All rights reserved.  See the file COPYING for the license terms" << endl;
        return 1;
    } else {
        char *infile = argv[1];
        char *outdir = argv[2];
        int showall = atoi(argv[3]);

        std::vector<solution> toplist;

        ifstream in;
        in.open( infile );
        if( in.is_open() ) {
            // read
            try {
                while ( !in.eof() ) {
                    char c;
                    bitset<BITS> b;
                    DAGcode code;
                    double score1, score2;

                    in.get( c );
                    if( c != '(' && !in.eof() )
                        throw;
                    if( in.eof() )
                        break;
                    while( 1 ) {
                        in >> b;
                        code.push_back( b );
                        in.get( c );
                        if( c == ',' ) {
                            in.get( c );
                            if( c != ' ' )
                                throw;
                        } else if( c == ')' )
                            break;
                        else
                            throw;
                    }
                    in.get( c );
                    if( c != ':' )
                        throw;
                    in.get( c );
                    if( c != ' ' )
                        throw;
                    in >> score1;
                    in.get( c );
                    if( c != ' ' )
                        throw;
                    in >> score2;

                    toplist.push_back( solution( code, score1 ) );

                    in.get( c );
                    if( c != '\n' && !in.eof() )
                        throw;
                }
            } catch( ... ) {
                cerr << "Error reading toplist" << endl;
                in.close();
                return 4;
            }
            in.close();

            size_t n = toplist.back().code.size() + 1;
            std::vector<size_t> Ecommon(n*n,0);
            size_t nr = 0;
            for( std::vector<solution>::const_iterator top = toplist.begin(); top != toplist.end(); top++, nr++ ) {
                DAGmatrix E = Code2Dag( top->code );

                for( size_t i = 0; i < n; i++ )
                    for( size_t j = 0; j < n; j++ )
                        Ecommon[i*n+j] += E[i*n+j];

                if( showall ) {
                    ofstream out;
                    char outname[strlen(outdir) + 100];
                    sprintf( outname, "%s/toplist_%06d.dot", outdir, nr );
                    out.open( outname );
                    if( !out.is_open() ) {
                        cerr << "Cannot open " << outname << " for writing" << endl;
                        return 5;
                    }

                    out << "digraph G {" << endl;
                    for( size_t i = 0; i < n; i++ )
                        for( size_t j = 0; j < n; j++ )
                            if( E[i*n+j] )
                                out << "  " << (i+1) << " -> " << (j+1) << ";" << endl;
                    out << "}" << endl;

                    out.close();
                }
            }


            ofstream out;
            char outname[strlen(outdir) + 100];
            sprintf( outname, "%s/toplist_common.dot", outdir );
            out.open( outname );
            if( !out.is_open() ) {
                cerr << "Cannot open " << outname << " for writing" << endl;
                return 5;
            }
            out << "digraph G {" << endl;
            for( size_t i = 0; i < n; i++ )
                for( size_t j = 0; j < n; j++ ) 
                    if( Ecommon[i*n+j] )
                        out << "  " << (i+1) << " -> " << (j+1) << "[color=grey" << (100-Ecommon[i*n+j]*100/toplist.size()) << "];" << endl;
            out << "}" << endl;
            out.close();


            char command[strlen(outdir) * 2 + 100];
            sprintf( command, "dot -T ps %s/toplist_common.dot > %s/toplist_common.eps", outdir, outdir );
            system( command );
            if( showall )
                for( nr = 0; nr < toplist.size(); nr++ ) {
                    sprintf( command, "dot -T ps %s/toplist_%06d.dot > %s/toplist_%06d.eps", outdir, nr, outdir, nr );
                    system( command );
                }


            sprintf( outname, "%s/toplist.tex", outdir );
            out.open( outname );
            if( !out.is_open() ) {
                cerr << "Cannot open " << outname << " for writing" << endl;
                return 5;
            }
            out << "\\documentclass{article}\n\\usepackage{graphicx}\n\\begin{document}\n";
            char fname[strlen(outdir) + 100];
            sprintf( fname, "%s/toplist_common", outdir );
            out << "Summary of " << toplist.size() << " DAGs:\n\n\\includegraphics[width=8cm,height=8cm]{" << fname << "}\n";
            if( showall ) {
                out << "\\clearpage\n";
                nr = 0;
                for( std::vector<solution>::const_iterator top = toplist.begin(); top != toplist.end(); top++, nr++ ) {
                    sprintf( fname, "%s/toplist_%06d", outdir, nr );
                    out << "\\begin{tabular}{c}\\includegraphics[width=4cm,height=4cm]{" << fname << "}\\\\ " << top->score << "\\end{tabular}\n";
                }
            }
            out << "\\end{document}" << endl;
            out.close();


            sprintf( command, "cd %s; latex toplist; dvips toplist", outdir );
            system( command );
        } else {
            cerr << "Cannot read " << infile << endl;
            return 2;
        }
    }
    return 0;
}
