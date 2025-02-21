#!/bin/bash

WORK="$(mktemp -d)"

#初始化操作目录
mkdir -p $WORK && cd $_
cp -rf $BUILD_DISTRIBUTION/$PNAME-$VERSION-$BUILD_NUMBER-* $WORK

#重新压缩与重命名
for x in linux-amd64 linux-arm64 mac-amd64 mac-arm64 windows-amd64; do
  FNAME=`ls -lrt $WORK |grep $PNAME |head -n 1 |awk '{print $NF}'`
  DNAME=`echo $FNAME |sed 's/.zip/-bundle.zip/;s/.tar.gz/-bundle.tar.gz/'`
  JARK=$(echo "$x" | sed -e 's/-amd64/_x64/;s/-arm64/_aarch64/;s/mac/macosx/;s/windows/win/')
  JNAME=`find $BUILD_JDKS -name "zulu*-$JARK*" |head -n 1`
  URL="$RELEASE_URL/$PNAME/stable/bundle/$DNAME"
  if curl -sI "$URL" | grep "HTTP/1.[01] 200" >/dev/null; then
    echo "Exists release file $DNAME"
    rm -rf $WORK/$FNAME
    continue
  fi
  echo -e "From $FNAME \nTo $DNAME \nJark $JARK \nJre $JNAME"
  # 解压并删除原文件
  mkdir -p $WORK/$PNAME && cd $WORK/$PNAME
  if [ "${FNAME##*.}" == "gz" ]; then
    tar -zxf $WORK/$FNAME
  else
    unzip -q $WORK/$FNAME
  fi
 
  # 配置jdk
  if [ "${JNAME##*.}" == "gz" ]; then
    tar -zxf $JNAME
  else
    unzip -q $JNAME
  fi
  mv zulu* jdk

  #plugin install
  if [ -z "$(ls -A $WORK/$PNAME/plugins)" ]; then
    plugins=(sql analysis-ik analysis-icu analysis-stconvert analysis-pinyin index-management ingest-common ingest-geoip ingest-user-agent mapper-annotated-text mapper-murmur3 mapper-size transport-nio cross-cluster-replication knn)
    for p in ${plugins[@]}; do
      echo "Installing plugin $p-$VERSION ..."
      echo y | $WORK/$PNAME/bin/$PNAME-plugin install file:///$BUILD_DISTRIBUTION/plugins/$p/$p-$VERSION.zip > /dev/null 2>&1
    done
  fi

  # 重新打包
  if [ "${DNAME##*.}" == "gz" ]; then
    tar -zcf $DNAME *
  else
    zip -r -q $DNAME *
  fi

  if [ -f $WORK/$PNAME/$DNAME ]; then
    echo "Repackaged file at $WORK/$PNAME/$DNAME"
    # 本地备份
    [ ! -d $BUILD_DISTRIBUTION/bundle ] && mkdir -p $BUILD_DISTRIBUTION/bundle
    cp -rf $WORK/$PNAME/$DNAME $BUILD_DISTRIBUTION/bundle
    # 文件上传
    oss upload -c $GITHUB_WORKSPACE/.oss.yml -o -f $WORK/$PNAME/$DNAME -k $PNAME/stable/bundle
  fi
  cd $WORK && rm -rf $WORK/$FNAME && rm -rf $WORK/$PNAME
done