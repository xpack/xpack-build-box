#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (http://xpack.github.io)
# Copyright (c) 2019 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software 
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Safety settings (see https://gist.github.com/ilg-ul/383869cbb01f61a51c4d).

if [[ ! -z ${DEBUG} ]]
then
  set ${DEBUG} # Activate the expand mode if DEBUG is -x.
else
  DEBUG=""
fi

set -o errexit # Exit if command failed.
set -o pipefail # Exit if pipe failed.
set -o nounset # Exit if variable not set.

# Remove the initial space and instead use '\n'.
IFS=$'\n\t'

# -----------------------------------------------------------------------------

# Script to build a subsequent version of a Docker image with the 
# xPack Build Box (xbb).

# To activate the new build environment, use:
#
#   $ source /opt/xbb/xbb-source.sh
#   $ xbb_activate

XBB_INPUT_FOLDER="/xbb-input"
source "${XBB_INPUT_FOLDER}/common-functions-source.sh"

prepare_env

# Create the xbb-source.sh file.
create_xbb_source

# Remove the old name, to enforce using the new one.
rm -rf "${XBB_FOLDER}/xbb.sh"

# -----------------------------------------------------------------------------

# Make the functions available to the entire script.
source "${XBB_FOLDER}/xbb-source.sh"

# -----------------------------------------------------------------------------

function do_coreutils()
{
  # https://ftp.gnu.org/gnu/coreutils/

  XBB_COREUTILS_VERSION="8.31"

  XBB_COREUTILS_FOLDER_NAME="coreutils-${XBB_COREUTILS_VERSION}"
  XBB_COREUTILS_ARCHIVE="${XBB_COREUTILS_FOLDER_NAME}.tar.xz"
  XBB_COREUTILS_URL="https://ftp.gnu.org/gnu/coreutils/${XBB_COREUTILS_ARCHIVE}"

  echo
  echo "Building coreutils ${XBB_COREUTILS_VERSION}..."

  cd "${XBB_BUILD_FOLDER}"

  download_and_extract "${XBB_COREUTILS_ARCHIVE}" "${XBB_COREUTILS_URL}"

  (
    cd "${XBB_BUILD_FOLDER}/${XBB_COREUTILS_FOLDER_NAME}"

    xbb_activate_dev

    # error: you should not run configure as root (set FORCE_UNSAFE_CONFIGURE=1 
    # in environment to bypass this check
    export FORCE_UNSAFE_CONFIGURE=1

    bash ./configure --help

    bash ./configure \
      --prefix="${XBB_FOLDER}" 
    
    make -j${MAKE_CONCURRENCY}
    make install-strip
  )

  (
    xbb_activate

    "${XBB_FOLDER}/bin/realpath" --version
  )

  hash -r
}

# -----------------------------------------------------------------------------

function do_python3() 
{
  # https://www.python.org
  # https://www.python.org/downloads/source/
  
  # https://git.archlinux.org/svntogit/packages.git/tree/trunk/PKGBUILD?h=packages/python
  # https://git.archlinux.org/svntogit/packages.git/tree/trunk/PKGBUILD?h=packages/python-pip

  # 2018-12-24
  XBB_PYTHON_VERSION="3.7.2"

  XBB_PYTHON_FOLDER_NAME="Python-${XBB_PYTHON_VERSION}"
  XBB_PYTHON_ARCHIVE="${XBB_PYTHON_FOLDER_NAME}.tar.xz"
  XBB_PYTHON_URL="https://www.python.org/ftp/python/${XBB_PYTHON_VERSION}/${XBB_PYTHON_ARCHIVE}"

  echo
  echo "Installing python ${XBB_PYTHON_VERSION}..."

  cd "${XBB_BUILD_FOLDER}"

  download_and_extract "${XBB_PYTHON_ARCHIVE}" "${XBB_PYTHON_URL}"

  (
    cd "${XBB_BUILD_FOLDER}/${XBB_PYTHON_FOLDER_NAME}"

    xbb_activate_dev

    bash ./configure --help

    # Python is happier with dynamic zlib and curl.
    # Without --enabled-shared the build fails with
    # ImportError: No module named '_struct'
    # --enable-universalsdk is required by -arch.

    # --with-lto fails.
    # --with-system-expat fails.
    # https://github.com/python/cpython/tree/2.7

    export CFLAGS="${CFLAGS} -Wno-int-in-bool-context -Wno-maybe-uninitialized -Wno-nonnull -Wno-stringop-overflow"

    bash ./configure \
      --prefix="${XBB_FOLDER}" \
      --enable-shared \
      --with-universal-archs=${BITS}-bits \
      --enable-universalsdk \
      --with-computed-gotos \
      --enable-optimizations \
      --with-lto \
      --with-system-expat \
      --with-dbmliborder=gdbm:ndbm \
      --with-system-ffi \
      --with-system-libmpdec \
      --enable-loadable-sqlite-extensions \
      --without-ensurepip

    make -j${MAKE_CONCURRENCY} build_all
    make install

    strip --strip-all "${XBB_FOLDER}/bin/python3"
  )

  (
    xbb_activate

    "${XBB_FOLDER}/bin/python3" --version

    hash -r

    cd "${XBB_BUILD_FOLDER}/${XBB_PYTHON_FOLDER_NAME}"

    # Install setuptools and pip. Be sure the new version is used.
    # https://packaging.python.org/tutorials/installing-packages/
    echo
    echo "Installing setuptools and pip..."
    set +e
    "${XBB_FOLDER}/bin/pip3" --version
    # pip3: command not found
    set -e
    "${XBB_FOLDER}/bin/python3" -m ensurepip --default-pip
    "${XBB_FOLDER}/bin/python3" -m pip install --upgrade pip setuptools wheel
    "${XBB_FOLDER}/bin/pip3" --version
  )

  hash -r
}

# -----------------------------------------------------------------------------

function do_native_binutils() 
{
  # https://ftp.gnu.org/gnu/binutils/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=binutils-git
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=gdb-git

  # 2019-02-02
  XBB_BINUTILS_VERSION="2.32"

  XBB_BINUTILS_FOLDER_NAME="binutils-${XBB_BINUTILS_VERSION}"
  XBB_BINUTILS_ARCHIVE="${XBB_BINUTILS_FOLDER_NAME}.tar.xz"
  XBB_BINUTILS_URL="https://ftp.gnu.org/gnu/binutils/${XBB_BINUTILS_ARCHIVE}"

  # Requires gmp, mpfr, mpc, isl.
  echo
  echo "Building native binutils ${XBB_BINUTILS_VERSION}..."

  cd "${XBB_BUILD_FOLDER}"

  download_and_extract "${XBB_BINUTILS_ARCHIVE}" "${XBB_BINUTILS_URL}"

  (
    mkdir -p "${XBB_BUILD_FOLDER}/${XBB_BINUTILS_FOLDER_NAME}-native-build"
    cd "${XBB_BUILD_FOLDER}/${XBB_BINUTILS_FOLDER_NAME}-native-build"

    xbb_activate_dev

    export CFLAGS="${CFLAGS} -Wno-sign-compare"
    export CXXFLAGS="${CXXFLAGS} -Wno-sign-compare"
    # export LDFLAGS="-static-libstdc++ ${LDFLAGS}"

    bash "${XBB_BUILD_FOLDER}/${XBB_BINUTILS_FOLDER_NAME}/configure" --help

    bash "${XBB_BUILD_FOLDER}/${XBB_BINUTILS_FOLDER_NAME}/configure" \
      --prefix="${XBB_FOLDER}" \
      --build="${BUILD}" \
      --disable-shared \
      --enable-static \
      --enable-threads \
      --enable-deterministic-archives \
      --disable-gdb

    make -j${MAKE_CONCURRENCY}
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

  # 2018-12-06
  XBB_GCC_VERSION="7.4.0"

  XBB_GCC_FOLDER_NAME="gcc-${XBB_GCC_VERSION}"
  XBB_GCC_ARCHIVE="${XBB_GCC_FOLDER_NAME}.tar.xz"
  XBB_GCC_URL="https://ftp.gnu.org/gnu/gcc/gcc-${XBB_GCC_VERSION}/${XBB_GCC_ARCHIVE}"
  XBB_GCC_BRANDING="xPack Build Box GCC\x2C ${BITS}-bit"

  # Requires gmp, mpfr, mpc, isl.
  echo
  echo "Building native gcc ${XBB_GCC_VERSION}..."

  cd "${XBB_BUILD_FOLDER}"

  download_and_extract "${XBB_GCC_ARCHIVE}" "${XBB_GCC_URL}"

  (
    mkdir -p "${XBB_BUILD_FOLDER}/${XBB_GCC_FOLDER_NAME}-build"
    cd "${XBB_BUILD_FOLDER}/${XBB_GCC_FOLDER_NAME}-build"

    xbb_activate_dev

    export CFLAGS="${CFLAGS} -Wno-sign-compare"
    export CXXFLAGS="${CXXFLAGS} -Wno-sign-compare"
    # export LDFLAGS="-static-libstdc++ ${LDFLAGS}"

    bash "${XBB_BUILD_FOLDER}/${XBB_GCC_FOLDER_NAME}/configure" --help

    # --disable-shared failed with errors in libstdc++-v3
    # --build used conservatively.
    bash "${XBB_BUILD_FOLDER}/${XBB_GCC_FOLDER_NAME}/configure" \
      --prefix="${XBB_FOLDER}" \
      --build="${BUILD}" \
      --with-pkgversion="${XBB_GCC_BRANDING}" \
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
      --enable-checking=release
    
    make -j${MAKE_CONCURRENCY}
    make install-strip
  )

  (
    xbb_activate

    "${XBB_FOLDER}/bin/g++" --version

    mkdir -p "${HOME}/tmp"
    cd "${HOME}/tmp"

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

      "${XBB_FOLDER}/bin/g++" hello.cpp -o hello
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
# mingw-w64

function do_mingw_binutils() 
{
  # https://ftp.gnu.org/gnu/binutils/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-binutils-weak

  # 2019-02-02
  XBB_MINGW_BINUTILS_VERSION="2.32"

  XBB_MINGW_BINUTILS_FOLDER_NAME="binutils-${XBB_MINGW_BINUTILS_VERSION}"
  XBB_MINGW_BINUTILS_ARCHIVE="${XBB_MINGW_BINUTILS_FOLDER_NAME}.tar.xz"
  XBB_MINGW_BINUTILS_URL="https://ftp.gnu.org/gnu/binutils/${XBB_MINGW_BINUTILS_ARCHIVE}"

  echo
  echo "Building mingw-w64 binutils ${XBB_MINGW_BINUTILS_VERSION}..."

  cd "${XBB_BUILD_FOLDER}"

  download_and_extract "${XBB_MINGW_BINUTILS_ARCHIVE}" "${XBB_MINGW_BINUTILS_URL}"

  (
    mkdir -p "${XBB_BUILD_FOLDER}/${XBB_MINGW_BINUTILS_FOLDER_NAME}-mingw-build"
    cd "${XBB_BUILD_FOLDER}/${XBB_MINGW_BINUTILS_FOLDER_NAME}-mingw-build"

    xbb_activate_dev

    export CFLAGS="${CFLAGS} -Wno-sign-compare"
    # export LDFLAGS="-static-libstdc++ ${LDFLAGS}"

    # --build used conservatively
    bash "${XBB_BUILD_FOLDER}/${XBB_MINGW_BINUTILS_FOLDER_NAME}/configure" --help

    bash "${XBB_BUILD_FOLDER}/${XBB_MINGW_BINUTILS_FOLDER_NAME}/configure" \
      --prefix="${XBB_FOLDER}" \
      --with-sysroot="${XBB_FOLDER}" \
      --build="${BUILD}" \
      --target=${MINGW_TARGET} \
      --disable-shared \
      --enable-static \
      --disable-multilib \
      --enable-lto \
      --enable-plugins \
      --disable-nls \
      --disable-werror

    make -j${MAKE_CONCURRENCY}
    make install-strip
  )

  (
    xbb_activate

    "${XBB_FOLDER}/bin/${UNAME_ARCH}-w64-mingw32-size" --version
  )

  hash -r
}

function do_mingw_all() 
{
  # http://mingw-w64.org/doku.php/start
  # https://sourceforge.net/projects/mingw-w64/files/mingw-w64/mingw-w64-release/

  # 2018-06-03
  XBB_MINGW_VERSION="5.0.4"

  # The original SourceForge location.
  XBB_MINGW_FOLDER_NAME="mingw-w64-v${XBB_MINGW_VERSION}"
  XBB_MINGW_ARCHIVE="${XBB_MINGW_FOLDER_NAME}.tar.bz2"
  # XBB_MINGW_URL="https://sourceforge.net/projects/mingw-w64/files/mingw-w64/mingw-w64-release/${XBB_MINGW_ARCHIVE}"
  XBB_MINGW_URL="https://github.com/gnu-mcu-eclipse/files/raw/master/libs/${XBB_MINGW_ARCHIVE}"
  
  # If SourceForge is down, there is also a GitHub mirror.
  # https://github.com/mirror/mingw-w64
  # XBB_MINGW_FOLDER_NAME="mingw-w64-${XBB_MINGW_VERSION}"
  # XBB_MINGW_ARCHIVE="v${XBB_MINGW_VERSION}.tar.gz"
  # XBB_MINGW_URL="https://github.com/mirror/mingw-w64/archive/${XBB_MINGW_ARCHIVE}"
 
  # https://sourceforge.net/p/mingw-w64/wiki2/Cross%20Win32%20and%20Win64%20compiler/
  # https://sourceforge.net/p/mingw-w64/mingw-w64/ci/master/tree/configure

  echo
  echo "Building mingw-w64 headers ${XBB_MINGW_VERSION}..."

  cd "${XBB_BUILD_FOLDER}"

  download_and_extract "${XBB_MINGW_ARCHIVE}" "${XBB_MINGW_URL}"

  (
    mkdir -p "${XBB_BUILD_FOLDER}/${XBB_MINGW_FOLDER_NAME}-headers-build"
    cd "${XBB_BUILD_FOLDER}/${XBB_MINGW_FOLDER_NAME}-headers-build"

    xbb_activate_dev

    export PATH="${XBB_FOLDER}/bin":${PATH}
    # export LDFLAGS="-static-libstdc++ ${LDFLAGS}"

    "${XBB_BUILD_FOLDER}/${XBB_MINGW_FOLDER_NAME}/mingw-w64-headers/configure" --help
    
    "${XBB_BUILD_FOLDER}/${XBB_MINGW_FOLDER_NAME}/mingw-w64-headers/configure" \
      --prefix="${XBB_FOLDER}/${MINGW_TARGET}" \
      --build="${BUILD}" \
      --host="${MINGW_TARGET}"

    make -j${MAKE_CONCURRENCY}
    make install-strip

    # GCC requires the `x86_64-w64-mingw32` folder be mirrored as `mingw` 
    # in the same root. 
    (cd "${XBB_FOLDER}"; ln -s "${MINGW_TARGET}" "mingw")

    # For non-multilib builds, links to "lib32" and "lib64" are no longer 
    # needed, "lib" is enough.
  )

  hash -r

  # https://gcc.gnu.org
  # https://gcc.gnu.org/wiki/InstallingGCC
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-gcc

  # https://ftp.gnu.org/gnu/gcc/
  # 2018-12-06
  XBB_MINGW_VERSION="7.4.0"

  XBB_MINGW_GCC_FOLDER_NAME="gcc-${XBB_MINGW_VERSION}"
  XBB_MINGW_GCC_ARCHIVE="${XBB_MINGW_GCC_FOLDER_NAME}.tar.xz"
  XBB_MINGW_GCC_URL="https://ftp.gnu.org/gnu/gcc/gcc-${XBB_MINGW_VERSION}/${XBB_MINGW_GCC_ARCHIVE}"
  XBB_MINGW_GCC_BRANDING="xPack Build Box Mingw-w64 GCC\x2C ${BITS}-bit"

  echo
  echo "Building mingw-w64 gcc ${XBB_MINGW_VERSION}, step 1..."

  cd "${XBB_BUILD_FOLDER}"

  download_and_extract "${XBB_MINGW_GCC_ARCHIVE}" "${XBB_MINGW_GCC_URL}"

  (
    mkdir -p "${XBB_BUILD_FOLDER}/${XBB_MINGW_GCC_FOLDER_NAME}-mingw-build"
    cd "${XBB_BUILD_FOLDER}/${XBB_MINGW_GCC_FOLDER_NAME}-mingw-build"

    xbb_activate_dev

    export CFLAGS="${CFLAGS} -Wno-sign-compare -Wno-implicit-function-declaration -Wno-missing-prototypes"
    export CXXFLAGS="${CXXFLAGS} -Wno-sign-compare -Wno-type-limits"
    # export LDFLAGS="-static-libstdc++ ${LDFLAGS}"

    # For the native build, --disable-shared failed with errors in libstdc++-v3
    "${XBB_BUILD_FOLDER}/${XBB_MINGW_GCC_FOLDER_NAME}/configure" --help

    "${XBB_BUILD_FOLDER}/${XBB_MINGW_GCC_FOLDER_NAME}/configure" \
      --prefix="${XBB_FOLDER}" \
      --with-sysroot="${XBB_FOLDER}" \
      --build="${BUILD}" \
      --target=${MINGW_TARGET} \
      --with-pkgversion="${XBB_MINGW_GCC_BRANDING}" \
      --enable-languages=c,c++ \
      --enable-shared \
      --enable-static \
      --enable-threads=posix \
      --enable-fully-dynamic-string \
      --enable-libstdcxx-time=yes \
      --with-system-zlib \
      --enable-cloog-backend=isl \
      --enable-lto \
      --disable-dw2-exceptions \
      --enable-libgomp \
      --disable-multilib \
      --enable-checking=release

    make all-gcc -j${MAKE_CONCURRENCY}
    make install-gcc
  )

  hash -r

  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-crt-git

  echo
  echo "Building mingw-w64 crt ${XBB_MINGW_VERSION}..."

  cd "${XBB_BUILD_FOLDER}"

  download_and_extract "${XBB_MINGW_ARCHIVE}" "${XBB_MINGW_URL}"

  (
    mkdir -p "${XBB_BUILD_FOLDER}/${XBB_MINGW_FOLDER_NAME}-crt-build"
    cd "${XBB_BUILD_FOLDER}/${XBB_MINGW_FOLDER_NAME}-crt-build"

    xbb_activate_dev

    # Overwrite the flags, -ffunction-sections -fdata-sections result in
    # {standard input}: Assembler messages:
    # {standard input}:693: Error: CFI instruction used without previous .cfi_startproc
    # {standard input}:695: Error: .cfi_endproc without corresponding .cfi_startproc
    # {standard input}:697: Error: .seh_endproc used in segment '.text' instead of expected '.text$WinMainCRTStartup'
    # {standard input}: Error: open CFI at the end of file; missing .cfi_endproc directive
    # {standard input}:7150: Error: can't resolve `.text' {.text section} - `.LFB5156' {.text$WinMainCRTStartup section}
    # {standard input}:8937: Error: can't resolve `.text' {.text section} - `.LFB5156' {.text$WinMainCRTStartup section}

    export CFLAGS="-g -O2 -pipe -Wno-unused-variable -Wno-implicit-fallthrough -Wno-implicit-function-declaration -Wno-cpp"
    export CXXFLAGS="-g -O2 -pipe"
    export LDFLAGS=""
    
    # Without it, apparently a bug in autoconf/c.m4, function AC_PROG_CC, results in:
    # checking for _mingw_mac.h... no
    # configure: error: Please check if the mingw-w64 header set and the build/host option are set properly.
    # (https://github.com/henry0312/build_gcc/issues/1)
    export CC=""

    "${XBB_BUILD_FOLDER}/${XBB_MINGW_FOLDER_NAME}/mingw-w64-crt/configure" --help
    if [ "${BITS}" == "64" ]
    then
      _crt_configure_lib32="--disable-lib32"
      _crt_configure_lib64="--enable-lib64"
    elif [ "${BITS}" == "32" ]
    then
      _crt_configure_lib32="--enable-lib32"
      _crt_configure_lib64="--disable-lib64"
    else
      exit 1
    fi

    "${XBB_BUILD_FOLDER}/${XBB_MINGW_FOLDER_NAME}/mingw-w64-crt/configure" \
      --prefix="${XBB_FOLDER}/${MINGW_TARGET}" \
      --with-sysroot="${XBB_FOLDER}" \
      --build="${BUILD}" \
      --host="${MINGW_TARGET}" \
      --enable-wildcard \
      ${_crt_configure_lib32} \
      ${_crt_configure_lib64}

    make -j${MAKE_CONCURRENCY}
    make install-strip

    ls -l "${XBB_FOLDER}" "${XBB_FOLDER}/${MINGW_TARGET}"
  )

  hash -r

  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-winpthreads-git

  echo
  echo "Building mingw-w64 winpthreads ${XBB_MINGW_VERSION}..."

  cd "${XBB_BUILD_FOLDER}"

  download_and_extract "${XBB_MINGW_ARCHIVE}" "${XBB_MINGW_URL}"

  (
    mkdir -p "${XBB_BUILD_FOLDER}/${XBB_MINGW_FOLDER_NAME}-winphreads-build"
    cd "${XBB_BUILD_FOLDER}/${XBB_MINGW_FOLDER_NAME}-winphreads-build"

    xbb_activate_dev

    export CFLAGS="-g -O2 -pipe"
    export CXXFLAGS="-g -O2 -pipe"
    export LDFLAGS=""
    
    export CC=""

    bash "${XBB_BUILD_FOLDER}/${XBB_MINGW_FOLDER_NAME}/mingw-w64-crt/configure" --help
    if [ "${BITS}" == "64" ]
    then
      _crt_configure_lib32="--disable-lib32"
      _crt_configure_lib64="--enable-lib64"
    elif [ "${BITS}" == "32" ]
    then
      _crt_configure_lib32="--enable-lib32"
      _crt_configure_lib64="--disable-lib64"
    else
      exit 1
    fi

    bash "${XBB_BUILD_FOLDER}/${XBB_MINGW_FOLDER_NAME}/mingw-w64-libraries/winpthreads/configure" \
      --prefix="${XBB_FOLDER}/${MINGW_TARGET}" \
      --build="${BUILD}" \
      --host="${MINGW_TARGET}" \
      --enable-static \
      --enable-shared

    make -j${MAKE_CONCURRENCY}
    make install-strip

    ls -l "${XBB_FOLDER}" "${XBB_FOLDER}/${MINGW_TARGET}"
  )

  hash -r

  echo
  echo "Building mingw-w64 gcc ${XBB_MINGW_VERSION}, step 2..."

  cd "${XBB_BUILD_FOLDER}"

  # download_and_extract "${XBB_MINGW_GCC_ARCHIVE}" "${XBB_MINGW_GCC_URL}"

  (
    mkdir -p "${XBB_BUILD_FOLDER}/${XBB_MINGW_GCC_FOLDER_NAME}-mingw-build"
    cd "${XBB_BUILD_FOLDER}/${XBB_MINGW_GCC_FOLDER_NAME}-mingw-build"

    xbb_activate_dev

    export CFLAGS="${CFLAGS} -Wno-sign-compare -Wno-implicit-function-declaration -Wno-missing-prototypes"
    export CXXFLAGS="${CXXFLAGS} -Wno-sign-compare -Wno-type-limits"

    make -j${MAKE_CONCURRENCY}
    make install-strip
  )

  (
    cd "${XBB_FOLDER}"

    xbb_activate

    if true
    then

      set +e
      find ${MINGW_TARGET} \
        -name '*.so' -type f \
        -print \
        -exec "${XBB_FOLDER}/bin/${UNAME_ARCH}-w64-mingw32-strip" --strip-debug {} \;
      find ${MINGW_TARGET} \
        -name '*.so.*'  \
        -type f \
        -print \
        -exec "${XBB_FOLDER}/bin/${UNAME_ARCH}-w64-mingw32-strip" --strip-debug {} \;
      # Note: without ranlib, windows builds failed.
      find ${MINGW_TARGET} lib/gcc/${MINGW_TARGET} \
        -name '*.a'  \
        -type f  \
        -print \
        -exec "${XBB_FOLDER}/bin/${UNAME_ARCH}-w64-mingw32-strip" --strip-debug {} \; \
        -exec "${XBB_FOLDER}/bin/${UNAME_ARCH}-w64-mingw32-ranlib" {} \;
      set -e
    
    fi
  )

  (
    xbb_activate

    "${XBB_FOLDER}/bin/${UNAME_ARCH}-w64-mingw32-g++" --version

    mkdir -p "${HOME}/tmp"
    cd "${HOME}/tmp"

    # Note: __EOF__ is quoted to prevent substitutions here.
    cat <<'__EOF__' > hello.cpp
#include <iostream>

int
main(int argc, char* argv[])
{
  std::cout << "Hello" << std::endl;
}
__EOF__

    "${XBB_FOLDER}/bin/${UNAME_ARCH}-w64-mingw32-g++" hello.cpp -o hello

    rm -rf hello.cpp hello
  )

  hash -r
}

# -----------------------------------------------------------------------------

function do_libpng()
{
  # To ensure builds stability, use slightly older releases.
  # https://sourceforge.net/projects/libpng/files/libpng16/
  # https://sourceforge.net/projects/libpng/files/libpng16/older-releases/

  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=libpng-git
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-libpng

  # LIBPNG_VERSION="1.2.53"
  # LIBPNG_VERSION="1.6.17"
  # LIBPNG_VERSION="1.6.23" # 2016-06-09
  # LIBPNG_VERSION="1.6.36" # 2018-12-01
  # LIBPNG_SFOLDER="libpng12"
  # LIBPNG_SFOLDER="libpng16"

  # 2017-09-16
  XBB_LIBPNG_VERSION="1.6.36" # 2018-12-01
  XBB_LIBPNG_SFOLDER="libpng16" 

  XBB_LIBPNG_FOLDER_NAME="libpng-${XBB_LIBPNG_VERSION}"
  XBB_LIBPNG_ARCHIVE="${XBB_LIBPNG_FOLDER_NAME}.tar.xz"
   # XBB_LIBPNG_URL="https://sourceforge.net/projects/libpng/files/${XBB_LIBPNG_SFOLDER}/${XBB_LIBPNG_VERSION}/${XBB_LIBPNG_ARCHIVE}"
  XBB_LIBPNG_URL="https://github.com/gnu-mcu-eclipse/files/raw/master/libs/${XBB_LIBPNG_ARCHIVE}"

  echo
  echo "Installing libpng ${XBB_LIBPNG_VERSION}..."

  cd "${XBB_BUILD_FOLDER}"

  download_and_extract "${XBB_LIBPNG_ARCHIVE}" "${XBB_LIBPNG_URL}"

  (
    cd "${XBB_BUILD_FOLDER}/${XBB_LIBPNG_FOLDER_NAME}"

    xbb_activate_dev

    bash ./configure --help

    bash ./configure \
      --prefix="${XBB_FOLDER}"
    
    make -j${MAKE_CONCURRENCY}
    make install-strip
  )
}

function do_wine()
{
  # https://www.winehq.org
  # https://dl.winehq.org/wine/source/4.x/wine-4.3.tar.xz

  # 2017-09-16
  XBB_WINE_VERSION_MAJOR="4"
  XBB_WINE_VERSION_MINOR="3"
  XBB_WINE_VERSION="${XBB_WINE_VERSION_MAJOR}.${XBB_WINE_VERSION_MINOR}"

  XBB_WINE_FOLDER_NAME="wine-${XBB_WINE_VERSION}"
  XBB_WINE_ARCHIVE="${XBB_WINE_FOLDER_NAME}.tar.xz"
  XBB_WINE_URL="https://dl.winehq.org/wine/source/${XBB_WINE_VERSION_MAJOR}.x/${XBB_WINE_ARCHIVE}"

  echo
  echo "Installing wine ${XBB_WINE_VERSION}..."

  cd "${XBB_BUILD_FOLDER}"

  download_and_extract "${XBB_WINE_ARCHIVE}" "${XBB_WINE_URL}"

  (
    cd "${XBB_BUILD_FOLDER}/${XBB_WINE_FOLDER_NAME}"

    xbb_activate_dev

    bash ./configure --help

    if [ "${BITS}" == "64" ]
    then
      ENABLE_64="--enable-win64"
    else
      ENABLE_64=""
    fi

    bash ./configure \
      --prefix="${XBB_FOLDER}" \
      \
      ${ENABLE_64} \
      --disable-win16 \
      --disable-tests \
      \
      --without-freetype \
      --without-x \
      --with-png
    
    make -j${MAKE_CONCURRENCY} STRIP=true
    make install

    if [ "${BITS}" == "64" ]
    then
      (cd "${XBB_FOLDER}/bin"; ln -s wine64 wine)
    fi
  )

  (
    xbb_activate

    # First check if the program is able to tell its version.
    "${XBB_FOLDER}/bin/wine" --version

    # This test should check if the program is able to start
    # a simple executable.
    # As a side effect, the "${HOME}/.wine" folder is created
    # and populated with lots of files., so subsequent runs
    # will no longer have to do it.
    "${XBB_FOLDER}/bin/wine" "${XBB_FOLDER}/lib/wine/fakedlls/netstat.exe"
  )

  hash -r
}

# -----------------------------------------------------------------------------

function do_ninja()
{
  # https://ninja-build.org
  # https://github.com/ninja-build/ninja/archive/v1.9.0.zip
  # https://github.com/ninja-build/ninja/archive/v1.9.0.tar.gz

  XBB_NINJA_VERSION="1.9.0"

  XBB_NINJA_FOLDER_NAME="ninja-${XBB_NINJA_VERSION}"
  XBB_NINJA_ARCHIVE="v${XBB_NINJA_VERSION}.tar.gz"
  XBB_NINJA_URL="https://github.com/ninja-build/ninja/archive/${XBB_NINJA_ARCHIVE}"

  echo
  echo "Installing ninja ${XBB_NINJA_VERSION}..."

  cd "${XBB_BUILD_FOLDER}"

  download_and_extract "${XBB_NINJA_ARCHIVE}" "${XBB_NINJA_URL}"

  (
    cd "${XBB_BUILD_FOLDER}/${XBB_NINJA_FOLDER_NAME}"

    xbb_activate_dev

    ./configure.py --help

    ./configure.py \
      --bootstrap \
      --verbose \
      --with-python=python2 \
      --platform=linux \

    install -m755 -t "${XBB_FOLDER}/bin" ninja
  )

  (
    xbb_activate

    "${XBB_FOLDER}/bin/ninja" --version
  )

  hash -r
}

# -----------------------------------------------------------------------------

function do_meson
{
  (
    xbb_activate

    pip3 install meson

    "${XBB_FOLDER}/bin/meson" --version
  )

  hash -r
}

# -----------------------------------------------------------------------------

(
  xbb_activate
  
  echo 
  echo "xbb_activate"
  echo ${PATH}
  echo ${LD_LIBRARY_PATH}

  echo
  ${CXX} --version
  ${MINGW_TARGET}-g++ --version
)

(
  xbb_activate_dev
  
  echo 
  echo "xbb_activate_dev"
  env

  echo
  ${CXX} --version
  ${MINGW_TARGET}-g++ --version
)

# Needed by QEMU.
# yum provides '*/X11/extensions/Xext.h'
# yum provides '*/GL/gl.h'
yum install -y libX11-devel libXext-devel mesa-libGL-devel

do_coreutils

do_ninja

if true
then
  do_python3
  do_meson
fi

if true
then
  do_native_binutils
  do_native_gcc
fi

if true
then
  do_mingw_binutils
  do_mingw_all
fi

# Lengthy...
if true
then
  do_libpng
  do_wine
fi

# -----------------------------------------------------------------------------

if true
then
  do_strip_libs

  do_cleaunup
fi

