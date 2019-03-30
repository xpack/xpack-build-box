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

# This script installs a set of Homebrew tools to bootstrap the
# macOS XBB (xPack Build Box).
# Basically it tries to be similar to the Docker images.

# -----------------------------------------------------------------------------

VERSION="$(cat "${script_folder_path}"/VERSION)"
echo
echo "macOS XBB Bootstrap v${VERSION} script started..."

# -----------------------------------------------------------------------------

XBB_FOLDER="${HOME}/opt/xbb-bootstrap"

DOWNLOAD_FOLDER_PATH="${HOME}/Library/Caches/XBB"
WORK_FOLDER_PATH="${HOME}/Work/darwin-$(basename "${XBB_FOLDER}")"

BUILD_FOLDER_PATH="${WORK_FOLDER_PATH}/build"
LIBS_BUILD_FOLDER_PATH="${WORK_FOLDER_PATH}/build/libs"
SOURCES_FOLDER_PATH="${WORK_FOLDER_PATH}/sources"
STAMPS_FOLDER_PATH="${WORK_FOLDER_PATH}/stamps"
LOGS_FOLDER_PATH="${WORK_FOLDER_PATH}/logs"

INSTALL_FOLDER_PATH="${XBB_FOLDER}"

JOBS=${JOBS:-""}
IS_BOOTSTRAP="y"

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

export CC=clang
export CXX=clang++

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

install -m 755 -c "$(dirname "${script_folder_path}")/scripts/pkg-config-verbose" "${INSTALL_FOLDER_PATH}/bin" 

export PKG_CONFIG="${INSTALL_FOLDER_PATH}/bin/pkg-config-verbose"

# -----------------------------------------------------------------------------

# To differentiate the binaries from the XBB ones which use `-7`.
GCC_SUFFIX="-7bs"

# =============================================================================

# Libraries

do_zlib "1.2.11"

do_gmp "6.1.2"
do_mpfr "3.1.6"
do_mpc "1.0.3"
do_isl "0.21"

# Applications

do_coreutils "8.31"

do_pkg_config "0.29.2"

do_m4 "1.4.18"

do_gawk "4.2.1"
do_sed "4.7"
do_autoconf "2.69"
do_automake "1.16"
do_libtool "2.4.6"

do_diffutils "3.7"
do_patch "2.7.6"

do_bison "3.3.2"

# Apple uses 2.5.3, an update is not mandatory.
# do_flex "2.6.4"

do_make "4.2.1"

# Apple uses 5.18.2, an update is not mandatory.
# do_perl "5.28.1"

do_cmake "3.13.4"

# makedepend is needed by openssl
do_util_macros "1.17.1"
do_xorg_xproto "7.0.31"
do_makedepend "1.0.5"

# By all means DO NOT build binutils, since this will override Apple 
# specific tools (ar, strip, etc) and break the build in multiple ways.

# Preferably leave it to the end, to benefit from all the goodies 
# compiled so far.
do_gcc "7.4.0"

# -----------------------------------------------------------------------------

check_binaries

# -----------------------------------------------------------------------------

echo
echo "macOS version ${macos_version}"
echo "Xcode version ${xcode_version}"
echo "XCode Command Line Tools version ${xclt_version}"

echo
echo "You may want to 'chmod -R -w \"${INSTALL_FOLDER_PATH}\"'"

echo
echo "macOS XBB Bootstrap v${VERSION} created in \"${INSTALL_FOLDER_PATH}\""
say done

# -----------------------------------------------------------------------------
