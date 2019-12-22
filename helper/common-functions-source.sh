# Common functions used for building the XBB environments.

CACHE_FOLDER_PATH="${HOME}/Work/cache"

# =============================================================================

function download()
{
  local url="$1"
  local archive_name="$2"

  if [ ! -f "${CACHE_FOLDER_PATH}/${archive_name}" ]
  then
    (
      echo
      echo "Downloading \"${archive_name}\" from \"${url}\"..."
      rm -f "${CACHE_FOLDER_PATH}/${archive_name}.download"
      mkdir -p "${CACHE_FOLDER_PATH}"
      curl --fail -L -o "${CACHE_FOLDER_PATH}/${archive_name}.download" "${url}"
      mv "${CACHE_FOLDER_PATH}/${archive_name}.download" "${CACHE_FOLDER_PATH}/${archive_name}"
    )
  else
    echo "File \"${CACHE_FOLDER_PATH}/${archive_name}\" already downloaded."
  fi

}

function download_rootfs()
{
  local archive_name="$1"

  # No trailing slash.
  download "https://github.com/xpack/xpack-build-box/releases/download/rootfs/${archive_name}" "${archive_name}"
}

# =============================================================================

function docker_build()
{
  arch="$1"
  distro_nickname="$2"
  tag="$3"

  archive_name="${arch}-${distro_nickname}-rootfs.xz"
  if [ ! -f "input/${archive_name}" ]
  then
    download_rootfs "${archive_name}"

    cp "${CACHE_FOLDER_PATH}/${archive_name}" "input"
  fi

  echo 
  echo "Building Docker image..."
  docker build --tag "${tag}" -f "${arch}-Dockerfile" .
}

# =============================================================================
