#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (http://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
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

script_path="$0"
if [[ "${script_path}" != /* ]]
then
  # Make relative path absolute.
  script_path="$(pwd)/$0"
fi

script_name="$(basename "${script_path}")"

script_folder_path="$(dirname "${script_path}")"
script_folder_name="$(basename "${script_folder_path}")"

# =============================================================================

# Script to build a separate macOS XBB.
# Basically it tries to be similar to the Docker images.

# -----------------------------------------------------------------------------

XBB_VERSION="3.1"

# XBB_FOLDER="${HOME}/opt/xbb-${XBB_VERSION}"
XBB_FOLDER="${HOME}/opt/xbb"
# XBB_BOOTSTRAP_FOLDER="${HOME}/opt/xbb-bootstrap-${XBB_VERSION}"
XBB_BOOTSTRAP_FOLDER="${HOME}/opt/xbb-bootstrap"

WORK_FOLDER_PATH="${HOME}/Work"

IS_BOOTSTRAP="n"

# Build the XBB tools with the bootstrap compiler.
# Some packages fail, and have to revert to the Apple clang.
CC="gcc-7bs"
CXX="g++-7bs"

echo
echo "$(uname) XBB v${XBB_VERSION} build script started..."

# -----------------------------------------------------------------------------

helper_folder_path="$(dirname "${script_folder_path}")/helper"

source "${helper_folder_path}/common-functions-source.sh"
source "${helper_folder_path}/common-libs-functions-source.sh"
source "${helper_folder_path}/common-apps-functions-source.sh"

source "${helper_folder_path}/common-versions-source.sh"

# -----------------------------------------------------------------------------

cd "${script_folder_path}"

detect_host

prepare_xbb_env

source "${XBB_BOOTSTRAP_FOLDER}/xbb-source.sh"

create_xbb_source

xbb_activate()
{
  xbb_activate_bootstrap      # Use only bootstrap binaries, not xbb
  xbb_activate_installed_dev  # Use xbb libraries and headers
}

# -----------------------------------------------------------------------------

do_build_versions

do_strip_libs

# Only in final Docker image
# do_cleanup

# -----------------------------------------------------------------------------

if [ "${HOST_UNAME}" == "Darwin" ]
then
  echo
  echo "macOS version ${macos_version}"
  echo "XCode Command Line Tools version ${xclt_version}"
fi

echo
echo "You may want to ' chmod -R -w \"${INSTALL_FOLDER_PATH}\" '"

echo
echo "$(uname) XBB v${XBB_VERSION} created in \"${INSTALL_FOLDER_PATH}\""

if [ "${HOST_UNAME}" == "Darwin" ]
then
  say done
fi

# -----------------------------------------------------------------------------
