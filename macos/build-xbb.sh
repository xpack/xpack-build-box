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

# Script to build a separate macOS XBB.
# Basically it tries to be similar to the Docker images.

# -----------------------------------------------------------------------------

XBB_VERSION="2.1"
echo
echo "macOS XBB v${XBB_VERSION} build script started..."

# -----------------------------------------------------------------------------

XBB_FOLDER="${HOME}/opt/xbb"
XBB_BOOTSTRAP_FOLDER="${HOME}/opt/xbb-bootstrap"

WORK_FOLDER_PATH="${HOME}/Work/darwin-$(basename "${XBB_FOLDER}")"

IS_BOOTSTRAP="n"

# -----------------------------------------------------------------------------

if [ ! -d "${XBB_BOOTSTRAP_FOLDER}" -o ! -x "${XBB_BOOTSTRAP_FOLDER}/bin/g++-7bs" ]
then
  echo "macOS XBB Bootstrap not found in \"${XBB_BOOTSTRAP_FOLDER}\""
  echo "https://github.com/xpack/xpack-build-box/tree/master/macos"
  exit 1
fi

# -----------------------------------------------------------------------------

source "${script_folder_path}/common-functions-source.sh"
source "${script_folder_path}/common-libs-functions-source.sh"
source "${script_folder_path}/common-apps-functions-source.sh"

# Build the XBB tools with the bootstrap compiler.
# Some packages fail, and have to revert to the Apple clang.
CC="gcc-7bs"
CXX="g++-7bs"

prepare_xbb_env

source "${XBB_BOOTSTRAP_FOLDER}/xbb-source.sh"

create_xbb_source

xbb_activate()
{
  xbb_activate_bootstrap
}

# -----------------------------------------------------------------------------

XBB_GCC_SUFFIX="-7"
XBB_GCC_BRANDING="xPack Build Box GCC\x2C 64-bit"

# =============================================================================

# Libraries

do_zlib "1.2.11"

do_gmp "6.1.2"
do_mpfr "3.1.6"
do_mpc "1.0.3"
do_isl "0.21"

do_nettle "3.4.1"
do_tasn1 "4.13"
do_expat "2.2.6"
do_libffi "3.2.1"

do_libiconv "1.15"

do_gnutls "3.6.7"

# Both libs and apps.
do_xz "5.2.4"

do_openssl "1.0.2r" # "1.1.1b"


# Applications

# By all means DO NOT build binutils, since this will override Apple 
# specific tools (ar, strip, etc) and break the build in multiple ways.

do_gcc "7.4.0"

do_curl "7.64.1"

do_tar "1.32"

do_coreutils "8.31"

do_pkg_config "0.29.2"

do_gawk "4.2.1"
do_sed "4.7"
do_autoconf "2.69"
do_automake "1.16"
do_libtool "2.4.6"

do_m4 "1.4.18"

do_gettext "0.19.8"

do_diffutils "3.7"
do_patch "2.7.6"

do_bison "3.3.2"

do_make "4.2.1"

do_wget "1.20.1"

do_texinfo "6.6"
do_patchelf "0.10"
do_dos2unix "7.4.0"

# macOS 10.10 uses 2.5.3, an update is not mandatory.
# do_flex "2.6.4"

# macOS 10.10 uses 5.18.2, an update is not mandatory.
# do_perl "5.28.1"

do_cmake "3.13.4"
do_ninja "1.9.0"

do_python "2.7.16"

# require xz, openssl
do_python3 "3.7.3"
do_meson "0.50.0"

do_scons "3.0.5"

do_git "2.21.0"

do_p7zip "16.02"

# -----------------------------------------------------------------------------


echo
echo "macOS version ${macos_version}"
echo "XCode Command Line Tools version ${xclt_version}"

echo
echo "You may want to ' chmod -R -w \"${INSTALL_FOLDER_PATH}\" '"

echo
echo "macOS XBB v${XBB_VERSION} created in \"${INSTALL_FOLDER_PATH}\""
say done

# -----------------------------------------------------------------------------
