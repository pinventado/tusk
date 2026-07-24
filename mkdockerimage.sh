#!/bin/bash
set -euo pipefail
#
# Build a docker image from a debootstrap rootfs, run quickinstall.sh inside
# the chroot, and publish the result to GHCR.
#
# Usage:
#   IMAGE_OWNER=YourOrg IMAGE_NAME=26-resolute-small-tusk ./mkdockerimage.sh
#
# Optional:
#   ./mkdockerimage.sh resolute

DIST="${1:-resolute}"
TARGET="${TARGET:-tusk-${DIST}}"
REMOTE_URL="$(git remote get-url origin 2>/dev/null || true)"

if [ -z "${IMAGE_OWNER:-}" ]; then
    IMAGE_OWNER="$(printf '%s' "${REMOTE_URL}" | sed -E 's#.*github.com[:/]+([^/]+)/[^/]+(\.git)?$#\1#')"
fi
if [ -z "${IMAGE_OWNER}" ]; then
    IMAGE_OWNER="mshafae"
fi

if [ -z "${IMAGE_NAME:-}" ]; then
    REPO_NAME="$(printf '%s' "${REMOTE_URL}" | sed -E 's#.*github.com[:/]+[^/]+/([^/]+)(\.git)?$#\1#')"
    if [ -z "${REPO_NAME}" ]; then
        REPO_NAME="tusk"
    fi
    IMAGE_NAME="${REPO_NAME}-${DIST}"
fi


# sudo apt-get update
#
# sudo apt-get install -y debootstrap ca-certificates curl gnupg lsb-release
#
# sudo mkdir -m 0755 -p /etc/apt/keyrings
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
#
# echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
#
# sudo apt-get update
#
# sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo debootstrap "${DIST}" "${TARGET}"

cd "${TARGET}"

# This only works if the versions match
# sudo cp /etc/apt/sources.list etc/apt
sed -e "s/$(lsb_release -cs)/${DIST}/g" /etc/apt/sources.list | sudo tee etc/apt/sources.list >/dev/null

sudo apt policy debootstrap
mkdir -p packages
sudo cp ../quickinstall.sh .
sudo cp ../packages/base.txt packages/base.txt
# See https://docs.docker.com/build/building/base-images/

# can we get away with not binding these two?
# sudo mount -o bind /dev dev/
# sudo mount -o bind /proc proc/

sudo cp /etc/resolv.conf etc/

# remember you can't run a script from a chroot
# https://stackoverflow.com/questions/51305706/shell-script-that-does-chroot-and-execute-commands-in-chroot
# Or you could chroot a lot. (Not tested.)
ROOTFS=$(pwd)
# sudo chroot $(pwd)

sudo chroot "$ROOTFS" apt-get update

sudo chroot "$ROOTFS" apt-get install -y wget

sudo chroot "$ROOTFS" env \
    TUSK_WARN="NO" \
    TUSK_INSTALL_VSCODE="NO" \
    TUSK_INSTALL_ZOOM="NO" \
    TUSK_INSTALL_GITHUBCLIENT="YES" \
    bash quickinstall.sh

sudo chroot "$ROOTFS" rm quickinstall.sh

# exit

DATE=$(date "+%Y%m%d")
echo "$DATE" | sudo tee TUSKBUILDDATE >/dev/null

cd ..

ID=$(sudo tar -C "${TARGET}" -c . | sudo docker import - "${TARGET}")

sudo docker image ls -a

echo "Are you logged into GHCR?"
docker login ghcr.io

# See https://github.com/moby/moby/blob/master/contrib/mkimage-alpine.sh
docker tag "${ID}" "ghcr.io/${IMAGE_OWNER}/${IMAGE_NAME}:${DATE}"
docker tag "${ID}" "ghcr.io/${IMAGE_OWNER}/${IMAGE_NAME}:latest"

docker push "ghcr.io/${IMAGE_OWNER}/${IMAGE_NAME}:${DATE}"
docker push "ghcr.io/${IMAGE_OWNER}/${IMAGE_NAME}:latest"
# sudo docker save ${TARGET} > ${TARGET}.tar
# gzip --best ${TARGET}.tar
