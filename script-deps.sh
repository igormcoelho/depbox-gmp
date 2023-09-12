#!/bin/bash

git submodule update --init --recursive
git pull --recurse-submodules

conan profile detect

VCPKG_DIR=./deps/vcpkg
VCPKG_TRIPLET=x64-windows-static
VCPKG_BOOTSTRAP=bootstrap-vcpkg.bat

COUNT_LINUX=`conan profile show | grep Linux | wc -l`
if [[ "$COUNT_LINUX" -ne 0 ]]; then
    VCPKG_TRIPLET=x64-linux
    VCPKG_BOOTSTRAP=bootstrap-vcpkg.sh
fi

echo "VCPKG_TRIPLET=$VCPKG_TRIPLET"
echo "VCPKG_DIR=$VCPKG_DIR"

mkdir -p deps
git submodule add https://github.com/microsoft/vcpkg $VCPKG_DIR

(cd $VCPKG_DIR && git checkout master && git pull)
$VCPKG_DIR/$VCPKG_BOOTSTRAP

$VCPKG_DIR/vcpkg --vcpkg-root $VCPKG_DIR search gmp
$VCPKG_DIR/vcpkg --vcpkg-root $VCPKG_DIR search mpir

$VCPKG_DIR/vcpkg --vcpkg-root $VCPKG_DIR integrate install

$VCPKG_DIR/vcpkg --vcpkg-root $VCPKG_DIR install --triplet=$VCPKG_TRIPLET
