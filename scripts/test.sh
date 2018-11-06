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

SYSTEM_NAME=`uname -s`

if [ $SYSTEM_NAME == "Darwin" ] 
then
	${__root}/scripts/testOSX.sh 32
	${__root}/scripts/testOSX.sh 64
	exit 0
fi

if [ $SYSTEM_NAME == "Linux" ] 
then
	${__root}/scripts/testLinux.sh 32
	${__root}/scripts/testLinux.sh 64
	exit 0
fi

exit 99