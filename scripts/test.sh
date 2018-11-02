#!/bin/bash
set -x
set -e

#Run Tests in OSX 32bits

LOCAL_DIR=`pwd`

./scripts/buildTestLibrary.sh

rm -rf ./tests/osx32	
mkdir -p ./tests/osx32
cd ./tests/osx32

wget -O - get.pharo.org/70+vm | bash

cp ../../build/PharoThreadedFFI-osx32.zip pharo-vm/Pharo.app/Contents/MacOS/Plugins/
unzip pharo-vm/Pharo.app/Contents/MacOS/Plugins/PharoThreadedFFI-osx32.zip -d pharo-vm/Pharo.app/Contents/MacOS/Plugins/

./pharo Pharo.image eval "

Metacello new
        baseline: 'ThreadedFFI';
        repository: 'tonel://../../src';
        load.
		
Smalltalk saveAs:'testFFI'.
		"

cp ../pharo-callback-test/library/build/testLibrary.dylib .

cd $LOCAL_DIR