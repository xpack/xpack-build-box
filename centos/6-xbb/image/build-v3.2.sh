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

# Script to build a subsequent version of a Docker image with the 
# xPack Build Box (xbb).

# To activate the new build environment, use:
#
#   $ source /opt/xbb/xbb-source.sh
#   $ xbb_activate

XBB_INPUT_FOLDER="/xbb-input"
source "${XBB_INPUT_FOLDER}/common-functions-source.sh"
source "${XBB_INPUT_FOLDER}/common-libs-functions-source.sh"
source "${XBB_INPUT_FOLDER}/common-apps-functions-source.sh"

prepare_env

# Create the xbb-source.sh file.
create_xbb_source

# Remove the old name, to enforce using the new one.
rm -rf "${XBB_FOLDER}/xbb.sh"

# -----------------------------------------------------------------------------

# Make the functions available to the entire script.
source "${XBB_FOLDER}/xbb-source.sh"

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

# -----------------------------------------------------------------------------

if true
then

  # Third party tools.

  # depends=('libutil-linux' 'gnutls' 'libidn' 'libpsl>=0.7.1-3' 'gpgme')
  do_wget "1.20.1"

  # Required to build PDF manuals.
  # depends=('coreutils')
  do_texinfo "6.6"
  # depends ?
  do_patchelf "0.10"
  # depends=('glibc')
  do_dos2unix "7.4.0"

  # depends=('glibc' 'm4' 'sh')
  do_flex "2.6.4"

  # depends=('gdbm' 'db' 'glibc')
  do_perl "5.28.1"

  # depends=('curl' 'libarchive' 'shared-mime-info' 'jsoncpp' 'rhash')
  do_cmake "3.13.4"

  # depends=('bzip2' 'gdbm' 'openssl' 'zlib' 'expat' 'sqlite' 'libffi')
  do_python "2.7.16"

  # require xz, openssl
  do_python3 "3.7.3"

  # depends=('python2')
  do_scons "3.0.5"

  # depends=('python2')
  do_ninja "1.9.0"

  # depends=('python3')
  do_meson

  # depends=('curl' 'expat>=2.0' 'perl-error' 'perl>=5.14.0' 'openssl' 'pcre2' 'grep' 'shadow')
  do_git "2.21.0"

  do_p7zip "16.02"

  do_wine

fi

if false
then
  # Native binutils and gcc.
  do_native_binutils "2.32"
  # makedepends=('binutils>=2.26' 'libmpc' 'gcc-ada' 'doxygen' 'git')
  do_native_gcc "7.4.0"
fi

if false
then
  # mingw-w64 binutils and gcc.
  # depends=('zlib')
  do_mingw_binutils "2.32"
  # depends=('zlib' 'libmpc' 'mingw-w64-crt' 'mingw-w64-binutils' 'mingw-w64-winpthreads' 'mingw-w64-headers')
  do_mingw_all "5.0.4" "7.4.0"
fi

# -----------------------------------------------------------------------------

if false
then
  do_strip_libs

  do_cleaunup
fi

# -----------------------------------------------------------------------------
