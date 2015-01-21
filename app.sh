### ZLIB ###
_build_zlib() {
local VERSION="1.2.8"
local FOLDER="zlib-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="http://zlib.net/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd target/"${FOLDER}"
./configure --prefix="${DEPS}" --libdir="${DEST}/lib"
make
make install
rm -v "${DEST}/lib"/*.a
popd
}

### NCURSES ###
_build_ncurses() {
local VERSION="5.9"
local FOLDER="ncurses-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="http://ftp.gnu.org/gnu/ncurses/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd target/"${FOLDER}"
./configure --host="${HOST}" --prefix="${DEPS}" --libdir="${DEST}/lib" --datadir="${DEST}/share" --with-shared --enable-rpath --with-termlib=tinfo
make
make install
rm -v "${DEST}/lib"/*.a
popd
}

### GMP ###
_build_gmp() {
local VERSION="6.0.0"
local FOLDER="gmp-${VERSION}"
local FILE="${FOLDER}a.tar.xz"
local URL="https://gmplib.org/download/gmp/${FILE}"

_download_xz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
./configure --host="${HOST}" --prefix="${DEPS}" --libdir="${DEST}/lib" --disable-static
make
make install
popd
}

### NETTLE ###
_build_nettle() {
local VERSION="2.7.1"
local FOLDER="nettle-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="https://ftp.gnu.org/gnu/nettle/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
./configure --host="${HOST}" --prefix="${DEPS}" --libdir="${DEST}/lib" --enable-public-key --disable-documentation
make
make install
rm -vf "${DEST}/lib/libnettle.a"
popd
}

### LIBTASN1 ###
_build_libtasn1() {
local VERSION="4.2"
local FOLDER="libtasn1-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="http://ftp.gnu.org/gnu/libtasn1/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
./configure --host="${HOST}" --prefix="${DEPS}" --libdir="${DEST}/lib" --disable-static
make
make install
popd
}

### GNUTLS ###
_build_gnutls() {
local VERSION="3.3.9"
local FOLDER="gnutls-${VERSION}"
local FILE="${FOLDER}.tar.xz"
local URL="ftp://ftp.gnutls.org/gcrypt/gnutls/v3.3/${FILE}"

_download_xz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
PKG_CONFIG_PATH="${DEST}/lib/pkgconfig" ./configure --host="${HOST}" --prefix="${DEPS}" --libdir="${DEST}/lib" --disable-static --disable-cxx --with-libz-prefix="${DEPS}" --without-included-libtasn1 --enable-local-libopts --disable-padlock --disable-crywrap --disable-guile --disable-libdane --with-unbound-root-key-file="${DEST}/etc/unbound/root.key" --with-system-priority-file="${DEST}/etc/gnutls/default-priorities"
make
make install
popd
}

### SAMBA ###
_build_samba() {
local VERSION="4.1.16"
local FOLDER="samba-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="https://ftp.samba.org/pub/samba/stable/${FILE}"
local PY=~/xtools/python2/${DROBO}
export QEMU_LD_PREFIX="${TOOLCHAIN}/${HOST}/libc"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
CPP=${HOST}-cpp \
  LDFLAGS="${LDFLAGS} -L${PY}/lib-${DROBO}" \
  PYTHON="${PY}/bin/python2" \
  PYTHON_CONFIG="${PY}/bin/python2.7-config" \
  ./buildtools/bin/waf configure --jobs=8 --verbose --progress \
  --cross-compile --cross-execute="qemu-arm-static" --hostcc="gcc" \
  --prefix="${DEST}" --mandir="${DEST}/man" --with-piddir="/tmp/DroboApps/samba" \
  --without-ads --without-ldap --disable-cups --disable-iprint --without-pam --without-pam_smbpass --without-systemd --nopyc --nopyo 
make
make install
popd
}

_build() {
  _build_zlib
  _build_ncurses
  _build_gmp
  _build_nettle
  _build_libtasn1
  _build_gnutls
  _build_samba
  _package
}
