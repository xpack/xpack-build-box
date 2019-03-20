#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (http://xpack.github.io)
# Copyright (c) 2019 Liviu Ionescu.
#
# Permission to use, copy, modify, and distribute this software
# is governed under the terms of the MIT license.
# -----------------------------------------------------------------------------

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

# Script to build a subsequent version of a Docker image with the 
# xPack Build Box (xbb).

# To activate the new build environment, use:
#
#   $ source /opt/xbb/xbb-source.sh
#   $ xbb_activate

XBB_INPUT="/xbb-input"
source "${XBB_INPUT}/common-functions-source.sh"

prepare_env

# -----------------------------------------------------------------------------

# Make the functions available to the entire script.
source "${XBB_FOLDER}/xbb-source.sh"

# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
