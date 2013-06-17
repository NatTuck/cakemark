
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
