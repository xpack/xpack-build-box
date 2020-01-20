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

    XBB_GCC_VERSION="8.3.0" # "7.4.0"
    XBB_GCC_SUFFIX="-8"

    XBB_BRANDING="xPack Build Box\x2C ${HOST_BITS}-bit"

    # -------------------------------------------------------------------------

    # New zlib, used in most of the tools.
    # depends=('glibc')
    do_zlib "1.2.11"

    # Libraries, required by gcc.
    # depends=('gcc-libs' 'sh')
    do_gmp "6.2.0" # "6.1.2"
    # depends=('gmp>=5.0')
    do_mpfr "4.0.2" # "3.1.6"
    # depends=('mpfr')
    do_mpc "1.1.0" # "1.0.3"
    # depends=('gmp')
    do_isl "0.22" # "0.21"

    # Libraries, required by gnutls.
    # depends=('glibc' 'gmp')
    do_nettle "3.5.1" # "3.4.1"
    # depends=('glibc')
    do_tasn1 "4.15.0" # "4.13"
    # Library, required by Python.
    # depends=('glibc')
    do_expat "2.2.9" # "2.2.6"
    # depends=('glibc')
    do_libffi "3.2.1"

    # Libary, required by tar. 
    # depends=('sh')
    do_xz "5.2.4"

    # depends=('perl')
    do_openssl "1.1.1d" # "1.0.2r" # "1.1.1b"

    # Needed by wine.
    do_libpng "1.6.37"

    # Library, required by wget.
    # depends=()
    do_libiconv "1.16" # "1.15"

    # depends=('glibc' 'glib2 (internal)')
    do_pkg_config "0.29.2"

    # depends=('ca-certificates' 'krb5' 'libssh2' 'openssl' 'zlib' 'libpsl' 'libnghttp2')
    do_curl "7.68.0" # "7.64.1"

    # tar with xz support.
    # depends=('glibc')
    do_tar "1.32"

    # depends=('glibc' 'libidn2' 'libtasn1' 'libunistring' 'nettle' 'p11-kit' 'readline' 'zlib')
    do_gnutls "3.6.11.1" # "3.6.7"

    do_coreutils "8.31"

    # -------------------------------------------------------------------------
    # GNU tools

    # depends=('glibc')
    do_m4 "1.4.18"

    # depends=('glibc' 'mpfr')
    do_gawk "5.0.1" # "4.2.1"

    # depends ?
    do_sed "4.8" # "4.7"

    # depends=('sh' 'perl' 'awk' 'm4' 'texinfo')
    do_autoconf "2.69"
    # depends=('sh' 'perl')
    do_automake "1.16"

    # depends=('sh' 'tar' 'glibc')
    do_libtool "2.4.6"

    # depends=('glibc' 'glib2' 'libunistring' 'ncurses')
    do_gettext "0.20.1" # "0.19.8"

    # depends=('glibc' 'attr')
    do_patch "2.7.6"

    # depends=('libsigsegv')
    do_diffutils "3.7"

    # depends=('glibc')
    do_bison "3.5" # "3.3.2"

    # depends=('glibc' 'guile')
    do_make "4.2.1"

    # -------------------------------------------------------------------------
    # Third party tools

    # depends=('libutil-linux' 'gnutls' 'libidn' 'libpsl>=0.7.1-3' 'gpgme')
    do_wget "1.20.3" # "1.20.1"

    # Required to build PDF manuals.
    # depends=('coreutils')
    do_texinfo "6.7" # "6.6"
    # depends ?
    do_patchelf "0.10"
    # depends=('glibc')
    do_dos2unix "7.4.1" # "7.4.0"

    # macOS 10.10 uses 2.5.3, an update is not mandatory.
    # depends=('glibc' 'm4' 'sh')
    do_flex "2.6.4"

    # macOS 10.10 uses 5.18.2, an update is not mandatory.
    # depends=('gdbm' 'db' 'glibc')
    do_perl "5.30.1" # "5.28.1"

    # depends=('curl' 'libarchive' 'shared-mime-info' 'jsoncpp' 'rhash')
    do_cmake "3.16.2" # "3.13.4"

    # depends=('bzip2' 'gdbm' 'openssl' 'zlib' 'expat' 'sqlite' 'libffi')
    do_python "2.7.17" # "2.7.16"

    # require xz, openssl
    do_python3 "3.8.1" # "3.7.3"

    # depends=('python2')
    do_scons "3.1.2" # "3.0.5"

    # depends=('python2')
    do_ninja "1.9.0"

    # depends=('python3')
    do_meson "0.53.0" # "0.50.0"

    # depends=('curl' 'expat>=2.0' 'perl-error' 'perl>=5.14.0' 'openssl' 'pcre2' 'grep' 'shadow')
    do_git "2.25.0" # "2.21.0"

    do_p7zip "16.02"

    if [ "${HOST_UNAME}" != "Darwin" ]
    then
      # depends=('libpng')
      : # do_wine "4.3"
    fi

    # -------------------------------------------------------------------------
    # Compilers, native & mingw

    # By all means DO NOT build binutils on macOS, since this will 
    # override Apple specific tools (ar, strip, etc) and break the
    # build in multiple ways.
    if [ "${HOST_UNAME}" != "Darwin" ]
    then
      # Requires gmp, mpfr, mpc, isl.
      do_native_binutils "2.33.1" 
    fi

    # makedepends=('binutils>=2.26' 'libmpc' 'gcc-ada' 'doxygen' 'git')
    do_native_gcc "${XBB_GCC_VERSION}"
     
    # mingw-w64 binutils and gcc.
    if [ "${HOST_UNAME}" != "Darwin" ]
    then
      # depends=('zlib')
      : # do_mingw_binutils "2.33.1"
      # depends=('zlib' 'libmpc' 'mingw-w64-crt' 'mingw-w64-binutils' 'mingw-w64-winpthreads' 'mingw-w64-headers')
      # do_mingw_all "5.0.4" "7.4.0"
    fi

    # do_strip_libs

    # do_cleaunup

    # -----------------------------------------------------------------------------

  else
    echo 
    echo "Version not yet supported."
  fi
}