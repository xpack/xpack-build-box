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

XBB_FOLDER=${XBB_FOLDER:-"${HOME}/opt/homebrew/xbb"}

mkdir -p "${XBB_FOLDER}"/bin

# -----------------------------------------------------------------------------
# Create a more verbose pkg-config.

echo
echo "Copying ${XBB_FOLDER}/bin/pkg-config-verbose..."
cp "$(dirname "${script_folder_path}")"/scripts/pkg-config-verbose "${XBB_FOLDER}"/bin
chmod +x "${XBB_FOLDER}"/bin/pkg-config-verbose

# -----------------------------------------------------------------------------
# Create the XBB activator script.

echo "Creating ${XBB_FOLDER}/xbb-source.sh..."
cat <<'__EOF__' > "${XBB_FOLDER}"/xbb-source.sh

export XBB_FOLDER="${HOME}"/opt/homebrew/xbb
export TEXLIVE_FOLDER="${HOME}"/opt/texlive

# Allow binaries from XBB to be found before all other.
# Includes and pkg_config should be enabled only when needed.
function xbb_activate()
{
  PATH=${PATH:-""}
  PATH=${TEXLIVE_FOLDER}/bin/$(uname -m)-darwin:${PATH}
  PATH="${XBB_FOLDER}"/opt/gnu-tar/libexec/gnubin:${PATH}
  PATH="${XBB_FOLDER}"/opt/coreutils/libexec/gnubin:${PATH}
  PATH="${XBB_FOLDER}"/opt/make/libexec/gnubin:${PATH}
  export PATH="${XBB_FOLDER}"/bin:${PATH}

  LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-""}
  export LD_LIBRARY_PATH="${XBB_FOLDER}/lib:${LD_LIBRARY_PATH}"
}

# Allow for pkg_config files to be found before all other.
function xbb_activate_pkgconfig()
{
  export PKG_CONFIG_PATH="${XBB_FOLDER}/lib/pkgconfig:${PKG_CONFIG_PATH}"

  export PKG_CONFIG=pkg-config-verbose
}

# Add the XBB include folders to the preprocessor defs.
function xbb_activate_includes()
{
  EXTRA_CPPFLAGS=${EXTRA_CPPFLAGS:-""}

  export EXTRA_CPPFLAGS="-I${XBB_FOLDER}/include ${EXTRA_CPPFLAGS}"
}

# Make the build use the XBB libs & includes.
function xbb_activate_dev()
{
  xbb_activate_pkgconfig
  xbb_activate_includes
}

__EOF__

# -----------------------------------------------------------------------------

echo "Done."

# -----------------------------------------------------------------------------

