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

# The place where files are downloaded.
CACHE_FOLDER_PATH="${WORK_FOLDER_PATH}/cache"
# The install destination folder.
INSTALL_FOLDER_PATH="${HOME}/opt/texlive"

# Make all tools choose gcc, not the old cc.
export CC=gcc
export CXX=g++

# -----------------------------------------------------------------------------

helper_folder_path="$(dirname "${script_folder_path}")/helper"

source "${helper_folder_path}/common-functions-source.sh"
source "${helper_folder_path}/common-texlive-functions-source.sh"

# -----------------------------------------------------------------------------

detect_host

echo
echo "$(uname) XBB TexLive ${TL_EDITION_YEAR} build script started..."

echo
echo "Checking if Xcode Command Line Tools are installed..."
xcode-select -p

function xbb_activate()
{
  :
}

# -----------------------------------------------------------------------------

do_texlive "${TL_EDITION_YEAR}" "${TL_EDITION_FOLDER_NAME}" "${TL_SCHEME}"

# -----------------------------------------------------------------------------

echo
echo "You may want to ' chmod -R -w \"${INSTALL_FOLDER_PATH}\" '"

echo
echo "$(uname) XBB TexLive ${TL_EDITION_YEAR} created in \"${INSTALL_FOLDER_PATH}\""

if [ "${HOST_UNAME}" == "Darwin" ]
then
  say done
fi

# -----------------------------------------------------------------------------
