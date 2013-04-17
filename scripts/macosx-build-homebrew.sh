#!/bin/zsh -eu
#
# This script builds all library dependencies of OpenSCAD for Mac OS X,
# using homebrew where possible. Sparkle isn't built. No specific
# provision is made for 32 bit machines or older OSes.
# Xcode's default compiler is used for homebrew packages, clang for
# OpenCSG.
# 
# This script must be run from the OpenSCAD source root directory
#
# Prerequisites:
# - homebrew, Xcode 4.6.1 (with command line tools installed)
#

# 
for formula in cmake qt eigen gmp mpfr boost cgal glew; do
    (brew list | grep -wq $formula) || brew install $formula
done

BASEDIR=$PWD/../libraries
OPENSCADDIR=$PWD
SRCDIR=$BASEDIR/src
DEPLOYDIR=$BASEDIR/install

# homebrew has no recipe for OpenCSG currently.
# TODO: Add one and submit a pull request.
build_opencsg()
{
  version=$1
  echo "Building OpenCSG" $version "..."
  cd $BASEDIR/src
  rm -rf OpenCSG-$version
  if [ ! -f OpenCSG-$version.tar.gz ]; then
    curl -O http://www.opencsg.org/OpenCSG-$version.tar.gz
  fi
  tar xzf OpenCSG-$version.tar.gz
  cd OpenCSG-$version
  patch -p1 < $OPENSCADDIR/patches/OpenCSG-$version-MacOSX-port.patch
  OPENSCAD_LIBRARIES=$DEPLOYDIR qmake -r CONFIG+="x86_64"
  make install
}

if [ ! -f $OPENSCADDIR/openscad.pro ]; then
  echo "Must be run from the OpenSCAD source root directory"
  exit 0
fi

export CC=clang
export CXX=clang++
export QMAKESPEC=unsupported/macx-clang

echo "Using basedir:" $BASEDIR
mkdir -p $SRCDIR $DEPLOYDIR
build_opencsg 1.3.2
