#!/bin/sh

cd /hostrepo/

void/xbps-src sort-dependencies $(cat /tmp/unsorted_packages) > /tmp/packages

echo "These packages will be built:"
cat /tmp/packages

while read package
do
  rm -r void/srcpkgs/$package/
  cp -r srcpkgs/$package/ void/srcpkgs/
done < /tmp/packages ;

cd void/

while read package
do
  chroot-git restore common/hooks/
  /bin/echo -e "\x1b[32mBuilding package: $package...\x1b[0m"
  
  [ -f srcpkgs/$package/hook ] && . srcpkgs/$package/hook
  ./xbps-src -j$NPROCS $_ARCH pkg "$package"
done < /tmp/packages ;
