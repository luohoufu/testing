#!/bin/bash

export WORKBASE=$HOME/go/src
export WORK=$WORKBASE/infini.sh

echo "Home path is $HOME"
mkdir -p $WORKBASE
ln -s $GITHUB_WORKSPACE $WORK
echo "Build path is $WORK"
# update Makefile
cp -rf $GITHUB_WORKSPACE/products/framework/Makefile $GITHUB_WORKSPACE/framework
# check work path
ls -alrt $WORK/
env | sort