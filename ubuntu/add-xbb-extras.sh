#!/usr/bin/env bash

# -----------------------------------------------------------------------------

# This script adds the XBB extra scripts.

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
# Identify helper scripts.

build_script_path=$0
if [[ "${build_script_path}" != /* ]]
then
  # Make relative path absolute.
  build_script_path=$(pwd)/$0
fi

script_folder_path="$(dirname ${build_script_path})"
script_folder_name="$(basename ${script_folder_path})"

# -----------------------------------------------------------------------------
# Definitions.

XBB_FOLDER_PATH=${XBB_FOLDER_PATH:-/opt/xbb}

mkdir -p "${XBB_FOLDER_PATH}"/bin

# -----------------------------------------------------------------------------
# Create a more verbose pkg-config.

echo
echo "Copying ${XBB_FOLDER_PATH}/bin/pkg-config-verbose..."
cp "$(dirname "${script_folder_path}")/scripts/pkg-config-verbose" "${XBB_FOLDER_PATH}/bin"
chmod +x "${XBB_FOLDER_PATH}/bin/pkg-config-verbose"

# -----------------------------------------------------------------------------
# Create the XBB activator script.

echo "Creating ${XBB_FOLDER_PATH}/xbb-source.sh..."
cat <<'__EOF__' > "${XBB_FOLDER_PATH}/xbb-source.sh"

export XBB_FOLDER_PATH="/opt/xbb"

# Allow binaries from XBB to be found before all other.
# Includes and pkg_config should be enabled only when needed.
function xbb_activate()
{
  PATH=${PATH:-""}
  export PATH="${XBB_FOLDER_PATH}/bin:${PATH}"

  LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-""}
  export LD_LIBRARY_PATH="${XBB_FOLDER_PATH}/lib:${LD_LIBRARY_PATH}"
}

# Allow for the headers and pkg_config files to be found before all other.
function xbb_activate_dev()
{
  EXTRA_CPPFLAGS=${EXTRA_CPPFLAGS:-""}

  if [ ! -z "${PKG_CONFIG_PATH}" ]
  then
    if [ -d "/usr/lib/pkgconfig" ]
    then
      PKG_CONFIG_PATH="/usr/lib/pkgconfig"
    fi
  fi
  if [ \( "${TARGET_BITS}" == "64" \) -a \( -d "/usr/lib/x86_64-linux-gnu/pkgconfig" \) ]
  then
    PKG_CONFIG_PATH="/usr/lib/x86_64-linux-gnu/pkgconfig:${PKG_CONFIG_PATH}"
  fi
  export PKG_CONFIG_PATH

  export PKG_CONFIG="pkg-config-verbose"
}

__EOF__

# -----------------------------------------------------------------------------

echo "Done."

# -----------------------------------------------------------------------------
