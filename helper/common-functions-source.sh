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

function do_prerequisites()
{
  detect_host

  docker_prepare_env

  prepare_xbb_env

  create_xbb_source
}

function detect_host()
{
  echo
  uname -a

  HOST_UNAME="$(uname)"
  HOST_LC_UNAME=$(echo ${HOST_UNAME} | tr "[:upper:]" "[:lower:]")

  HOST_MACHINE="$(uname -m)"

  HOST_DISTRO_NAME="?" # Linux distribution name (Ubuntu|CentOS|...)
  HOST_DISTRO_LC_NAME="?" # Same, in lower case.
  HOST_DISTRO_RELEASE="?"

  HOST_NODE_ARCH="?" # Node.js process.arch (x32|x64|arm|arm64)
  HOST_NODE_PLATFORM="?" # Node.js process.platform (darwin|linux|win32)

  IS_HOST_ARM=""
  IS_HOST_INTEL=""

  if [ "${HOST_UNAME}" == "Darwin" ]
  then
    # uname -p -> i386
    # uname -m -> x86_64

    HOST_BITS="64"

    HOST_DISTRO_NAME="$(sw_vers -productName)"
    HOST_DISTRO_LC_NAME=$(echo ${HOST_DISTRO_NAME} | sed -e 's/ //g' | tr "[:upper:]" "[:lower:]")
    HOST_DISTRO_RELEASE="$(sw_vers -productVersion)"

    HOST_NODE_ARCH="x64" # For now.
    HOST_NODE_PLATFORM="darwin"

    BUILD="$(gcc --version 2>&1 | grep 'Target:' | sed -e 's/Target: //')"

  elif [ "${HOST_UNAME}" == "Linux" ]
  then
    # ----- Determine distribution name and word size -----

    # uname -p -> x86_64|i686 (unknown in recent versions, use -m)
    # uname -m -> x86_64|i686|aarch64|armv7l

    if [ "${HOST_MACHINE}" == "x86_64" ]
    then
      HOST_BITS="64"
      HOST_NODE_ARCH="x64"
      IS_HOST_INTEL="y"
    elif [ "${HOST_MACHINE}" == "i686" ]
    then
      HOST_BITS="32"
      HOST_NODE_ARCH="x32"
      IS_HOST_INTEL="y"
    elif [ "${HOST_MACHINE}" == "aarch64" ]
    then
      HOST_BITS="64"
      HOST_NODE_ARCH="arm64"
      IS_HOST_ARM="y"
    elif [ "${HOST_MACHINE}" == "armv7l" -o "${HOST_MACHINE}" == "armv8l" ]
    then
      HOST_BITS="32"
      HOST_NODE_ARCH="arm"
      IS_HOST_ARM="y"
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

    HOST_DISTRO_RELEASE=$(lsb_release -sr)

    if [ -x "/usr/share/libtool/build-aux/config.guess" ]
    then
      BUILD="$(/usr/share/libtool/build-aux/config.guess)"
    else
      BUILD="$(gcc -dumpmachine)"
    fi

  else
    echo "Unsupported uname ${HOST_UNAME}"
    exit 1
  fi

  MACOS_SDK_PATH=""
  if [ "${HOST_UNAME}" == "Darwin" ]
  then
    local print_path="$(xcode-select -print-path)"
    if [ -d "${print_path}/SDKs/MacOSX.sdk" ]
    then
      # Without Xcode, use the SDK that comes with the CLT.
      MACOS_SDK_PATH="${print_path}/SDKs/MacOSX.sdk"
    elif [ -d "${print_path}/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk" ]
    then
      # With Xcode, chose the SDK from the macOS platform.
      MACOS_SDK_PATH="${print_path}/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
    elif [ -d "/usr/include" ]
    then
      # Without Xcode, on 10.10 there is no SDK, use the root.
      MACOS_SDK_PATH="/"
    else
      echo "Cannot find SDK in ${print_path}."
      exit 1
    fi
  fi
  export MACOS_SDK_PATH

  # x86_64-w64-mingw32 or i686-w64-mingw32
  MINGW_TARGET="${HOST_MACHINE}-w64-mingw32"

  echo
  echo "Running on ${HOST_DISTRO_NAME} ${HOST_DISTRO_RELEASE} ${HOST_MACHINE} (${HOST_BITS}-bit)."

  USER_ID=$(id -u)
  USER_NAME="$(id -u -n)"
  GROUP_ID=$(id -g)
  GROUP_NAME="$(id -g -n)"
}

function is_linux()
{
  local uname="$(uname)"
  if [ "${uname}" == "Linux" ]
  then
    return 0
  else
    return 1
  fi
}

function is_darwin()
{
  local uname="$(uname)"
  if [ "${uname}" == "Darwin" ]
  then
    return 0
  else
    return 1
  fi
}

function is_intel()
{
  local machine="$(uname -m)"
  if [ "${machine}" == "x86_64" ]
  then
    return 0
  elif [ "${machine}" == "i686" ]
  then
    return 0
  else
    return 1
  fi
}

function is_arm()
{
  local machine="$(uname -m)"
  if [ "${machine}" == "aarch64" ]
  then
    return 0
  elif [ "${machine}" == "armv8l" ]
  then
    return 0
  elif [ "${machine}" == "armv7l" ]
  then
    return 0
  else
    return 1
  fi
}

function prepare_xbb_env()
{
  IS_BOOTSTRAP=${IS_BOOTSTRAP:-""}
  RUN_LONG_TESTS=${RUN_LONG_TESTS:=""}

  if [ "${HOST_UNAME}" == "Darwin" ]
  then
    macos_version=$(defaults read loginwindow SystemVersionStampAsString)
    xclt_version=$(xcode-select --version | sed -e 's/xcode-select version \([0-9]*\)\./\1/')

    if [ "${IS_BOOTSTRAP}" == "y" ]
    then
      CC=${CC:-"clang"}
      CXX=${CXX:-"clang++"}
    else
      CC=${CC:-"gcc-8bs"}
      CXX=${CXX:-"g++-8bs"}
    fi
  else
    if [ "${IS_BOOTSTRAP}" == "y" ]
    then
      CC=${CC:-"gcc"}
      CXX=${CXX:-"g++"}
    else
      CC=${CC:-"gcc-8bs"}
      CXX=${CXX:-"g++-8bs"}
    fi
  fi

  if [ "${IS_BOOTSTRAP}" != "y" ]
  then
    if [ ! -d "${XBB_BOOTSTRAP_FOLDER_PATH}" -o ! -x "${XBB_BOOTSTRAP_FOLDER_PATH}/bin/${CXX}" ]
    then
      echo "XBB Bootstrap not found in \"${XBB_BOOTSTRAP_FOLDER_PATH}\""
      exit 1
    fi
  fi
  
  CACHE_FOLDER_PATH="${WORK_FOLDER_PATH}/cache"

  XBB_WORK_FOLDER_PATH="${WORK_FOLDER_PATH}/$(basename "${XBB_FOLDER_PATH}")-${XBB_VERSION}-${HOST_DISTRO_LC_NAME}-${HOST_DISTRO_RELEASE}-${HOST_MACHINE}"

  BUILD_FOLDER_PATH="${XBB_WORK_FOLDER_PATH}/build"
  LIBS_BUILD_FOLDER_PATH="${XBB_WORK_FOLDER_PATH}/build/libs"
  SOURCES_FOLDER_PATH="${XBB_WORK_FOLDER_PATH}/sources"
  STAMPS_FOLDER_PATH="${XBB_WORK_FOLDER_PATH}/stamps"
  LOGS_FOLDER_PATH="${XBB_WORK_FOLDER_PATH}/logs"

  INSTALL_FOLDER_PATH="${XBB_FOLDER_PATH}"

  # ---------------------------------------------------------------------------

  mkdir -p "${CACHE_FOLDER_PATH}"
  mkdir -p "${BUILD_FOLDER_PATH}"
  mkdir -p "${LIBS_BUILD_FOLDER_PATH}"
  mkdir -p "${SOURCES_FOLDER_PATH}"
  mkdir -p "${STAMPS_FOLDER_PATH}"
  mkdir -p "${LOGS_FOLDER_PATH}"

  mkdir -p "${INSTALL_FOLDER_PATH}"

  mkdir -p "${INSTALL_FOLDER_PATH}/bin"
  mkdir -p "${INSTALL_FOLDER_PATH}/include"
  mkdir -p "${INSTALL_FOLDER_PATH}/lib"

  # ---------------------------------------------------------------------------


  # This is a very important option, which has a higher precedence than 
  # LD_LIBRARY_PATH, so the binaries use exactly the shared libraries
  # that were used during link.
  XBB_RPATH=""
  
  # Darwin bootstrap uses clang, which does not enjoy -rpath.
  if [ ! \( "${IS_BOOTSTRAP}" == "y" -a "${HOST_UNAME}" == "Darwin" \) ]
  then
    if [ "${HOST_BITS}" == "64" ]
    then
      XBB_RPATH+="-Wl,-rpath,${XBB_FOLDER_PATH}/lib64 "
    fi
    XBB_RPATH+="-Wl,-rpath,${XBB_FOLDER_PATH}/lib"
  fi

  XBB_CPPFLAGS=""

  XBB_CFLAGS="-pipe"
  XBB_CXXFLAGS="-pipe"

  XBB_LDFLAGS="${XBB_RPATH}"
  XBB_LDFLAGS_LIB="${XBB_LDFLAGS}"
  XBB_LDFLAGS_LIB_STATIC_GCC="${XBB_LDFLAGS}"
  XBB_LDFLAGS_APP="${XBB_LDFLAGS}"
  XBB_LDFLAGS_APP_STATIC="${XBB_LDFLAGS_APP} -static"
  XBB_LDFLAGS_APP_STATIC_GCC="${XBB_LDFLAGS_APP}"

  if [ "${HOST_UNAME}" == "Linux" ]
  then
    # Minimise the risk of picking the wrong shared libraries.
    XBB_LDFLAGS_LIB_STATIC_GCC+=" -static-libgcc -static-libstdc++"
    XBB_LDFLAGS_APP_STATIC_GCC+=" -static-libgcc -static-libstdc++"
  fi

  # Applications should generally use STATIC_GCC, otherwise XBB apps which
  # require GCC shared libs from bootstrap might not find them.

  # ---------------------------------------------------------------------------

  install -m 755 -c "${helper_folder_path}/pkg-config-verbose" "${INSTALL_FOLDER_PATH}/bin/pkg-config-verbose" 

  PKG_CONFIG="${INSTALL_FOLDER_PATH}/bin/pkg-config-verbose"

  echo "${XBB_VERSION}" >  "${INSTALL_FOLDER_PATH}/VERSION"

  # ---------------------------------------------------------------------------

  if [ "${HOST_UNAME}" == "Darwin" ]
  then
    JOBS=${JOBS:-"$(sysctl -n hw.ncpu)"}
  else
    JOBS=${JOBS:-"$(nproc)"}
  fi

  # Default PATH.
  PATH=${PATH:-""}

  # Default LD_LIBRARY_PATH.
  LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-""}

  # Default empty PKG_CONFIG_PATH.
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
  export XBB_LDFLAGS_LIB_STATIC_GCC
  export XBB_LDFLAGS_APP
  export XBB_LDFLAGS_APP_STATIC
  export XBB_LDFLAGS_APP_STATIC_GCC

  export XBB_RPATH

  export PATH
  export LD_LIBRARY_PATH
  
  export PKG_CONFIG_PATH
  export PKG_CONFIG_LIBDIR
  export PKG_CONFIG

  export CC
  export CXX

  set +e
  local java_home=$(java -XshowSettings:properties -version 2>&1 > /dev/null | grep 'java.home' | sed -e 's/.*= //' | sed -e 's|/jre||' )
  set -e

  if [ ! -z "${java_home}" ]
  then
    export JAVA_HOME="${java_home}"
  fi

  export SHELL="/bin/bash"
  export CONFIG_SHELL="/bin/bash"

  echo
  echo "xbb env..."
  env | sort
}

# -----------------------------------------------------------------------------

# For the XBB builds, add the freshly built binaries.
function xbb_activate_installed_bin()
{
  # Add the XBB bin to the PATH.
  PATH="${INSTALL_FOLDER_PATH}/bin:${PATH}"

  # Disabled, shared libs must be located via rpath.

  # Add XBB lib to LD_LIBRARY_PATH.
  # LD_LIBRARY_PATH="${INSTALL_FOLDER_PATH}/lib:${LD_LIBRARY_PATH}"

  # if [ -d "${INSTALL_FOLDER_PATH}/lib64" ]
  # then
    # On 64-bit systems, add lib64 in front of LD_LIBRARY_PATH.
    # LD_LIBRARY_PATH="${INSTALL_FOLDER_PATH}/lib64:${LD_LIBRARY_PATH}"
  # fi

  export PATH
  # export LD_LIBRARY_PATH
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
  XBB_LDFLAGS_APP_STATIC_GCC="-L${INSTALL_FOLDER_PATH}/lib ${XBB_LDFLAGS_APP_STATIC_GCC}"

  # Add XBB lib in front of PKG_CONFIG_PATH.
  PKG_CONFIG_PATH="${INSTALL_FOLDER_PATH}/lib/pkgconfig:${PKG_CONFIG_PATH}"

  # If lib64 present, add it in front of lib.
  if [ -d "${XBB_FOLDER_PATH}/lib64" ]
  then
    XBB_LDFLAGS="-L${INSTALL_FOLDER_PATH}/lib64 ${XBB_LDFLAGS}"
    XBB_LDFLAGS_LIB="-L${INSTALL_FOLDER_PATH}/lib64 ${XBB_LDFLAGS_LIB}"
    XBB_LDFLAGS_APP="-L${INSTALL_FOLDER_PATH}/lib64 ${XBB_LDFLAGS_APP}"
    XBB_LDFLAGS_APP_STATIC="-L${INSTALL_FOLDER_PATH}/lib64 ${XBB_LDFLAGS_APP_STATIC}"
    XBB_LDFLAGS_APP_STATIC_GCC="-L${INSTALL_FOLDER_PATH}/lib64 ${XBB_LDFLAGS_APP_STATIC_GCC}"

    # Add XBB lib in front of PKG_CONFIG_PATH.
    PKG_CONFIG_PATH="${INSTALL_FOLDER_PATH}/lib64/pkgconfig:${PKG_CONFIG_PATH}"
  fi

  # Add XBB lib to LD_LIBRARY_PATH.
  LD_LIBRARY_PATH="${INSTALL_FOLDER_PATH}/lib:${LD_LIBRARY_PATH}"

  if [ -d "${INSTALL_FOLDER_PATH}/lib64" ]
  then
    # On 64-bit systems, add lib64 in front of LD_LIBRARY_PATH.
    LD_LIBRARY_PATH="${INSTALL_FOLDER_PATH}/lib64:${LD_LIBRARY_PATH}"
  fi

  export LD_LIBRARY_PATH

  export XBB_CPPFLAGS

  export XBB_LDFLAGS
  export XBB_LDFLAGS_LIB
  export XBB_LDFLAGS_APP
  export XBB_LDFLAGS_APP_STATIC
  export XBB_LDFLAGS_APP_STATIC_GCC

  export PKG_CONFIG_PATH
}

# -----------------------------------------------------------------------------

function create_xbb_source()
{
  echo
  echo "Creating ${INSTALL_FOLDER_PATH}/xbb-source.sh..."

  # Note: __EOF__ is NOT quoted to allow substitutions.
  cat <<__EOF__ > "${INSTALL_FOLDER_PATH}/xbb-source.sh"
# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (http://xpack.github.io)
# Copyright (c) $(date '+%Y') Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software 
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

__EOF__
# The above marker must start in the first column.

  if [ -f "/.dockerenv" ]
  then
    if [ "${IS_BOOTSTRAP}" == "y" ]
    then
      echo "export XBB_BOOTSTRAP_FOLDER_PATH=\"/opt/$(basename "${XBB_FOLDER_PATH}")\"" >> "${INSTALL_FOLDER_PATH}/xbb-source.sh"
    else
      echo "export XBB_FOLDER_PATH=\"/opt/$(basename "${XBB_FOLDER_PATH}")\"" >> "${INSTALL_FOLDER_PATH}/xbb-source.sh"
    fi
  else
    if [ "${IS_BOOTSTRAP}" == "y" ]
    then
      echo "export XBB_BOOTSTRAP_FOLDER_PATH=\"\${HOME}/opt/$(basename "${XBB_FOLDER_PATH}")\"" >> "${INSTALL_FOLDER_PATH}/xbb-source.sh"
    else
      echo "export XBB_FOLDER_PATH=\"\${HOME}/opt/$(basename "${XBB_FOLDER_PATH}")\"" >> "${INSTALL_FOLDER_PATH}/xbb-source.sh"
    fi
  fi

  echo "export TEXLIVE_FOLDER_PATH=\"/opt/texlive\"" >> "${INSTALL_FOLDER_PATH}/xbb-source.sh"

  if [ "${IS_BOOTSTRAP}" == "y" ]
  then

    # Note: __EOF__ is quoted to prevent substitutions here.
    cat <<'__EOF__' >> "${INSTALL_FOLDER_PATH}/xbb-source.sh"

# Adjust PATH to prefer the XBB bootstrap binaries.
function xbb_activate_bootstrap()
{
  PATH="${XBB_BOOTSTRAP_FOLDER_PATH}/bin:${PATH}"

  # Disabled, shared libs must be located via rpath.

  # Add XBB lib to LD_LIBRARY_PATH.
  # LD_LIBRARY_PATH="${XBB_BOOTSTRAP_FOLDER_PATH}/lib:${LD_LIBRARY_PATH}"

  # if [ -d "${XBB_BOOTSTRAP_FOLDER_PATH}/lib64" ]
  # then
    # On 64-bit systems, add lib64 in front of LD_LIBRARY_PATH.
    # LD_LIBRARY_PATH="${XBB_BOOTSTRAP_FOLDER_PATH}/lib64:${LD_LIBRARY_PATH}"
  # fi

  export PATH
  # export LD_LIBRARY_PATH
}

__EOF__
# The above marker must start in the first column.

  else

    # Note: __EOF__ is quoted to prevent substitutions here.
    cat <<'__EOF__' >> "${INSTALL_FOLDER_PATH}/xbb-source.sh"

# Adjust PATH to prefer the XBB binaries.
function xbb_activate()
{
  PATH=${PATH:-""}
  PATH="${XBB_FOLDER_PATH}/bin:${PATH}"

  # Disabled, shared libs must be located via rpath.

  # Add XBB lib to LD_LIBRARY_PATH.
  # LD_LIBRARY_PATH="${XBB_FOLDER_PATH}/lib:${LD_LIBRARY_PATH}"

  # if [ -d "${XBB_FOLDER_PATH}/lib64" ]
  # then
    # On 64-bit systems, add lib64 in front of LD_LIBRARY_PATH.
    # LD_LIBRARY_PATH="${XBB_FOLDER_PATH}/lib64:${LD_LIBRARY_PATH}"
  # fi

  export PATH
  # export LD_LIBRARY_PATH
}
__EOF__
# The above marker must start in the first column.

  fi

  # Adjust to TexLive conventions.
  tl_machine="${HOST_MACHINE}"
  if [ "${HOST_MACHINE}" == "i686" ]
  then
      tl_machine="i386"
  elif [ "${HOST_MACHINE}" == "armv8l" -o "${HOST_MACHINE}" == "armv7l" ]
  then
      tl_machine="armhf"
  fi

  # Note: __EOF__ is NOT quoted to allow substitutions.
  cat <<__EOF__ >> "${INSTALL_FOLDER_PATH}/xbb-source.sh"

# Add TeX to PATH.
function xbb_activate_tex()
{
  PATH="\${TEXLIVE_FOLDER_PATH}/bin/${tl_machine}-linux:\${PATH}"

  export PATH
}

__EOF__
# The above marker must start in the first column.

  if false
  then

    echo "export NVM_DIR=\"/opt/$(basename "${XBB_FOLDER_PATH}")/nvm\"" >> "${INSTALL_FOLDER_PATH}/xbb-source.sh"

    # Note: __EOF__ is quoted to prevent substitutions here.
    cat <<'__EOF__' >> "${INSTALL_FOLDER_PATH}/xbb-source.sh"
# Add nvm shell functions.
function xbb_activate_nvm()
{
  if [ -s "${NVM_DIR}/nvm.sh" ] 
  then
    source "${NVM_DIR}/nvm.sh"  # This loads nvm
  fi
}

__EOF__
# The above marker must start in the first column.

  fi

  if [ "${IS_BOOTSTRAP}" != "y" ]
  then

    set +e
    local java_home=$(java -XshowSettings:properties -version 2>&1 > /dev/null | grep 'java.home' | sed -e 's/.*= //' | sed -e 's|/jre||')
    set -e

    if [ ! -z "${java_home}" ]
    then
      echo "export JAVA_HOME=\"${java_home}\"" >> "${INSTALL_FOLDER_PATH}/xbb-source.sh"
    fi

    echo "export ANT_HOME=\"${INSTALL_FOLDER_PATH}/share/ant\"" >> "${INSTALL_FOLDER_PATH}/xbb-source.sh"
    echo "export M2_HOME=\"${INSTALL_FOLDER_PATH}/share/maven\"" >> "${INSTALL_FOLDER_PATH}/xbb-source.sh"

    echo >> "${INSTALL_FOLDER_PATH}/xbb-source.sh"

  fi

}

# -----------------------------------------------------------------------------

function extract()
{
  local archive_name="$1"
  # Must be exactly what results from expanding the archive.
  local folder_name="$2"
  # local patch_file_name="$3"
  local pwd="$(pwd)"

  if [ ! -d "${folder_name}" ]
  then
    (
      xbb_activate

      echo
      echo "Extracting \"${archive_name}\" -> \"${pwd}/${folder_name}\"..."
      if [[ "${archive_name}" == *zip ]]
      then
        unzip "${archive_name}" 
      else
        tar xf "${archive_name}"
      fi

      # Docker containers run as root, adjust owner and mode.
      if [ -f "/.dockerenv" ]
      then
        chown -R $(id -u):$(id -g) "${folder_name}"
        chmod -R +w "${folder_name}"
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

function _download_one()
{
  local url="$1"
  local archive_name="$2"
  local exit_code

  echo
  echo "Downloading \"${archive_name}\" from \"${url}\"..."
  rm -f "${CACHE_FOLDER_PATH}/${archive_name}.download"
  mkdir -p "${CACHE_FOLDER_PATH}"

  set +e
  curl --fail -L -o "${CACHE_FOLDER_PATH}/${archive_name}.download" "${url}"
  exit_code=$?
  set -e
  
  # return true for process exit code 0.
  return ${exit_code}
}

function download()
{
  local url="$1"
  local archive_name="$2"
  local url_base="https://github.com/xpack-dev-tools/files-cache/raw/master/libs"

  if [ ! -f "${CACHE_FOLDER_PATH}/${archive_name}" ]
  then
    (
      xbb_activate

      for count in 1 2 3 4
      do
        if [ ${count} -eq 4 ]
        then
          local backup_url="${url_base}/$(basename "${url}")"
          if _download_one "${backup_url}" "${archive_name}" 
          then
            break
          else
            echo "Several download attempts failed. Quit."
            exit 1
          fi 
        fi
        if _download_one "${url}" "${archive_name}" 
        then
          break
        fi
      done

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
  # Must be exactly what results from expanding the archive.
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

function run_app()
{
  # Does not include the .exe extension.
  local app_path=$1
  shift

  echo
  echo "${app_path} $@"
  "${app_path}" $@ 2>&1
}

function show_libs()
{
  # Does not include the .exe extension.
  local app_path=$1
  shift

  if [ "${HOST_UNAME}" == "Linux" ]
  then
    echo
    echo "readelf -d ${app_path} | grep 'ibrary'"
    readelf -d "${app_path}" | grep 'ibrary'
    echo "ldd -v ${app_path}"
    ldd -v "${app_path}"
  elif [ "${HOST_UNAME}" == "Darwin" ]
  then
    echo
    echo "otool -L ${app_path}"
    otool -L "${app_path}"
  fi
}

# -----------------------------------------------------------------------------

function do_strip_debug_libs() 
{
  echo
  echo "Stripping debug info from libraries..."

  if [ "${HOST_UNAME}" == "Linux" ]
  then
    (
      cd "${XBB_FOLDER_PATH}"

      xbb_activate

      local strip
      if [ -x "${XBB_FOLDER_PATH}/bin/strip" ]
      then
        strip="${XBB_FOLDER_PATH}/bin/strip"
      elif [ -x "${XBB_BOOTSTRAP_FOLDER_PATH}/bin/strip" ]
      then
        strip="${XBB_BOOTSTRAP_FOLDER_PATH}/bin/strip"
      else
        strip="strip"
      fi

      local ranlib
      if [ -x "${XBB_FOLDER_PATH}/bin/ranlib" ]
      then
        ranlib="${XBB_FOLDER_PATH}/bin/ranlib"
      elif [ -x "${XBB_BOOTSTRAP_FOLDER_PATH}/bin/ranlib" ]
      then
        ranlib="${XBB_BOOTSTRAP_FOLDER_PATH}/bin/ranlib"
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
  fi
}

function check_rpath()
{
  (
    echo
    echo "Checking rpath in elf files.."

    find "${XBB_FOLDER_PATH}/bin" "${XBB_FOLDER_PATH}/libexec" "${XBB_FOLDER_PATH}/openssl" \
      -type f \
      -exec bash ${helper_folder_path}/check_rpath.sh {} \;

    if [ -d "${XBB_FOLDER_PATH}/usr" ]
    then
      find "${XBB_FOLDER_PATH}/usr"  \
        -type f \
        -exec bash ${helper_folder_path}/check_rpath.sh {} \;
    fi

    find "${XBB_FOLDER_PATH}/lib"  \
      -type f \
      -name '*.so*' \
      -exec bash ${helper_folder_path}/check_rpath.sh {} \;

    if [ -d "${XBB_FOLDER_PATH}/lib64" ]
    then
      find "${XBB_FOLDER_PATH}/lib64"  \
        -type f \
        -name '*.so*' \
        -exec bash ${helper_folder_path}/check_rpath.sh {} \;
    fi
  ) 2>&1 | tee "${LOGS_FOLDER_PATH}/check-rpath-output.txt"
}

# -----------------------------------------------------------------------------

function do_cleaunup() 
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
