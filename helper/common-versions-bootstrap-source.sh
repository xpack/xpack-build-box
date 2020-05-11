# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (http://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software 
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

function build_versioned_components()
{
  if [[ "${XBB_VERSION}" =~ 3\.[2] ]]
  then

    # -------------------------------------------------------------------------

    # The main characteristic of XBB Bootstrap is the compiler version.
    XBB_GCC_VERSION="8.4.0" # "8.3.0" "7.5.0" "7.4.0"
    XBB_GCC_SUFFIX="-xbs" # "-$(echo ${XBB_GCC_VERSION} | sed -e 's|\([0-9][0-9]*\)\..*|\1|')bs"
    
    XBB_BINUTILS_VERSION="2.32" # "2.31"
    XBB_GLIBC_VERSION="2.30"

    XBB_BINUTILS_BRANDING="xPack Build Box Bootstrap binutils\x2C ${HOST_BITS}-bit"
    XBB_GCC_BRANDING="xPack Build Box Bootstrap GCC\x2C ${HOST_BITS}-bit"
    XBB_GLIBC_BRANDING="xPack Build Box Bootstrap GNU libc\x2C ${HOST_BITS}-bit"

    # -------------------------------------------------------------------------

    # All of he following are compiled with the original Ubuntu compiler 
    # (GCC 6.x) and should be locked to system shared libraries.

    # TODO: Use ldconfig to get the folders.
    # libc is in /lib/x86_64-linux-gnu
    # libstdc++ is in /usr/lib/x86_64-linux-gnu
    if is_linux
    then
      # Start the path with the local XBB folder, to pick the newly compiled 
      # libraries.
      if [ "${HOST_BITS}" == "64" ]
      then
        LD_RUN_PATH="${INSTALL_FOLDER_PATH}/lib64:${INSTALL_FOLDER_PATH}/lib"
      else
        LD_RUN_PATH="${INSTALL_FOLDER_PATH}/lib"
      fi

      # Add the system paths.
      readarray -t lines <<< "$(ldconfig -v 2>/dev/null | grep ':' | sed -e 's|:||')"
      LD_RUN_PATH+=":$(IFS=":"; echo "${lines[*]}")"

      echo "LD_RUN_PATH=${LD_RUN_PATH}"
      export LD_RUN_PATH
    fi

    # depends ?
    do_patchelf "0.10"

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

    # depends=('sh' 'perl' 'awk' 'm4' 'texinfo')
    do_autoconf "2.69"

    # depends=('sh' 'perl')
    # Requires autoconf, the order is important on macOS.
    # PATCH! .xz!
    do_automake "1.16"

    # depends=('sh' 'tar' 'glibc')
    # Notice: will use the system compiler
    do_libtool "2.4.6"

    # Replacement for the old libcrypt.so.1.
    # ! Requires new autotools.
    do_libxcrypt "4.4.15"

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
    # PATCH!
    do_m4 "1.4.18"

    # depends=('glibc' 'mpfr')
    do_gawk "4.2.1"

    # depends ?
    do_sed "4.7"

    # depends=('glibc' 'glib2' 'libunistring' 'ncurses')
    do_gettext "0.19.8"

    # depends=('libsigsegv')
    do_diffutils "3.7"
    # depends=('glibc' 'attr')
    do_patch "2.7.6"

    # depends=('glibc')
    do_bison "3.4.2" # "3.3.2"

    # depends=('glibc' 'guile')
    # PATCH!
    do_make "4.2.1"

    # macOS 10.10 uses 2.5.3, an update is not mandatory.
    # Ubuntu 12 uses 2.5.35, an update is not mandatory.
    # ! Requires autopoint from autotools.
    # depends=('glibc' 'm4' 'sh')
    # PATCH!
    do_flex "2.6.4" # "2.6.3" fails

    # depends=()
    # Not needed, possibly harmful for GCC 9.
    # do_libiconv "1.16" # "1.15"

    # Required by Python3
    do_expat "2.2.9"
    do_libmpdec "2.4.2"
    do_libffi "3.3"

    # depends=('glibc' 'glib2 (internal)')
    do_pkg_config "0.29.2"

    if is_linux
    then
      # macOS 10.10 uses 5.18.2, an update is not mandatory.
      # Ubuntu 12 uses 5.14.2.
      # 5.18.2 fails to build automake 1.16 on Linux (fixed by a patch)

      # ! Requires patchelf.
      # depends=('gdbm' 'db' 'glibc')
      # On macOS 10.10 newer versions fail with clang, due to a missing clock_gettime()
      # Warning: macOS divergence!
      # old PATCH!
      do_perl "5.30.1" # "5.18.2" # "5.24.4" # "5.26.3" # "5.28.2"
    fi

    # -------------------------------------------------------------------------

    # Recent versions require C++11.
    # depends=('curl' 'libarchive' 'shared-mime-info' 'jsoncpp' 'rhash')
    do_cmake "3.15.6" # "3.13.4"

    # -------------------------------------------------------------------------

    # macOS: Segmentation fault: 11
    if is_linux
    then
      # depends=('bzip2' 'gdbm' 'openssl' 'zlib' 'expat' 'sqlite' 'libffi')
      # macOS 10.10 uses 2.7.10, bring it in sync.
      do_python2 "2.7.10" # "2.7.12" # "2.7.14" # "2.7.16" # "2.7.14"
    fi

    if is_linux
    then
      # required by Glibc

      # require xz, openssl
      do_python3 "3.7.6" # "3.8.1" # "3.7.3"
      # The necessary bits to build these optional modules were not found:
      # _bz2                  _curses               _curses_panel      
      # _dbm                  _gdbm                 _sqlite3           
      # _tkinter              _uuid                 readline 
                
      # depends=('python3')
      do_meson "0.53.1" # "0.50.0"
    fi

    # depends=('python2')
    do_scons "3.1.1" # "3.0.5" # "3.0.1"

    # Requires scons
    # depends=('python2')
    do_ninja "1.10.0" # "1.9.0"

    # makedepend is needed by openssl
    do_util_macros "1.19.2" # "1.17.1"
    # PATCH!
    do_xorg_xproto "7.0.31" # Needs a patch for aarch64.
    do_makedepend "1.0.6" # "1.0.5"

    # -------------------------------------------------------------------------
    # Native binutils and gcc.

    # Libraries, required by gcc.
    # depends=('gcc-libs' 'sh')
    do_gmp "6.1.2"
    # depends=('gmp>=5.0')
    do_mpfr "3.1.6"
    # depends=('mpfr')
    do_mpc "1.1.0" # "1.0.3"
    # depends=('gmp')
    do_isl "0.21"

    # By all means DO NOT build binutils on macOS, since this will 
    # override Apple specific tools (ar, strip, etc) and break the
    # build in multiple ways.
    if is_linux
    then
      # Requires gmp, mpfr, mpc, isl.
      # PATCH!
      do_native_binutils "${XBB_BINUTILS_VERSION}" 
    fi

    # Requires gmp, mpfr, mpc, isl.
    do_native_gcc "${XBB_GCC_VERSION}"

    # From here on, a reasonable C++11 is available.

    strip_static_objects

    patch_elf_rpath

    run_tests

    # -------------------------------------------------------------------------
  elif [ "${XBB_VERSION}" = "3.1" ]
  then

    # -------------------------------------------------------------------------

    # The main characteristic of XBB Bootstrap is the compiler version.
    XBB_GCC_VERSION="8.3.0" # "7.5.0" "7.4.0"
    XBB_GCC_SUFFIX="-$(echo ${XBB_GCC_VERSION} | sed -e 's|\([0-9][0-9]*\)\..*|\1|')bs"
    XBB_BINUTILS_VERSION="2.32" # "2.31"

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

    # depends=('sh' 'perl' 'awk' 'm4' 'texinfo')
    do_autoconf "2.69"

    # depends=('sh' 'perl')
    # Requires autoconf, the order is important on macOS.
    # PATCH! .xz!
    do_automake "1.16"

    # depends=('sh' 'tar' 'glibc')
    do_libtool "2.4.6"

    # Replacement for the old libcrypt.so.1.
    # Requires new autotools.
    do_libxcrypt "4.4.15"

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
    # PATCH!
    do_m4 "1.4.18"

    # depends=('glibc' 'mpfr')
    do_gawk "4.2.1"

    # depends ?
    do_sed "4.7"

    # depends=('glibc' 'glib2' 'libunistring' 'ncurses')
    do_gettext "0.19.8"

    # depends=('libsigsegv')
    do_diffutils "3.7"
    # depends=('glibc' 'attr')
    do_patch "2.7.6"

    # depends=('glibc')
    do_bison "3.4.2" # "3.3.2"

    # depends=('glibc' 'guile')
    # PATCH!
    do_make "4.2.1"

    # macOS 10.10 uses 2.5.3, an update is not mandatory.
    # Ubuntu 12 uses 2.5.35, an update is not mandatory.
    # depends=('glibc' 'm4' 'sh')
    # PATCH!
    do_flex "2.6.4" # "2.6.3" fails

    # depends=()
    # Not needed, possibly harmful for GCC 9.
    # do_libiconv "1.16" # "1.15"

    # depends=('glibc' 'glib2 (internal)')
    do_pkg_config "0.29.2"

    if is_linux
    then
      # macOS 10.10 uses 5.18.2, an update is not mandatory.
      # Ubuntu 12 uses 5.14.2.
      # 5.18.2 fails to build automake 1.16 on Linux (fixed by a patch)

      # depends=('gdbm' 'db' 'glibc')
      # On macOS 10.10 newer versions fail with clang, due to a missing clock_gettime()
      # Warning: macOS divergence!
      # PATCH!
      do_perl "5.18.2" # "5.24.4" # "5.26.3" # "5.28.2"
    fi

    # -------------------------------------------------------------------------

    # Recent versions require C++11.
    # depends=('curl' 'libarchive' 'shared-mime-info' 'jsoncpp' 'rhash')
    do_cmake "3.15.6" # "3.13.4"

    # -------------------------------------------------------------------------

    # macOS: Segmentation fault: 11
    if is_linux
    then
      # depends=('bzip2' 'gdbm' 'openssl' 'zlib' 'expat' 'sqlite' 'libffi')
      # macOS 10.10 uses 2.7.10, bring it in sync.
      do_python2 "2.7.10" # "2.7.12" # "2.7.14" # "2.7.16" # "2.7.14"
    fi

    # macOS: fails with "ModuleNotFoundError: No module named '_ctypes'" in meson
    # TODO: make it work for v3.2.
    if false # is_linux
    then
      # require xz, openssl
      do_python3 "3.7.6" # "3.8.1" # "3.7.3"
      # The necessary bits to build these optional modules were not found:
      # _bz2                  _curses               _curses_panel      
      # _dbm                  _gdbm                 _sqlite3           
      # _tkinter              _uuid                 readline 
                
      # depends=('python3')
      do_meson "0.53.1" # "0.50.0"
    fi

    # depends=('python2')
    do_scons "3.1.1" # "3.0.5" # "3.0.1"

    # Requires scons
    # depends=('python2')
    do_ninja "1.10.0" # "1.9.0"

    # makedepend is needed by openssl
    do_util_macros "1.19.2" # "1.17.1"
    # PATCH!
    do_xorg_xproto "7.0.31" # Needs a patch for aarch64.
    do_makedepend "1.0.6" # "1.0.5"

    # -------------------------------------------------------------------------
    # Native binutils and gcc.

    # Libraries, required by gcc.
    # depends=('gcc-libs' 'sh')
    do_gmp "6.1.2"
    # depends=('gmp>=5.0')
    do_mpfr "3.1.6"
    # depends=('mpfr')
    do_mpc "1.1.0" # "1.0.3"
    # depends=('gmp')
    do_isl "0.21"

    # By all means DO NOT build binutils on macOS, since this will 
    # override Apple specific tools (ar, strip, etc) and break the
    # build in multiple ways.
    if is_linux
    then
      # Requires gmp, mpfr, mpc, isl.
      do_native_binutils "${XBB_BINUTILS_VERSION}" 
    fi

    # Requires gmp, mpfr, mpc, isl.
    do_native_gcc "${XBB_GCC_VERSION}"

    # From here on, a reasonable C++11 is available.

    strip_static_objects

    patch_elf_rpath

    run_tests

    # -------------------------------------------------------------------------

  else
    echo 
    echo "Version ${XBB_VERSION} not yet supported."
  fi
}

# -----------------------------------------------------------------------------
