N=100

OPT = -O3
INC = -I.
CCFLAGS = -Ofast -march=native -funroll-loops -DNDEBUG -fwhole-program #-flto
FCFLAGS = -Ofast -march=native -funroll-loops -DNDEBUG -fwhole-program #-flto
CXXFLAGS = -std=c++14 $(OPT) -march=native -funroll-loops -DNDEBUG

# INCLUDE PATHS AND PACKAGE SPECIFIC FLAGS
# ------------------------------------------------------------------------------------ #
EIGEN_INC = -I/Users/roman/Downloads/eigen-master/ $(INC)

BLAZE_INC = -I/Users/roman/Downloads/blaze-3.7/ $(INC)

ARMA_INC = -I/Users/roman/Downloads/armadillo-9.850.1/include/ $(INC)
ARMA_FLAGS = -DARMA_NO_DEBUG -lblas -llapack

XTENSOR_INC = -I/Users/roman/Downloads/xtensor/include/ -I/Users/roman/Downloads/xtl/include/
XTENSOR_INC += -I/Users/roman/Downloads/xtensor-blas/include/ -I/Users/roman/Downloads/xsimd/include/
XTENSOR_INC += $(INC)
XTENSOR_FLAGS = -DXTENSOR_USE_XSIMD -lblas -llapack

FASTOR_INC = -I//Users/roman/Dropbox/zHandies_Docs/Fastor/
FASTOR_FLAGS = -DFASTOR_NO_ALIAS -DFASTOR_USE_VECTORISED_EXPR_ASSIGN -DFASTOR_DISPATCH_DIV_TO_MUL_EXPR
# ------------------------------------------------------------------------------------ #


ifeq "$(CXX)" "g++"
	CXXFLAGS += -finline-functions -finline-limit=1000000 -ffp-contract=fast
endif
ifeq "$(CXX)" "g++-9"
	CXXFLAGS += -finline-functions -finline-limit=1000000 -ffp-contract=fast
endif
ifeq "$(CXX)" "/usr/local/bin/g++-9"
	CXXFLAGS += -finline-functions -finline-limit=1000000 -ffp-contract=fast
endif

CL_REC_DEPTH = 10000000
ifeq "$(CXX)" "clang++"
	CXXFLAGS += -ftemplate-depth=$(CL_REC_DEPTH) -fconstexpr-depth=$(CL_REC_DEPTH) -foperator-arrow-depth=$(CL_REC_DEPTH)
	CXXFLAGS += -mllvm -inline-threshold=$(CL_REC_DEPTH) -ffp-contract=fast
endif
ifeq "$(CXX)" "c++"
	CXXFLAGS += -ftemplate-depth=$(CL_REC_DEPTH) -fconstexpr-depth=$(CL_REC_DEPTH) -foperator-arrow-depth=$(CL_REC_DEPTH)
	CXXFLAGS += -mllvm -inline-threshold=$(CL_REC_DEPTH) -ffp-contract=fast
endif

ifeq "$(CXX)" "icpc"
	CXXFLAGS += -inline-forceinline -fp-model fast=2
endif

# On some architectures -march=native does not define -mfma
HAS_FMA := $(shell $(CXX) -march=native -dM -E - < /dev/null | egrep "AVX2" | sort)
ifeq ($(HAS_FMA),)
else
CXXFLAGS += -mfma
endif


all:
# 	$(FC) views_loops.f90 -o out_floops.exe $(FCFLAGS)
# 	$(FC) views_vectorised.f90 -o out_fvec.exe $(FCFLAGS)
	$(CXX) views_eigen.cpp -o out_cpp_eigen.exe $(CXXFLAGS) $(EIGEN_INC)
	$(CXX) views_blaze.cpp -o out_cpp_blaze.exe $(CXXFLAGS) $(BLAZE_INC)
	$(CXX) views_fastor.cpp -o out_cpp_fastor.exe $(CXXFLAGS) $(FASTOR_INC) $(FASTOR_FLAGS)
	$(CXX) views_armadillo.cpp -o out_cpp_armadillo.exe $(CXXFLAGS) $(ARMA_INC) $(ARMA_FLAGS)
	$(CXX) views_xtensor.cpp -o out_cpp_xtensor.exe $(CXXFLAGS) $(XTENSOR_INC) $(XTENSOR_FLAGS)

run:
# 	./out_c.exe $(N)
# 	./out_floops.exe $(N)
# 	./out_fvec.exe $(N)
	./out_cpp_eigen.exe $(N)
	./out_cpp_blaze.exe $(N)
	./out_cpp_armadillo.exe $(N)
	./out_cpp_fastor.exe $(N)
	./out_cpp_xtensor.exe $(N)

clean:
	rm -rf *.exe