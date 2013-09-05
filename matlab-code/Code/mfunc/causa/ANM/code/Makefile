##### Local configuration #####
 
# Specify C++ compiler
CC=g++

# Specify MEX compiler
# e.g. for MatLab:
MEX=/agbs/share/sw/matlab/bin/mex
MEXEXT=.mexglx
# or for Octave:
#MEX=mkoctfile --mex
#MEXEXT=.mex


##### Makefile rules #####

all: viewtoplist fasthsic$(MEXEXT) testalldags$(MEXEXT)

viewtoplist: viewtoplist.cpp dags/dags.cpp
	g++ -Idags viewtoplist.cpp dags/dags.cpp -o viewtoplist

fasthsic$(MEXEXT): fasthsic/fasthsic.cpp fasthsic/hsic.cpp fasthsic/hsic.h
	$(MEX) fasthsic/fasthsic.cpp fasthsic/hsic.cpp -Ifasthsic -lgsl -lgslcblas

testalldags$(MEXEXT): testalldags.cpp fasthsic/hsic.cpp dags/dags.cpp dags/dags.h
	$(MEX) testalldags.cpp fasthsic/hsic.cpp dags/dags.cpp -Ifasthsic -Idags -lgsl -lgslcblas

.PHONY : clean
clean:
	-rm viewtoplist
	-rm fasthsic$(MEXEXT)
	-rm testalldags$(MEXEXT)
