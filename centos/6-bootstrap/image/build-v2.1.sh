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

# Script to build a Docker image with a bootstrap system, used to later build  
# the final xPack Build Box (xbb).
#
# Since the orginal CentOS 6 is too old to compile some of the modern
# sources, two steps are required. In the first step are compiled the most
# recent versions allowed by CentOS 6; being based on GCC 7.4, they should 
# be enough for a few years to come. With them, in the second step, are 
# compiled the very latest versions.

# Credits: Inspired by Holy Build Box build script.

# Note: the initial approach was to disable the creation of all shared 
# libraries and try to build everything as static. Unfortunately some
# of the tools are not able to do this correctly, and the final version
# was simplified to the defaults, which generally include both shared and
# static versions for the libraries. The drawback is that, in addition to 
# PATH, for the programs to start, the LD_LIBRARY_PATH must also be set 
# correctly.

XBB_VERSION="2.1"
XBB_INPUT_FOLDER="/xbb-input"

XBB_DOWNLOAD_FOLDER="/tmp/xbb-download"
XBB_TMP_FOLDER="/tmp/xbb"

XBB_FOLDER="/opt/xbb-bootstrap"
XBB_BUILD_FOLDER="${XBB_TMP_FOLDER}"/bootstrap-build

JOBS=${JOBS:-""}

# -----------------------------------------------------------------------------

mkdir -p "${XBB_TMP_FOLDER}"
mkdir -p "${XBB_DOWNLOAD_FOLDER}"

mkdir -p "${XBB_FOLDER}"
mkdir -p "${XBB_BUILD_FOLDER}"

# -----------------------------------------------------------------------------

# x86_64 or i686 (warning -p deprecated)
UNAME_ARCH=$(uname -m)
if [ "${UNAME_ARCH}" == "x86_64" ]
then
  BITS="64"
  LIB_ARCH="lib64"
elif [ "${UNAME_ARCH}" == "i686" ]
then
  BITS="32"
  LIB_ARCH="lib"
fi

XBB_CPPFLAGS=""

XBB_CFLAGS="-O2 -ffunction-sections -fdata-sections -m${BITS} -pipe"
XBB_CXXFLAGS="-O2 -ffunction-sections -fdata-sections -m${BITS} -pipe"

XBB_LDFLAGS=""
XBB_LDFLAGS_LIB="${XBB_LDFLAGS}"
XBB_LDFLAGS_APP="${XBB_LDFLAGS} -Wl,--gc-sections"
XBB_LDFLAGS_APP_STATIC="${XBB_LDFLAGS_APP} -static -static-libgcc -static-libstdc++"

PKG_CONFIG_PATH=${PKG_CONFIG_PATH:-":"}

BUILD=${UNAME_ARCH}-linux-gnu
GCC_SUFFIX="-7bs"

# -----------------------------------------------------------------------------

# Make all tools choose gcc, not the old cc.
export CC="gcc"
export CXX="g++"

echo
g++ --version

# -----------------------------------------------------------------------------

echo "${XBB_VERSION}" > "${XBB_FOLDER}/VERSION"

# Note: __EOF__ is quoted to prevent substitutions here.
cat <<'__EOF__' > "${XBB_FOLDER}/xbb-source.sh"
# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (http://xpack.github.io)
# Copyright (c) 2019 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software 
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

export XBB_FOLDER="/opt/xbb-bootstrap"
__EOF__
# The above marker must start in the first column.

echo "export XBB_VERSION=\"${XBB_VERSION}\"" >> "${XBB_FOLDER}/xbb-source.sh"

# Note: __EOF__ is quoted to prevent substitutions here.
cat <<'__EOF__' >> "${XBB_FOLDER}/xbb-source.sh"

# Adjust PATH & LD_LIBRARY_PATH to prefer the XBB binaries.
# This is enough to run the XBB binaries in the application script.
# This **does not** provide access to the XBB libraries and headers,
# which normally are internal to XBB and should not be used.
xbb_activate()
{
  # Default PATH.
  PATH=${PATH:-""}

  # Add TeX to PATH.
  if [ -d "/opt/texlive/bin/x86_64-linux" ]
  then
    PATH="/opt/texlive/bin/x86_64-linux:${PATH}"
  elif [ -d "/opt/texlive/bin/i386-linux" ]
  then
    PATH="/opt/texlive/bin/i386-linux:${PATH}"
  fi

  # Add the XBB bin to PATH.
  PATH="${XBB_FOLDER}/bin:${PATH}"
  export PATH

  # Default LD_LIBRARY_PATH.
  LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-""}

  # Add XBB lib to LD_LIBRARY_PATH.
  LD_LIBRARY_PATH="${XBB_FOLDER}/lib:${LD_LIBRARY_PATH}"

  if [ -d "${XBB_FOLDER}/lib64" ]
  then
    # On 64-bit systems, add lib64 in front of LD_LIBRARY_PATH.
    LD_LIBRARY_PATH="${XBB_FOLDER}/lib64:${LD_LIBRARY_PATH}"
  fi
  export LD_LIBRARY_PATH
}
__EOF__
# The above marker must start in the first column.

source "${XBB_FOLDER}/xbb-source.sh"

function xbb_activate_dev()
{
  xbb_activate

  XBB_CPPFLAGS="-I${XBB_FOLDER}/include ${XBB_CPPFLAGS}"

  XBB_LDFLAGS="-L${XBB_FOLDER}/lib ${XBB_LDFLAGS}"
  XBB_LDFLAGS_LIB="-L${XBB_FOLDER}/lib ${XBB_LDFLAGS_LIB}"
  XBB_LDFLAGS_APP="-L${XBB_FOLDER}/lib ${XBB_LDFLAGS_APP}"
  XBB_LDFLAGS_APP_STATIC="-L${XBB_FOLDER}/lib ${XBB_LDFLAGS_APP_STATIC}"

  PKG_CONFIG_PATH="${XBB_FOLDER}/lib/pkgconfig:${PKG_CONFIG_PATH}"

  if [ -d "${XBB_FOLDER}/lib64" ]
  then
    XBB_LDFLAGS="-L${XBB_FOLDER}/lib64 ${XBB_LDFLAGS}"
    XBB_LDFLAGS_LIB="-L${XBB_FOLDER}/lib64 ${XBB_LDFLAGS_LIB}"
    XBB_LDFLAGS_APP="-L${XBB_FOLDER}/lib64 ${XBB_LDFLAGS_APP}"
    XBB_LDFLAGS_APP_STATIC="-L${XBB_FOLDER}/lib64 ${XBB_LDFLAGS_APP_STATIC}"
    PKG_CONFIG_PATH="${XBB_FOLDER}/lib64/pkgconfig:${PKG_CONFIG_PATH}"
  fi

  export XBB_CPPFLAGS
  export XBB_LDFLAGS
  export XBB_LDFLAGS_LIB
  export XBB_LDFLAGS_APP
  export XBB_LDFLAGS_APP_STATIC
}


# -----------------------------------------------------------------------------

# Note: __EOF__ is quoted to prevent substitutions here.
mkdir -p "${XBB_FOLDER}/bin"
cat <<'__EOF__' > "${XBB_FOLDER}/bin/pkg-config-verbose"
#! /bin/sh
# pkg-config wrapper for debug

pkg-config $@
RET=$?
OUT=$(pkg-config $@)
echo "($PKG_CONFIG_PATH) | pkg-config $@ -> $RET [$OUT]" 1>&2
exit ${RET}

__EOF__
# The above marker must start in the first column.

chmod +x "${XBB_FOLDER}/bin/pkg-config-verbose"

export PKG_CONFIG="${XBB_FOLDER}/bin/pkg-config-verbose"

# -----------------------------------------------------------------------------
# Common functions.

function extract()
{
  local ARCHIVE_NAME="$1"

  if [ -x "${XBB_FOLDER}/bin/tar" ]
  then
    (
      PATH="${XBB_FOLDER}/bin:${PATH}"
      tar xf "${ARCHIVE_NAME}"
    )
  else
    if [[ "${ARCHIVE_NAME}" =~ '\.bz2$' ]]; then
      tar xjf "${ARCHIVE_NAME}"
    else
      tar xzf "${ARCHIVE_NAME}"
    fi
  fi
}

function download_and_extract()
{
  local ARCHIVE_NAME="$1"
  local URL="$2"

  if [ ! -f "${XBB_DOWNLOAD_FOLDER}/${ARCHIVE_NAME}" ]
  then
    rm -f "${XBB_DOWNLOAD_FOLDER}/${ARCHIVE_NAME}.download"
    if [ -x "${XBB_FOLDER}/bin/curl" ]
    then
      (
        PATH="${XBB_FOLDER}/bin:${PATH}"
        curl --fail -L -o "${XBB_DOWNLOAD_FOLDER}/${ARCHIVE_NAME}.download" "${URL}"
      )
    else
      curl --fail -L -o "${XBB_DOWNLOAD_FOLDER}/${ARCHIVE_NAME}.download" "${URL}"
    fi
    mv "${XBB_DOWNLOAD_FOLDER}/${ARCHIVE_NAME}.download" "${XBB_DOWNLOAD_FOLDER}/${ARCHIVE_NAME}"
  fi

  extract "${XBB_DOWNLOAD_FOLDER}/${ARCHIVE_NAME}"
}

# -----------------------------------------------------------------------------

source "${XBB_INPUT_FOLDER}/common-functions-source.sh"

# -----------------------------------------------------------------------------

do_strip_libs() 
{
  (
    cd "${XBB_FOLDER}"

    xbb_activate

    set +e
    if [ -f "${XBB_FOLDER}/bin/strip" ]
    then
      # -type f to skip links.
      find lib* -name '*.so' -type f -print -exec "${XBB_FOLDER}/bin/strip" --strip-debug {} \;
      find lib* -name '*.so.*'  -type f -print -exec "${XBB_FOLDER}/bin/strip" --strip-debug {} \;
      find lib* -name '*.a'  -type f  -print -exec "${XBB_FOLDER}/bin/strip" --strip-debug {} \;
    fi
    set -e
  )
}

# -----------------------------------------------------------------------------

do_cleaunup() 
{
  # Preserve download, will be used by xbb and removed later.
  # rm -rf "$XBB_DOWNLOAD_FOLDER"

  # All other can go.
  rm -rf "${XBB_BUILD_FOLDER}"
  rm -rf "${XBB_TMP_FOLDER}"
  rm -rf "${XBB_INPUT_FOLDER}"
}

# =============================================================================

# WARNING: the order is important, since some of the builds depend
# on previous ones.

# For extra safety, the ${XBB_FOLDER} folder is not permanently in the PATH,
# it is added explicitly with xbb_activate_dev in sub-shells;
# by default, the environment is that of the original CentOS.

# -----------------------------------------------------------------------------

if true
then
  # New zlib, it is used in most of the tools.
  do_zlib

  # Library, required by tar. 
  do_xz

  # New tar, with xz support.
  do_tar # Requires xz.

  # From this moment on, .xz archives can be processed.

  # New openssl, required by curl, cmake, python, etc.
  do_openssl

  # New curl, that better understands all protocols.
  do_curl
fi

if true
then
  # GNU tools. 
  do_m4
  do_gawk
  do_autoconf
  do_automake
  do_libtool
  do_gettext
  do_patch
  do_diffutils
  do_bison
  do_make

  # Third party tools.
  do_pkg_config

  do_flex # Requires gettext.

  do_perl
fi

if true
then
  # Libraries, required by gcc.
  do_gmp
  do_mpfr
  do_mpc
  do_isl
fi

if true
then
  # Native binutils and gcc.
  do_native_binutils # Requires gmp, mpfr, mpc, isl.
  do_native_gcc # Requires gmp, mpfr, mpc, isl.
fi

# Switch to the newly compiled GCC.
export CC="gcc${GCC_SUFFIX}"
export CXX="g++${GCC_SUFFIX}"

(
  xbb_activate
  echo
  ${CXX} --version
)

if true
then
  # Recent versions require C++11.
  do_cmake
fi

if true
then
  do_python
  do_scons
fi

if true
then
  # Strip debug from *.a and *.so.
  do_strip_libs
  do_cleaunup
fi

# -----------------------------------------------------------------------------
