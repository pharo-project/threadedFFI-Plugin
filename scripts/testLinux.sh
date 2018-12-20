#!/usr/bin/env bash
# Bash3 Boilerplate. Copyright (c) 2014, kvz.io

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__root="$(cd "$(dirname "${__dir}")" && pwd)"

#Run Tests in Linux
LOCAL_DIR=`pwd`

if [ $1 -eq "32" ]; then
	ARCH=32
	PHARO_URL=get.pharo.org/70+vm
else
	ARCH=64
	PHARO_URL=get.pharo.org/64/70+vm
fi


rm -rf "${__root}/results/tests/linux$ARCH"
mkdir -p "${__root}/results/tests/linux$ARCH"
cd "${__root}/results/tests/linux$ARCH"

wget -O - $PHARO_URL | bash

cp "${__root}/results/PharoThreadedFFI-linux$ARCH.zip" "pharo-vm/lib/pharo/5.0-201806281256/"
unzip pharo-vm/lib/pharo/5.0-201806281256/PharoThreadedFFI-linux$ARCH.zip -d pharo-vm/lib/pharo/5.0-201806281256/


ldd pharo-vm/lib/pharo/5.0-201806281256/libffi.so.7

ldd pharo-vm/lib/pharo/5.0-201806281256/libPThreadedPlugin.so

file libPThreadedPlugin.so

objdump -t libPThreadedPlugin.so 

export LD_DEBUG=libs

./pharo Pharo.image eval "

[Metacello new
        baseline: 'ThreadedFFI';
        repository: 'tonel://${__root}/src';
        ignoreImage;
        onConflictUseIncoming;
        onUpgradeUseLoaded: false;
        onDowngradeUseIncoming;
        load] on: MetacelloIgnorePackageLoaded do: [ :e | e resume: true ].
		
Smalltalk saveAs:'testFFI'.
		"

cp "${__root}/results/testLibrary/$ARCH/testLibrary.so" .

./pharo testFFI.image test --fail-on-failure "ThreadedFFI-Tests" "ThreadedFFI-UFFI-Tests"

cd $LOCAL_DIR
