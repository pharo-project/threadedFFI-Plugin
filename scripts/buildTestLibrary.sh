#!/bin/bash
set -x
set -e

LOCAL_DIR=`pwd`

if [ -d "tests/pharo-callback-test" ]; then
	exit 0
fi

mkdir -p tests
cd tests

git clone git@github.com:tesonep/pharo-callback-test.git pharo-callback-test
cd pharo-callback-test/library

make