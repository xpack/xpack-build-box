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
python \
g++-7 \
g++-mingw-w64 \
\
libexpat1-dev \
libgmp-dev \
libmpfr-dev \
libmpc-dev \
libisl-dev \
libffi-dev \
libiconv-hook-dev \

# -----------------------------------------------------------------------------

# Additional libraries needed by QEMU builds.
apt install --yes \
libpng-dev \
libjpeg-dev \
libsdl2-dev \
libsdl2-image-dev \
libpixman-1-dev \
libglib2.0-dev \

# -----------------------------------------------------------------------------

XBB_FOLDER=/opt/xbb

mkdir -p "${XBB_FOLDER}"
mkdir -p "${XBB_FOLDER}"/bin
mkdir -p "${XBB_FOLDER}"/lib

# -----------------------------------------------------------------------------
# Create a more verbose pkg-config.

cat <<'__EOF__' > "${XBB_FOLDER}"/bin/pkg-config-verbose
#! /bin/sh
# pkg-config wrapper for debug

pkg-config $@
RET=$?
OUT=$(pkg-config $@)
echo "($PKG_CONFIG_PATH) | pkg-config $@ -> $RET [$OUT]" 1>&2
exit ${RET}

__EOF__

chmod +x "${XBB_FOLDER}"/bin/pkg-config-verbose

# -----------------------------------------------------------------------------
# Create the XBB activator script.

cat <<'__EOF__' > "${XBB_FOLDER}"/bin/xbb-source.sh

export XBB_FOLDER=/opt/xbb

# Allow binaries from XBB to be found before all other.
# Includes and pkg_config should be enabled only when needed.
function xbb_activate()
{
  PATH=${PATH:-""}
  export PATH="${XBB_FOLDER}"/bin:${PATH}

  LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-""}
  export LD_LIBRARY_PATH="${XBB_FOLDER}/lib:${LD_LIBRARY_PATH}"
}

# Allow for the headers and pkg_config files to be found before all other.
function xbb_activate_dev()
{
  EXTRA_CPPFLAGS=${EXTRA_CPPFLAGS:-""}

  if [ ! -z "${PKG_CONFIG_PATH}" ]
  then
    if [ -d "/usr/lib/pkgconfig" ]
    then
      PKG_CONFIG_PATH="/usr/lib/pkgconfig"
    fi
  fi
  if [ \( "${TARGET_BITS}" == "64" \) -a \( -d "/usr/lib/x86_64-linux-gnu/pkgconfig" \) ]
  then
    PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig:"${PKG_CONFIG_PATH}"
  fi
  export PKG_CONFIG_PATH
}

__EOF__

# -----------------------------------------------------------------------------

echo "Done."

# -----------------------------------------------------------------------------
