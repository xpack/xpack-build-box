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

# Walk two steps up.
helper_folder_path="$(dirname $(dirname "${script_folder_path}"))/helper"

source "${helper_folder_path}/common-functions-source.sh"
source "${helper_folder_path}/common-docker-functions-source.sh"

# -----------------------------------------------------------------------------

version="3.3"

arch="i386"
distro="ubuntu"
release="16.04"
from="ilegeul/${distro}:${arch}-${release}-develop-v${version}"
layer="tex"

# -----------------------------------------------------------------------------

detect_host

host_init_docker_env
host_init_docker_input \
  "$(dirname $(dirname "${script_folder_path}"))/ca-bundle/ca-bundle.crt" \

host_run_docker_it_with_image

host_clean_docker_input

echo
echo "Done."

# -----------------------------------------------------------------------------
