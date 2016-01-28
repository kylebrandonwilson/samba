CPPFLAGS="${CPPFLAGS:-} -I${DEPS}/include/ncurses"
CFLAGS="${CFLAGS:-} -ffunction-sections -fdata-sections"
LDFLAGS="-L${DEST}/lib -L${DEPS}/lib -Wl,--gc-sections"

### ZLIB ###
_build_zlib() {
local VERSION="1.2.8"
local FOLDER="zlib-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="http://zlib.net/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
./configure --prefix="${DEPS}"
make
make install
rm -vf "${DEPS}/lib/libz.so"*
popd
}

### LIBAIO ###
_build_libaio() {
local VERSION="0.3.110-1"
local FOLDER="libaio-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="https://git.fedorahosted.org/cgit/libaio.git/snapshot/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
make prefix="${DEPS}" install
rm -vf "${DEPS}/lib/libaio.so" "${DEPS}/lib/libaio.so.1" "${DEPS}/lib/libaio.so.1.0.1"
popd
}

### LIBPOPT ###
_build_libpopt() {
local VERSION="1.16"
local FOLDER="popt-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="http://rpm5.org/files/popt/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
./configure --host="${HOST}" --prefix="${DEPS}" --enable-static --disable-shared
make
make install
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
./configure --host="${HOST}" --prefix="${DEPS}" --without-shared --with-termlib=tinfo
make
make install
popd
}

### LIBEDIT ###
_build_libedit() {
local VERSION="20150325-3.1"
local FOLDER="libedit-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="http://thrysoee.dk/editline/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
./configure --host="${HOST}" --prefix="${DEPS}" --enable-static --disable-shared ac_cv_lib_ncurses_tgetent=yes
make
make install
popd
}

### SQLITE ###
_build_sqlite() {
local VERSION="3100200"
local FOLDER="sqlite-autoconf-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="http://sqlite.org/$(date +%Y)/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
./configure --host="${HOST}" --prefix="${DEPS}" --enable-static --disable-shared
make
make install
popd
}

### LIBATTR ###
_build_libattr() {
local VERSION="2.4.47"
local FOLDER="attr-${VERSION}"
local FILE="${FOLDER}.src.tar.gz"
local URL="http://download.savannah.gnu.org/releases/attr/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
./configure --host="${HOST}" --prefix="${DEPS}" --enable-static --disable-shared
make
make install install-dev install-lib
# make install-lib does not install the static lib
cp -vf libattr/.libs/libattr.a "${DEPS}/lib/"
popd
}

### HEIMDAL ###
_build_heimdal() {
# Version 1.5.2 changes some field names in kdc.h::krb5_kdc_configuration
# See: http://upstream-tracker.org/compat_reports/heimdal/1.5.1_to_1.5.2/abi_compat_report.html
local VERSION="1.5.1"
local FOLDER="heimdal-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="http://www.h5l.org/dist/src/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
cp -vf "src/${FOLDER}-base64-rename.patch" "target/${FOLDER}/"
pushd "target/${FOLDER}"
patch -p1 -i "${FOLDER}-base64-rename.patch"
rm -vfr lib/libedit

export QEMU_LD_PREFIX="${TOOLCHAIN}/${HOST}/libc"
./configure --host="${HOST}" --prefix="${DEPS}" --with-cross-tools="${DEPS}-native" --enable-static --disable-shared --enable-littleendian --disable-heimdal-documentation \
  --with-libedit="${DEPS}" \
  --with-sqlite="${DEPS}" --with-sqlite3-include="${DEPS}/include" --with-sqlite3-lib="${DEPS}/lib" \
  --without-openldap --without-x
make
make install
popd
}

### GMP ###
# _build_gmp() {
# local VERSION="6.0.0"
# local FOLDER="gmp-${VERSION}"
# local FILE="${FOLDER}a.tar.xz"
# local URL="https://gmplib.org/download/gmp/${FILE}"
# 
# _download_xz "${FILE}" "${URL}" "${FOLDER}"
# pushd "target/${FOLDER}"
# ./configure --host="${HOST}" --prefix="${DEPS}" --enable-static --disable-shared
# make
# make install
# popd
# }

### NETTLE ###
# _build_nettle() {
# # Versions 3.0+ are not supported by gnutls 3.3.x.
# local VERSION="2.7.1"
# local FOLDER="nettle-${VERSION}"
# local FILE="${FOLDER}.tar.gz"
# local URL="https://ftp.gnu.org/gnu/nettle/${FILE}"
# 
# _download_tgz "${FILE}" "${URL}" "${FOLDER}"
# pushd "target/${FOLDER}"
# ./configure --host="${HOST}" --prefix="${DEPS}" --enable-public-key --disable-documentation --enable-static --disable-shared
# make
# make install
# popd
# }

### LIBTASN1 ###
# _build_libtasn1() {
# local VERSION="4.5"
# local FOLDER="libtasn1-${VERSION}"
# local FILE="${FOLDER}.tar.gz"
# local URL="http://ftp.gnu.org/gnu/libtasn1/${FILE}"
# 
# _download_tgz "${FILE}" "${URL}" "${FOLDER}"
# pushd "target/${FOLDER}"
# ./configure --host="${HOST}" --prefix="${DEPS}" --enable-static --disable-shared
# make
# make install
# popd
# }

### GNUTLS ###
# _build_gnutls() {
# # Version 3.4.0 removes gnutls_certificate_type_set_priority(),
# # which is used by samba 4.2.2.
# local VERSION="3.3.9"
# local FOLDER="gnutls-${VERSION}"
# local FILE="${FOLDER}.tar.xz"
# local URL="ftp://ftp.gnutls.org/gcrypt/gnutls/v3.3/${FILE}"
# export QEMU_LD_PREFIX="${TOOLCHAIN}/${HOST}/libc"
# 
# _download_xz "${FILE}" "${URL}" "${FOLDER}"
# pushd "target/${FOLDER}"
# PKG_CONFIG_PATH="${DEPS}/lib/pkgconfig" ./configure --host="${HOST}" --prefix="${DEPS}" --enable-static --disable-shared --disable-cxx --with-libz-prefix="${DEPS}" --without-included-libtasn1 --without-p11-kit --enable-local-libopts --disable-padlock --disable-crywrap --disable-guile --disable-libdane
# make
# make install
# popd
# }

### LIBARCHIVE ###
# _build_libarchive() {
# local VERSION="3.1.2"
# local FOLDER="libarchive-${VERSION}"
# local FILE="${FOLDER}.tar.gz"
# local URL="http://www.libarchive.org/downloads/${FILE}"
# 
# _download_tgz "${FILE}" "${URL}" "${FOLDER}"
# pushd "target/${FOLDER}"
# ./configure --host="${HOST}" --prefix="${DEPS}" --enable-static --disable-shared --without-bz2lib --without-lzmadec --without-lzma --without-lzo2 --without-openssl --without-xml2 --without-expat
# make
# make install
# popd
# }

### SAMBA ###
_build_samba() {
# --with-ad-dc requires gnutls, which requires libtasn1, nettle, and gmp.
# Also add these to LDFLAGS: -lgnutls -ltasn1 -lnettle -lhogweed -lgmp -lz
local VERSION="4.2.7"
local FOLDER="samba-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="https://ftp.samba.org/pub/samba/stable/${FILE}"
local PY="${HOME}/xtools/python2/${DROBO}"
export QEMU_LD_PREFIX="${TOOLCHAIN}/${HOST}/libc"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"

cp -vf "src/${FOLDER}-smbstatus-static-link.patch" "target/${FOLDER}/"
cp -vf "src/${FOLDER}-bug-11466-attach-11499.patch" "target/${FOLDER}/"
cp -vf "src/${FOLDER}-bug-11347.patch" "target/${FOLDER}/"
cp -vf "src/${FOLDER}-vfs_fruit-nfs_aces.patch" "target/${FOLDER}/"
cp -vf "src/${FOLDER}-FILE_OFFSET_BITS.patch" "target/${FOLDER}/"
pushd "target/${FOLDER}"
patch -p1 -i "${FOLDER}-smbstatus-static-link.patch"
patch -p1 -i "${FOLDER}-bug-11466-attach-11499.patch"
patch -p1 -i "${FOLDER}-bug-11347.patch"
patch -p1 -i "${FOLDER}-vfs_fruit-nfs_aces.patch"
patch -p1 -i "${FOLDER}-FILE_OFFSET_BITS.patch"

LDFLAGS="${LDFLAGS} -lheimntlm -lgssapi -lkrb5 -lheimbase -lhx509 -lhcrypto -lasn1 -lwind -lroken -lcom_err -lsqlite3 -ledit -lncurses -lpopt -lresolv -lcrypt -ldl"
PATH="${DEPS}/bin:${PATH}" \
  LD_LIBRARY_PATH="${PY}/lib" \
  PKG_CONFIG_PATH="${DEPS}/lib/pkgconfig" \
  PYTHON="${PY}/bin/python2" \
  PYTHON_CONFIG="${PY}/bin/python2.7-config" \
  DESTDIR="${DEST}" \
  ./buildtools/bin/waf configure --jobs=4 --prefix="/" \
  --cross-compile --cross-execute="qemu-arm-static" --hostcc="gcc" \
  --enable-pthreadpool --with-aio-support \
  --disable-cups --disable-iprint \
  --without-acl-support --without-ad-dc --without-ads --without-ldap \
  --without-libarchive --without-pam --without-pam_smbpass \
  --without-systemd --without-winbind \
  --nopyc --nopyo \
  --bundled-libraries=tdb,ldb,ntdb,talloc,tevent,pytalloc-util,pyldb-util,nss_wrapper,socket_wrapper,uid_wrapper,subunit,replace,util,NONE \
  --builtin-libraries=tdb,ldb,ntdb,talloc,tevent,pytalloc-util,pyldb-util,nss_wrapper,socket_wrapper,uid_wrapper,subunit,replace,util,NONE \
  --with-static-modules=vfs_recycle,vfs_catia,vfs_fruit,vfs_streams_depot,vfs_streams_xattr \
  --nonshared-binary=ALL

DESTDIR="${DEST}" ./buildtools/bin/waf build install -vv --jobs=4 --prefix="/" \
  --targets=smbd/smbd,nmbd/nmbd,smbpasswd,pdbedit,smbstatus,smbtorture,client/smbclient,nmblookup

"${STRIP}" -s -R .comment -R .note -R .note.ABI-tag \
  "${DEST}/sbin/smbd" "${DEST}/sbin/nmbd" \
  "${DEST}/bin/smbpasswd" "${DEST}/bin/pdbedit" "${DEST}/bin/smbclient" "${DEST}/bin/nmblookup"
popd
}

_build_rootfs() {
# /sbin/smbd
# /sbin/nmbd
# /usr/bin/pdbedit
# /usr/bin/smbpasswd
# /bin/getfattr
# /bin/setfattr
  return 0
}

_build() {
  _build_zlib
  _build_libaio
  _build_libpopt
  _build_ncurses
  _build_libedit
  _build_sqlite
  _build_libattr
  _build_heimdal
#  _build_gmp
#  _build_nettle
#  _build_libtasn1
#  _build_gnutls
#  _build_libarchive
  _build_samba
  _package
}
