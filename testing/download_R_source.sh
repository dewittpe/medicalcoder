#/bin/bash
VERSION=$1
MAJOR=`echo $VERSION | cut -c1-1`

wget -N https://cran.r-project.org/src/base/R-$MAJOR/R-$VERSION.tar.gz
