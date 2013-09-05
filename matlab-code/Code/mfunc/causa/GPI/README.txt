Matlab implementation of the probabilistic causal discovery approach described in: 
"Probabilistic latent variable models for distinguishing between cause and effect"
Joris M. Mooij, Oliver Stegle, Dominik Janzing, Kun Zhang, Bernhard Schölkopf. NIPS 2010.


LICENSE:

This project is licensed under the GNU Public License version 2.
Parts of the code are licensed under the more permissive (Free)BSD License.
Each source code file contains notes about which license applies.


DIRECTORY STRUCTURE:

./experiments_nips2010
    Contains the code to produce the figures presented in the main paper.
    See demo.m for a short example how to use the package.
    Licensed under GPL2.

./gpi
    Contains the actual GPI code (needs MEX compilation for speed).
    Mostly FreeBSD licensed, apart for some files that invoke ./mixturecode/*

./webdav
    Download directory for the cause-effect pairs.
    If you want to reproduce the results on real data you need to download the data first 
    from http://webdav.tuebingen.mpg.de/cause-effect/. We used pairs 1-75 in the paper.


CONTRIBUTED PACKAGES:

GPI has dependencies on a number of other packages which we include for ease of use:

./fasthsic
    Fast HSIC code (needs MEX compilation).
    Licensed under FreeBSD License.

./mixturecode
    Mixture fitting algorithm described in the paper
    M. Figueiredo and A.K.Jain, "Unsupervised learning of
    finite mixture models",  IEEE Transaction on Pattern Analysis
    and Machine Intelligence, vol. 24, no. 3, pp. 381-396, March 2002.
    Downloaded from http://www.lx.it.pt/~mtf/mixturecode2.zip
    Licensed under GPL2.

./exportfig 
    Makes exporting figures from MatLab easy.

./gpml-matlab-v3.1-2010-09-27
    Gaussian Processes for Machine Learning Toolbox (needs MEX compilation for
    L-BFGS-B support).
