
OPENCL ?= nvidia

ifeq ($(OPENCL),pocl)
	OCL_LDLIBS  := -lpocl -lltdl
	OCL_LDPATH  := $(HOME)/Apps/pocl-baseline/lib
	OCL_DTYPE   := cpu
endif

ifeq ($(OPENCL),cake)
	OCL_LDLIBS := -lpocl -lltdl
	OCL_LDPATH := $(HOME)/Apps/pocl/lib
	OCL_DTYPE  := cpu
endif

ifeq ($(OPENCL),amd)
	OCL_LDLIBS := -lamdocl64
	OCL_LDPATH := /usr/lib/fglrx:/usr/local/lib:
	OCL_DTYPE  := cpu
endif

ifeq ($(OPENCL),amdgpu)
	OCL_LDLIBS := -lamdocl64
	OCL_LDPATH := /usr/lib/fglrx
	OCL_DTYPE  := gpu
endif

ifeq ($(OPENCL),clover)
	OCL_LDLIBS := -lOpenCL
	OCL_LDPATH := /usr/local/lib
	OCL_DTYPE  := gpu
endif


ifeq ($(OPENCL),nvidia)
	OCL_LDLIBS  := -lOpenCL
	OCL_LDPATH  := /usr/lib
	OCL_DTYPE   := gpu
endif

OCL_LDFLAGS := -L$(OCL_LDPATH) -L$(PANCAKE)/lib
OCL_LDPATH  := $(OCL_LDPATH):/usr/local/lib:$(PANCAKE)/lib

export OPENCL
export OCL_LDLIBS
export OCL_LDPATH
export OCL_LDFLAGS
