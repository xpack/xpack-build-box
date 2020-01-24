# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (http://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software 
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# Common functions used for building the XBB environments.

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

# =============================================================================

function detect_host()
{
  echo
  uname -a

  HOST_UNAME="$(uname)"
  HOST_MACHINE="$(uname -m)"

  HOST_DISTRO_NAME="?" # Linux distribution name (Ubuntu|CentOS|...)
  HOST_DISTRO_LC_NAME="?" # Same, in lower case.

  HOST_NODE_ARCH="?" # Node.js process.arch (x32|x64|arm|arm64)
  HOST_NODE_PLATFORM="?" # Node.js process.platform (darwin|linux|win32)

  if [ "${HOST_UNAME}" == "Darwin" ]
  then
    # uname -p -> i386
    # uname -m -> x86_64

    HOST_BITS="64"

    HOST_DISTRO_NAME=Darwin
    HOST_DISTRO_LC_NAME=darwin

    HOST_NODE_ARCH="x64" # For now.
    HOST_NODE_PLATFORM="darwin"

    BUILD="$(gcc -print-effective-triple)"

  elif [ "${HOST_UNAME}" == "Linux" ]
  then
    # ----- Determine distribution name and word size -----

    # uname -p -> x86_64|i686 (unknown in recent versions, use -m)
    # uname -m -> x86_64|i686|aarch64|armv7l

    if [ "${HOST_MACHINE}" == "x86_64" ]
    then
      HOST_BITS="64"
      HOST_NODE_ARCH="x64"
    elif [ "${HOST_MACHINE}" == "i686" ]
    then
      HOST_BITS="32"
      HOST_NODE_ARCH="x32"
    elif [ "${HOST_MACHINE}" == "aarch64" ]
    then
      HOST_BITS="64"
      HOST_NODE_ARCH="arm64"
    elif [ "${HOST_MACHINE}" == "armv7l" -o "${HOST_MACHINE}" == "armv8l" ]
    then
      HOST_BITS="32"
      HOST_NODE_ARCH="arm"
    else
      echo "Unknown uname -m ${HOST_MACHINE}"
      exit 1
    fi

    HOST_NODE_PLATFORM="linux"

    local lsb_path=$(which lsb_release)
    if [ -z "${lsb_path}" ]
    then
      echo "Please install the lsb core package and rerun."
      exit 1
    fi

    HOST_DISTRO_NAME=$(lsb_release -si)
    HOST_DISTRO_LC_NAME=$(echo ${HOST_DISTRO_NAME} | tr "[:upper:]" "[:lower:]")

    BUILD="$(gcc -dumpmachine)"

  else
    echo "Unsupported uname ${HOST_UNAME}"
    exit 1
  fi

  # x86_64-w64-mingw32 or i686-w64-mingw32
  MINGW_TARGET="${HOST_MACHINE}-w64-mingw32"

  echo
  echo "Running on ${HOST_DISTRO_NAME} ${HOST_NODE_ARCH} (${HOST_BITS}-bit)."

  USER_ID=$(id -u)
  USER_NAME="$(id -u -n)"
  GROUP_ID=$(id -g)
  GROUP_NAME="$(id -g -n)"
}

function prepare_xbb_env()
{
  if [ "${IS_BOOTSTRAP}" != "y" ]
  then
    if [ ! -d "${XBB_BOOTSTRAP_FOLDER}" -o ! -x "${XBB_BOOTSTRAP_FOLDER}/bin/${CXX}" ]
    then
      echo "XBB Bootstrap not found in \"${XBB_BOOTSTRAP_FOLDER}\""
      exit 1
    fi
  fi
  
  CACHE_FOLDER_PATH="${WORK_FOLDER_PATH}/cache"

  XBB_WORK_FOLDER_PATH="${WORK_FOLDER_PATH}/$(basename "${XBB_FOLDER}")"

  BUILD_FOLDER_PATH="${XBB_WORK_FOLDER_PATH}/build"
  LIBS_BUILD_FOLDER_PATH="${XBB_WORK_FOLDER_PATH}/build/libs"
  SOURCES_FOLDER_PATH="${XBB_WORK_FOLDER_PATH}/sources"
  STAMPS_FOLDER_PATH="${XBB_WORK_FOLDER_PATH}/stamps"
  LOGS_FOLDER_PATH="${XBB_WORK_FOLDER_PATH}/logs"

  INSTALL_FOLDER_PATH="${XBB_FOLDER}"

  # ---------------------------------------------------------------------------

  if [ "${HOST_UNAME}" == "Darwin" ]
  then
    macos_version=$(defaults read loginwindow SystemVersionStampAsString)
    xclt_version=$(xcode-select --version | sed -e 's/xcode-select version \([0-9]*\)\./\1/')

    CC=${CC:-"clang"}
    CXX=${CXX:-"clang++"}
  else
    CC=${CC:-"gcc"}
    CXX=${CXX:-"g++"}
  fi

  # ---------------------------------------------------------------------------

  mkdir -p "${INSTALL_FOLDER_PATH}"

  mkdir -p "${CACHE_FOLDER_PATH}"
  mkdir -p "${BUILD_FOLDER_PATH}"
  mkdir -p "${LIBS_BUILD_FOLDER_PATH}"
  mkdir -p "${SOURCES_FOLDER_PATH}"
  mkdir -p "${STAMPS_FOLDER_PATH}"
  mkdir -p "${LOGS_FOLDER_PATH}"

  mkdir -p "${INSTALL_FOLDER_PATH}/bin"
  mkdir -p "${INSTALL_FOLDER_PATH}/include"
  mkdir -p "${INSTALL_FOLDER_PATH}/lib"

  # ---------------------------------------------------------------------------

  JOBS=${JOBS:-"1"}

  XBB_CPPFLAGS=""

  XBB_CFLAGS="-pipe"
  XBB_CXXFLAGS="-pipe"

  XBB_LDFLAGS=""
  XBB_LDFLAGS_LIB="${XBB_LDFLAGS}"
  XBB_LDFLAGS_APP="${XBB_LDFLAGS}"
  XBB_LDFLAGS_APP_STATIC="${XBB_LDFLAGS_APP}"

  # ---------------------------------------------------------------------------

  install -m 755 -c "${helper_folder_path}/pkg-config-verbose" "${INSTALL_FOLDER_PATH}/bin/pkg-config-verbose" 

  PKG_CONFIG="${INSTALL_FOLDER_PATH}/bin/pkg-config-verbose"

  echo "${XBB_VERSION}" >  "${INSTALL_FOLDER_PATH}/VERSION"

  # ---------------------------------------------------------------------------

  PATH=${PATH:-""}

  PKG_CONFIG_PATH=${PKG_CONFIG_PATH:-":"}

  # Prevent pkg-config to search the system folders (configured in the
  # pkg-config at build time).
  PKG_CONFIG_LIBDIR=${PKG_CONFIG_LIBDIR:-":"}

  # ---------------------------------------------------------------------------

  export XBB_CPPFLAGS
  export XBB_CFLAGS
  export XBB_CXXFLAGS
  export XBB_LDFLAGS
  export XBB_LDFLAGS_LIB
  export XBB_LDFLAGS_APP
  export XBB_LDFLAGS_APP_STATIC

  export PATH
  export PKG_CONFIG_PATH
  export PKG_CONFIG_LIBDIR
  export PKG_CONFIG

  export CC
  export CXX

  export SHELL="/bin/bash"
  export CONFIG_SHELL="/bin/bash"
}

# -----------------------------------------------------------------------------

# For the XBB builds, add the freshly built binaries.
function xbb_activate_installed_bin()
{
  # Add the XBB bin to the PATH.
  PATH="${INSTALL_FOLDER_PATH}/bin:${PATH}"

  export PATH
}

# For the XBB builds, add the freshly built headrs and libraries.
function xbb_activate_installed_dev()
{
  # Add XBB include in front of XBB_CPPFLAGS.
  XBB_CPPFLAGS="-I${INSTALL_FOLDER_PATH}/include ${XBB_CPPFLAGS}"

  # Add XBB lib in front of XBB_LDFLAGS.
  XBB_LDFLAGS="-L${INSTALL_FOLDER_PATH}/lib ${XBB_LDFLAGS}"
  XBB_LDFLAGS_LIB="-L${INSTALL_FOLDER_PATH}/lib ${XBB_LDFLAGS_LIB}"
  XBB_LDFLAGS_APP="-L${INSTALL_FOLDER_PATH}/lib ${XBB_LDFLAGS_APP}"
  XBB_LDFLAGS_APP_STATIC="-L${INSTALL_FOLDER_PATH}/lib ${XBB_LDFLAGS_APP_STATIC}"

  # Add XBB lib in front of PKG_CONFIG_PATH.
  PKG_CONFIG_PATH="${INSTALL_FOLDER_PATH}/lib/pkgconfig:${PKG_CONFIG_PATH}"

  export XBB_CPPFLAGS

  export XBB_LDFLAGS
  export XBB_LDFLAGS_LIB
  export XBB_LDFLAGS_APP
  export XBB_LDFLAGS_APP_STATIC

  export PKG_CONFIG_PATH
}

# -----------------------------------------------------------------------------

function create_xbb_source()
{
  echo
  echo "Creating ${INSTALL_FOLDER_PATH}/xbb-source.sh..."
  cat <<'__EOF__' > "${INSTALL_FOLDER_PATH}/xbb-source.sh"
# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (http://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software 
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

export TEXLIVE_FOLDER="${HOME}/opt/texlive"
__EOF__
# The above marker must start in the first column.

  if [ "${IS_BOOTSTRAP}" == "y" ]
  then
    echo "export XBB_BOOTSTRAP_FOLDER=\"\${HOME}/opt/$(basename "${XBB_FOLDER}")\"" >> "${INSTALL_FOLDER_PATH}/xbb-source.sh"
  else
    echo "export XBB_FOLDER=\"\${HOME}/opt/$(basename "${XBB_FOLDER}")\"" >> "${INSTALL_FOLDER_PATH}/xbb-source.sh"
  fi

  echo "export XBB_VERSION=\"${XBB_VERSION}\"" >> "${INSTALL_FOLDER_PATH}/xbb-source.sh"

  if [ "${IS_BOOTSTRAP}" == "y" ]
  then

    # Note: __EOF__ is quoted to prevent substitutions here.
    cat <<'__EOF__' >> "${INSTALL_FOLDER_PATH}/xbb-source.sh"

# Adjust PATH to prefer the XBB bootstrap binaries.
function xbb_activate_bootstrap()
{
  PATH="${XBB_BOOTSTRAP_FOLDER}/bin:${PATH}"

  export PATH
}
__EOF__
# The above marker must start in the first column.

  else

    # Note: __EOF__ is quoted to prevent substitutions here.
    cat <<'__EOF__' >> "${INSTALL_FOLDER_PATH}/xbb-source.sh"

# Adjust PATH to prefer the XBB binaries.
function xbb_activate()
{
  PATH="${XBB_FOLDER}/bin:${PATH}"

  export PATH
}
__EOF__
# The above marker must start in the first column.

  fi

  # Note: __EOF__ is quoted to prevent substitutions here.
  cat <<'__EOF__' >> "${INSTALL_FOLDER_PATH}/xbb-source.sh"

# Add TeX to PATH.
function xbb_activate_tex()
{
  PATH="${TEXLIVE_FOLDER}/bin/$(uname -m)-${HOST_DISTRO_LC_NAME}:${PATH}"

  export PATH
}

__EOF__
# The above marker must start in the first column.
}

# -----------------------------------------------------------------------------

function extract()
{
  local archive_name="$1"
  local folder_name="$2"
  # local patch_file_name="$3"
  local pwd="$(pwd)"

  if [ ! -d "${folder_name}" ]
  then
    (
      xbb_activate

      echo
      echo "Extracting \"${archive_name}\"..."
      if [[ "${archive_name}" == *zip ]]
      then
        unzip "${archive_name}" 
      else
        tar xf "${archive_name}"
      fi

      if [ $# -gt 2 ]
      then
        if [ ! -z "$3" ]
        then
          local patch_path="$3"
          if [ -f "${patch_path}" ]
          then
            echo "Patching..."
            cd "${folder_name}"
            patch -p0 < "${patch_path}"
          fi
        fi
      fi
    )
  else
    echo "Folder \"${pwd}/${folder_name}\" already present."
  fi
}

function download()
{
  local url="$1"
  local archive_name="$2"

  if [ ! -f "${CACHE_FOLDER_PATH}/${archive_name}" ]
  then
    (
      xbb_activate

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

function download_and_extract()
{
  local url="$1"
  local archive_name="$2"
  local folder_name="$3"

  download "${url}" "${archive_name}"
  if [ $# -gt 3 ]
  then
    extract "${CACHE_FOLDER_PATH}/${archive_name}" "${folder_name}" "$4"
  else
    extract "${CACHE_FOLDER_PATH}/${archive_name}" "${folder_name}"
  fi
}

# -----------------------------------------------------------------------------

do_strip_libs() 
{
  echo
  echo "Stipping libraries..."

  (
    cd "${XBB_FOLDER}"

    xbb_activate

    local strip
    if [ -f "${XBB_FOLDER}/bin/strip" ]
    then
      strip="${XBB_FOLDER}/bin/strip"
    elif [ -f "${XBB_BOOTSTRAP_FOLDER}/bin/strip" ]
    then
      strip="${XBB_BOOTSTRAP_FOLDER}/bin/strip"
    else
      strip="strip"
    fi

    local ranlib
    if [ -f "${XBB_FOLDER}/bin/ranlib" ]
    then
      ranlib="${XBB_FOLDER}/bin/ranlib"
    elif [ -f "${XBB_BOOTSTRAP_FOLDER}/bin/ranlib" ]
    then
      ranlib="${XBB_BOOTSTRAP_FOLDER}/bin/ranlib"
    else
      ranlib="ranlib"
    fi

    set +e
    # -type f to skip links.
    find lib* \
      -type f \
      -name '*.so' \
      -print \
      -exec chmod +w {} \; \
      -exec "${strip}" --strip-debug {} \;
    find lib* \
      -type f \
      -name '*.so.*' \
      -print \
      -exec chmod +w {} \; \
      -exec "${strip}" --strip-debug {} \;
    find lib* \
      -type f \
      -name '*.a' \
      -not -path 'lib/gcc/*-w64-mingw32/*'  \
      -print \
      -exec chmod +w {} \; \
      -exec "${strip}" --strip-debug {} \; \
      -exec "${ranlib}" {} \;
    set -e
  )
}

# -----------------------------------------------------------------------------

do_cleaunup() 
{
  # In bootstrap preserve download, it'll be used by xbb and removed later.
  if [ "${IS_BOOTSTRAP}" != "y" ]
  then
    rm -rf "${CACHE_FOLDER_PATH}"
  fi

  # All other can go.
  rm -rf "${XBB_WORK_FOLDER_PATH}"
}

# =============================================================================
