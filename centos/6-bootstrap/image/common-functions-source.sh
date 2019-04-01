# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (http://xpack.github.io)
# Copyright (c) 2019 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software 
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Support functions to be used in all versions of the containers.
# -----------------------------------------------------------------------------

function do_zlib() 
{
  # http://zlib.net
  # http://zlib.net/fossils/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=zlib-static
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=zlib-git

  # 2017-01-15
  XBB_ZLIB_VERSION="1.2.11"

  XBB_ZLIB_FOLDER="zlib-${XBB_ZLIB_VERSION}"
  XBB_ZLIB_ARCHIVE="${XBB_ZLIB_FOLDER}.tar.gz"
  # XBB_ZLIB_URL="http://zlib.net/fossils/${XBB_ZLIB_ARCHIVE}"
  XBB_ZLIB_URL="https://github.com/gnu-mcu-eclipse/files/raw/master/libs/${XBB_ZLIB_ARCHIVE}"

  echo
  echo "Building zlib ${XBB_ZLIB_VERSION}..."

  cd "${XBB_BUILD_FOLDER}"

  download_and_extract "${XBB_ZLIB_ARCHIVE}" "${XBB_ZLIB_URL}"

  (
    cd "${XBB_BUILD_FOLDER}/${XBB_ZLIB_FOLDER}"

    xbb_activate_dev

    # -fPIC makes possible to include static libs in shared libs.
    export CPPFLAGS="${XBB_CPPFLAGS}" 
    export CFLAGS="${XBB_CFLAGS} -fPIC"
    export CXXFLAGS="${XBB_CXXFLAGS}"
    export LDFLAGS="${XBB_LDFLAGS_LIB}"

    ./configure --help

    # Some apps (cmake) would be happier with shared libs.
    # Some apps (python) fail without shared libs.

    ./configure \
      --prefix="${XBB_FOLDER}"

    make -j ${JOBS}
    make install
  )
}

# -----------------------------------------------------------------------------

function do_xz() 
{
  # https://tukaani.org/xz/
  # https://sourceforge.net/projects/lzmautils/files/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=xz-git

  # 2016-12-30
  XBB_XZ_VERSION="5.2.3"

  XBB_XZ_FOLDER="xz-${XBB_XZ_VERSION}"
  # Conservatively use .gz, the native tar may be very old.
  XBB_XZ_ARCHIVE="${XBB_XZ_FOLDER}.tar.gz"
  # XBB_XZ_URL="https://sourceforge.net/projects/lzmautils/files/${XBB_XZ_ARCHIVE}"
  XBB_XZ_URL="https://github.com/gnu-mcu-eclipse/files/raw/master/libs/${XBB_XZ_ARCHIVE}"

  echo
  echo "Building xz ${XBB_XZ_VERSION}..."

  cd "${XBB_BUILD_FOLDER}"

  download_and_extract "${XBB_XZ_ARCHIVE}" "${XBB_XZ_URL}"

  (
    cd "${XBB_BUILD_FOLDER}/${XBB_XZ_FOLDER}"
    
    xbb_activate_dev

    export CPPFLAGS="${XBB_CPPFLAGS}" 
    export CFLAGS="${XBB_CFLAGS}"
    export CXXFLAGS="${XBB_CXXFLAGS}"
    export LDFLAGS="${XBB_LDFLAGS_LIB}"

    ./configure --help

    ./configure \
      --prefix="${XBB_FOLDER}" \
      --disable-rpath
    
    make -j ${JOBS}
    make install-strip
  )

  (
    xbb_activate

    "${XBB_FOLDER}/bin/xz" --version
  )

  hash -r
}

function do_tar() 
{
  # https://www.gnu.org/software/tar/
  # https://ftp.gnu.org/gnu/tar/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=tar-git

  # 2016-05-16
  # XBB_TAR_VERSION="1.29"
  # 2017-12-17
  XBB_TAR_VERSION="1.30"

  XBB_TAR_FOLDER="tar-${XBB_TAR_VERSION}"
  # Conservatively use .gz, the native tar may be very old.
  XBB_TAR_ARCHIVE="${XBB_TAR_FOLDER}.tar.gz"
  XBB_TAR_URL="https://ftp.gnu.org/gnu/tar/${XBB_TAR_ARCHIVE}"

  # Requires xz.

  echo
  echo "Building tar ${XBB_TAR_VERSION}..."

  cd "${XBB_BUILD_FOLDER}"

  download_and_extract "${XBB_TAR_ARCHIVE}" "${XBB_TAR_URL}"

  (
    cd "${XBB_BUILD_FOLDER}/${XBB_TAR_FOLDER}"

    xbb_activate_dev

    export CPPFLAGS="${XBB_CPPFLAGS}" 
    export CFLAGS="${XBB_CFLAGS}"
    export CXXFLAGS="${XBB_CXXFLAGS}"
    export LDFLAGS="${XBB_LDFLAGS_APP}"

    # Avoid 'configure: error: you should not run configure as root'.
    export FORCE_UNSAFE_CONFIGURE=1

    ./configure --help

    ./configure \
      --prefix="${XBB_FOLDER}" 
    
    make -j ${JOBS}
    make install-strip
  )

  (
    xbb_activate

    "${XBB_FOLDER}/bin/tar" --version
  )

  hash -r
}

# -----------------------------------------------------------------------------

function do_openssl() 
{
  # https://www.openssl.org
  # https://www.openssl.org/source/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=openssl-static
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=openssl-git

  # 2017-Nov-02 
  # XBB_OPENSSL_VERSION="1.1.0g"
  # The new version deprecated CRYPTO_set_locking_callback, and yum fails with
  # /usr/lib64/python2.6/site-packages/pycurl.so: undefined symbol: CRYPTO_set_locking_callback

  # 2017-Dec-07 
  XBB_OPENSSL_VERSION="1.0.2n"

  XBB_OPENSSL_FOLDER="openssl-${XBB_OPENSSL_VERSION}"
  # Only .gz available.
  XBB_OPENSSL_ARCHIVE="${XBB_OPENSSL_FOLDER}.tar.gz"
  # XBB_OPENSSL_URL="https://www.openssl.org/source/${XBB_OPENSSL_ARCHIVE}"
  XBB_OPENSSL_URL="https://github.com/gnu-mcu-eclipse/files/raw/master/libs/${XBB_OPENSSL_ARCHIVE}"

  # https://github.com/openssl/openssl/blob/master/INSTALL

  echo
  echo "Building openssl ${XBB_OPENSSL_VERSION}..."

  cd "${XBB_BUILD_FOLDER}"

  download_and_extract "${XBB_OPENSSL_ARCHIVE}" "${XBB_OPENSSL_URL}"

  (
    cd "${XBB_BUILD_FOLDER}/${XBB_OPENSSL_FOLDER}"

    xbb_activate_dev

    export CPPFLAGS="${XBB_CPPFLAGS}" 
    export CFLAGS="${XBB_CFLAGS}"
    export CXXFLAGS="${XBB_CXXFLAGS}"
    export LDFLAGS="${XBB_LDFLAGS}"

    # Parallel builds fail with an odd error related to libcrypt.so.
    JOBS=1

    ./config --help

    if [ "${UNAME_ARCH}" == 'x86_64' ]; then
		  optflags='enable-ec_nistp_64_gcc_128'
	  elif [ "${UNAME_ARCH}" == 'i686' ]; then
		  optflags=''
	  fi

    ./config \
      --prefix="${XBB_FOLDER}" \
      --openssldir="${XBB_FOLDER}/openssl" \
      shared \
      no-ssl3-method \
      ${optflags} \
      "-Wa,--noexecstack ${CPPFLAGS} ${CFLAGS} ${LDFLAGS}"
    
    make depend -j ${JOBS}
    make -j ${JOBS}
    make install_sw

    strip --strip-all "${XBB_FOLDER}/bin/openssl"

    if [ ! -f "${XBB_FOLDER}/openssl/cert.pem" ]
    then
      mkdir -p "${XBB_FOLDER}/openssl"
      ln -s /etc/pki/tls/certs/ca-bundle.crt "${XBB_FOLDER}/openssl/cert.pem"
    fi
  )

  (
    xbb_activate

    "${XBB_FOLDER}/bin/openssl" version
  )

  hash -r
}

# -----------------------------------------------------------------------------

function do_curl() 
{
  # https://curl.haxx.se
  # https://curl.haxx.se/download/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=curl-git

  # 2017-10-23 
  # XBB_CURL_VERSION="7.56.1"
  # 2017-11-29
  XBB_CURL_VERSION="7.57.0"

  XBB_CURL_FOLDER="curl-${XBB_CURL_VERSION}"
  XBB_CURL_ARCHIVE="${XBB_CURL_FOLDER}.tar.xz"
  # XBB_CURL_URL="https://curl.haxx.se/download/${XBB_CURL_ARCHIVE}"
  XBB_CURL_URL="https://github.com/gnu-mcu-eclipse/files/raw/master/libs/${XBB_CURL_ARCHIVE}"

  # Requires openssl & zlib.

  echo
  echo "Building curl ${XBB_CURL_VERSION}..."

  cd "${XBB_BUILD_FOLDER}"

  download_and_extract "${XBB_CURL_ARCHIVE}" "${XBB_CURL_URL}"

  (
    cd "${XBB_BUILD_FOLDER}/${XBB_CURL_FOLDER}"

    xbb_activate_dev

    export CPPFLAGS="${XBB_CPPFLAGS}" 
    export CFLAGS="${XBB_CFLAGS}"
    export CXXFLAGS="${XBB_CXXFLAGS}"
    export LDFLAGS="${XBB_LDFLAGS_APP}"

    ./buildconf

    ./configure --help

    ./configure \
      --prefix="${XBB_FOLDER}" \
      --disable-debug \
      --with-ssl \
      --enable-optimize \
      --disable-manual \
      --disable-ldap \
      --disable-ldaps \
      --enable-versioned-symbols \
      --enable-threaded-resolver \
      --with-gssapi \
      --with-ca-bundle=/etc/pki/tls/certs/ca-bundle.crt
    
    make -j ${JOBS}
    make install

    strip --strip-all "${XBB_FOLDER}/bin/curl"
  )

  (
    xbb_activate

    "${XBB_FOLDER}/bin/curl" --version
  )

  hash -r
}

# -----------------------------------------------------------------------------

function do_m4() 
{
  # https://www.gnu.org/software/m4/
  # https://ftp.gnu.org/gnu/m4/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=m4-git

  # 2016-12-31
  XBB_M4_VERSION="1.4.18"

  XBB_M4_FOLDER="m4-${XBB_M4_VERSION}"
  XBB_M4_ARCHIVE="${XBB_M4_FOLDER}.tar.xz"
  XBB_M4_URL="https://ftp.gnu.org/gnu/m4/${XBB_M4_ARCHIVE}"

  echo
  echo "Building m4 ${XBB_M4_VERSION}..."

  cd "${XBB_BUILD_FOLDER}"

  download_and_extract "${XBB_M4_ARCHIVE}" "${XBB_M4_URL}"

  (
    cd "${XBB_BUILD_FOLDER}/${XBB_M4_FOLDER}"

    xbb_activate_dev

    export CPPFLAGS="${XBB_CPPFLAGS}" 
    export CFLAGS="${XBB_CFLAGS}"
    export CXXFLAGS="${XBB_CXXFLAGS}"
    export LDFLAGS="${XBB_LDFLAGS_APP}"

    ./configure --help

    ./configure \
      --prefix="${XBB_FOLDER}"
    
    make -j ${JOBS}
    make install-strip
  )

  (
    xbb_activate

    "${XBB_FOLDER}/bin/m4" --version
  )

  hash -r
}

function do_gawk() 
{
  # https://www.gnu.org/software/gawk/
  # https://ftp.gnu.org/gnu/gawk/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=gawk-git

  # 2017-10-19
  XBB_GAWK_VERSION="4.2.0"

  XBB_GAWK_FOLDER="gawk-${XBB_GAWK_VERSION}"
  XBB_GAWK_ARCHIVE="${XBB_GAWK_FOLDER}.tar.xz"
  XBB_GAWK_URL="https://ftp.gnu.org/gnu/gawk/${XBB_GAWK_ARCHIVE}"

  echo
  echo "Building gawk ${XBB_GAWK_VERSION}..."

  cd "${XBB_BUILD_FOLDER}"

  download_and_extract "${XBB_GAWK_ARCHIVE}" "${XBB_GAWK_URL}"

  (
    cd "${XBB_BUILD_FOLDER}/${XBB_GAWK_FOLDER}"

    xbb_activate_dev

    export CPPFLAGS="${XBB_CPPFLAGS}" 
    export CFLAGS="${XBB_CFLAGS}"
    export CXXFLAGS="${XBB_CXXFLAGS}"
    export LDFLAGS="${XBB_LDFLAGS_APP}"

    ./configure --help

    ./configure \
      --prefix="${XBB_FOLDER}" \
      --without-libsigsegv
    
    make -j ${JOBS}
    make install-strip
  )

  (
    xbb_activate

    "${XBB_FOLDER}/bin/awk" --version
  )

  hash -r
}

function do_autoconf() 
{
  # https://www.gnu.org/software/autoconf/
  # https://ftp.gnu.org/gnu/autoconf/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=autoconf-git

  # 2012-04-24
  XBB_AUTOCONF_VERSION="2.69"

  XBB_AUTOCONF_FOLDER="autoconf-${XBB_AUTOCONF_VERSION}"
  XBB_AUTOCONF_ARCHIVE="${XBB_AUTOCONF_FOLDER}.tar.xz"
  XBB_AUTOCONF_URL="https://ftp.gnu.org/gnu/autoconf/${XBB_AUTOCONF_ARCHIVE}"

  echo
  echo "Building autoconf ${XBB_AUTOCONF_VERSION}..."

  cd "${XBB_BUILD_FOLDER}"

  download_and_extract "${XBB_AUTOCONF_ARCHIVE}" "${XBB_AUTOCONF_URL}"

  (
    cd "${XBB_BUILD_FOLDER}/${XBB_AUTOCONF_FOLDER}"

    xbb_activate_dev

    export CPPFLAGS="${XBB_CPPFLAGS}" 
    export CFLAGS="${XBB_CFLAGS}"
    export CXXFLAGS="${XBB_CXXFLAGS}"
    export LDFLAGS="${XBB_LDFLAGS_APP}"

    ./configure --help

    ./configure \
      --prefix="${XBB_FOLDER}" 
    
    make -j ${JOBS}
    make install-strip
  )

  (
    xbb_activate

    "${XBB_FOLDER}/bin/autoconf" --version
  )

  hash -r
}

function do_automake() 
{
  # https://www.gnu.org/software/automake/
  # https://ftp.gnu.org/gnu/automake/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=automake-git

  # 2015-01-05
  XBB_AUTOMAKE_VERSION="1.15"

  XBB_AUTOMAKE_FOLDER="automake-${XBB_AUTOMAKE_VERSION}"
  XBB_AUTOMAKE_ARCHIVE="${XBB_AUTOMAKE_FOLDER}.tar.xz"
  XBB_AUTOMAKE_URL="https://ftp.gnu.org/gnu/automake/${XBB_AUTOMAKE_ARCHIVE}"

  echo
  echo "Building automake ${XBB_AUTOMAKE_VERSION}..."

  cd "${XBB_BUILD_FOLDER}"

  download_and_extract "${XBB_AUTOMAKE_ARCHIVE}" "${XBB_AUTOMAKE_URL}"

  (
    cd "${XBB_BUILD_FOLDER}/${XBB_AUTOMAKE_FOLDER}"

    xbb_activate_dev

    export CPPFLAGS="${XBB_CPPFLAGS}" 
    export CFLAGS="${XBB_CFLAGS}"
    export CXXFLAGS="${XBB_CXXFLAGS}"
    export LDFLAGS="${XBB_LDFLAGS_APP}"

    ./configure --help

    ./configure \
      --prefix="${XBB_FOLDER}" 
    
    make -j ${JOBS}
    make install-strip
  )

  (
    xbb_activate

    "${XBB_FOLDER}/bin/automake" --version
  )

  hash -r
}

function do_libtool() 
{
  # https://www.gnu.org/software/libtool/
  # http://gnu.mirrors.linux.ro/libtool/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=libtool-git

  # 15-Feb-2015
  XBB_LIBTOOL_VERSION="2.4.6"

  XBB_LIBTOOL_FOLDER="libtool-${XBB_LIBTOOL_VERSION}"
  XBB_LIBTOOL_ARCHIVE="${XBB_LIBTOOL_FOLDER}.tar.xz"
  # XBB_LIBTOOL_URL="http://ftpmirror.gnu.org/libtool/${XBB_LIBTOOL_ARCHIVE}"
  XBB_LIBTOOL_URL="https://github.com/gnu-mcu-eclipse/files/raw/master/libs/${XBB_LIBTOOL_ARCHIVE}"

  echo
  echo "Building libtool ${XBB_LIBTOOL_VERSION}..."

  cd "${XBB_BUILD_FOLDER}"

  download_and_extract "${XBB_LIBTOOL_ARCHIVE}" "${XBB_LIBTOOL_URL}"

  (
    cd "${XBB_BUILD_FOLDER}/${XBB_LIBTOOL_FOLDER}"

    xbb_activate_dev

    export CPPFLAGS="${XBB_CPPFLAGS}" 
    export CFLAGS="${XBB_CFLAGS}"
    export CXXFLAGS="${XBB_CXXFLAGS}"
    export LDFLAGS="${XBB_LDFLAGS_APP}"

    ./configure --help

    ./configure \
      --prefix="${XBB_FOLDER}" 
    
    make -j ${JOBS}
    make install-strip
  )

  (
    xbb_activate

    "${XBB_FOLDER}/bin/libtool" --version
  )

  hash -r
}

function do_gettext() 
{
  # https://www.gnu.org/software/gettext/
  # https://ftp.gnu.org/gnu/gettext/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=gettext-git

  # 2016-06-09
  XBB_GETTEXT_VERSION="0.19.8"

  XBB_GETTEXT_FOLDER="gettext-${XBB_GETTEXT_VERSION}"
  XBB_GETTEXT_ARCHIVE="${XBB_GETTEXT_FOLDER}.tar.xz"
  XBB_GETTEXT_URL="https://ftp.gnu.org/gnu/gettext/${XBB_GETTEXT_ARCHIVE}"

  echo
  echo "Building gettext ${XBB_GETTEXT_VERSION}..."

  cd "${XBB_BUILD_FOLDER}"

  download_and_extract "${XBB_GETTEXT_ARCHIVE}" "${XBB_GETTEXT_URL}"

  (
    cd "${XBB_BUILD_FOLDER}/${XBB_GETTEXT_FOLDER}"

    xbb_activate_dev

    export CFLAGS="${XBB_CFLAGS} -Wno-discarded-qualifiers"

    export CPPFLAGS="${XBB_CPPFLAGS}" 
    export CFLAGS="${XBB_CFLAGS}"
    export CXXFLAGS="${XBB_CXXFLAGS}"
    export LDFLAGS="${XBB_LDFLAGS_APP}"

    ./configure --help

    ./configure \
      --prefix="${XBB_FOLDER}" 
    
    make -j ${JOBS}
    make install-strip
  )

  (
    xbb_activate

    "${XBB_FOLDER}/bin/gettext" --version
  )

  hash -r
}

function do_patch() 
{
  # https://www.gnu.org/software/patch/
  # https://ftp.gnu.org/gnu/patch/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=patch-git

  # 2015-03-06
  XBB_PATCH_VERSION="2.7.5"

  XBB_PATCH_FOLDER="patch-${XBB_PATCH_VERSION}"
  XBB_PATCH_ARCHIVE="${XBB_PATCH_FOLDER}.tar.xz"
  XBB_PATCH_URL="https://ftp.gnu.org/gnu/patch/${XBB_PATCH_ARCHIVE}"

  echo
  echo "Building patch ${XBB_PATCH_VERSION}..."

  cd "${XBB_BUILD_FOLDER}"

  download_and_extract "${XBB_PATCH_ARCHIVE}" "${XBB_PATCH_URL}"

  (
    cd "${XBB_BUILD_FOLDER}/${XBB_PATCH_FOLDER}"

    xbb_activate_dev

    export CPPFLAGS="${XBB_CPPFLAGS}" 
    export CFLAGS="${XBB_CFLAGS}"
    export CXXFLAGS="${XBB_CXXFLAGS}"
    export LDFLAGS="${XBB_LDFLAGS_APP}"

    ./configure --help

    ./configure \
      --prefix="${XBB_FOLDER}" 
    
    make -j ${JOBS}
    make install-strip
  )

  (
    xbb_activate

    "${XBB_FOLDER}/bin/patch" --version
  )

  hash -r
}

function do_diffutils() 
{
  # https://www.gnu.org/software/diffutils/
  # https://ftp.gnu.org/gnu/diffutils/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=diffutils-git

  # 2017-05-21
  XBB_DIFFUTILS_VERSION="3.6"

  XBB_DIFFUTILS_FOLDER="diffutils-${XBB_DIFFUTILS_VERSION}"
  XBB_DIFFUTILS_ARCHIVE="${XBB_DIFFUTILS_FOLDER}.tar.xz"
  XBB_DIFFUTILS_URL="https://ftp.gnu.org/gnu/diffutils/${XBB_DIFFUTILS_ARCHIVE}"

  echo
  echo "Building diffutils ${XBB_DIFFUTILS_VERSION}..."

  cd "${XBB_BUILD_FOLDER}"

  download_and_extract "${XBB_DIFFUTILS_ARCHIVE}" "${XBB_DIFFUTILS_URL}"

  (
    cd "${XBB_BUILD_FOLDER}/${XBB_DIFFUTILS_FOLDER}"

    xbb_activate_dev

    export CPPFLAGS="${XBB_CPPFLAGS}" 
    export CFLAGS="${XBB_CFLAGS}"
    export CXXFLAGS="${XBB_CXXFLAGS}"
    export LDFLAGS="${XBB_LDFLAGS_APP}"

    ./configure --help

    ./configure \
      --prefix="${XBB_FOLDER}" 

    make -j ${JOBS}
    make install-strip
  )

  (
    xbb_activate

    "${XBB_FOLDER}/bin/diff" --version
  )

  hash -r
}

function do_bison() 
{
  # https://www.gnu.org/software/bison/
  # https://ftp.gnu.org/gnu/bison/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=bison-git

  # 2015-01-23
  XBB_BISON_VERSION="3.0.4"

  XBB_BISON_FOLDER="bison-${XBB_BISON_VERSION}"
  XBB_BISON_ARCHIVE="${XBB_BISON_FOLDER}.tar.xz"
  XBB_BISON_URL="https://ftp.gnu.org/gnu/bison/${XBB_BISON_ARCHIVE}"

  echo
  echo "Building bison ${XBB_BISON_VERSION}..."

  cd "${XBB_BUILD_FOLDER}"

  download_and_extract "${XBB_BISON_ARCHIVE}" "${XBB_BISON_URL}"

  (
    cd "${XBB_BUILD_FOLDER}/${XBB_BISON_FOLDER}"

    xbb_activate_dev

    export CPPFLAGS="${XBB_CPPFLAGS}" 
    export CFLAGS="${XBB_CFLAGS}"
    export CXXFLAGS="${XBB_CXXFLAGS}"
    export LDFLAGS="${XBB_LDFLAGS_APP}"

    ./configure --help

    ./configure \
      --prefix="${XBB_FOLDER}" 
    
    make -j ${JOBS}
    make install-strip
  )

  (
    xbb_activate

    "${XBB_FOLDER}/bin/bison" --version
  )

  hash -r
}

function do_make() 
{
  # https://www.gnu.org/software/make/
  # https://ftp.gnu.org/gnu/make/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=make-git

  # 2016-06-10
  XBB_MAKE_VERSION="4.2.1"

  XBB_MAKE_FOLDER="make-${XBB_MAKE_VERSION}"
  # Only .bz2 available.
  XBB_MAKE_ARCHIVE="${XBB_MAKE_FOLDER}.tar.bz2"
  XBB_MAKE_URL="https://ftp.gnu.org/gnu/make/${XBB_MAKE_ARCHIVE}"

  echo
  echo "Building make ${XBB_MAKE_VERSION}..."

  cd "${XBB_BUILD_FOLDER}"

  download_and_extract "${XBB_MAKE_ARCHIVE}" "${XBB_MAKE_URL}"

  (
    cd "${XBB_BUILD_FOLDER}/${XBB_MAKE_FOLDER}"

    xbb_activate_dev

    export CPPFLAGS="${XBB_CPPFLAGS}" 
    export CFLAGS="${XBB_CFLAGS}"
    export CXXFLAGS="${XBB_CXXFLAGS}"
    export LDFLAGS="${XBB_LDFLAGS_APP}"

    ./configure --help

    ./configure \
      --prefix="${XBB_FOLDER}"
    
    make -j ${JOBS}
    make install-strip
  )

  (
    xbb_activate

    "${XBB_FOLDER}/bin/make" --version
  )

  hash -r
}

# -----------------------------------------------------------------------------

function do_pkg_config() 
{
  # https://www.freedesktop.org/wiki/Software/pkg-config/
  # https://pkgconfig.freedesktop.org/releases/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=pkg-config-git

  # 2017-03-20
  XBB_PKG_CONFIG_VERSION="0.29.2"

  XBB_PKG_CONFIG_FOLDER="pkg-config-${XBB_PKG_CONFIG_VERSION}"
  XBB_PKG_CONFIG_ARCHIVE="${XBB_PKG_CONFIG_FOLDER}.tar.gz"
  # XBB_PKG_CONFIG_URL="https://pkgconfig.freedesktop.org/releases/${XBB_PKG_CONFIG_ARCHIVE}"
  XBB_PKG_CONFIG_URL="https://github.com/gnu-mcu-eclipse/files/raw/master/libs/${XBB_PKG_CONFIG_ARCHIVE}"

  echo
  echo "Building pkg-config ${XBB_PKG_CONFIG_VERSION}..."

  cd "${XBB_BUILD_FOLDER}"

  download_and_extract "${XBB_PKG_CONFIG_ARCHIVE}" "${XBB_PKG_CONFIG_URL}"

  (
    cd "${XBB_BUILD_FOLDER}/${XBB_PKG_CONFIG_FOLDER}"

    xbb_activate_dev

    export CPPFLAGS="${XBB_CPPFLAGS}" 
    export CFLAGS="${XBB_CFLAGS}"
    export CXXFLAGS="${XBB_CXXFLAGS}"
    export LDFLAGS="${XBB_LDFLAGS_APP}"

    ./configure --help

    ./configure \
      --prefix="${XBB_FOLDER}" \
      --with-internal-glib
    
    # rm -f "${XBB_FOLDER}"/bin/*pkg-config
    make -j ${JOBS} 
    make install-strip
  )

  (
    xbb_activate

    "${XBB_FOLDER}/bin/pkg-config" --version
  )

  hash -r
}

function do_flex() 
{
  # https://github.com/westes/flex
  # https://github.com/westes/flex/releases
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=flex-git

  # May 6, 2017
  XBB_FLEX_VERSION="2.6.4"

  XBB_FLEX_FOLDER="flex-${XBB_FLEX_VERSION}"
  XBB_FLEX_ARCHIVE="${XBB_FLEX_FOLDER}.tar.gz"
  XBB_FLEX_URL="https://github.com/westes/flex/releases/download/v${XBB_FLEX_VERSION}/${XBB_FLEX_ARCHIVE}"

  # Requires gettext.
  echo
  echo "Building flex ${XBB_FLEX_VERSION}..."

  cd "${XBB_BUILD_FOLDER}"

  download_and_extract "${XBB_FLEX_ARCHIVE}" "${XBB_FLEX_URL}"

  (
    cd "${XBB_BUILD_FOLDER}/${XBB_FLEX_FOLDER}"

    xbb_activate_dev

    export CPPFLAGS="${XBB_CPPFLAGS}" 
    export CFLAGS="${XBB_CFLAGS}"
    export CXXFLAGS="${XBB_CXXFLAGS}"
    export LDFLAGS="${XBB_LDFLAGS_APP}"

    ./autogen.sh

    ./configure --help

    ./configure \
      --prefix="${XBB_FOLDER}" 
    
    make -j ${JOBS}
    make install-strip
  )

  (
    xbb_activate

    "${XBB_FOLDER}/bin/flex" --version
  )

  hash -r
}

function do_perl() 
{
  # https://www.cpan.org
  # http://www.cpan.org/src/
  # https://git.archlinux.org/svntogit/packages.git/tree/trunk/PKGBUILD?h=packages/perl

  # 2017-09-22
  XBB_PERL_MAJOR_VERSION="5.0"
  XBB_PERL_VERSION="5.24.1"

  # Fails with undefined reference to `Perl_fp_class_denorm'
  # 2017-09-22
  # XBB_PERL_VERSION="5.26.1"

  XBB_PERL_FOLDER="perl-${XBB_PERL_VERSION}"
  XBB_PERL_ARCHIVE="${XBB_PERL_FOLDER}.tar.gz"
  XBB_PERL_URL="http://www.cpan.org/src/${XBB_PERL_MAJOR_VERSION}/${XBB_PERL_ARCHIVE}"

  echo
  echo "Building perl ${XBB_PERL_VERSION}..."

  cd "${XBB_BUILD_FOLDER}"

  download_and_extract "${XBB_PERL_ARCHIVE}" "${XBB_PERL_URL}"

  (
    cd "${XBB_BUILD_FOLDER}/${XBB_PERL_FOLDER}"

    xbb_activate_dev

    export CPPFLAGS="${XBB_CPPFLAGS}" 
    export CFLAGS="${XBB_CFLAGS}"
    export CXXFLAGS="${XBB_CXXFLAGS}"
    export LDFLAGS="${XBB_LDFLAGS_APP}"

    set +e
    # Exits with error.
    ./Configure --help
    set -e

    ./Configure -d -e -s \
      -Dprefix="${XBB_FOLDER}" \
      -Dcc=gcc
 
    make -j ${JOBS}
    make install-strip

    # Install modules.
    curl -L http://cpanmin.us | perl - App::cpanminus
  )

  (
    xbb_activate

    "${XBB_FOLDER}/bin/perl" --version
  )

  hash -r
}

# -----------------------------------------------------------------------------

function do_cmake() 
{
  # https://cmake.org
  # https://cmake.org/download/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=cmake-git

  # November 10, 2017
  # XBB_CMAKE_MAJOR_VERSION="3.9"
  # XBB_CMAKE_VERSION="${XBB_CMAKE_MAJOR_VERSION}.6"

  # Fails with 'CMake 3.1 or higher is required.  You are running version 2.8.12.2'.
  # November 2017
  # XBB_CMAKE_MAJOR_VERSION="3.10"
  # XBB_CMAKE_VERSION="${XBB_CMAKE_MAJOR_VERSION}.1"

  XBB_CMAKE_MAJOR_VERSION="3.13"
  XBB_CMAKE_VERSION="${XBB_CMAKE_MAJOR_VERSION}.4"

  XBB_CMAKE_FOLDER="cmake-${XBB_CMAKE_VERSION}"
  XBB_CMAKE_ARCHIVE="${XBB_CMAKE_FOLDER}.tar.gz"
  XBB_CMAKE_URL="https://cmake.org/files/v${XBB_CMAKE_MAJOR_VERSION}/${XBB_CMAKE_ARCHIVE}"

  echo
  echo "Installing cmake ${XBB_CMAKE_VERSION}..."

  cd "${XBB_BUILD_FOLDER}"

  download_and_extract "${XBB_CMAKE_ARCHIVE}" "${XBB_CMAKE_URL}"

  (
    cd "${XBB_BUILD_FOLDER}/${XBB_CMAKE_FOLDER}"

    xbb_activate_dev

    export CPPFLAGS="${XBB_CPPFLAGS}" 
    export CFLAGS="${XBB_CFLAGS}"
    export CXXFLAGS="${XBB_CXXFLAGS}"
    export LDFLAGS="${XBB_LDFLAGS_APP}"

    # Parallel builds fail while running build/genrecog.
    if [ -z "${JOBS}" ]
    then
      JOBS=1
    elif [ ${JOBS} -gt 1 ]
    then
      JOBS=1
    fi

    # CMake 3.1 or higher is required.  You are running version 2.8.12.2
    if false
    then
      # If more verbosity is needed:
      #  -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON 

      # Use the existing cmake to configure this one.
      cmake \
        -DCMAKE_INSTALL_PREFIX="${XBB_FOLDER}" \
        .
    else
      ./bootstrap \
        --prefix="${XBB_FOLDER}"
    fi

    make -j ${JOBS}
    make install

    strip --strip-all "${XBB_FOLDER}/bin/cmake"
  )

  (
    xbb_activate

    "${XBB_FOLDER}/bin/cmake" --version
  )

  hash -r
}

function do_python() 
{
  # https://www.python.org
  # https://www.python.org/downloads/source/
  # https://git.archlinux.org/svntogit/packages.git/tree/trunk/PKGBUILD?h=packages/python2

  # 2017-09-16
  XBB_PYTHON_VERSION="2.7.14"

  XBB_PYTHON_FOLDER="Python-${XBB_PYTHON_VERSION}"
  XBB_PYTHON_ARCHIVE="${XBB_PYTHON_FOLDER}.tar.xz"
  XBB_PYTHON_URL="https://www.python.org/ftp/python/${XBB_PYTHON_VERSION}/${XBB_PYTHON_ARCHIVE}"

  echo
  echo "Installing python ${XBB_PYTHON_VERSION}..."

  cd "${XBB_BUILD_FOLDER}"

  download_and_extract "${XBB_PYTHON_ARCHIVE}" "${XBB_PYTHON_URL}"

  (
    cd "${XBB_BUILD_FOLDER}/${XBB_PYTHON_FOLDER}"

    xbb_activate_dev 

    export CPPFLAGS="${XBB_CPPFLAGS}" 
    export CFLAGS="${XBB_CFLAGS} -Wno-int-in-bool-context -Wno-maybe-uninitialized -Wno-nonnull -Wno-stringop-overflow"
    export CXXFLAGS="${XBB_CXXFLAGS}"
    export LDFLAGS="${XBB_LDFLAGS_APP}"

    ./configure --help

    # It is happier with dynamic zlib and curl.
    # Without --enabled-shared the build fails with
    # ImportError: No module named '_struct'
    # --enable-universalsdk is required by -arch.
    # --with-system-expat fails.

    # https://github.com/python/cpython/tree/2.7
    ./configure \
      --prefix="${XBB_FOLDER}" \
      --enable-shared \
      --with-universal-archs=${BITS}-bits \
      --enable-universalsdk \
      --enable-optimizations \
      --with-threads \
      --enable-unicode=ucs4 \
      --without-system-expat \
      --with-system-ffi \
      --with-dbmliborder=gdbm:ndbm \
      --without-ensurepip
    
    make -j ${JOBS} 
    make install

    strip --strip-all "${XBB_FOLDER}/bin/python"
  )

  (
    xbb_activate

    "${XBB_FOLDER}/bin/python" --version
  )

  hash -r

  (
    xbb_activate

    # Install setuptools and pip. Be sure the new version is used.
    # https://packaging.python.org/tutorials/installing-packages/
    echo
    echo "Installing setuptools and pip..."
    set +e
    "${XBB_FOLDER}/bin/pip" --version
    # pip: command not found
    set -e
    "${XBB_FOLDER}/bin/python" -m ensurepip --default-pip
    "${XBB_FOLDER}/bin/python" -m pip install --upgrade pip setuptools wheel
    "${XBB_FOLDER}/bin/pip" --version
  )

  hash -r
}

function do_scons() 
{
  # http://scons.org
  # https://sourceforge.net/projects/scons/files/scons/3.0.1/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=python2-scons

  # 2017-09-16
  XBB_SCONS_VERSION="3.0.1"

  XBB_SCONS_FOLDER="scons-${XBB_SCONS_VERSION}"
  XBB_SCONS_ARCHIVE="${XBB_SCONS_FOLDER}.tar.gz"
  # XBB_SCONS_URL="https://sourceforge.net/projects/scons/files/scons/${XBB_SCONS_VERSION}/${XBB_SCONS_ARCHIVE}"
  XBB_SCONS_URL="https://github.com/gnu-mcu-eclipse/files/raw/master/libs/${XBB_SCONS_ARCHIVE}"

  echo
  echo "Installing scons ${XBB_SCONS_VERSION}..."

  cd "${XBB_BUILD_FOLDER}"

  download_and_extract "${XBB_SCONS_ARCHIVE}" "${XBB_SCONS_URL}"

  (
    cd "${XBB_BUILD_FOLDER}/${XBB_SCONS_FOLDER}"

    xbb_activate_dev

    export CPPFLAGS="${XBB_CPPFLAGS}" 
    export CFLAGS="${XBB_CFLAGS}"
    export CXXFLAGS="${XBB_CXXFLAGS}"
    export LDFLAGS="${XBB_LDFLAGS_APP}"

    "${XBB_FOLDER}/bin/python" setup.py install \
      --prefix="${XBB_FOLDER}" \
      --optimize=1
  )

  hash -r
}

# -----------------------------------------------------------------------------

function do_gmp() 
{
  # https://gmplib.org
  # https://gmplib.org/download/gmp/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=gmp-hg

  # 16-Dec-2016
  XBB_GMP_VERSION="6.1.2"

  XBB_GMP_FOLDER="gmp-${XBB_GMP_VERSION}"
  XBB_GMP_ARCHIVE="${XBB_GMP_FOLDER}.tar.xz"
  # XBB_GMP_URL="https://gmplib.org/download/gmp/${XBB_GMP_ARCHIVE}"
  XBB_GMP_URL="https://github.com/gnu-mcu-eclipse/files/raw/master/libs/${XBB_GMP_ARCHIVE}"

  echo
  echo "Building gmp ${XBB_GMP_VERSION}..."

  cd "${XBB_BUILD_FOLDER}"

  download_and_extract "${XBB_GMP_ARCHIVE}" "${XBB_GMP_URL}"

  (
    cd "${XBB_BUILD_FOLDER}/${XBB_GMP_FOLDER}"

    xbb_activate_dev

    export CPPFLAGS="${XBB_CPPFLAGS}" 
    export CFLAGS="${XBB_CFLAGS}"
    export CXXFLAGS="${XBB_CXXFLAGS}"
    export LDFLAGS="${XBB_LDFLAGS_LIB}"

    # Mandatory, otherwise it fails on 32-bit. 
    export ABI="${BITS}"

    ./configure --help

    ./configure \
      --prefix="${XBB_FOLDER}" 
    
    make -j ${JOBS}
    make install-strip
  )
}

function do_mpfr() 
{
  # http://www.mpfr.org
  # http://www.mpfr.org/mpfr-3.1.6
  # https://www.archlinux.org/packages/core/x86_64/mpfr/

  # 7 September 2017
  XBB_MPFR_VERSION="3.1.6"

  XBB_MPFR_FOLDER="mpfr-${XBB_MPFR_VERSION}"
  XBB_MPFR_ARCHIVE="${XBB_MPFR_FOLDER}.tar.xz"
  # XBB_MPFR_URL="http://www.mpfr.org/${XBB_MPFR_FOLDER}/${XBB_MPFR_ARCHIVE}"
  XBB_MPFR_URL="https://github.com/gnu-mcu-eclipse/files/raw/master/libs/${XBB_MPFR_ARCHIVE}"

  echo
  echo "Building mpfr ${XBB_MPFR_VERSION}..."

  cd "${XBB_BUILD_FOLDER}"

  download_and_extract "${XBB_MPFR_ARCHIVE}" "${XBB_MPFR_URL}"

  (
    cd "${XBB_BUILD_FOLDER}/${XBB_MPFR_FOLDER}"

    xbb_activate_dev

    export CPPFLAGS="${XBB_CPPFLAGS}" 
    export CFLAGS="${XBB_CFLAGS}"
    export CXXFLAGS="${XBB_CXXFLAGS}"
    export LDFLAGS="${XBB_LDFLAGS_LIB}"

    ./configure --help

    ./configure \
      --prefix="${XBB_FOLDER}" 
    
    make -j ${JOBS}
    make install-strip
  )
}

function do_mpc() 
{
  # http://www.multiprecision.org/
  # ftp://ftp.gnu.org/gnu/mpc/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-libmpc

  # February 2015
  XBB_MPC_VERSION="1.0.3"

  XBB_MPC_FOLDER="mpc-${XBB_MPC_VERSION}"
  XBB_MPC_ARCHIVE="${XBB_MPC_FOLDER}.tar.gz"
  XBB_MPC_URL="ftp://ftp.gnu.org/gnu/mpc/${XBB_MPC_ARCHIVE}"

  echo
  echo "Building mpc ${XBB_MPC_VERSION}..."

  cd "${XBB_BUILD_FOLDER}"

  download_and_extract "${XBB_MPC_ARCHIVE}" "${XBB_MPC_URL}"

  (
    cd "${XBB_BUILD_FOLDER}/${XBB_MPC_FOLDER}"

    xbb_activate_dev

    export CPPFLAGS="${XBB_CPPFLAGS}" 
    export CFLAGS="${XBB_CFLAGS}"
    export CXXFLAGS="${XBB_CXXFLAGS}"
    export LDFLAGS="${XBB_LDFLAGS_LIB}"

    ./configure --help

    ./configure \
      --prefix="${XBB_FOLDER}" 
    
    make -j ${JOBS}
    make install-strip
  )
}

function do_isl() 
{
  # http://isl.gforge.inria.fr
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=isl

  # 2016-12-20
  XBB_ISL_VERSION="0.18"

  XBB_ISL_FOLDER="isl-${XBB_ISL_VERSION}"
  XBB_ISL_ARCHIVE="${XBB_ISL_FOLDER}.tar.xz"
  # XBB_ISL_URL="http://isl.gforge.inria.fr/${XBB_ISL_ARCHIVE}"
  XBB_ISL_URL="https://github.com/gnu-mcu-eclipse/files/raw/master/libs/${XBB_ISL_ARCHIVE}"

  echo
  echo "Building isl ${XBB_ISL_VERSION}..."

  cd "${XBB_BUILD_FOLDER}"

  download_and_extract "${XBB_ISL_ARCHIVE}" "${XBB_ISL_URL}"

  (
    cd "${XBB_BUILD_FOLDER}/${XBB_ISL_FOLDER}"

    xbb_activate_dev

    export CPPFLAGS="${XBB_CPPFLAGS}" 
    export CFLAGS="${XBB_CFLAGS}"
    export CXXFLAGS="${XBB_CXXFLAGS}"
    export LDFLAGS="${XBB_LDFLAGS_LIB}"

    ./configure --help

    ./configure \
      --prefix="${XBB_FOLDER}" 
    
    make -j ${JOBS}
    make install-strip
  )
}

# -----------------------------------------------------------------------------
# Other GCC dependencies (from https://gcc.gnu.org/install/prerequisites.html):

# gperf version 2.7.2 (or later)
#   Necessary when modifying gperf input files, e.g. gcc/cp/cfns.gperf to regenerate its associated header file, e.g. gcc/cp/cfns.h.
#
# DejaGnu 1.4.4
# Expect
# Tcl
#   Necessary to run the GCC testsuite
#
# autogen version 5.5.4 (or later) and
# guile version 1.4.1 (or later)
#   Necessary to regenerate fixinc/fixincl.x from fixinc/inclhack.def and fixinc/*.tpl.
#
# Texinfo version 4.8 or later is required for make pdf.
# TeX (any working version)

# XBB_ZLIB_VERSION=1.2.11

# -----------------------------------------------------------------------------

function do_native_binutils() 
{
  # https://www.gnu.org/software/binutils/
  # https://ftp.gnu.org/gnu/binutils/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=gdb-git

  # 2017-07-24, "2.29"
  # 2018-07-14, "2.31"
  # cmake fails with Internal error.
  # 2019-02-02, "2.32"

  XBB_BINUTILS_VERSION="2.31"

  XBB_BINUTILS_FOLDER="binutils-${XBB_BINUTILS_VERSION}"
  XBB_BINUTILS_ARCHIVE="${XBB_BINUTILS_FOLDER}.tar.xz"
  XBB_BINUTILS_URL="https://ftp.gnu.org/gnu/binutils/${XBB_BINUTILS_ARCHIVE}"

  # Requires gmp, mpfr, mpc, isl.
  echo
  echo "Building native binutils ${XBB_BINUTILS_VERSION}..."

  cd "${XBB_BUILD_FOLDER}"

  download_and_extract "${XBB_BINUTILS_ARCHIVE}" "${XBB_BINUTILS_URL}"

  (
    cd "${XBB_BUILD_FOLDER}/${XBB_BINUTILS_FOLDER}"

    xbb_activate_dev

    export CPPFLAGS="${XBB_CPPFLAGS}" 
    export CFLAGS="${XBB_CFLAGS} -Wno-sign-compare"
    export CXXFLAGS="${XBB_CXXFLAGS} -Wno-sign-compare"
    export LDFLAGS="${XBB_LDFLAGS_APP}"

    ./configure --help

    # --with-sysroot failed.
    ./configure \
      --prefix="${XBB_FOLDER}" \
      --build="${BUILD}" \
      --disable-shared \
      --enable-static \
      --enable-threads \
      --enable-deterministic-archives \
      --disable-gdb
  
    make -j ${JOBS}
    make install-strip
  )

  (
    xbb_activate

    "${XBB_FOLDER}/bin/size" --version
  )

  hash -r
}

# -----------------------------------------------------------------------------

function do_native_gcc() 
{
  # https://gcc.gnu.org
  # https://ftp.gnu.org/gnu/gcc/
  # https://gcc.gnu.org/wiki/InstallingGCC
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=gcc-git

  # 2017-08-14, "7.2.0"
  # 2018-01-25, "7.3.0"
  # 2018-12-06, "7.4.0"

  XBB_GCC_VERSION="7.4.0"

  XBB_GCC_FOLDER="gcc-${XBB_GCC_VERSION}"
  XBB_GCC_ARCHIVE="${XBB_GCC_FOLDER}.tar.xz"
  XBB_GCC_URL="https://ftp.gnu.org/gnu/gcc/gcc-${XBB_GCC_VERSION}/${XBB_GCC_ARCHIVE}"
  XBB_GCC_BRANDING="xPack Build Box Bootstrap GCC\x2C ${BITS}-bit"

  # Requires gmp, mpfr, mpc, isl.
  echo
  echo "Building native gcc ${XBB_GCC_VERSION}..."

  cd "${XBB_BUILD_FOLDER}"

  download_and_extract "${XBB_GCC_ARCHIVE}" "${XBB_GCC_URL}"

  # The documentation recommands a separate build folder.
  (
    mkdir -p "${XBB_BUILD_FOLDER}/${XBB_GCC_FOLDER}"-build
    cd "${XBB_BUILD_FOLDER}/${XBB_GCC_FOLDER}"-build

    xbb_activate_dev

    export CPPFLAGS="${XBB_CPPFLAGS}" 
    export CFLAGS="${XBB_CFLAGS} -Wno-sign-compare"
    export CXXFLAGS="${XBB_CXXFLAGS} -Wno-sign-compare"
    export LDFLAGS="${XBB_LDFLAGS_APP}"

    # Parallel builds fail while running build/genrecog.
    if [ -z "${JOBS}" ]
    then
      JOBS=2
    elif [ ${JOBS} -gt 2 ]
    then
      JOBS=2
    fi

    bash "${XBB_BUILD_FOLDER}/${XBB_GCC_FOLDER}/configure" --help

    # --with-sysroot failed.
    # --disable-shared failed with errors in libstdc++-v3
    bash "${XBB_BUILD_FOLDER}/${XBB_GCC_FOLDER}/configure" \
      --prefix="${XBB_FOLDER}" \
      --build="${BUILD}" \
      --with-pkgversion="${XBB_GCC_BRANDING}" \
      --program-suffix="${GCC_SUFFIX}" \
      --enable-languages=c,c++ \
      --enable-static \
      --enable-threads=posix \
      --enable-libmpx \
      --enable-__cxa_atexit \
      --disable-libunwind-exceptions \
      --enable-clocale=gnu \
      --disable-libstdcxx-pch \
      --disable-libssp \
      --enable-gnu-unique-object \
      --enable-linker-build-id \
      --enable-lto \
      --enable-plugin \
      --enable-install-libiberty \
      --with-linker-hash-style=gnu \
      --enable-gnu-indirect-function \
      --disable-multilib \
      --disable-werror \
      --disable-bootstrap
    
    make -j ${JOBS}
    make install-strip
  )

  (
    xbb_activate

    "${XBB_FOLDER}/bin/g++${GCC_SUFFIX}" --version
  )

  (
    mkdir -p "${HOME}/tmp"
    cd "${HOME}/tmp"

    xbb_activate

    # Note: __EOF__ is quoted to prevent substitutions here.
    cat <<'__EOF__' > hello.cpp
#include <iostream>

int
main(int argc, char* argv[])
{
  std::cout << "Hello" << std::endl;
}
__EOF__

    if true
    then

      "${XBB_FOLDER}/bin/g++${GCC_SUFFIX}" hello.cpp -o hello
      "${XBB_FOLDER}/bin/readelf" -d hello

      if [ "x$(./hello)x" != "xHellox" ]
      then
        exit 1
      fi

    fi

    rm -rf hello.cpp hello
  )

  hash -r
}

# -----------------------------------------------------------------------------
