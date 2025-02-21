#!/bin/bash

WORKDIR="$(mktemp -d)"
SRC=$GITHUB_WORKSPACE/$PNAME
DEST=$BUILD_DISTRIBUTION

echo "Clean history build release files"
rm -rf $DEST/easysearch-*.tar.gz

echo "Repack $PNAME from $SRC to $DEST with [ $VERSION-$BUILD_NUMBER ]"

# 查找符合条件的文件
FOUND_FILES=$(find "$SRC/distribution/archives/oss-no-jdk-linux-tar/build/distributions" -name "$PNAME-oss-*.tar.gz" -type f -print -quit)

# 判断是否找到文件
if [ -z "$FOUND_FILES" ]; then
  echo "Error: $PNAME distribution files not found exit now."
  exit 1
fi

#初始化操作目录
mkdir -p $WORKDIR && cd $WORKDIR
cp -rf $SRC/distribution/archives/oss-no-jdk-*/build/distributions/$PNAME-oss* $WORKDIR
ls -lrt $WORKDIR

#重新压缩与命名
for x in linux-amd64 linux-aarch64 mac-amd64 mac-aarch64 windows; do
  FNAME=`ls -lrt |grep $PNAME |head -n 1 |awk '{print $NF}'`
  DNAME=`echo $FNAME |sed "s/$VERSION/$VERSION-$BUILD_NUMBER/"|sed 's/darwin/mac/;s/aarch64/arm64/;s/x86_64/amd64/' |awk -F'-' '{print $1"-"$3"-"$4"-"$(NF-1)"-"$NF}'`
  if [ "${FNAME##*.}" == "gz" ]; then
    tar -zxf $FNAME && cd $PNAME-$VERSION
    if [ "$(echo $DNAME |grep -wo mac)" == "mac" ]; then
      DNAME=`echo $DNAME |sed 's/.tar.gz/.zip/'`
      zip -r -q $DNAME *
    else
      tar -zcf $DNAME *
    fi
  else
    unzip -q $FNAME && cd $PNAME-$VERSION && zip -r -q $DNAME *
  fi
  echo -e "Repackaged file at $PWD \nfrom $FNAME \nto $DNAME"

  # 文件上传
  if [[ "$(echo "$PUBLISH_RELEASE" | tr '[:upper:]' '[:lower:]')" == "true" ]]; then
    echo Upload $DNAME to oss
    [ ! -f /tmp/.oss.yml ] && cp -rf $GITHUB_WORKSPACE/.oss.yml /tmp
    if [[ "$(echo "$PRE_RELEASE" | tr '[:upper:]' '[:lower:]')" == "true" ]]; then
      grep -wq "pre" /tmp/.oss.yml || echo "pre: true" >> /tmp/.oss.yml
    fi
    oss upload -c /tmp/.oss.yml -o -p $PNAME -f $WORKDIR/$PNAME-$VERSION/$DNAME
  fi

  # 本地备份
  mv $WORKDIR/$PNAME-$VERSION/$DNAME $DEST
  cd $WORKDIR && rm -rvf $WORKDIR/$FNAME && rm -rf $WORKDIR/$PNAME-$VERSION
done

#插件
plugins=(sql jieba analysis-hanlp analysis-icu analysis-ik analysis-pinyin analysis-stconvert index-management ingest-common ingest-geoip ingest-user-agent mapper-annotated-text mapper-murmur3 mapper-size transport-nio cross-cluster-replication knn)
for p in ${plugins[@]}; do
  f=$DEST/plugins/$p/$p-$VERSION.zip
  if [ ! -d $DEST/plugins/$p ]; then
    mkdir -p $DEST/plugins/$p
  fi

  q=$p
  if [ "$p" == "sql" ]; then
    q=search-sql
    if [[ "$(echo "$PUBLISH_RELEASE" | tr '[:upper:]' '[:lower:]')" == "true" ]]; then
      echo Upload $SRC/plugins/$q/sql-jdbc/build/libs/sql-jdbc-$VERSION.jar to oss
      oss upload -c $GITHUB_WORKSPACE/.oss.yml -o -f $SRC/plugins/$q/sql-jdbc/build/libs/sql-jdbc-$VERSION.jar -k $PNAME/archive/plugins
    fi
    if [ ! -d $DEST/archive/plugins ]; then
      mkdir -p $DEST/archive/plugins
    fi
    cp -rf $SRC/plugins/$q/sql-jdbc/build/libs/sql-jdbc-$VERSION.jar $DEST/archive/plugins
  fi
  cp -rf $SRC/plugins/$q/build/distributions/$p-$VERSION.zip $f
  sha512sum $f |awk -F'/' '{print $1$NF}' > $f.sha512

  if [[ "$(echo "$PUBLISH_RELEASE" | tr '[:upper:]' '[:lower:]')" == "true" ]]; then
    echo Upload $f to oss
    oss upload -c $GITHUB_WORKSPACE/.oss.yml -o -f $f -k $PNAME/stable/plugins/$p
    oss upload -c $GITHUB_WORKSPACE/.oss.yml -o -f $f.sha512 -k $PNAME/stable/plugins/$p
  fi
done

# 清理工作目录
find "$BUILD_DISTRIBUTION" -type f \( -name "*.tar.gz" -o -name "*.zip" -o -name "*.jar" \) -print0 | while IFS= read -r -d $'\0' file; do
  if [[ ! "$file" =~ "$VERSION" ]]; then
   echo "Removing file $file"
   rm -rf "$file"
  fi
done
