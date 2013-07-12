
OPENCL ?= cake

ifeq ($(OPENCL),pocl)
	OCL_LDLIBS = -lpocl -lltdl
	OCL_LDPATH = $(HOME)/Apps/pocl-baseline/lib
endif

ifeq ($(OPENCL),cake)
	OCL_LDLIBS = -lpocl -lltdl
	OCL_LDPATH = $(HOME)/Apps/pocl/lib
endif

ifeq ($(OPENCL),amd)
	OCL_LDLIBS = -lamdocl64
	OCL_LDPATH = /usr/lib 
endif

ifeq ($(OPENCL),bzr)
	OCL_LDLIBS = -lpocl -lltdl
	OCL_LDPATH = $(HOME)/Apps/pocl-bzr/lib
endif

ifeq ($(OPENCL),eight)
	OCL_LDLIBS = -lpocl -lltdl
	OCL_LDPATH = $(HOME)/Apps/pocl-0.8/lib
endif

export OPENCL
export OCL_LDLIBS
export OCL_LDPATH
