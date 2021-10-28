#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

source "kit/helper.sh"
cd "${WORKDIR}"

VERSION="$(helper::workdir::version)"

BUILDTAGS="${BUILDTAGS:-seccomp apparmor selinux nokmem}"

BUILD_PLATFORMS=(
    linux/amd64
    # linux/arm
    linux/arm64
    # linux/s390x
    # linux/ppc64le
)

for platform in ${BUILD_PLATFORMS[*]}; do
    os="${platform%/*}"
    arch="${platform#*/}"
    echo "Building ${platform}"
    rm -rf ~/.cache/go-build bin || :
    rm -rf "_output/${os}/${arch}/runc" || :
    mkdir -p "_output/${os}/${arch}/runc"
    docker run --rm -v $(pwd):/go/src/github.com/opencontainers/runc -w /go/src/github.com/opencontainers/runc golang:1.17 \
        /bin/bash -c "
    apt-get update && apt-get install libseccomp-dev
    GO111MODULE=auto GOOS=${os} GOARCH=${arch} make BUILDTAGS='${BUILDTAGS}' runc && \
        mv runc _output/${os}/${arch}/runc/ || :
" || echo "fail ${platform}"

done

mkdir -p "${ROOT}/output" && cp -r "${WORKDIR}/_output"/* "${ROOT}/output/"
