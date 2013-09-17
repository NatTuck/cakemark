
OPENCL ?= cake

ifeq ($(OPENCL),pocl)
	OCL_LDLIBS = -lpocl -lltdl
	OCL_LDPATH = $(HOME)/Apps/pocl-baseline/lib
	OCL_DTYPE  = cpu
endif

ifeq ($(OPENCL),cake)
	OCL_LDLIBS = -lpocl -lltdl
	OCL_LDPATH = $(HOME)/Apps/pocl/lib
	OCL_DTYPE  = cpu
endif

ifeq ($(OPENCL),amd)
	OCL_LDLIBS = -lamdocl64
	OCL_LDPATH = /usr/lib
	OCL_DTYPE  = cpu
endif

ifeq ($(OPENCL),clover)
	OCL_LDLIBS = -lOpenCL
	OCL_LDPATH = /usr/local/lib
	OCL_DTYPE  = gpu
endif

ifeq ($(OPENCL),nvidia)
	OCL_LDLIBS = -lOpenCL
    OCL_LDPATH = "/usr/lib:$(PANCAKE)/lib"
	OCL_DTYPE  = gpu
endif

export OPENCL
export OCL_LDLIBS
export OCL_LDPATH
