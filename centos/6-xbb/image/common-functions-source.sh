# -----------------------------------------------------------------------------

# Support functions to be used in all versions of the containers.

# -----------------------------------------------------------------------------

function prepare_env()
{
  XBB_DOWNLOAD="/tmp/xbb-download"
  XBB_TMP="/tmp/xbb"

  XBB="/opt/xbb"
  XBB_BUILD="${XBB_TMP}/xbb-build"

  MAKE_CONCURRENCY=2

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
  export CC="gcc"
  export CXX="g++"

  mkdir -p "${XBB_TMP}"
  mkdir -p "${XBB_DOWNLOAD}"

  mkdir -p "${XBB}"
  mkdir -p "${XBB_BUILD}"

}

# This build uses the bootstrap binaries; redefine 
# this function to add the bootstrap path.
# The newly built binaries will be prefered.
xbb_activate_dev()
{
  # x86_64 or i686
  UNAME_ARCH=$(uname -m)
  PATH=${PATH:-""}
  PATH=/opt/texlive/bin/${UNAME_ARCH}-linux:${PATH}
  export PATH="${XBB_BOOTSTRAP}/bin":${PATH}

  LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-""}
  export LD_LIBRARY_PATH="${XBB_BOOTSTRAP}/lib:${LD_LIBRARY_PATH}"

  if [ "${UNAME_ARCH}" == "x86_64" ]
  then
    export LD_LIBRARY_PATH="${XBB_BOOTSTRAP}/lib64:${LD_LIBRARY_PATH}"
  fi

  PREFIX_="${XBB}"

  EXTRA_CFLAGS_="-pipe -ffunction-sections -fdata-sections"
  EXTRA_CXXFLAGS_="-pipe -ffunction-sections -fdata-sections"
  # Do not use extra quotes around XBB, tools like guile fail.
  EXTRA_LDFLAGS_="-static-libstdc++ -Wl,--gc-sections -Wl,-rpath -Wl,${XBB}/lib"

  # This will also add XBB in front of XBB_BOOTSTRAP.
  xbb_activate_param
}

# -----------------------------------------------------------------------------

function extract()
{
  local ARCHIVE_NAME="$1"
  (
    xbb_activate

    if [[ "${ARCHIVE_NAME}" == *zip ]]
    then
      unzip "${ARCHIVE_NAME}" -d "$(basename ${ARCHIVE_NAME} ".zip")"
    else
      tar xf "${ARCHIVE_NAME}"
    fi
  )
}

function download()
{
  local ARCHIVE_NAME="$1"
  local URL="$2"

  if [ ! -f "${XBB_DOWNLOAD}/${ARCHIVE_NAME}" ]
  then
    (
      xbb_activate

      rm -f "${XBB_DOWNLOAD}/${ARCHIVE_NAME}.download"
      curl --fail -L -o "${XBB_DOWNLOAD}/${ARCHIVE_NAME}.download" "${URL}"
      mv "${XBB_DOWNLOAD}/${ARCHIVE_NAME}.download" "${XBB_DOWNLOAD}/${ARCHIVE_NAME}"
    )
  fi
}

function download_and_extract()
{
  local ARCHIVE_NAME="$1"
  local URL="$2"

  download "${ARCHIVE_NAME}" "${URL}"
  extract "${XBB_DOWNLOAD}/${ARCHIVE_NAME}"
}

function eval_bool()
{
  local VAL="$1"
  [[ "${VAL}" = 1 || "${VAL}" = true || "${VAL}" = yes || "${VAL}" = y ]]
}

do_strip_libs() 
{
  (
    cd "${XBB}"

    xbb_activate

    local STRIP
    if [ -f "${XBB}/bin/strip" ]
    then
      STRIP="${XBB}/bin/strip"
    elif [ -f "${XBB_BOOTSTRAP}/bin/strip" ]
    then
      STRIP="${XBB_BOOTSTRAP}/bin/strip"
    else
      STRIP=strip
    fi

    local RANLIB
    if [ -f "${XBB}/bin/ranlib" ]
    then
      RANLIB="${XBB}/bin/ranlib"
    elif [ -f "${XBB_BOOTSTRAP}/bin/ranlib" ]
    then
      RANLIB="${XBB_BOOTSTRAP}/bin/ranlib"
    else
      RANLIB=strip
    fi

    echo
    echo "Stripping libraries..."

    set +e
    # -type f to skip links.
    find lib* \
      -type f \
      -name '*.so' \
      -print \
      -exec "${STRIP}" --strip-debug {} \;
    find lib* \
      -type f \
      -name '*.so.*' \
      -print \
      -exec "${STRIP}" --strip-debug {} \;
    find lib* \
      -type f \
      -name '*.a' \
      -not -path 'lib/gcc/*-w64-mingw32/*'  \
      -print \
      -exec "${STRIP}" --strip-debug {} \; \
      -exec "${RANLIB}" {} \;
    set -e
  )
}

# -----------------------------------------------------------------------------

function do_cleaunup() 
{
  rm -rf "${XBB_DOWNLOAD}"

  # rm -rf "${XBB_BOOTSTRAP}"
  rm -rf "${XBB_BUILD}"
  rm -rf "${XBB_TMP}"
  rm -rf "${XBB_INPUT}"  
}

# -----------------------------------------------------------------------------
