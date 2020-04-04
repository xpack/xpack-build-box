#!/usr/bin/env bash

# -----------------------------------------------------------------------------

# This script installs a simplified XBB (xPack Build Box) on Ubuntu 18 LTS.

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
# Identify helper scripts.

build_script_path=$0
if [[ "${build_script_path}" != /* ]]
then
  # Make relative path absolute.
  build_script_path=$(pwd)/$0
fi

script_folder_path="$(dirname ${build_script_path})"
script_folder_name="$(basename ${script_folder_path})"

# =============================================================================

helper_folder_path="$(dirname ${script_folder_path})/helper"

source "${helper_folder_path}/common-docker-functions-source.sh"

# -----------------------------------------------------------------------------

apt-get update 
apt-get upgrade --yes 

ubuntu_install_develop

apt-get install --yes \
g++-mingw-w64 \
patchelf \
meson \
scons \
ninja-build \
p7zip \
rhash \
re2c \
gnupg \
ant \
maven \

# Optional, to check if Windows binaries start properly.
# On 32-bit machines it is win32.
if [ -z "$(which wsl.exe)" ]
then
  # If not on WSL, install wine.
  apt-get install --yes wine64
fi

ubuntu_clean

# -----------------------------------------------------------------------------

echo "Done."

# -----------------------------------------------------------------------------
