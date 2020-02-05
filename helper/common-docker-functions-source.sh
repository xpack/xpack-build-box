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

function host_init_docker_env()
{
  WORK_FOLDER_PATH="${HOME}/Work"
  CACHE_FOLDER_PATH="${WORK_FOLDER_PATH}/cache"

  cd "${script_folder_path}"
}

function host_init_docker_input()
{
  rm -rf "${script_folder_path}/input"
  mkdir -p "${script_folder_path}/input/helper/patches"

  if [ -d "${script_folder_path}/container-scripts" ]
  then
    ln -v "${script_folder_path}/container-scripts"/*.sh "${script_folder_path}/input"
  fi

  # Using hard links simplifies development, since edits will no longer 
  # need to be propagated back.

  # Hard link the entire content of the helper folder.
  ln -v "${helper_folder_path}"/*.sh "${script_folder_path}/input/helper"
  ln -v "${helper_folder_path}"/pkg-config-verbose "${script_folder_path}/input/helper"

  ln -v "${helper_folder_path}/patches"/*.patch "${script_folder_path}/input/helper/patches"
  
  # Possibly hard link additional files.
  while [ $# -gt 0 ]
  do
    if [ -f "$1" ]
    then
      ln -v "$1" "${script_folder_path}/input/helper"
    elif [ -d "$1" ]
    then
      local subfolder=$(basename "$1")
      mkdir -p "${script_folder_path}/input/helper/${subfolder}"
      ln -v "$1"/* "${script_folder_path}/input/helper/${subfolder}"
    fi

    shift
  done
}

function host_clean_docker_input()
{
  rm -rf "${script_folder_path}/input"
}

function host_run_docker_it()
{
  out="${HOME}/opt/${name}-${arch}"
  mkdir -p "${out}"

  echo 
  echo "Running parent Docker image ${from}..."
  docker run \
    --interactive \
    --tty \
    --hostname "${name}-${arch}" \
    --workdir="/root" \
    --volume="${WORK_FOLDER_PATH}:/root/Work" \
    --volume="${script_folder_path}/input:/input" \
    --volume="${out}:/opt/${name}" \
    ${from}

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
  
  IS_BOOTSTRAP=${IS_BOOTSTRAP:-""}

  # The place where files are downloaded.
  CACHE_FOLDER_PATH="${WORK_FOLDER_PATH}/cache"

  if [ "${IS_BOOTSTRAP}" == "y" ]
  then
    # Make all tools choose gcc, not the old cc.
    export CC=gcc
    export CXX=g++
  else
    # Build the XBB tools with the bootstrap compiler.
    # Some packages fail, and have to revert to the Apple clang.
    CC="gcc-8bs"
    CXX="g++-8bs"
  fi
  
  echo
  echo "env..."
  env
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
