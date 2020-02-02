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

echo
echo "The orginal /etc/apt/sources.list"
cat "/etc/apt/sources.list"
echo "---"

# -----------------------------------------------------------------------------

# Copied from a system installed directly from updates.
# Note: __EOF__ is quoted to prevent substitutions here.
cat <<'__EOF__'  >"/etc/apt/sources.list"
# https://help.ubuntu.com/community/Repositories/Ubuntu
# See http://help.ubuntu.com/community/UpgradeNotes for how to upgrade to
# newer versions of the distribution.

deb http://us.ports.ubuntu.com/ubuntu-ports/ xenial main restricted
# deb-src http://us.ports.ubuntu.com/ubuntu-ports/ xenial main restricted
deb http://ports.ubuntu.com/ubuntu-ports xenial-security main restricted
# deb-src http://ports.ubuntu.com/ubuntu-ports xenial-security main restricted

## Major bug fix updates produced after the final release of the
## distribution.
deb http://us.ports.ubuntu.com/ubuntu-ports/ xenial-updates main restricted
# deb-src http://us.ports.ubuntu.com/ubuntu-ports/ xenial-updates main restricted

deb http://us.ports.ubuntu.com/ubuntu-ports/ xenial-backports main restricted 
# deb-src http://us.ports.ubuntu.com/ubuntu-ports/ xenial-backports main restricted 
__EOF__

if false
then
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
__EOF__
fi

if false
then
cat <<'__EOF__' >>"/etc/apt/sources.list"

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
fi

# deb http://us.ports.ubuntu.com/ubuntu-ports/ xenial universe

# Some packages could not be installed. This may mean that you have
# requested an impossible situation or if you are using the unstable
# distribution that some required packages have not yet been created
# or been moved out of Incoming.
# The following information may help to resolve the situation:
# 
# The following packages have unmet dependencies:
#  gcc-4.7-plugin-dev : Depends: libgmpv4-dev (>= 2:5.0.1~) but it is not going to be installed
#  lib32gcc-4.9-dev-s390x-cross : Depends: gcc-4.9-s390x-linux-gnu-base (>= 4.9.3-13ubuntu2) but it is not installable
#  lib64gcc-4.8-dev-powerpc-cross : Depends: gcc-4.8-powerpc-linux-gnu-base (= 4.8.5-4ubuntu2cross3) but it is not installable
#                                   Depends: lib64asan0-powerpc-cross (>= 4.8.5-4ubuntu2cross3) but it is not going to be installed
#  lib64gcc-4.9-dev-powerpc-cross : Depends: gcc-4.9-powerpc-linux-gnu-base (>= 4.9.3-13ubuntu2) but it is not installable
#                                   Depends: lib64asan1-powerpc-cross (>= 4.9.3-13ubuntu2cross1) but it is not going to be installed
#  libgcc-4.7-dev-armel-cross : Depends: gcc-4.7-arm-linux-gnueabi-base (= 4.7.4-3ubuntu12cross3) but it is not installable
#  libgcc-4.8-dev-arm64-cross : Depends: gcc-4.8-aarch64-linux-gnu-base (= 4.8.5-4ubuntu1cross2) but it is not installable
#  libgcc-4.8-dev-powerpc-cross : Depends: gcc-4.8-powerpc-linux-gnu-base (= 4.8.5-4ubuntu2cross3) but it is not installable
#                                 Depends: libasan0-powerpc-cross (>= 4.8.5-4ubuntu2cross3) but it is not going to be installed
#  libgcc-4.8-dev-ppc64el-cross : Depends: gcc-4.8-powerpc64le-linux-gnu-base (= 4.8.5-4ubuntu1cross2) but it is not installable
#  libgcc-4.9-dev-arm64-cross : Depends: gcc-4.9-aarch64-linux-gnu-base (>= 4.9.3-13ubuntu2) but it is not installable
#  libgcc-4.9-dev-powerpc-cross : Depends: gcc-4.9-powerpc-linux-gnu-base (>= 4.9.3-13ubuntu2) but it is not installable
#                                 Depends: libasan1-powerpc-cross (>= 4.9.3-13ubuntu2cross1) but it is not going to be installed
#  libgcc-4.9-dev-ppc64el-cross : Depends: gcc-4.9-powerpc64le-linux-gnu-base (>= 4.9.3-13ubuntu2) but it is not installable
#  libgcc-4.9-dev-s390x-cross : Depends: gcc-4.9-s390x-linux-gnu-base (>= 4.9.3-13ubuntu2) but it is not installable
#  libhfgcc-4.7-dev-armel-cross : Depends: gcc-4.7-arm-linux-gnueabi-base (= 4.7.4-3ubuntu12cross3) but it is not installable
# E: Unable to correct problems, you have held broken packages.

echo
echo "The resulting /etc/apt/sources.list"
cat "/etc/apt/sources.list" | egrep '^deb '
echo "---"

apt-get update 
apt-get upgrade --yes 

# -----------------------------------------------------------------------------

apt-get clean
apt-get autoclean
apt-get autoremove

# -----------------------------------------------------------------------------

echo
uname -a
lsb_release -a

echo
echo "Container done."

# -----------------------------------------------------------------------------
