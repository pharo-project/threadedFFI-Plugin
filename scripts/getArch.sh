#!/usr/bin/env bash
# Bash3 Boilerplate. Copyright (c) 2014, kvz.io

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

ARCH=`uname -m`

if [ $ARCH == "x86_64" ] 
then
	echo '64'
	exit 0
fi

if [ $ARCH == 'i686' ] 
then
	echo '32'
	exit 0
fi

#I have no fucking where we are
exit 99