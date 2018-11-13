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

os=$(${__root}/scripts/getOS.sh)

cp ${__root}/results/PharoThreadedFFI-${os}${arch}.zip ${__root}/dev/pharo-vm/Pharo.app/Contents/MacOS/Plugins/

unzip -u ${__root}/dev/pharo-vm/Pharo.app/Contents/MacOS/Plugins/PharoThreadedFFI-osx$arch.zip -d ${__root}/dev/pharo-vm/Pharo.app/Contents/MacOS/Plugins/

cp "${__root}/results/testLibrary/testLibrary.dylib" ${__root}/dev/
