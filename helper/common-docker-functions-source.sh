# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (http://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software 
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# Common functions used for building the XBB environments.

# =============================================================================

function host_init_docker_input()
{
  rm -rf "input"
  mkdir -p "input/helper"

  if [ -d "container-scripts" ]
  then
    cp "container-scripts"/*.sh "input"
  fi
}

function host_init_docker_env()
{
  WORK_FOLDER_PATH="${HOME}/Work"
  CACHE_FOLDER_PATH="${WORK_FOLDER_PATH}/cache"
}

# =============================================================================

function xbb_activate()
{
  :
}

# =============================================================================

function docker_prepare_env()
{
  if [ ! -d "${WORK_FOLDER_PATH}" ]
  then
    mkdir -p "${WORK_FOLDER_PATH}"
    touch "${WORK_FOLDER_PATH}/.dockerenv"
  fi
  
  # The place where files are downloaded.
  CACHE_FOLDER_PATH="${WORK_FOLDER_PATH}/cache"

  # Make all tools choose gcc, not the old cc.
  export CC=gcc
  export CXX=g++
}

function docker_download_rootfs()
{
  local archive_name="$1"

  # No trailing slash.
  download "https://github.com/xpack/xpack-build-box/releases/download/rootfs/${archive_name}" "${archive_name}"
}

# =============================================================================

function docker_build_from_archive()
{
  arch="$1"
  archive_name="$2"
  tag="$3"

  docker_download_rootfs "${archive_name}"

  # Assume "input" was created by init_input().
  cp "${CACHE_FOLDER_PATH}/${archive_name}" "input"

  echo 
  echo "Building Docker image..."
  docker build --tag "${tag}" -f "${arch}-Dockerfile" .
}

# =============================================================================
