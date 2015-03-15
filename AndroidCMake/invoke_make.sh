#!/bin/sh

# Simple helper script to invoke make on the already generated CMake projects.
# Also invokes ant.

./AndroidCMake/make_cmakeandroid.pl --targetdir=buildandroidcmake/ -j2 "$@"
#export NDK_MODULE_PATH=`pwd`/build
#ant

