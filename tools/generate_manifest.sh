#!/bin/bash

#
#  metadata around this build
#
set -e


GIT_HEAD=$(git log --pretty=format:"%H" -1)

cat <<!
BUILD_TAG=$BUILD_TAG
GIT_HEAD=$GIT_HEAD
!

exit 0
