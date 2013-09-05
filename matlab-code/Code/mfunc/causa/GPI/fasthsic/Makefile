##### Local configuration #####
 
# Specify C++ compiler
CC=g++

# Specify MatLab MEX compiler
MEX=mex
MEXEXT=.mexglx

# Alternatively, for Octave:
# MEX=mkoctfile --mex
# MEXEXT=.mex

##### Makefile rules #####

all: matlab 

matlab: fasthsic$(MEXEXT) 

# NOTE: the GNU scientific library needs to be installed

fasthsic$(MEXEXT): fasthsic.cpp hsic.cpp hsic.h
	$(MEX) -output $@ $< hsic.cpp -Ifasthsic -lgsl -lgslcblas

.PHONY : clean
clean:
	-rm fasthsic$(MEXEXT)
