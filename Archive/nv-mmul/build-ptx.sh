#!/bin/bash

INC=`pkg-config libclc --variable=includedir`
LIB=`pkg-config libclc --variable=libexecdir`

SRC=$1
DST=$2

LL0=`tempfile`.ll
LL1=`tempfile`.ll
LL2=`tempfile`.ll

if [[ "x$SRC" = "x" || "x$DST" = "x" ]]
then
    echo "Usage: $0 xx.cl yy.ptx"
    exit 1
fi


echo "Compiling OpenCL ($SRC) to NVIDIA PTX ($DST)"


clang -emit-llvm -xcl -target nvptx--nvidiacl -S -o $LL0 $SRC \
    -include $INC/clc/clc.h -Dcl_clang_storage_class_specifiers

opt -S -o $LL1 $LL0

llvm-link -S $LIB/nvptx--nvidiacl.bc $LL1 -o $LL2

clang -target nvptx $LL2 -S -o $DST
