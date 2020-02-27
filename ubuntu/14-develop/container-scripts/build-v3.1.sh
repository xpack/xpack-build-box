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
unset TERM

# -----------------------------------------------------------------------------

# These tools should be enough to build the bootstrap tools.

apt-get install --yes \
\
autoconf \
automake \
bison \
bzip2 \
ca-certificates \
cmake \
curl \
diffutils \
file \
flex \
gawk \
gcc \
g++ \
gettext \
git \
libc6-dev \
libtool \
lsb-release \
m4 \
make \
patch \
perl \
pkg-config \
python \
python3 \
tcl \
time \
unzip \
wget \
xz-utils \
zip \
zlib1g-dev \

# libtool-bin - not present in precise

# For QEMU
apt-get install --yes \
libx11-dev \
libxext-dev \
mesa-common-dev

# For QEMU & OpenOCD
apt-get install --yes \
libudev-dev

# From  (universe)
apt-get install --yes \
texinfo \
help2man \

# Not available.
# dos2unix \

# For add-apt-repository
apt-get install --yes software-properties-common
# Not longer available.
# apt-get install --yes python-software-properties

add-apt-repository --yes ppa:ubuntu-toolchain-r/test 
add-apt-repository --yes ppa:openjdk-r/ppa

apt-get update

# Upgrade to 6.5.
apt-get install --yes \
gcc-6 \
g++-6 \

update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-6 60 --slave /usr/bin/g++ g++ /usr/bin/g++-6
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 60 --slave /usr/bin/g++ g++ /usr/bin/g++-4.6

echo 2 | update-alternatives --config gcc

apt-get install --yes openjdk-8-jdk

apt-get install --yes ant

# Not available.
# apt-get install --yes maven

# https://www.thomas-krenn.com/en/wiki/Configure_Locales_in_Ubuntu
apt-get install --yes locales
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8

# patchelf - not present in precise

# -----------------------------------------------------------------------------

apt-get clean
apt-get autoclean
apt-get autoremove

# -----------------------------------------------------------------------------

echo
uname -a
lsb_release -a

ant -version
autoconf --version
bison --version
cmake --version
curl --version
flex --version
g++ --version
gawk --version
git --version
java -version
m4 --version
# mvn -version
make --version
patch --version
perl --version
pkg-config --version
python --version
python3 --version

# -----------------------------------------------------------------------------

echo
echo "Container done."

# -----------------------------------------------------------------------------
