
-------------------------------------------------------------------------------

BASIC INFO

Name of pack: 	lingam

Homepage:	http://www.cs.helsinki.fi/group/neuroinf/lingam/

Version:	1.4.2 (21 Dec 2006)

What it does:	Estimates a linear non-gaussian causal model, assuming
		no unobserved confounders.

                The method is described in the following papers (all
                available online, see LiNGAM homepage):

                S. Shimizu, P.O. Hoyer, A. Hyvarinen, and A.J. Kerminen
                "A linear non-gaussian acyclic model for causal discovery"
                Journal of Machine Learning Research 7: 2003-2030, 2006.

                P.O. Hoyer, S. Shimizu, A. Hyvarinen, Y. Kano, and
                A.J. Kerminen
                "New permutation algorithms for causal discovery using ICA"
                Proc. Int. Symp. on Independent Component Analysis and
                Blind Signal Separation (ICA-2006), pp. 115-122, Charleston,
                SC, USA, 2006.

                S. Shimizu, A. Hyvarinen, Y. Kano, and P.O. Hoyer
                "Discovery of non-gaussian linear causal models using ICA"
                Proc. Uncertainty in Artificial Intelligence (UAI-2005)
                pp. 526-533, Cambridge, MA, USA, 2005.

Requirements:	Matlab or Octave (a free Matlab clone), see
		http://www.mathworks.com/
		http://www.octave.org/

		For graph visualization: Graphviz, see
		http://www.graphviz.org/

Authors:	Version 1.0: Patrik O. Hoyer 
		Version 1.1: Patrik O. Hoyer
		Version 1.2: Antti Kerminen
		Version 1.3: Shohei Shimizu and Antti Kerminen
		Version 1.4: Patrik O. Hoyer, Antti Kerminen and
		             Shohei Shimizu
		Version 1.4.1: Patrik O. Hoyer		             
		Version 1.4.2: Shohei Shimizu

-------------------------------------------------------------------------------

FASTICA CODE

This package uses the ICA code implemented in the FastICA code package,
available from 

http://www.cis.hut.fi/projects/ica/fastica/

For convenience, this code is supplied as part of this package, so there
should be no need for you to separately download this code. 

As of version 1.1, we also include the excellent port of FastICA to Octave
by Daniel Ryan (High Energy Physics, Tufts University, Boston, MA). 

-------------------------------------------------------------------------------

VERSION HISTORY

1.0 (22 March 2005)   - Initial version of the package, based on
			method described in (Shimizu et al. 2005).

1.1 (5 July 2005)     - Included new algorithms for finding the optimal
			permutations. These new algorithms allow the
			estimation of networks of more than 8 variables
			(which was the practical limit for the brute-
			force method). 

			Also made the package Octave-compatible.

1.2 (29 Sep 2005)     - Included possibility to visualize the estimated
			causal model as a graph. 

1.3 (8 Mar 2006)      - The code is revised to follow the description
                        in (Shimizu et al. 2006). Includes new pruning
			algorithms and a model fit test.

1.4 (12 Jul 2006)     - The linear programming method for the linear
			assigment problem (the first permutation algorithm)
			is replaced by the Hungarian algorithm.

			The function to produce figure 2 in the JMLR
			paper is revised.

			Some small changes to ensure Octave compatibility.

1.4.1 (18 Sep 2006)   -	Fixed a bug in 'nzdiagbruteforce.m'. Essentially,
			the buggy output variable 'rowp' was the inverse of 
			the correct permutation. This did not, however, show
			up in our code or experiments since we only used
			the 'Wopt' output variable. Nevertheless, this bug
			was fixed to avoid future problems and/or problems
			for other users utilizing the function.

1.4.2 (21 Dec 2006)   - Added a pruning method based on proper Bootstrap
			resampling ('olsboot'). See 'help prune' for 
			more information. 

-------------------------------------------------------------------------------

USAGE

Main code files:

estimate.m    - the code estimating a causal model from data
prune.m       - the code for pruning the causal connections
modelfit.m    - a statistical test for estimating the model fit
testlingam.m  - tests the LiNGAM analysis using random parameter settings
plots.m       - produces figure 2 in the UAI-2005 paper

For backwards compatibility:

lingam.m      - the code for performing the complete LiNGAM analysis

To try it out, simply start up Matlab (or Octave) and, while in the 
'code' directory, call

>> testlingam;

The code will create a random network, generate some data according to
this model, and then call on 'lingam' to estimate the generating
parameters. Finally, it shows scatterplots of how well the estimation
worked, as well as prints out the original and estimated connection
matrices, to allow the user to judge whether the structure of the
DAG was correctly estimated (same patterns of zero/non-zero coefficients
in the connection matrices).

To perform the LiNGAM analysis on your own data, simply call

>> [B stde ci k W] = estimate(X);

with 'X' containing your data such that each row is a variable and each
column one observed vector. Note that you should have many more columns
than variables to have any chance of getting any reliable results.

The returned matrix 'B' contains the estimated connection strengths,
the vectors 'stde' and 'ci' contain the standard deviations of the
disturbance variables as well as the constants. The 'k' contains an
estimated causal order.

'W' is the demixing matrix of the independent components, in the
estimated row ordering. It is needed by pruning algorithms based
on Wald statistics.

To prune the weight matrix 'B', call

>> Bpruned = prune(X, k, 'method', 'olsboot', 'B', B);

This will try to remove the weights in 'B' that are small estimation errors
of FastICA. For more options on pruning, see the help section of 'prune'.

For backwards compatibility, we provide the 'lingam' function. The call

>> [B stde ci k] = lingam(X);

equals to calls

>> [B stde ci k] = estimate(X);
>> [B stde ci] = prune(X, k);

To visualize the estimated causal model, call

>> plotmodel(B, k)

This will plot the model as a directed graph. The 'plotmodel' function
accepts several parameters to control the plotting. Type 'help plotmodel'
for more detailed information.

In order to use 'plotmodel', you need
  1) Graphviz graph visualization software installed in your system, or
  2) Java and an internet connection.

Graphviz is an Open Source program available at www.graphviz.org.
The download section includes source code and binaries for most
common platforms. We also distribute (in the 'graphviz' directory)
the latest stable source code at Sep 2005, along with the binaries
for Mac OS X and Windows platforms. Linux users should be able
to compile the source code without difficulties. The 'INSTALL' file
contains short instructions for installing Graphviz for various
platforms.

Java plotting uses Grappa, a Java graph drawing package by John Mocenigo.
We include it as a jar-package only. The full distribution is available at
http://www.research.att.com/~john/Grappa/.

-------------------------------------------------------------------------------

REPRODUCING THE RESULTS IN THE PAPERS

We provide code for reproducing the results presented in our papers.
To run the code, add path to the corresponding subdirectory while
keeping the 'code' directory your working directory.

UAI-2005: m-files in subdirectory 'uai2005'
    plots                - Produces the plots for figure 2.

ICA-2006: m-files in subdirectory 'ica2006'
    hdplots              - Demonstrates the performance of the method in
                           high dimensions (figure 1).

JMLR: m-files in subdirectory 'jmlr'
    findexample          - Finds an example graph (figure 4).
    graphsjmlr           - Plots graphs (figure 3).
    plotsjmlr            - Produces scatterplots (figure 2).
    testlingamforpruning - Tests LiNGAM using completely random parameters.
    testpruning          - Tests edge pruning (table 1).


-------------------------------------------------------------------------------

FORTHCOMING IMPROVEMENTS

Among other things, the following are on our to-do list:

- Tests of independence of the components found by ICA

-------------------------------------------------------------------------------

ACKOWLEDGEMENTS

We use an implementation of the Hungarian algorithm written by Niclas
Borlin.

The permsOctave.m is an translation of a C program written by Frank
Ruskey and Joe Sawada.

-------------------------------------------------------------------------------

QUESTIONS?

Feel free to ask us anything relating to the method or the code. However,
we would really appreciate it if before you asked you would make an effort 
to thoroughly read this document and also the above mentioned papers
describing the method. If something still is unclear, please email your
question to us. Please try to be specific, in what way is the code not 
functioning properly, what error messages do you get, etc. Thanks!

patrik.hoyer@helsinki.fi
shoheishimizu@mac.com

-------------------------------------------------------------------------------
