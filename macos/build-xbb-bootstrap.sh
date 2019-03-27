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
  set ${DEBUG} # Activate the expand mode if DEBUG is anything but empty.
else
  DEBUG=""
fi

set -o errexit # Exit if command failed.
set -o pipefail # Exit if pipe failed.
set -o nounset # Exit if variable not set.

# Remove the initial space and instead use '\n'.
IFS=$'\n\t'

# -----------------------------------------------------------------------------
# Identify the script location, to reach, for example, the helper scripts.

build_script_path="$0"
if [[ "${build_script_path}" != /* ]]
then
  # Make relative path absolute.
  build_script_path="$(pwd)/$0"
fi

script_folder_path="$(dirname "${build_script_path}")"
script_folder_name="$(basename "${script_folder_path}")"

# =============================================================================

# WARNING: NOT YET fUNCTIONAL!

# This script installs a set of Homebrew tools to bootstrap the
# macOS XBB (xPack Build Box).
# Basically it tries to be similar to the Docker images.

# -----------------------------------------------------------------------------

XBB_FOLDER="${HOME}/opt/xbb-bootstrap"

DOWNLOAD_FOLDER_PATH="${HOME}/Library/Caches/XBB"
WORK_FOLDER_PATH="${HOME}/Work/darwin-$(basename "${XBB_FOLDER}")"

BUILD_FOLDER_PATH="${WORK_FOLDER_PATH}/build"
LIBS_BUILD_FOLDER_PATH="${WORK_FOLDER_PATH}/build/libs"
SOURCES_FOLDER_PATH="${WORK_FOLDER_PATH}/sources"
STAMPS_FOLDER_PATH="${WORK_FOLDER_PATH}/stamps"
LOGS_FOLDER_PATH="${WORK_FOLDER_PATH}/logs"

if true
then
  INSTALL_FOLDER_PATH="${XBB_FOLDER}"
else
  INSTALL_FOLDER_PATH="${WORK_FOLDER_PATH}/install"
fi

JOBS=-j2

# -----------------------------------------------------------------------------

mkdir -p "${XBB_FOLDER}"

mkdir -p "${DOWNLOAD_FOLDER_PATH}"
mkdir -p "${BUILD_FOLDER_PATH}"
mkdir -p "${LIBS_BUILD_FOLDER_PATH}"
mkdir -p "${SOURCES_FOLDER_PATH}"
mkdir -p "${STAMPS_FOLDER_PATH}"
mkdir -p "${LOGS_FOLDER_PATH}"

export SHELL="/bin/bash"
export CONFIG_SHELL="/bin/bash"

export CC=gcc
export CXX=g++

# -----------------------------------------------------------------------------

XBB_CPPFLAGS=""

XBB_CFLAGS="-pipe"
XBB_CXXFLAGS="-pipe"

XBB_LDFLAGS=""
XBB_LDFLAGS_LIB="${XBB_LDFLAGS}"
XBB_LDFLAGS_APP="${XBB_LDFLAGS}"

PATH=${PATH:-""}
export PATH

PKG_CONFIG_PATH=${PKG_CONFIG_PATH:-":"}
export PKG_CONFIG_PATH

# Prevent pkg-config to search the system folders (configured in the
# pkg-config at build time).
PKG_CONFIG_LIBDIR=${PKG_CONFIG_LIBDIR:-":"}
export PKG_CONFIG_LIBDIR

xbb_activate()
{
  PATH=${PATH:-""}
  PATH="${INSTALL_FOLDER_PATH}/bin:${PATH}"
  export PATH
}

xbb_activate_this()
{
  xbb_activate

  XBB_CPPFLAGS="-I${INSTALL_FOLDER_PATH}/include ${XBB_CPPFLAGS}"
  
  XBB_LDFLAGS_LIB="-L${INSTALL_FOLDER_PATH}/lib ${XBB_LDFLAGS_LIB}"
  XBB_LDFLAGS_APP="-L${INSTALL_FOLDER_PATH}/lib ${XBB_LDFLAGS_APP}"

  PKG_CONFIG_PATH=${PKG_CONFIG_PATH:=""}
  PKG_CONFIG_PATH="${INSTALL_FOLDER_PATH}/lib/pkgconfig:${PKG_CONFIG_PATH}"
}

# -----------------------------------------------------------------------------

macos_version=$(defaults read loginwindow SystemVersionStampAsString)
xcode_version=$(xcodebuild -version | grep Xcode | sed -e 's/Xcode //')
xclt_version=$(xcode-select --version | sed -e 's/xcode-select version \([0-9]*\)\./\1/')

# -----------------------------------------------------------------------------

source "${script_folder_path}/common-functions-source.sh"
source "${script_folder_path}/common-libs-functions-source.sh"
source "${script_folder_path}/common-apps-functions-source.sh"

create_pkg_config_verbose

export PKG_CONFIG="${INSTALL_FOLDER_PATH}/bin/pkg-config-verbose"

# -----------------------------------------------------------------------------

# To differentiate the binaries from the XBB ones which use `-7`.
GCC_SUFFIX="-7bs"

function do_gcc() 
{
  # https://gcc.gnu.org
  # https://ftp.gnu.org/gnu/gcc/
  # https://gcc.gnu.org/wiki/InstallingGCC
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=gcc-git

  # 2018-12-06
  local gcc_version="7.4.0"

  local gcc_folder_name="gcc-${gcc_version}"
  local gcc_archive="${gcc_folder_name}.tar.xz"
  local gcc_url="https://ftp.gnu.org/gnu/gcc/gcc-${gcc_version}/${gcc_archive}"
  local gcc_branding="xPack Build Box Bootstrap GCC\x2C 64-bit"

  local gcc_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-gcc-${gcc_version}-installed"
  if [ ! -f "${gcc_stamp_file_path}" -o ! -d "${BUILD_FOLDER_PATH}/${gcc_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${gcc_url}" "${gcc_archive}" "${gcc_folder_name}" 

    (
      mkdir -p "${BUILD_FOLDER_PATH}/${gcc_folder_name}"
      cd "${BUILD_FOLDER_PATH}/${gcc_folder_name}"

      xbb_activate_this

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS} -Wno-sign-compare -Wno-varargs -Wno-tautological-compare  "
      export CXXFLAGS="${XBB_CXXFLAGS} -Wno-sign-compare -Wno-varargs -Wno-tautological-compare"
      export LDFLAGS="${XBB_LDFLAGS_APP}"

      local sdk_path
      if [ "${xcode_version}" == "7.2.1" ]
      then
        # macOS 10.10
        sdk_path="$(xcode-select -print-path)/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk"
      elif [ "${xcode_version}" == "10.1" ]
      then
        # macOS 10.13
        sdk_path="$(xcode-select -print-path)/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
      else
        echo "Unsupported Xcode ${xcode_version}; edit the script to add new versions."
        exit 1
      fi

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running gcc configure..."

          bash "${SOURCES_FOLDER_PATH}/${gcc_folder_name}/configure" --help

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${gcc_folder_name}/configure" \
            --prefix="${INSTALL_FOLDER_PATH}" \
            --program-suffix="${GCC_SUFFIX}" \
            --with-pkgversion="${gcc_branding}" \
            --with-native-system-header-dir="/usr/include" \
            --with-sysroot="${sdk_path}" \
            \
            --enable-languages=c,c++ \
            --enable-checking=release \
            --enable-static \
            --enable-threads=posix \
            \
            --disable-multilib \
            --disable-werror \
            --disable-bootstrap \
            --disable-libssp \
            \
            --with-gmp="${INSTALL_FOLDER_PATH}" \
            --with-mpfr="${INSTALL_FOLDER_PATH}" \
            --with-mpc="${INSTALL_FOLDER_PATH}" \
            --with-isl="${INSTALL_FOLDER_PATH}" \

          cp "config.log" "${LOGS_FOLDER_PATH}/config-gcc-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-gcc-output.txt"
      fi

      (
        echo
        echo "Running gcc make..."

        # Build.
        make ${JOBS}
        make install-strip
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-gcc-output.txt"
    )

    (
      echo
      "${INSTALL_FOLDER_PATH}/bin/g++${GCC_SUFFIX}" --version
      "${INSTALL_FOLDER_PATH}/bin/g++${GCC_SUFFIX}" -dumpmachine
      "${INSTALL_FOLDER_PATH}/bin/g++${GCC_SUFFIX}" -dumpspecs | wc -l

      mkdir -p "${HOME}"/tmp
      cd "${HOME}"/tmp

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

        "${INSTALL_FOLDER_PATH}/bin/g++${GCC_SUFFIX}" hello.cpp -o hello

        if [ "x$(./hello)x" != "xHellox" ]
        then
          exit 1
        fi

      fi

      rm -rf hello.cpp hello
    )

    hash -r

    touch "${gcc_stamp_file_path}"

  else
    echo "Component gcc already installed."
  fi
}

# =============================================================================

if true
then

  # New zlib, used in most of the tools.
  do_zlib

  do_coreutils

  do_pkg_config

  do_m4

  do_gawk
  do_sed
  do_autoconf
  do_automake
  do_libtool
  do_make

  do_diffutils
  do_patch

  do_bison

  do_cmake
fi

do_gmp
do_mpfr
do_mpc
do_isl

# By all means DO NOT build binutils, since this will override Apple 
# specific tools (ar, strip, etc) and break the build in multiple ways.
# do_binutils

# TODO: /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk for 10.10!
do_gcc

# -----------------------------------------------------------------------------

check_binaries

# -----------------------------------------------------------------------------

echo
echo "macOS version ${macos_version}"
echo "Xcode version ${xcode_version}"
echo "XCode Command Line Tools version ${xclt_version}"

echo
echo "You may want to 'chmod -R -w "${INSTALL_FOLDER_PATH}"'"

echo
echo Done
say done

# -----------------------------------------------------------------------------
