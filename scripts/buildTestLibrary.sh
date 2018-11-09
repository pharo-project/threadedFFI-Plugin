#!/usr/bin/env bash
# Bash3 Boilerplate. Copyright (c) 2014, kvz.io

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__root="$(cd "$(dirname "${__dir}")" && pwd)"

LOCAL_DIR=`pwd`
OS=`${__root}/scripts/getOS.sh`

cd "${__root}/tests/src/c"

if [ $OS == "osx" ]
then
    make -f Makefile.osx
fi

if [ $OS == "linux" ]
then
    make -f Makefile.linux ARCHITECTURE=32 EXTRA=-m32
    make -f Makefile.linux ARCHITECTURE=64 EXTRA=-fPIC
fi

if [ $OS == "windows" ]
then
    make -f Makefile.windows ARCHITECTURE=32 EXTRA=-m32
    make -f Makefile.windows ARCHITECTURE=64 EXTRA=-fPIC
fi

cd "${LOCAL_DIR}"
