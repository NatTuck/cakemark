#!/bin/bash
MOD=$1
LIB=/home/nat/Apps/pocl/lib/pocl/llvmopencl.so

FLAGS=-load=$LIB

if test "x$SPEC_TEXT" = "x"
then
    SPEC_TEXT="nn=2048,spin=1"
fi

if test "x$CAKE_SPEC" = "x1"
then
    FLAGS="$FLAGS -specialize -spec-text=\"$SPEC_TEXT\" -kernel=fmma"
fi

FLAGS="$FLAGS $CAKE_OPT_EARLY $CAKE_OPT_LATER $CAKE_OPT_EXTRA -o $MOD-opt.bc $MOD"
echo "opt $FLAGS"
opt $FLAGS
cp $MOD-opt.bc $MOD

echo "Output: $MOD-opt.bc"
