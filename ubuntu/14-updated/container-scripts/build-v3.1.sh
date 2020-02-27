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

deb http://ports.ubuntu.com/ubuntu-ports/ trusty main restricted 
# deb-src http://ports.ubuntu.com/ubuntu-ports/ trusty main restricted 
deb http://ports.ubuntu.com/ubuntu-ports/ trusty-security main restricted 
# deb-src http://ports.ubuntu.com/ubuntu-ports/ trusty-security main restricted 

## Major bug fix updates produced after the final release of the
## distribution.
deb http://ports.ubuntu.com/ubuntu-ports/ trusty-updates main restricted 
# deb-src http://ports.ubuntu.com/ubuntu-ports/ trusty-updates main restricted 

deb http://ports.ubuntu.com/ubuntu-ports/ trusty-backports main restricted 
# deb-src http://ports.ubuntu.com/ubuntu-ports/ trusty-backports main restricted 

## N.B. software from this repository is ENTIRELY UNSUPPORTED by the Ubuntu
## team. Also, please note that software in universe WILL NOT receive any
## review or updates from the Ubuntu security team.
deb http://ports.ubuntu.com/ubuntu-ports/ trusty universe
# deb-src http://ports.ubuntu.com/ubuntu-ports/ trusty universe
deb http://ports.ubuntu.com/ubuntu-ports/ trusty-security universe
# deb-src http://ports.ubuntu.com/ubuntu-ports/ trusty-security universe

deb http://ports.ubuntu.com/ubuntu-ports/ trusty-updates universe
# deb-src http://ports.ubuntu.com/ubuntu-ports/ trusty-updates universe

deb http://ports.ubuntu.com/ubuntu-ports/ trusty-backports universe 
# deb-src http://ports.ubuntu.com/ubuntu-ports/ trusty-backports universe 

## N.B. software from this repository is ENTIRELY UNSUPPORTED by the Ubuntu 
## team, and may not be under a free licence. Please satisfy yourself as to 
## your rights to use the software. Also, please note that software in 
## multiverse WILL NOT receive any review or updates from the Ubuntu
## security team.
deb http://ports.ubuntu.com/ubuntu-ports/ trusty multiverse
# deb-src http://ports.ubuntu.com/ubuntu-ports/ trusty multiverse
deb http://ports.ubuntu.com/ubuntu-ports/ trusty-security multiverse
# deb-src http://ports.ubuntu.com/ubuntu-ports/ trusty-security multiverse

deb http://ports.ubuntu.com/ubuntu-ports/ trusty-updates multiverse
# deb-src http://ports.ubuntu.com/ubuntu-ports/ trusty-updates multiverse

deb http://ports.ubuntu.com/ubuntu-ports/ trusty-backports multiverse
# deb-src http://ports.ubuntu.com/ubuntu-ports/ trusty-backports multiverse
__EOF__

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

apt-get install --yes lsb-release

echo
uname -a
lsb_release -a

echo
echo "Container done."

# -----------------------------------------------------------------------------
