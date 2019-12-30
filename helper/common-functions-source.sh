# Common functions used for building the XBB environments.

CACHE_FOLDER_PATH="${HOME}/Work/cache"

# =============================================================================

function init_input()
{
  rm -rf "input"
  mkdir -p "input"

  if [ -d "container-scripts" ]
  then
    cp "container-scripts"/*.sh "input"
  fi
}

function clean_input()
{
  rm -rf "input"
}

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

function docker_build_from_archive()
{
  arch="$1"
  archive_name="$2"
  tag="$3"

  download_rootfs "${archive_name}"

  # Assume "input" was created by init_input().
  cp "${CACHE_FOLDER_PATH}/${archive_name}" "input"

  echo 
  echo "Building Docker image..."
  docker build --tag "${tag}" -f "${arch}-Dockerfile" .
}

# =============================================================================
