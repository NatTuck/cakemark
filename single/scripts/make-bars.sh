#!/bin/sh

SCRIPTS=`pwd`/scripts
export PATH="$SCRIPTS:$PATH"
export PERL5LIB="$SCRIPTS:$PERL5LIB"

find charts -name "*.bars" -exec sh -c \
    '(cd `dirname {}` && barchart.pl `basename {}`)' \;

touch charts/bars.xx
