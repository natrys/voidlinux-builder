#!/bin/sh

while read package
do
  bin/echo -e '\x1b[32mBuilding package: $package...\x1b[0m'
  rm -r /hostrepo/void/srcpkgs/$package/
  cp -r /hostrepo/templates/$package/ /hostrepo/void/srcpkgs/$package/
  /hostrepo/void/xbps-src -j$NPROCS $_ARCH pkg "$package"
done < /tmp/packages ;
