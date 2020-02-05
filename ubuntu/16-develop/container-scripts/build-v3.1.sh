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
cmake \
curl \
diffutils \
file \
flex \
gawk \
gcc++ \
gettext \
git \
help2man \
libc6-dev \
libtool \
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

apt-get install --yes software-properties-common

# For add-apt-repository
apt-get install --yes python-software-properties

add-apt-repository --yes ppa:ubuntu-toolchain-r/test 
add-apt-repository --yes ppa:openjdk-r/ppa

cat <<'__EOF__' >>"/etc/apt/sources.list"

## N.B. software from this repository is ENTIRELY UNSUPPORTED by the Ubuntu
## team. Also, please note that software in universe WILL NOT receive any
## review or updates from the Ubuntu security team.
deb http://us.ports.ubuntu.com/ubuntu-ports/ xenial universe
# deb-src http://us.ports.ubuntu.com/ubuntu-ports/ xenial universe
deb http://ports.ubuntu.com/ubuntu-ports xenial-security universe
# deb-src http://ports.ubuntu.com/ubuntu-ports xenial-security universe

deb http://us.ports.ubuntu.com/ubuntu-ports/ xenial-updates universe
# deb-src http://us.ports.ubuntu.com/ubuntu-ports/ xenial-updates universe

deb http://us.ports.ubuntu.com/ubuntu-ports/ xenial-backports universe 
# deb-src http://us.ports.ubuntu.com/ubuntu-ports/ xenial-backports universe 

## N.B. software from this repository is ENTIRELY UNSUPPORTED by the Ubuntu 
## team, and may not be under a free licence. Please satisfy yourself as to 
## your rights to use the software. Also, please note that software in 
## multiverse WILL NOT receive any review or updates from the Ubuntu
## security team.
deb http://us.ports.ubuntu.com/ubuntu-ports/ xenial multiverse
# deb-src http://us.ports.ubuntu.com/ubuntu-ports/ xenial multiverse
deb http://ports.ubuntu.com/ubuntu-ports xenial-security multiverse
# deb-src http://ports.ubuntu.com/ubuntu-ports xenial-security multiverse

deb http://us.ports.ubuntu.com/ubuntu-ports/ xenial-updates multiverse
# deb-src http://us.ports.ubuntu.com/ubuntu-ports/ xenial-updates multiverse

deb http://us.ports.ubuntu.com/ubuntu-ports/ xenial-backports multiverse
# deb-src http://us.ports.ubuntu.com/ubuntu-ports/ xenial-backports multiverse
__EOF__

echo
echo "The resulting /etc/apt/sources.list"
cat "/etc/apt/sources.list" | egrep '^deb '
echo "---"

apt-get update 

# From  (universe)
apt-get install --yes \
dos2unix \
texinfo \

# GCC 6.0.1 already available, update to 6.5.
apt-get install --yes \
gcc-6 \
g++-6 \

update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-6 60 --slave /usr/bin/g++ g++ /usr/bin/g++-6
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 60 --slave /usr/bin/g++ g++ /usr/bin/g++-5

echo 2 | update-alternatives --config gcc

apt-get install --yes openjdk-8-jdk
apt-get install --yes ant
apt-get install --yes maven

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
mvn -version
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
