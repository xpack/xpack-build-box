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

helper_folder_path="${script_folder_path}/helper"

source "${helper_folder_path}/common-functions-source.sh"
source "${helper_folder_path}/common-docker-functions-source.sh"

# -----------------------------------------------------------------------------

echo
env | sort
unset TERM

# -----------------------------------------------------------------------------

if is_intel
then
  docker_replace_source_list "http://archive.ubuntu.com/ubuntu/" "bionic"
elif is_arm
then
  docker_replace_source_list "http://ports.ubuntu.com/ubuntu-ports/" "bionic"
fi

# Keep it to a minimum, mainly to allow scripts to
# download/uncompress archives.
run_verbose apt-get -qq install -y \
bzip2 \
ca-certificates \
coreutils \
curl \
file \
git \
gzip \
lsb-release \
patch \
tar \
time \
unzip \
wget \
xz-utils \

# https://www.thomas-krenn.com/en/wiki/Configure_Locales_in_Ubuntu
run_verbose apt-get install --yes locales
run_verbose locale-gen en_US.UTF-8
run_verbose update-locale LANG=en_US.UTF-8

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash

export NVM_DIR="${HOME}/.nvm"
[ -s "${NVM_DIR}/nvm.sh" ] && \. "${NVM_DIR}/nvm.sh"  # This loads nvm
[ -s "${NVM_DIR}/bash_completion" ] && \. "${NVM_DIR}/bash_completion"  # This loads nvm bash_completion

# run_verbose nvm install --lts node
# run_verbose nvm use --lts node
# run_verbose nvm install-latest-npm

if [ "${XBB_VERSION}" == "1" ]
then
  run_verbose nvm install v16.13.1
  run_verbose nvm use v16.13.1
  run_verbose npm install -g npm@8.3.0
else
  echo "Version ${XBB_VERSION} not supported."
  exit 1
fi

# -----------------------------------------------------------------------------

echo
echo "Container done."

# -----------------------------------------------------------------------------
