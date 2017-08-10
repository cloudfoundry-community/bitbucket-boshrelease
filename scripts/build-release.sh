#!/bin/bash

set -e

BOSHV="$(bosh --version)"
if echo "$BOSHV" | grep -q "BOSH 1."; then
 echo "bosh is in version 1"
 BOSHVERSION=1
else
 echo "bosh is in version 2 or more."
 BOSHVERSION=2
fi


if [ "$0" != "./scripts/build-release.sh" ]; then
    echo "'build-release.sh' should be run from repository root"
    exit 1
fi

function usage(){
  >&2 echo "
 Usage:
    $0 [version]
 Ex:
    $0 0+dev.1
"
  exit 1
}

if [ "$1" == "-h" ] || [ "$1" == "--help"  ] || [ "$1" == "help"  ]; then
    usage
fi


if [ "$#" -gt 0 ]; then
    if [ -e "$1" ]; then
        export version=`cat $1`
    else
        export version=$1
    fi
fi

echo '################################################################################'
echo "Building sonarqube-boshrelese ${version}"
echo '################################################################################'
echo ''

echo '################################################################################'
echo 'Cleaning up blobs'
echo '################################################################################'
echo ''

rm -rf .blobs/* blobs/*
echo "--- {} " > config/blobs.yml

echo '################################################################################'
echo 'Downloading binaries'
echo '################################################################################'
echo ''

if [ ! -d './tmp' ]; then
  mkdir -p ./tmp/completed
fi

cd ./tmp

if [ -e './completed/jdk-8u131-linux-x64.tar.gz' ]; then
  echo 'httpd package already exists, skipping'
else
  echo 'Downloading file jdk-8u131-linux-x64.tar.gz'
   wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.tar.gz
  mv jdk-8u131-linux-x64.tar.gz completed/
fi

if [ -e './completed/atlassian-bitbucket-5.0.2.tar.gz' ]; then
  echo 'httpd package already exists, skipping'
else
  echo 'Downloading file atlassian-bitbucket-5.0.2.tar.gz'
   wget https://www.atlassian.com/software/stash/downloads/binary/atlassian-bitbucket-5.0.2.tar.gz
  mv atlassian-bitbucket-5.0.2.tar.gz completed/
fi

if [ -e './completed/git-2.13.1.tar.gz' ]; then
  echo 'httpd package already exists, skipping'
else
  echo 'Downloading file git-2.13.1.tar.gz'
   wget https://www.kernel.org/pub/software/scm/git/git-2.13.1.tar.gz
  mv git-2.13.1.tar.gz completed/
fi

if [ -e './completed/jq-1.5.tar.gz' ]; then
  echo 'httpd package already exists, skipping'
else
  echo 'Downloading file jq-1.5.tar.gz'
   wget https://github.com/stedolan/jq/releases/download/jq-1.5/jq-1.5.tar.gz
  mv jq-1.5.tar.gz completed/
fi

cd -

echo ''
echo '################################################################################'
echo 'Adding blobs'
echo '################################################################################'
echo $BOSHVERSION 


echo ''

echo 'Adding blob java/jdk-8u131-linux-x64.tar.gz'
if [ "$BOSHVERSION" = "1" ]; then
 bosh add blob ./tmp/completed/jdk-8u131-linux-x64.tar.gz java
else
 bosh add-blob ./tmp/completed/jdk-8u131-linux-x64.tar.gz java/jdk-8u131-linux-x64.tar.gz
fi
echo 'Adding blob bitbucket/atlassian-bitbucket-5.0.2.tar.gz'
if [ "$BOSHVERSION" = "1" ]; then
 bosh add blob ./tmp/completed/atlassian-bitbucket-5.0.2.tar.gz bitbucket
else
 bosh add-blob ./tmp/completed/atlassian-bitbucket-5.0.2.tar.gz bitbucket/atlassian-bitbucket-5.0.2.tar.gz
fi

echo 'Adding blob jq/jq-1.5.tar.gz'
if [ "$BOSHVERSION" = "1" ]; then
 bosh add blob ./tmp/completed/jq-1.5.tar.gz jq
else
 bosh add-blob ./tmp/completed/jq-1.5.tar.gz jq/jq-1.5.tar.gz
fi

echo 'Adding blob git/git-2.13.1.tar.gz'
if [ "$BOSHVERSION" = "1" ]; then
 bosh add blob ./tmp/completed/git-2.13.1.tar.gz git
else
 bosh add-blob ./tmp/completed/git-2.13.1.tar.gz git/git-2.13.1.tar.gz
fi



echo ''
echo '################################################################################'
echo 'Creating release'
echo '################################################################################'

echo ''

echo "Creating release"
if [ "$BOSHVERSION" = "1" ]; then
 create_cmd="bosh create release --name bitbucket --with-tarball --force"
else
 create_cmd="bosh create-release --name bitbucket --force"
fi

if [ -n "$version" ]; then
    create_cmd+=" --version "${version}""
fi

eval ${create_cmd}
