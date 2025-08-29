#!/bin/sh

say() {
  /bin/echo -e "\x1b[32m$@\x1b[0m"
}

if [ "$BOOTSTRAP" != "$ARCH" ]; then
	arch="-a $ARCH"
fi

export NPROCS=1
if [ -r /proc/cpuinfo ]; then
        NPROCS=$(grep ^proc /proc/cpuinfo | wc -l)
fi

cd $GITHUB_WORKSPACE

sh ./add_repo.sh

# TODO Understand the left-tree thing Void does here
git diff --name-only HEAD^ HEAD | \
  grep ^srcpkgs/ | perl -pe 's|srcpkgs/(.*?)(/.*)$|\1|' | \
    sort | uniq > /tmp/unsorted_packages

cat common/shlibs >> void/common/shlibs

sh ./build.sh

say "Finished building packages, now onto deploying them."
