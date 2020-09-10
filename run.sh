#!/bin/sh

say() {
  /bin/echo -e "\x1b[32m$@\x1b[0m"
}

BOOTSTRAP=x86_64
. etc/conf

if [ "$BOOTSTRAP" != "$ARCH" ]; then
	arch="-a $ARCH"
fi

export NPROCS=1
if [ -r /proc/cpuinfo ]; then
        NPROCS=$(grep ^proc /proc/cpuinfo|wc -l)
fi


cd $GITHUB_WORKSPACE

DOCKER_NAME=${DOCKER_NAME:-void}
grep -o 'DOCKER_BASE.*' void/.travis.yml > /tmp/docker_masterdir
grep -o 'TAG.*' void/.travis.yml | sed -e 's/^TAG/DOCKER_TAG/' >> /tmp/docker_masterdir
. /tmp/docker_masterdir
rm /tmp/docker_masterdir

DOCKER_IMAGE=${DOCKER_BASE}-${BOOTSTRAP}:${DOCKER_TAG}
DOCKER_IMAGE=ghcr.io/natrys/voidlinux:masterdir

/bin/echo -e "\x1b[32mPulling docker image $DOCKER_IMAGE...\x1b[0m"
docker pull $DOCKER_BASE-$BOOTSTRAP:$DOCKER_TAG
docker run -d \
	   --name $DOCKER_NAME \
	   -v "${GITHUB_WORKSPACE}":/hostrepo \
	   -v /tmp:/tmp \
     -e NPROCS="$NPROCS" \
     -e _ARCH="$arch" \
	   -e PATH="$PATH" \
	   ${DOCKER_IMAGE} \
	   /bin/sh -c 'sleep inf'

cd void/

. common/travis/set_mirror.sh
. common/travis/prepare.sh

cd ../

# TODO Understand the left-tree thing Void does here
git diff --name-only HEAD^ HEAD | \
  grep ^srcpkgs/ | perl -pe 's|srcpkgs/(.*?)/.*$|\1|' | \
    sort | uniq > /tmp/packages

say "These packages will be built:"
cat /tmp/packages

docker exec -t ${DOCKER_NAME} sh /hostrepo/build.sh

say "Finished building packages, now onto deploying them."
