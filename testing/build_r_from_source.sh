#!/bin/bash

VERSION=$1

tar -xvf R-$VERSION.tar.gz
export CURL_CONFIG="$PWD/curl8_spoof.sh"
cd R-$VERSION
./configure --with-blas --with-lapack
make -j"$(nproc)"
