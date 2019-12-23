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

env

apt-get install --yes software-properties-common

# Use this ppa to get GCC 7.x.
add-apt-repository ppa:ubuntu-toolchain-r/test
apt-get update

apt-get install --yes \
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
g++-7 

apt-get install --yes \
libpython-dev \
libpython3-dev 

apt-get install --yes \
texlive \
texlive-generic-recommended \
texlive-extra-utils

echo
gcc-7 --version
