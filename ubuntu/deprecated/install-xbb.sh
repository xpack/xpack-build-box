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

# -----------------------------------------------------------------------------

# Packages that reflect the tools and libraries built from sources
# in the Docker images.
apt install --yes \
git \
curl \
make \
pkg-config \
m4 \
gawk \
autoconf automake \
libtool libtool-bin \
gettext \
bison \
texinfo \
patchelf \
dos2unix \
flex \
perl \
cmake \
python python3 \
g++-7 \
g++-mingw-w64 \

echo apt install --yes \
libexpat1-dev \
libgmp-dev \
libmpfr-dev \
libmpc-dev \
libisl-dev \
libffi-dev \
libiconv-hook-dev \
libxml2-dev \

# -----------------------------------------------------------------------------

# Packages needed by QEMU builds.
echo apt install --yes \
gettext \
libpng-dev \
libjpeg-dev \
libsdl2-dev \
libsdl2-image-dev \
libpixman-1-dev \
libglib2.0-dev \
zlib1g-dev \
libffi-dev \
libxml2-dev \

# -----------------------------------------------------------------------------

# Optional, to check if Windows binaries start properly.
# On 32-bit machines it is win32.
if [ -z "$(which wsl.exe)" ]
then
  # If not on WSL, install wine.
  apt install --yes wine64
fi

# -----------------------------------------------------------------------------

echo "Done."

# -----------------------------------------------------------------------------
