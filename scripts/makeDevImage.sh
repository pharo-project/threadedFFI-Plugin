#!/usr/bin/env bash
# Bash3 Boilerplate. Copyright (c) 2014, kvz.io

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__root="$(cd "$(dirname "${__dir}")" && pwd)"


${__root}/scripts/buildPlugin.sh
${__root}/scripts/buildTestLibrary.sh

if [ $# -ne 1 ]
then
	arch=$(${__root}/scripts/getArch.sh)
else
	arch=$1
fi

if [ $arch eq 32 ]
then
	arch=32
	getPharoURL=get.pharo.org/80+vmLatest
else
	arch=64
	getPharoURL=get.pharo.org/64/80+vmLatest
fi

os=$(${__root}/scripts/getOS.sh)

rm -rf ${__root}/dev
mkdir ${__root}/dev

cd ${__root}/dev
wget -O - ${getPharoURL} | bash

cp ${__root}/results/PharoThreadedFFI-${os}${arch}.zip ${__root}/dev/pharo-vm/Pharo.app/Contents/MacOS/Plugins/

unzip ${__root}/dev/pharo-vm/Pharo.app/Contents/MacOS/Plugins/PharoThreadedFFI-osx$arch.zip -d ${__root}/dev/pharo-vm/Pharo.app/Contents/MacOS/Plugins/

cp "${__root}/results/testLibrary/testLibrary.dylib" ${__root}/dev/

cd ${__root}/dev/

./pharo Pharo.image st --save --quit ${__root}/scripts/updateIceberg.st

./pharo Pharo.image eval --save "
[Metacello new
        baseline: 'ThreadedFFI';
        repository: 'tonel://${__root}/src';
        ignoreImage;
        onConflictUseIncoming;
        onUpgradeUseLoaded: false;
        onDowngradeUseIncoming;
        load] on: MetacelloIgnorePackageLoaded do: [ :e | e resume: true ].
"

cd ${__root}