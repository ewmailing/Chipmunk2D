#!/bin/sh
# This must be run from the root directory, not the JenkinsScripts directory.

if [ -z "$1" ]
then
	echo "No argument supplied. Using $ANDROID_NDK_ROOT for latest NDK"
	LATEST_ANDROID_NDK_ROOT=$ANDROID_NDK_ROOT
else
	LATEST_ANDROID_NDK_ROOT=$1
fi

# To create
#git submodule add git@github.com:ewmailing/Chipmunk2D.git Chipmunk2D
#git submodule update --init
#git commit -m "Added Chipmunk2D as submodule"

# to fetch (unverified)
#git submodule update --init


#Add copy of Android-CMake toolchain and helper Perl scripts for convenience.
# (Official repo is in Mercurial and I didn't want to add a git-hg dependency for demo purposes.)

mkdir -p buildandroidcmake


# DO NOT SET ANDROID_NDK variable because CMake-Android script doesn't choose the standalone toolchain (bug).
#unset ANDROID_NDK

# The STLPort flag is not required for C code like Chipmunk. But don't forget it for C++ code.
./AndroidCMake/gen_cmakeandroid.pl --sourcedir=. --targetdir=buildandroidcmake --toolchain=AndroidCMake/android.toolchain.cmake --standalone=$LATEST_ANDROID_NDK_ROOT/standalone/ --buildtype=Release --no-build
./AndroidCMake/make_cmakeandroid.pl --targetdir=buildandroidcmake -j2

# Module-ify the built libraries to conform to the Android external module system
(cd buildandroidcmake
#ln -s ../include include;
cp -R ../include include;
)
cp AndroidCMake/Android.mk buildandroidcmake/
#export NDK_MODULE_PATH=`pwd`/build

# (A lib directory needs to exist. Titanium bug in my opinion.)
#mkdir -p lib

#ant

# output goes to the dist subdirectory

