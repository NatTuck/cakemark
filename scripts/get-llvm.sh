#!/bin/bash

J=`cat /proc/cpuinfo | grep processor | wc -l`

if [[ ! -d ~/Apps ]]
then
  mkdir ~/Apps
fi
cd ~/Apps

if [[ ! -d build ]]
then
  mkdir build
fi
cd build

if [[ ! -d llvm ]]
then
    svn co http://llvm.org/svn/llvm-project/llvm/tags/RELEASE_33/final llvm
    (cd llvm/tools &&
        svn co http://llvm.org/svn/llvm-project/cfe/tags/RELEASE_33/final clang)
    (cd llvm/projects &&
        svn co http://llvm.org/svn/llvm-project/compiler-rt/tags/RELEASE_33/final compiler-rt)
fi

(cd llvm &&
    C=gcc CXX=g++ ./configure --enable-shared --enable-targets=all --enable-experimental-targets=R600 --enable-libffi &&
    make -j$J)

# Need to build and install llvm first here?

#(cd llvm/projects &&
#    git clone https://bitbucket.org/gnarf/axtor.git)
