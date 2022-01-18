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

declare -A archToCC
archToCC["amd64"]=""
archToCC["arm64"]="aarch64-linux-gnu-gcc"
archToCC["ppc64le"]="powerpc64le-linux-gnu-gcc"

docker build -t runcdev .

for platform in ${BUILD_PLATFORMS[*]}; do
    os="${platform%/*}"
    arch="${platform#*/}"
    echo "Building ${platform}"
    rm -rf ~/.cache/go-build bin || :
    rm -rf "_output/${os}/${arch}/runc" || :
    mkdir -p "_output/${os}/${arch}/runc"
    docker run --rm -v $(pwd):/go/src/github.com/opencontainers/runc -w /go/src/github.com/opencontainers/runc runcdev \
        /bin/bash -c "
    GO111MODULE=auto GOOS=${os} GOARCH=${arch} CC=${archToCC[$arch]} CGO_ENABLED=1 make BUILDTAGS='${BUILDTAGS}' runc && \
        mv runc _output/${os}/${arch}/runc/ || :
" || echo "fail ${platform}"

done

mkdir -p "${ROOT}/output" && cp -r "${WORKDIR}/_output"/* "${ROOT}/output/"
