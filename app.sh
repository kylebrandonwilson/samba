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
./configure --host="${HOST}" --prefix="${DEPS}" --libdir="${DEST}/lib" --datadir="${DEST}/share" --with-shared --enable-rpath
make
make install
rm -v "${DEST}/lib"/*.a
popd
}

### SAMBA ###
_build_samba() {
#local VERSION="4.0.22"
local VERSION="4.1.16"
local FOLDER="samba-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="https://ftp.samba.org/pub/samba/stable/${FILE}"
local PY=~/xtools/python2/${DROBO}

# sudo apt-get install python-dev

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"

CPP=${HOST}-cpp \
  LDFLAGS="${LDFLAGS} -L${PY}/lib-${DROBO}" \
  PYTHON="${PY}/bin/python2" \
  PYTHON_CONFIG="${PY}/bin/python2.7-config" \
  ./buildtools/bin/waf configure --jobs=8 --verbose --progress \
  --cross-compile --cross-execute="qemu-arm-static -E LD_LIBRARY_PATH=${TOOLCHAIN}/${HOST}/libc/lib" --hostcc="gcc" \
  --prefix="${DEST}" --mandir="${DEST}/man" --with-piddir="/tmp/DroboApps/samba" \
  --without-ads --without-ldap --disable-cups --disable-iprint --without-pam --without-pam_smbpass --without-systemd --nopyc --nopyo 

#make
#make install
popd
}

### OPENSSL ###
_build_openssl() {
local OPENSSL_VERSION="1.0.1l"
local OPENSSL_FOLDER="openssl-${OPENSSL_VERSION}"
local OPENSSL_FILE="${OPENSSL_FOLDER}.tar.gz"
local OPENSSL_URL="http://www.openssl.org/source/${OPENSSL_FILE}"

_download_tgz "${OPENSSL_FILE}" "${OPENSSL_URL}" "${OPENSSL_FOLDER}"
pushd target/"${OPENSSL_FOLDER}"
./Configure --prefix="${DEPS}" \
  --openssldir="${DEST}/etc/ssl" \
  --with-zlib-include="${DEPS}/include" \
  --with-zlib-lib="${DEPS}/lib" \
  shared zlib-dynamic threads linux-armv4 -DL_ENDIAN ${CFLAGS} ${LDFLAGS}
sed -i -e "s/-O3//g" Makefile
make -j1
make install_sw
mkdir -p "${DEST}"/libexec
cp -avR "${DEPS}/bin/openssl" "${DEST}/libexec/"
cp -avR "${DEPS}/lib"/* "${DEST}/lib/"
rm -vfr "${DEPS}/lib"
rm -vf "${DEST}/lib"/*.a
sed -i -e "s|^exec_prefix=.*|exec_prefix=${DEST}|g" "${DEST}"/lib/pkgconfig/openssl.pc
popd
}

_build() {
  _build_zlib
  _build_ncurses
  _build_samba
  _package
}
