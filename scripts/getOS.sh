#!/usr/bin/env bash
# Bash3 Boilerplate. Copyright (c) 2014, kvz.io

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

SYSTEM_NAME=`uname -s`

if [ $SYSTEM_NAME == "Darwin" ] 
then
	echo 'osx'
	exit 0
fi

if [ $SYSTEM_NAME == 'Linux' ] 
then
	echo 'linux'
	exit 0
fi

if [ $SYSTEM_NAME == 'CYGWIN_NT-10.0' ] 
then
	echo 'windows'
	exit 0
fi

#I have no idea where we are
exit 99