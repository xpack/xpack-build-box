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

echo
echo "The orginal /etc/apt/sources.list"
cat "/etc/apt/sources.list"
echo "---"

# -----------------------------------------------------------------------------

# Copied from a system installed directly from updates.
# Note: __EOF__ is quoted to prevent substitutions here.
cat <<'__EOF__'  >"/etc/apt/sources.list"
# deb http://us.ports.ubuntu.com/ubuntu-ports/ xenial main restricted

# deb http://us.ports.ubuntu.com/ubuntu-ports/ xenial-updates main restricted
# deb http://ports.ubuntu.com/ubuntu-ports xenial-security main restricted

# See http://help.ubuntu.com/community/UpgradeNotes for how to upgrade to
# newer versions of the distribution.
deb http://us.ports.ubuntu.com/ubuntu-ports/ xenial main restricted
# deb-src http://us.ports.ubuntu.com/ubuntu-ports/ xenial main restricted

## Major bug fix updates produced after the final release of the
## distribution.
deb http://us.ports.ubuntu.com/ubuntu-ports/ xenial-updates main restricted
# deb-src http://us.ports.ubuntu.com/ubuntu-ports/ xenial-updates main restricted

## N.B. software from this repository is ENTIRELY UNSUPPORTED by the Ubuntu
## team. Also, please note that software in universe WILL NOT receive any
## review or updates from the Ubuntu security team.
deb http://us.ports.ubuntu.com/ubuntu-ports/ xenial universe
# deb-src http://us.ports.ubuntu.com/ubuntu-ports/ xenial universe
deb http://us.ports.ubuntu.com/ubuntu-ports/ xenial-updates universe
# deb-src http://us.ports.ubuntu.com/ubuntu-ports/ xenial-updates universe

## N.B. software from this repository is ENTIRELY UNSUPPORTED by the Ubuntu 
## team, and may not be under a free licence. Please satisfy yourself as to 
## your rights to use the software. Also, please note that software in 
## multiverse WILL NOT receive any review or updates from the Ubuntu
## security team.
deb http://us.ports.ubuntu.com/ubuntu-ports/ xenial multiverse
# deb-src http://us.ports.ubuntu.com/ubuntu-ports/ xenial multiverse
deb http://us.ports.ubuntu.com/ubuntu-ports/ xenial-updates multiverse
# deb-src http://us.ports.ubuntu.com/ubuntu-ports/ xenial-updates multiverse

## N.B. software from this repository may not have been tested as
## extensively as that contained in the main release, although it includes
## newer versions of some applications which may provide useful features.
## Also, please note that software in backports WILL NOT receive any review
## or updates from the Ubuntu security team.
deb http://us.ports.ubuntu.com/ubuntu-ports/ xenial-backports main restricted universe multiverse
# deb-src http://us.ports.ubuntu.com/ubuntu-ports/ xenial-backports main restricted universe multiverse

## Uncomment the following two lines to add software from Canonical's
## 'partner' repository.
## This software is not part of Ubuntu, but is offered by Canonical and the
## respective vendors as a service to Ubuntu users.
# deb http://archive.canonical.com/ubuntu xenial partner
# deb-src http://archive.canonical.com/ubuntu xenial partner

deb http://ports.ubuntu.com/ubuntu-ports xenial-security main restricted
# deb-src http://ports.ubuntu.com/ubuntu-ports xenial-security main restricted
deb http://ports.ubuntu.com/ubuntu-ports xenial-security universe
# deb-src http://ports.ubuntu.com/ubuntu-ports xenial-security universe
deb http://ports.ubuntu.com/ubuntu-ports xenial-security multiverse
# deb-src http://ports.ubuntu.com/ubuntu-ports xenial-security multiverse
__EOF__

apt-get update 
apt-get upgrade --yes 

apt-get install --yes time

apt-get clean
apt-get autoclean
apt-get autoremove

# -----------------------------------------------------------------------------

echo
uname -a
lsb_release -a

# -----------------------------------------------------------------------------
