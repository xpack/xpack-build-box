#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Safety settings (see https://gist.github.com/ilg-ul/383869cbb01f61a51c4d).

if [[ ! -z ${DEBUG} ]]
then
  set ${DEBUG} # Activate the expand mode if DEBUG is -x.
else
  DEBUG=""
fi

set -o errexit # Exit if command failed.
set -o pipefail # Exit if pipe failed.
set -o nounset # Exit if variable not set.

# Remove the initial space and instead use '\n'.
IFS=$'\n\t'

# -----------------------------------------------------------------------------

# echo
# echo "Checking if Xcode Command Line Tools are installed..."
# xcode-select -print-path

# -----------------------------------------------------------------------------
# This script installs a local instance of TeX Live (https://tug.org/texlive/).

tl_edition="2016"
tl_archive_name="install-tl-unx.tar.gz"
tl_archive_path="$HOME/Downloads/${tl_edition}-${tl_archive_name}"
tl_folder="/tmp/install-tl"

# tl_url="http://mirror.ctan.org/"
# tl_repo_url="${tl_url}"/systems/texlive/tlnet
# tl_archive_url="${tl_url}"/systems/texlive/tlnet/${tl_archive_name}

# The main URL has a connection limit of 10, it is not usable.
# tl_url="ftp://tug.org/historic"
tl_url="ftp://ftp.math.utah.edu/pub/tex/historic"

tl_repo_url="${tl_url}"/systems/texlive/${tl_edition}/tlnet-final
tl_archive_url="${tl_url}"/systems/texlive/${tl_edition}/${tl_archive_name}

# The install destination folder.
texlive_prefix="${HOME}/opt/texlive"

# -----------------------------------------------------------------------------

# Download the install tools.
echo
echo "Downloading '${tl_archive_url}'..."
curl --fail -L "${tl_archive_url}" -o "${tl_archive_path}"

rm -rf "${tl_folder}"
mkdir -p "${tl_folder}"

# Unpack the install tools.
echo
echo "Unpacking '${tl_archive_path}'..."
tar x -v -C "${tl_folder}" --strip-components 1 -f "${tl_archive_path}"

# -----------------------------------------------------------------------------

if [ -d "${texlive_prefix}" ]
then
  rm -rf "${texlive_prefix}.bak"
  echo "Backing-up previous install..."
  mv "${texlive_prefix}" "${texlive_prefix}.bak"
fi

mkdir -p "${texlive_prefix}"

# -----------------------------------------------------------------------------

# Create the texlive.profile used to automate the install.
# These definitions are specific to TeX Live 2016.
tmp_profile=$(mktemp /tmp/texlive.XXXXXX)

# Note: __EOF__ is not quoted to allow local substitutions.
cat <<__EOF__ >> "${tmp_profile}"
# texlive.profile
TEXDIR ${texlive_prefix}
TEXMFCONFIG ~/.texlive/texmf-config
TEXMFHOME ~/texmf
TEXMFLOCAL ${texlive_prefix}/texmf-local
TEXMFSYSCONFIG ${texlive_prefix}/texmf-config
TEXMFSYSVAR ${texlive_prefix}/texmf-var
TEXMFVAR ~/.texlive/texmf-var

option_doc 0
option_src 0
__EOF__

# -----------------------------------------------------------------------------

# https://www.tug.org/texlive/doc/install-tl.html

export PATH="${texlive_prefix}"/bin/x86_64-darwin:${PATH}

# Schmes: basic (~80 packs), medium (~1000 packs), full (~3400)
echo
echo "Running install-tl..."
time "${tl_folder}/install-tl" \
-repository ${tl_repo_url} \
-no-gui \
-lang en \
-profile "${tmp_profile}" \
-scheme medium

# tlmgr install collection-fontsrecommended

# Keep no backups (not required, simply makes cache bigger)
tlmgr option -- autobackup 0

# -----------------------------------------------------------------------------

# rm "${tmp_profile}"

echo
echo "Done."

# -----------------------------------------------------------------------------
