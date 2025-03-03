#!/bin/bash

DNAME=easysearrch
DEST=$GITHUB_WORKSPACE/dest
WORK=$GITHUB_WORKSPACE/products/$PNAME

echo "Prepar build docker files"
mkdir -p $DEST

cd $WORK

for t in amd64 arm64; do
  mkdir -p $WORK/{$PNAME-$t,$DNAME-$t}
  EZS_VER=curl -sSL $RELEASE_URL/.latest |jq ".$DNAME"
  EZS_FILE=$DEST/$DNAME-$EZS_VER-linux-$t.tar.gz
  wget -q -nc --show-progress --progress=bar:force:noscroll $RELEASE_URL/$DNAME/stable/$DNAME-$EZS_VER-linux-$t.tar.gz -O $EZS_FILE
  if [ -f $EZS_FILE ]; then
    echo -e "Extract file \nfrom $EZS_FILE \nto $WORK/$DNAME-$t"
    tar -zxf $EZS_FILE -C $WORK/$DNAME-$t
  else
    echo "Error: $EZS_FILE not found exit now."
    exit 1
  fi

  # Copy coco
  cp -rf $WORK/bin/$PNAME-linux-$t $WORK/$PNAME-$t
  cp -rf $WORK/bin/{LICENSE,NOTICE,$PNAME.yml} $WORK/$PNAME-$t

  # ES_DISTRIBUTION_TYPE need change to docker
  sed -i 's/tar/docker/' $WORK/$DNAME-$t/bin/$DNAME-env
  cat $GITHUB_WORKSPACE/products/$PNAME/config/$DNAME.yml > $WORK/$DNAME-$t/config/$DNAME.yml

  #plugin install
  if [ -z "$(ls -A $WORK/$DNAME-$t/plugins)" ]; then
    plugins=(sql analysis-ik analysis-icu analysis-stconvert analysis-pinyin async_search index-management ingest-common ingest-geoip ingest-user-$DNAME mapper-annotated-text mapper-murmur3 mapper-size transport-nio cross-cluster-replication knn)
    for p in ${plugins[@]}; do
      echo "Installing plugin $p ..."
      echo y | $WORK/$DNAME-$t/bin/$DNAME-plugin install $p
    done
  fi
done