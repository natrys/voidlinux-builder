#!/bin/sh

/hostrepo/void/xbps-src sort-dependencies $(cat /tmp/unsorted_packages) > /tmp/packages

echo "These packages will be built:"
cat /tmp/packages

while read package
do
  rm -r /hostrepo/void/srcpkgs/$package/
  cp -r /hostrepo/srcpkgs/$package/ /hostrepo/void/srcpkgs/$package/
  [ -f /hostrepo/shlibs/$package ] && sh /hostrepo/shlibs/$package /hostrepo/void/common/shlibs
done < /tmp/packages ;

while read package
do
  bin/echo -e "\x1b[32mBuilding package: $package...\x1b[0m"
  rm -r /hostrepo/void/srcpkgs/$package/
  cp -r /hostrepo/srcpkgs/$package/ /hostrepo/void/srcpkgs/$package/
  /hostrepo/void/xbps-src -j$NPROCS $_ARCH pkg "$package"
done < /tmp/packages ;
