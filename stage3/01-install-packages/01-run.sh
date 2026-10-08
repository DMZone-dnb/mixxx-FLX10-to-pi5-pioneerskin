#!/bin/bash -e
MIXXX_BRANCH="${MIXXX_BRANCH:-2.6}"
## Build Mixxx
mkdir -p ${BASE_DIR}/.ccache/
mkdir -p "${ROOTFS_DIR}/ccache"
mount --bind ${BASE_DIR}/.ccache  "${ROOTFS_DIR}/ccache"
on_chroot << EOF
    git clone --branch ${MIXXX_BRANCH} https://github.com/mixxxdj/mixxx.git /code/
    cd /code/
    tools/debian_buildenv.sh setup
    # Mixxx 2.6 needs hidapi >= 0.14.0 but Debian bookworm only ships 0.13.1:
    # build 0.14.0 from source over the distro copy (same soname) and keep apt from downgrading it.
    apt-get install -y --no-install-recommends libudev-dev pkg-config
    git clone --depth 1 --branch hidapi-0.14.0 https://github.com/libusb/hidapi.git /tmp/hidapi
    cmake -S /tmp/hidapi -B /tmp/hidapi/build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr -DBUILD_SHARED_LIBS=ON -DHIDAPI_BUILD_HIDTEST=OFF
    cmake --build /tmp/hidapi/build -j4
    cmake --install /tmp/hidapi/build
    ldconfig
    apt-mark hold libhidapi-dev libhidapi-libusb0 libhidapi-hidraw0 || true
    rm -rf /tmp/hidapi
    git rev-parse HEAD > /opt/mixxx.version
    export CCACHE_DIR=/ccache
    ccache -M 5G
    export CCACHE_NOCOMPRESS="true"
    export CTEST_PARALLEL_LEVEL="$(nproc)"
    export CMAKE_BUILD_PARALLEL_LEVEL="$(nproc)"
    export PATH="$HOME/.local/bin:$PATH"
    export GTEST_COLOR="1"
    export CTEST_OUTPUT_ON_FAILURE="1"
    export QT_QPA_PLATFORM="offscreen"
    mkdir -p build && cd build
    cmake \
      -DKEYFINDER=ON -DFFMPEG=ON -DMAD=ON -DMODPLUG=ON -DWAVPACK=ON -DBULK=ON \
      -DCMAKE_INSTALL_PREFIX=/usr/ -S /code -B /code/build
    cmake --build /code/build --target install
    ccache -s
    cpack -G DEB
EOF

unmount "${BASE_DIR}/.ccache"
mkdir -p "$DEPLOY_DIR"
cp ${ROOTFS_DIR}/code/build/*.deb "$DEPLOY_DIR/"
rm -rf ${ROOTFS_DIR}/code/
