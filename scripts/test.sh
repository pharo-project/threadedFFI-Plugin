#!/bin/bash
set -x
set -e

#Run Tests in OSX 32bits

./scripts/buildTestLibrary.sh

./scripts/testOSX.sh 32
./scripts/testOSX.sh 64
