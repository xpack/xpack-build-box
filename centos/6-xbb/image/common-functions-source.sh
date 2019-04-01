# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (http://xpack.github.io)
# Copyright (c) 2019 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software 
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Support functions to be used in all versions of the containers.
# -----------------------------------------------------------------------------

# To split version into components:
# local XBB_CMAKE_MAJOR_VERSION="$(echo ${XBB_CMAKE_MAJOR_VERSION} | sed -e 's|\([0-9][0-9]*\)\.\([0-9][0-9]*\)\.\([0-9][0-9]*\)|\1.\2|')"

function prepare_env()
{
  XBB_DOWNLOAD_FOLDER="/tmp/xbb-download"
  XBB_TMP_FOLDER="/tmp/xbb"

  XBB_FOLDER="/opt/xbb"
  XBB_BOOTSTRAP_FOLDER="/opt/xbb-bootstrap"
  XBB_BUILD_FOLDER="${XBB_TMP_FOLDER}/xbb-build"

  JOBS=${JOBS:-""}

  # x86_64 or i686
  UNAME_ARCH="$(uname -m)"
  if [ "${UNAME_ARCH}" == "x86_64" ]
  then
    BITS="64"
    LIB_ARCH="lib64"
  elif [ "${UNAME_ARCH}" == "i686" ]
  then
    BITS="32"
    LIB_ARCH="lib"
  fi

  BUILD="${UNAME_ARCH}-linux-gnu"

  # x86_64-w64-mingw32 or i686-w64-mingw32
  MINGW_TARGET="${UNAME_ARCH}-w64-mingw32"

  # ---------------------------------------------------------------------------

  # Make all tools choose gcc, not the old cc.
  export CC="gcc-7bs"
  export CXX="g++-7bs"

  mkdir -p "${XBB_TMP_FOLDER}"
  mkdir -p "${XBB_DOWNLOAD_FOLDER}"

  mkdir -p "${XBB_FOLDER}"
  mkdir -p "${XBB_BUILD_FOLDER}"
}

function create_xbb_source()
{
  # Create the main source file to be source included by the applications.
  cat <<'__EOF__' > "${XBB_FOLDER}/xbb-source.sh"
# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (http://xpack.github.io)
# Copyright (c) 2019 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software 
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

export XBB_FOLDER="/opt/xbb"
export XBB_VERSION="2"

# Adjust PATH & LD_LIBRARY_PATH to prefer the XBB binaries.
# This is enough to run the XBB binaries in the application script.
# This **does not** provide access to the XBB libraries and headers,
# which normally are internal to XBB and should not be used.
xbb_activate()
{
  # Default PATH.
  PATH=${PATH:-""}

  # Add TeX to PATH.
  if [ -d "/opt/texlive/bin/x86_64-linux" ]
  then
    PATH="/opt/texlive/bin/x86_64-linux:${PATH}"
  elif [ -d "/opt/texlive/bin/i386-linux" ]
  then
    PATH="/opt/texlive/bin/i386-linux:${PATH}"
  fi

  # Add the XBB bin to PATH.
  PATH="${XBB_FOLDER}/bin:${PATH}"
  export PATH

  # Default LD_LIBRARY_PATH.
  LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-""}

  # Add XBB lib to LD_LIBRARY_PATH.
  LD_LIBRARY_PATH="${XBB_FOLDER}/lib:${LD_LIBRARY_PATH}"

  if [ -d "${XBB_FOLDER}/lib64" ]
  then
    # On 64-bit systems, add lib64 in front of LD_LIBRARY_PATH.
    LD_LIBRARY_PATH="${XBB_FOLDER}/lib64:${LD_LIBRARY_PATH}"
  fi
  export LD_LIBRARY_PATH
}
__EOF__
# The above marker must start in the first column.
}

# This build uses the bootstrap binaries; redefine 
# this function to add the bootstrap path.
# The newly built binaries will be prefered.
function xbb_activate_dev()
{
  # Default PATH.
  PATH=${PATH:-""}
  # Default LD_LIBRARY_PATH.
  LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-""}

  # Insert XBB bootstrap paths at the bottom.

  # Add the XBB bootstrap bin to PATH.
  PATH="${XBB_BOOTSTRAP_FOLDER}/bin:${PATH}"

  # Add the XBB bootstrap lib to LD_LIBRARY_PATH.
  LD_LIBRARY_PATH="${XBB_BOOTSTRAP_FOLDER}/lib:${LD_LIBRARY_PATH}"

  xbb_activate

  XBB_CPPFLAGS="-I${XBB_FOLDER}/include ${XBB_CPPFLAGS}"

  XBB_LDFLAGS_LIB="-L${XBB_FOLDER}/lib ${XBB_LDFLAGS_LIB}"
  XBB_LDFLAGS_APP="-L${XBB_FOLDER}/lib ${XBB_LDFLAGS_APP}"
  XBB_LDFLAGS_APP_STATIC="-L${XBB_FOLDER}/lib ${XBB_LDFLAGS_APP_STATIC}"

  PKG_CONFIG_PATH="${XBB_FOLDER}/lib/pkgconfig:${PKG_CONFIG_PATH}"

  if [ -d "${XBB_FOLDER}/lib" ]
  then
    XBB_LDFLAGS_LIB="-L${XBB_FOLDER}/lib64 ${XBB_LDFLAGS_LIB}"
    XBB_LDFLAGS_APP="-L${XBB_FOLDER}/lib64 ${XBB_LDFLAGS_APP}"
    XBB_LDFLAGS_APP_STATIC="-L${XBB_FOLDER}/lib54 ${XBB_LDFLAGS_APP_STATIC}"
    PKG_CONFIG_PATH="${XBB_FOLDER}/lib64/pkgconfig:${PKG_CONFIG_PATH}"
  fi

  export XBB_CPPFLAGS
  export XBB_LDFLAGS_LIB
  export XBB_LDFLAGS_APP
  export XBB_LDFLAGS_APP_STATIC

}

# -----------------------------------------------------------------------------

function extract()
{
  local archive_name="$1"
  (
    xbb_activate

    if [[ "${archive_name}" == *zip ]]
    then
      unzip "${archive_name}" -d "$(basename ${archive_name} ".zip")"
    else
      tar xf "${archive_name}"
    fi
  )
}

function download()
{
  local archive_name="$1"
  local url="$2"

  if [ ! -f "${XBB_DOWNLOAD_FOLDER}/${archive_name}" ]
  then
    (
      xbb_activate

      rm -f "${XBB_DOWNLOAD_FOLDER}/${archive_name}.download"
      curl --fail -L -o "${XBB_DOWNLOAD_FOLDER}/${archive_name}.download" "${url}"
      mv "${XBB_DOWNLOAD_FOLDER}/${archive_name}.download" "${XBB_DOWNLOAD_FOLDER}/${archive_name}"
    )
  fi
}

function download_and_extract()
{
  local archive_name="$1"
  local url="$2"

  download "${archive_name}" "${url}"
  extract "${XBB_DOWNLOAD_FOLDER}/${archive_name}"
}

function eval_bool()
{
  local val="$1"
  [[ "${val}" = 1 || "${val}" = true || "${val}" = yes || "${val}" = y ]]
}

do_strip_libs() 
{
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

    echo
    echo "Stripping libraries..."

    set +e
    # -type f to skip links.
    find lib* \
      -type f \
      -name '*.so' \
      -print \
      -exec "${strip}" --strip-debug {} \;
    find lib* \
      -type f \
      -name '*.so.*' \
      -print \
      -exec "${strip}" --strip-debug {} \;
    find lib* \
      -type f \
      -name '*.a' \
      -not -path 'lib/gcc/*-w64-mingw32/*'  \
      -print \
      -exec "${strip}" --strip-debug {} \; \
      -exec "${ranlib}" {} \;
    set -e
  )
}

# -----------------------------------------------------------------------------

function do_cleaunup() 
{
  rm -rf "${XBB_DOWNLOAD_FOLDER}"

  # rm -rf "${XBB_BOOTSTRAP_FOLDER}"
  rm -rf "${XBB_BUILD_FOLDER}"
  rm -rf "${XBB_TMP_FOLDER}"
  rm -rf "${XBB_INPUT_FOLDER}"  
}

# -----------------------------------------------------------------------------
