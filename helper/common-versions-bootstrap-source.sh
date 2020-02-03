# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (http://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software 
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

function do_build_versions()
{
  if [ "${XBB_VERSION}" = "3.1" ]
  then

    # -------------------------------------------------------------------------

    # To differentiate the binaries from the XBB ones which use `-7`.
    XBB_GCC_SUFFIX="-7bs"
    XBB_BINUTILS_BRANDING="xPack Build Box Bootstrap Binutils\x2C ${HOST_BITS}-bit"
    XBB_GCC_BRANDING="xPack Build Box Bootstrap GCC\x2C ${HOST_BITS}-bit"

    # -------------------------------------------------------------------------

    # New zlib, it is used in most of the tools.
    # depends=('glibc')
    do_zlib "1.2.11"

    # Library, required by tar. 
    # depends=('sh')
    do_xz "5.2.3"

    # New tar, with xz support.
    # depends=('glibc')
    do_tar "1.30" # Requires xz.

    # -------------------------------------------------------------------------
    # From this moment on, .xz archives can be processed.

    # New openssl, required by curl, cmake, python, etc.
    # depends=('perl')
    do_openssl "1.0.2u" # "1.0.2r"

    # New curl, that better understands all protocols.
    # depends=('ca-certificates' 'krb5' 'libssh2' 'openssl' 'zlib' 'libpsl' 'libnghttp2')
    do_curl "7.64.1" # "7.57.0"

    # -------------------------------------------------------------------------
    # From this moment on, new https sites can be accessed.

    do_coreutils "8.31"

    # depends=('glibc')
    do_m4 "1.4.18"

    # depends=('glibc' 'mpfr')
    do_gawk "4.2.1"

    # depends ?
    do_sed "4.7"

    # depends=('sh' 'perl' 'awk' 'm4' 'texinfo')
    do_autoconf "2.69"
    # depends=('sh' 'perl')
    do_automake "1.16"

    # depends=('sh' 'tar' 'glibc')
    do_libtool "2.4.6"

    # depends=('glibc' 'glib2' 'libunistring' 'ncurses')
    do_gettext "0.19.8"

    # depends=('libsigsegv')
    do_diffutils "3.7"
    # depends=('glibc' 'attr')
    do_patch "2.7.6"

    # depends=('glibc')
    do_bison "3.4.2" # "3.3.2"

    # depends=('glibc' 'guile')
    do_make "4.2.1"

    # macOS 10.10 uses 2.5.3, an update is not mandatory.
    # Ubuntu 12 uses 2.5.35, an update is not mandatory.
    # depends=('glibc' 'm4' 'sh')
    do_flex "2.6.3" # "2.6.4" fails

    # depends=()
    do_libiconv "1.16" # "1.15"

    # requires libiconv
    # depends=('glibc' 'glib2 (internal)')
    do_pkg_config "0.29.2"

    if [ "${HOST_UNAME}" != "Darwin" ]
    then
      # macOS 10.10 uses 5.18.2, an update is not mandatory.
      # 5.18.2 fails to build automake 1.16 on Linux
      # depends=('gdbm' 'db' 'glibc')
      # On macOS 10.10 newer versions fail with clang, due to a missing clock_gettime()
      # Warning: macOS divergence!
      do_perl "5.28.2" # "5.18.2" # "5.24.4" # "5.26.3" # "5.28.2"
    fi

    # Libraries, required by gcc.
    # depends=('gcc-libs' 'sh')
    do_gmp "6.1.2"
    # depends=('gmp>=5.0')
    do_mpfr "3.1.6"
    # depends=('mpfr')
    do_mpc "1.1.0" # "1.0.3"
    # depends=('gmp')
    do_isl "0.21"
 
    # -------------------------------------------------------------------------


    if [ "${HOST_UNAME}" != "Darwin" ]
    then
      # depends=('bzip2' 'gdbm' 'openssl' 'zlib' 'expat' 'sqlite' 'libffi')
      # macOS 10.10 uses 2.7.10, bring it in sync.
      do_python "2.7.10" # "2.7.12" # "2.7.14" # "2.7.16" # "2.7.14"
    fi
    # depends=('python2')
    do_scons "3.0.5" # "3.0.1"

    # makedepend is needed by openssl
    do_util_macros "1.19.2" # "1.17.1"
    do_xorg_xproto "7.0.31"
    do_makedepend "1.0.6" # "1.0.5"

    # -------------------------------------------------------------------------
    # Native binutils and gcc.

    # By all means DO NOT build binutils on macOS, since this will 
    # override Apple specific tools (ar, strip, etc) and break the
    # build in multiple ways.
    if [ "${HOST_UNAME}" != "Darwin" ]
    then
      # Requires gmp, mpfr, mpc, isl.
      do_native_binutils "2.31" 
    fi

    # Requires gmp, mpfr, mpc, isl.
    do_native_gcc "7.5.0" # "7.4.0"

    # From here on, a reasonable C++11 is available.
    # -------------------------------------------------------------------------

    # Recent versions require C++11.
    # depends=('curl' 'libarchive' 'shared-mime-info' 'jsoncpp' 'rhash')
    do_cmake "3.15.6" # "3.13.4"

    # -------------------------------------------------------------------------

  else
    echo 
    echo "Version not yet supported."
  fi
}