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

source "${helper_folder_path}/common-docker-functions-source.sh"

# -----------------------------------------------------------------------------

env
unset TERM

# -----------------------------------------------------------------------------

# Hack from https://github.com/Microsoft/WSL/issues/143#issuecomment-209075558
# copy+pasta-able version of canonical's fix via @russalex

cat <<__EOF__ >"/usr/sbin/policy-rc.d"
#!/bin/sh
exit 101
__EOF__

chmod +x "/usr/sbin/policy-rc.d"
dpkg-divert --local --rename --add /sbin/initctl
ln -s /bin/true /sbin/initctl

# -----------------------------------------------------------------------------

docker_replace_source_list "http://old-releases.ubuntu.com/ubuntu/" "precise"

# -----------------------------------------------------------------------------

echo
echo "Container done."

# -----------------------------------------------------------------------------
