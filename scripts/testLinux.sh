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
	PHARO_URL=get.pharo.org/70+vmLatest
else
	ARCH=64
	PHARO_URL=get.pharo.org/64/70+vmLatest
fi


rm -rf "${__root}/results/tests/linux$ARCH"
mkdir -p "${__root}/results/tests/linux$ARCH"
cd "${__root}/results/tests/linux$ARCH"

wget -O - $PHARO_URL | bash

PHARO_PLUGIN_DIR=`find . -type d | grep "/pharo-vm/lib/pharo/"`

cp "${__root}/results/PharoThreadedFFI-linux$ARCH.zip" "$PHARO_PLUGIN_DIR"
unzip $PHARO_PLUGIN_DIR/PharoThreadedFFI-linux$ARCH.zip -d $PHARO_PLUGIN_DIR

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
