#!/usr/bin/env bash

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
# This script installs a local instance of TeX Live (https://tug.org/texlive/).

TL_EDITION_YEAR="2018"
TL_EDITION_FOLDER_NAME="install-tl-20180414"
# Schemes: basic (~80 packs), medium (~1000 packs), full (~3400)
TL_SCHEME="medium"

WORK_FOLDER_PATH="${HOME}/Work"

# The install destination folder.
INSTALL_FOLDER_PATH="/opt/texlive"

# -----------------------------------------------------------------------------

cd "${script_folder_path}"

source "helper/common-functions-source.sh"
source "helper/common-docker-functions-source.sh"
source "helper/common-texlive-functions-source.sh"

# -----------------------------------------------------------------------------

env

detect_host

docker_prepare_env

echo
echo "$(uname) XBB TexLive ${TL_EDITION_YEAR} build script started..."

function xbb_activate()
{
  :
}

# -----------------------------------------------------------------------------

# Make all tools choose gcc, not the old cc.
export CC=gcc
export CXX=g++

# -----------------------------------------------------------------------------

function do_cleanup()
{
  if [ -f "${WORK_FOLDER_PATH}/.dockerenv" ]
  then
    rm -rf "${TL_FOLDER_PATH}"
    rm -rf "${CACHE_FOLDER_PATH}"
  fi
}

# =============================================================================

do_texlive "${TL_EDITION_YEAR}" "${TL_EDITION_FOLDER_NAME}" "${TL_SCHEME}"

echo
echo "$(uname) XBB TexLive ${TL_EDITION_YEAR} created in \"${INSTALL_FOLDER_PATH}\""

do_cleanup

# -----------------------------------------------------------------------------
