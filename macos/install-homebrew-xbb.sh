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

echo
echo "Checking if Xcode Command Line Tools are installed..."
xcode-select -p

# -----------------------------------------------------------------------------

HB_PREFIX=${HB_PREFIX:-"$HOME/opt/homebrew/xbb"}
export HOMEBREW_NO_EMOJI=1

echo "Recreating \"${HB_PREFIX}\"..."
rm -rf "${HB_PREFIX}"
mkdir -p "${HB_PREFIX}"

PATH=${HB_PREFIX}/bin:${PATH}

# -----------------------------------------------------------------------------

bash -c "(curl -L https://github.com/Homebrew/homebrew/tarball/master | \
  tar -x -v --strip 1 -C "${HB_PREFIX}" -f -)"
  
brew --version

echo "Updating homebrew..."
rm -rf "${HB_PREFIX}/share/doc/homebrew"
brew update

# -----------------------------------------------------------------------------

brew install curl
brew link curl --force

brew install autoconf automake
brew install cmake
brew install pkg-config

# Required by QEMU
brew install gettext
brew link gettext --force

# makeinfo required to build openOCD & QEMU manuals.
brew install texinfo
brew link texinfo --force

# libtool required to build openOCD (bootstrap) 
brew install libtool

brew install readline
brew link readline --force

# gawk & gsed required by GCC
brew install gawk gnu-sed

# Same as for CentOS XBB (missing 'patch')
brew install git python perl flex dos2unix wget make diffutils m4 bison gpatch
brew link sqlite --force
brew link openssl --force
brew link flex --force
brew link m4 --force
brew link bison --force

brew install gnu-tar

# OpenOCD does not build with gcc-7 :-(
# brew install gcc

# -----------------------------------------------------------------------------

cat <<'__EOF__' > "${HB_PREFIX}"/bin/pkg-config-verbose
#! /bin/sh
# pkg-config wrapper for debug

pkg-config $@
RET=$?
OUT=$(pkg-config $@)
echo "($PKG_CONFIG_PATH) | pkg-config $@ -> $RET [$OUT]" 1>&2
exit ${RET}

__EOF__

chmod +x "${HB_PREFIX}"/bin/pkg-config-verbose

# -----------------------------------------------------------------------------

cat <<'__EOF__' > "${HB_PREFIX}"/bin/xbb-source.sh

export XBB_FOLDER="${HOME}/opt/homebrew/xbb"
export TEXLIVE_FOLDER="${HOME}/opt/texlive"

function xbb_activate()
{
  PATH=${PATH:-""}
  PATH=${TEXLIVE_FOLDER}/bin/$(uname -m)-darwin:${PATH}
  PATH="${XBB_FOLDER}"/opt/gnu-tar/libexec/gnubin:${PATH}
  export PATH="${XBB_FOLDER}"/bin:${PATH}

  LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-""}
  export LD_LIBRARY_PATH="${XBB_FOLDER}/lib:${LD_LIBRARY_PATH}"
}

__EOF__


# -----------------------------------------------------------------------------

# To use Homebrew, add something like this to ~/.profile
echo alias axbb=\'export PATH=${HB_PREFIX}/bin:\${PATH}\'
