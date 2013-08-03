#
# MandelCPU & MandelGPU Makefile
#

ATISTREAMSDKROOT=/home/david/src/ati-stream-sdk-v2.0-lnx64

CC=gcc
CCFLAGS=-O3 -msse2 -mfpmath=sse -ftree-vectorize -funroll-loops -Wall \
	-I$(ATISTREAMSDKROOT)/include -L$(ATISTREAMSDKROOT)/lib/x86_64 -lGL -lglut -lOpenCL
# Jens's patch for MacOS, comment the 2 lines above and un-comment the lines below
#CCFLAGS=-O3 -ftree-vectorize -msse -msse2 -msse3 -mssse3 -fvariable-expansion-in-unroller \
#	-cl-fast-relaxed-math -cl-mad-enable -Wall -framework OpenCL -framework OpenGl -framework Glut

default: all

all: mandelCPU mandelGPU preprocessed_kernels

mandelGPU: mandelGPU.c displayfunc.c Makefile displayfunc.h
	$(CC) $(CCFLAGS) -o mandelGPU mandelGPU.c displayfunc.c

mandelCPU: mandelCPU.c displayfunc.c Makefile displayfunc.h
	$(CC) $(CCFLAGS) -o mandelCPU mandelCPU.c displayfunc.c

clean:
	rm -rf image.ppm mandelGPU mandelCPU mandelgpu-v1.3.tgz MandelGPU-v1.3 preprocessed_rendering_kernel.cl preprocessed_rendering_kernel_float4.cl

preprocessed_kernelsX:
	cpp <rendering_kernel.cl >preprocessed_rendering_kernel.cl
	cpp <rendering_kernel_float4.cl >preprocessed_rendering_kernel_float4.cl

preprocessed_kernels:
	cat <rendering_kernel.cl >preprocessed_rendering_kernel.cl
	cat <rendering_kernel_float4.cl >preprocessed_rendering_kernel_float4.cl

tgz: all
	mkdir MandelGPU-v1.3
	cp displayfunc.c displayfunc.h LICENSE.txt Makefile mandelCPU.c mandelGPU.c README.txt \
		rendering_kernel.cl rendering_kernel_float4.cl preprocessed_rendering_kernel.cl preprocessed_rendering_kernel_float4.cl \
		mandelCPU mandelGPU MandelGPU.exe glut32.dll \
		MandelGPU-v1.3
	tar zcvf mandelgpu-v1.3.tgz MandelGPU-v1.3
	rm -rf MandelGPU-v1.3
