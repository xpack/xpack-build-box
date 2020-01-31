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

# -----------------------------------------------------------------------------

# These tools should be enough to build the bootstrap tools.

apt-get install --yes \
\
build-essential \
\
gcc++ \
make \
automake \
pkg-config \
curl \
xz-utils \
zip \
unzip \
bzip2 \
libtool \
gettext \
texinfo \
bison \
flex \
dos2unix \
patch \
perl \
zlib1g-dev \
file \
diffutils \
cmake \
libudev-dev \
tcl \
wget \

apt-get clean
apt-get autoclean
apt-get autoremove

# -----------------------------------------------------------------------------

echo
uname -a
lsb_release -a

# -----------------------------------------------------------------------------
