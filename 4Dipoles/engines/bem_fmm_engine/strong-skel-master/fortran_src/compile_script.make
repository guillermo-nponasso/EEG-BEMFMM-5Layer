#location of mex, can be set to ``mex'' on linux systems

MEX=/Applications/MATLAB_R2021a.app/bin/mex


FMM3DINSTALLDIR=/usr/local/lib
FMM3DBIEINSTALLDIR=/usr/local/lib

# Optional on linux systems
GCCPATH=/usr/local/lib/gcc/11

OBJECTS = helmquadcorr.o read_plane_geom.o

FC = gfortran
FFLAGS = -fPIC -march=native -O3 -fopenmp
FEND = -L$(FMM3DINSTALLDIR) -lfmm3d -L$(FMM3DBIEINSTALLDIR) -lfmm3dbie_matlab

.PHONY: all clean

%.o: %.f %.h
	$(FC) -c $(FFLAGS) $< -o $@

all: matlab

matlab: $(OBJECTS) 
	$(MEX) -v fmm3dbierouts.c $(OBJECTS) -largeArrayDims -DMWF77_UNDERSCORE1 -D_OPENMP -L$(GCCPATH) -output fmm3dbierouts -L$(FMM3DINSTALLDIR) -lfmm3d -L$(FMM3DBIEINSTALLDIR) -lfmm3dbie_matlab -lgomp -lstdc++ -lm -ldl -lgfortran

clean:
	rm -f $(OBJECTS)
	rm -f *.mex*
    
