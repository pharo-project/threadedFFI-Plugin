#!/bin/bash
set -x
set -e

#Run Tests in OSX

LOCAL_DIR=`pwd`

if [ $1 -eq "32" ]; then
	ARCH=32
	PHARO_URL=get.pharo.org/70+vm
else
	ARCH=64
	PHARO_URL=get.pharo.org/64/70+vm
fi


rm -rf ./tests/osx$ARCH	
mkdir -p ./tests/osx$ARCH
cd ./tests/osx$ARCH

wget -O - $PHARO_URL | bash

cp ../../build/PharoThreadedFFI-osx$ARCH.zip pharo-vm/Pharo.app/Contents/MacOS/Plugins/
unzip pharo-vm/Pharo.app/Contents/MacOS/Plugins/PharoThreadedFFI-osx$ARCH.zip -d pharo-vm/Pharo.app/Contents/MacOS/Plugins/

./pharo Pharo.image eval "

Metacello new
        baseline: 'ThreadedFFI';
        repository: 'tonel://../../src';
        load.
		
Smalltalk saveAs:'testFFI'.
		"

cp ../pharo-callback-test/library/build/testLibrary.dylib .

./pharo testFFI.image test --fail-on-failure "ThreadedFFI-Tests" "ThreadedFFI-UFFI-Tests"

cd $LOCAL_DIR