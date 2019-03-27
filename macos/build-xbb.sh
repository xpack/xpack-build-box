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
# Identify the script location, to reach, for example, the helper scripts.

build_script_path="$0"
if [[ "${build_script_path}" != /* ]]
then
  # Make relative path absolute.
  build_script_path="$(pwd)/$0"
fi

script_folder_path="$(dirname "${build_script_path}")"
script_folder_name="$(basename "${script_folder_path}")"

# =============================================================================

# WARNING: NOT YET fUNCTIONAL!

# Script to build a separate macOS XBB.
# Basically it tries to be similar to the Docker images.

# -----------------------------------------------------------------------------

XBB_FOLDER="${HOME}/opt/xbb"

DOWNLOAD_FOLDER_PATH="${HOME}/Library/Caches/XBB"
WORK_FOLDER_PATH="${HOME}/Work/darwin-xbb"

BUILD_FOLDER_PATH="${WORK_FOLDER_PATH}/build"
LIBS_BUILD_FOLDER_PATH="${WORK_FOLDER_PATH}/build/libs"
SOURCES_FOLDER_PATH="${WORK_FOLDER_PATH}/sources"
STAMPS_FOLDER_PATH="${WORK_FOLDER_PATH}/stamps"
LOGS_FOLDER_PATH="${WORK_FOLDER_PATH}/logs"

# INSTALL_FOLDER_PATH="${XBB_FOLDER}"
INSTALL_FOLDER_PATH="${WORK_FOLDER_PATH}/install"

JOBS=-j2

# -----------------------------------------------------------------------------

mkdir -p "${XBB_FOLDER}"

mkdir -p "${DOWNLOAD_FOLDER_PATH}"
mkdir -p "${BUILD_FOLDER_PATH}"
mkdir -p "${LIBS_BUILD_FOLDER_PATH}"
mkdir -p "${SOURCES_FOLDER_PATH}"
mkdir -p "${STAMPS_FOLDER_PATH}"
mkdir -p "${LOGS_FOLDER_PATH}"

export SHELL="/bin/bash"
export CONFIG_SHELL="/bin/bash"

# -----------------------------------------------------------------------------

xbb_activate()
{
  PATH=${PATH:-""}
  PATH="${INSTALL_FOLDER_PATH}/bin:${PATH}"
  export PATH
}

xbb_activate_this()
{
  PATH=${PATH:-""}
  PATH="${INSTALL_FOLDER_PATH}/bin:${PATH}"
  export PATH

  XBB_CPPFLAGS="-I${INSTALL_FOLDER_PATH}/include ${XBB_CPPFLAGS}"
  
  XBB_LDFLAGS_LIB="-L${INSTALL_FOLDER_PATH}/lib ${XBB_LDFLAGS_LIB}"
  XBB_LDFLAGS_APP="-L${INSTALL_FOLDER_PATH}/lib ${XBB_LDFLAGS_APP}"

  PKG_CONFIG_PATH="${INSTALL_FOLDER_PATH}/lib/pkgconfig:${PKG_CONFIG_PATH}"
}

XBB_CPPFLAGS=""

XBB_CFLAGS="-ffunction-sections -fdata-sections -pipe"
XBB_CXXFLAGS="-ffunction-sections -fdata-sections -pipe"

XBB_LDFLAGS=""
XBB_LDFLAGS_LIB="${XBB_LDFLAGS}"
XBB_LDFLAGS_APP="${XBB_LDFLAGS} -Wl,-dead_strip"

# -----------------------------------------------------------------------------

# Note: __EOF__ is quoted to prevent substitutions here.
mkdir -p "${INSTALL_FOLDER_PATH}/bin"
cat <<'__EOF__' > "${INSTALL_FOLDER_PATH}/bin/pkg-config-verbose"
#! /bin/sh
# pkg-config wrapper for debug

pkg-config $@
RET=$?
OUT=$(pkg-config $@)
echo "($PKG_CONFIG_PATH) | pkg-config $@ -> $RET [$OUT]" 1>&2
exit ${RET}

__EOF__
# The above marker must start in the first column.

chmod +x "${INSTALL_FOLDER_PATH}/bin/pkg-config-verbose"

export PKG_CONFIG="${INSTALL_FOLDER_PATH}/bin/pkg-config-verbose"

PKG_CONFIG_PATH=${PKG_CONFIG_PATH:-":"}
export PKG_CONFIG_PATH

# Prevent pkg-config to search the system folders (configured in the
# pkg-config at build time).
PKG_CONFIG_LIBDIR=${PKG_CONFIG_LIBDIR:-":"}
export PKG_CONFIG_LIBDIR

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
          local patch_file_name="$3"
          local patch_path="${BUILD_GIT_PATH}/patches/${patch_file_name}"
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

  if [ ! -f "${DOWNLOAD_FOLDER_PATH}/${archive_name}" ]
  then
    (
      xbb_activate

      echo
      echo "Downloading \"${archive_name}\" from \"${url}\"..."
      rm -f "${DOWNLOAD_FOLDER_PATH}/${archive_name}.download"
      mkdir -p "${DOWNLOAD_FOLDER_PATH}"
      curl --fail -L -o "${DOWNLOAD_FOLDER_PATH}/${archive_name}.download" "${url}"
      mv "${DOWNLOAD_FOLDER_PATH}/${archive_name}.download" "${DOWNLOAD_FOLDER_PATH}/${archive_name}"
    )
  else
    echo "File \"${DOWNLOAD_FOLDER_PATH}/${archive_name}\" already downloaded."
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
    extract "${DOWNLOAD_FOLDER_PATH}/${archive_name}" "${folder_name}" "$4"
  else
    extract "${DOWNLOAD_FOLDER_PATH}/${archive_name}" "${folder_name}"
  fi
}

function eval_bool()
{
  local VAL="$1"
  [[ "${VAL}" = 1 || "${VAL}" = true || "${VAL}" = yes || "${VAL}" = y ]]
}

# -----------------------------------------------------------------------------


function do_zlib() 
{
  # http://zlib.net
  # http://zlib.net/fossils/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=zlib-static
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=zlib-git

  # 2017-01-15
  local zlib_version="1.2.11"

  local zlib_folder_name="zlib-${zlib_version}"
  local zlib_archive="${zlib_folder_name}.tar.gz"
  # local zlib_url="http://zlib.net/fossils/${zlib_archive}"
  local zlib_url="https://github.com/gnu-mcu-eclipse/files/raw/master/libs/${zlib_archive}"

  local zlib_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-zlib-installed"
  if [ ! -f "${zlib_stamp_file_path}" -o ! -d "${LIBS_BUILD_FOLDER_PATH}/${zlib_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${zlib_url}" "${zlib_archive}" "${zlib_folder_name}"

    (
      if [ ! -d "${LIBS_BUILD_FOLDER_PATH}/${zlib_folder_name}" ]
      then
        mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${zlib_folder_name}"
        # Copy the sources in the build folder.
        cp -r "${SOURCES_FOLDER_PATH}/${zlib_folder_name}"/* \
          "${LIBS_BUILD_FOLDER_PATH}/${zlib_folder_name}"
      fi
      cd "${LIBS_BUILD_FOLDER_PATH}/${zlib_folder_name}"

      xbb_activate_this

      export CFLAGS="${XBB_CFLAGS} -fPIC"

      (
        echo
        echo "Running zlib configure..."

        bash "./configure" --help

        bash ${DEBUG} "./configure" \
          --prefix="${INSTALL_FOLDER_PATH}" 

        cp "configure.log" "${LOGS_FOLDER_PATH}/configure-zlib-log.txt"
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-zlib-output.txt"

      (
        echo
        echo "Running zlib make..."

        # Build.
        make ${JOBS}
        make install
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-zlib-output.txt"
    )

    touch "${zlib_stamp_file_path}"

  else
    echo "Library zlib already installed."
  fi
}


function do_openssl() 
{
  # https://www.openssl.org
  # https://www.openssl.org/source/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=openssl-static
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=openssl-git
  
  # 2017-Nov-02 
  # XBB_OPENSSL_VERSION="1.1.0g"
  # The new version deprecated CRYPTO_set_locking_callback, and yum fails with
  # /usr/lib64/python2.6/site-packages/pycurl.so: undefined symbol: CRYPTO_set_locking_callback

  # 2017-Dec-07 
  local openssl_version="1.0.2n"

  local openssl_folder_name="openssl-${openssl_version}"
  local openssl_archive="${openssl_folder_name}.tar.gz"
  # local openssl_url="https://www.openssl.org/source/${openssl_archive}"
  local openssl_url="https://github.com/gnu-mcu-eclipse/files/raw/master/libs/${openssl_archive}"

  local openssl_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-openssl-installed"
  if [ ! -f "${openssl_stamp_file_path}" -o ! -d "${BUILD_FOLDER_PATH}/${openssl_folder_name}" ]
  then

    cd "${BUILD_FOLDER_PATH}"

    download_and_extract "${openssl_url}" "${openssl_archive}" "${openssl_folder_name}"

    (
      mkdir -p "${BUILD_FOLDER_PATH}/${openssl_folder_name}"
      cd "${BUILD_FOLDER_PATH}/${openssl_folder_name}"

      xbb_activate_this

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS}"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_APP}"

      if [ ! -f config.stamp ]
      then
        (
          echo
          echo "Running openssl configure..."

          # This config does not use the standard GNU environment definitions.
          bash ./Configure --help || true

          ./Configure darwin64-x86_64-cc \
            --prefix="${INSTALL_FOLDER_PATH}" \
            --openssldir="${INSTALL_FOLDER_PATH}/openssl" \
            shared \
            no-ssl3-method 

          make depend ${JOBS}

          touch config.stamp

          # cp "configure.log" "${LOGS_FOLDER_PATH}/configure-openssl-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-openssl-output.txt"
      fi

      (
        echo
        echo "Running openssl make..."

        # Build.
        make ${JOBS}
        make install_sw

        strip "${INSTALL_FOLDER_PATH}/bin/openssl"

        if [ ! -f "${INSTALL_FOLDER_PATH}/openssl/cert.pem" ]
        then
          mkdir -p "${INSTALL_FOLDER_PATH}/openssl"
          ln -s "/private/etc/ssl/cert.pem" "${INSTALL_FOLDER_PATH}/openssl/cert.pem"
        fi

      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-openssl-output.txt"

      (
        xbb_activate

        echo
        "${INSTALL_FOLDER_PATH}/bin/openssl" version
      )
    )

    touch "${openssl_stamp_file_path}"

  else
    echo "Component openssl already installed."
  fi
}

function do_curl() 
{
  # https://curl.haxx.se
  # https://curl.haxx.se/download/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=curl-git

  # 2017-10-23 
  # XBB_CURL_VERSION="7.56.1"
  # 2017-11-29
  local curl_version="7.57.0"

  local curl_folder_name="curl-${curl_version}"
  local curl_archive="${curl_folder_name}.tar.xz"
  # local curl_url="http://curl.net/abc/${curl_archive}"
  local curl_url="https://github.com/gnu-mcu-eclipse/files/raw/master/libs/${curl_archive}"

  local curl_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-curl-installed"
  if [ ! -f "${curl_stamp_file_path}" -o ! -d "${BUILD_FOLDER_PATH}/${curl_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${curl_url}" "${curl_archive}" "${curl_folder_name}"

    (
      mkdir -p "${BUILD_FOLDER_PATH}/${curl_folder_name}"
      cd "${BUILD_FOLDER_PATH}/${curl_folder_name}"

      xbb_activate_this

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS} -Wno-deprecated-declarations"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_APP}"

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running curl configure..."

          bash "${SOURCES_FOLDER_PATH}/${curl_folder_name}/configure" --help

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${curl_folder_name}/configure" \
            --prefix="${INSTALL_FOLDER_PATH}" \
            --disable-debug \
            --with-ssl \
            --enable-optimize \
            --disable-manual \
            --disable-ldap \
            --disable-ldaps \
            --enable-versioned-symbols \
            --enable-threaded-resolver \
            --with-gssapi \
            --with-ca-bundle="${INSTALL_FOLDER_PATH}/openssl/cert.pem"

          cp "config.log" "${LOGS_FOLDER_PATH}/config-curl-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-curl-output.txt"
      fi

      (
        echo
        echo "Running curl make..."

        # Build.
        make ${JOBS}
        make install

        strip "${INSTALL_FOLDER_PATH}/bin/curl"
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-curl-output.txt"
    )

    (
      echo
      "${INSTALL_FOLDER_PATH}/bin/curl" --version
    )

    touch "${curl_stamp_file_path}"

  else
    echo "Component curl already installed."
  fi
}

function do_xz() 
{
  # https://tukaani.org/xz/
  # https://sourceforge.net/projects/lzmautils/files/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=xz-git

  # 2016-12-30
  local xz_version="5.2.3"

  local xz_folder_name="xz-${xz_version}"
  local xz_archive="${xz_folder_name}.tar.xz"
  # local xz_url="http://xz.net/abc/${xz_archive}"
  local xz_url="https://github.com/gnu-mcu-eclipse/files/raw/master/libs/${xz_archive}"

  local xz_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-xz-installed"
  if [ ! -f "${xz_stamp_file_path}" -o ! -d "${BUILD_FOLDER_PATH}/${xz_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${xz_url}" "${xz_archive}" "${xz_folder_name}"

    (
      mkdir -p "${BUILD_FOLDER_PATH}/${xz_folder_name}"
      cd "${BUILD_FOLDER_PATH}/${xz_folder_name}"

      xbb_activate_this

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS}"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_APP}"

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running xz configure..."

          bash "${SOURCES_FOLDER_PATH}/${xz_folder_name}/configure" --help

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${xz_folder_name}/configure" \
            --prefix="${INSTALL_FOLDER_PATH}" \
            --disable-rpath

          cp "config.log" "${LOGS_FOLDER_PATH}/config-xz-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-xz-output.txt"
      fi

      (
        echo
        echo "Running xz make..."

        # Build.
        make ${JOBS}
        make install-strip
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-xz-output.txt"
    )

    (
      echo
      "${INSTALL_FOLDER_PATH}/bin/xz" --version
    )

    hash -r

    touch "${xz_stamp_file_path}"

  else
    echo "Component xz already installed."
  fi
}

function do_tar() 
{
  # https://www.gnu.org/software/tar/
  # https://ftp.gnu.org/gnu/tar/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=tar-git

  # 2016-05-16
  # XBB_TAR_VERSION="1.29"
  # 2017-12-17
  local tar_version="1.30"

  local tar_folder_name="tar-${tar_version}"
  local tar_archive="${tar_folder_name}.tar.xz"
  local tar_url="https://ftp.gnu.org/gnu/tar/${tar_archive}"
  
  local tar_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-tar-installed"
  if [ ! -f "${tar_stamp_file_path}" -o ! -d "${BUILD_FOLDER_PATH}/${tar_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${tar_url}" "${tar_archive}" "${tar_folder_name}"

    (
      mkdir -p "${BUILD_FOLDER_PATH}/${tar_folder_name}"
      cd "${BUILD_FOLDER_PATH}/${tar_folder_name}"

      xbb_activate_this

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS}"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_APP}"

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running tar configure..."

          bash "${SOURCES_FOLDER_PATH}/${tar_folder_name}/configure" --help

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${tar_folder_name}/configure" \
            --prefix="${INSTALL_FOLDER_PATH}" 

          cp "config.log" "${LOGS_FOLDER_PATH}/config-tar-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-tar-output.txt"
      fi

      (
        echo
        echo "Running tar make..."

        # Build.
        make ${JOBS}
        make install-strip
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-tar-output.txt"
    )

    (
      echo
      "${INSTALL_FOLDER_PATH}/bin/tar" --version
    )

    hash -r

    touch "${tar_stamp_file_path}"

  else
    echo "Component tar already installed."
  fi
}

function do_coreutils() 
{
  # https://ftp.gnu.org/gnu/coreutils/
  local coreutils_version="8.31"

  local coreutils_folder_name="coreutils-${coreutils_version}"
  local coreutils_archive="${coreutils_folder_name}.tar.xz"
  local coreutils_url="https://ftp.gnu.org/gnu/coreutils/${coreutils_archive}"

  local coreutils_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-coreutils-installed"
  if [ ! -f "${coreutils_stamp_file_path}" -o ! -d "${BUILD_FOLDER_PATH}/${coreutils_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${coreutils_url}" "${coreutils_archive}" "${coreutils_folder_name}"

    (
      mkdir -p "${BUILD_FOLDER_PATH}/${coreutils_folder_name}"
      cd "${BUILD_FOLDER_PATH}/${coreutils_folder_name}"

      xbb_activate_this

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS} -Wno-pointer-sign -Wno-incompatible-pointer-types"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_APP}"

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running coreutils configure..."

          bash "${SOURCES_FOLDER_PATH}/${coreutils_folder_name}/configure" --help

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${coreutils_folder_name}/configure" \
            --prefix="${INSTALL_FOLDER_PATH}" 

          cp "config.log" "${LOGS_FOLDER_PATH}/config-coreutils-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-coreutils-output.txt"
      fi

      (
        echo
        echo "Running coreutils make..."

        # Build.
        make ${JOBS}
        # make install-strip
        make install
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-coreutils-output.txt"
    )

    (
      echo
      "${INSTALL_FOLDER_PATH}/bin/realpath" --version
    )

    hash -r

    touch "${coreutils_stamp_file_path}"

  else
    echo "Component coreutils already installed."
  fi
}

function do_gmp() 
{
  # https://gmplib.org
  # https://gmplib.org/download/gmp/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=gmp-hg

  # 16-Dec-2016
  local gmp_version="6.1.2"

  local gmp_folder_name="gmp-${gmp_version}"
  local gmp_archive="${gmp_folder_name}.tar.xz"
  # local gmp_url="http://gmp.net/abc/${gmp_archive}"
  local gmp_url="https://github.com/gnu-mcu-eclipse/files/raw/master/libs/${gmp_archive}"

  local gmp_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-gmp-installed"
  if [ ! -f "${gmp_stamp_file_path}" -o ! -d "${LIBS_BUILD_FOLDER_PATH}/${gmp_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${gmp_url}" "${gmp_archive}" "${gmp_folder_name}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${gmp_folder_name}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${gmp_folder_name}"

      xbb_activate_this

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS}"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_LIB}"
      export ABI="64"

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running gmp configure..."

          bash "${SOURCES_FOLDER_PATH}/${gmp_folder_name}/configure" --help

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${gmp_folder_name}/configure" \
            --prefix="${INSTALL_FOLDER_PATH}" 

          cp "config.log" "${LOGS_FOLDER_PATH}/config-gmp-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-gmp-output.txt"
      fi

      (
        echo
        echo "Running gmp make..."

        # Build.
        make ${JOBS}
        make install-strip
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-gmp-output.txt"
    )

    touch "${gmp_stamp_file_path}"

  else
    echo "Library gmp already installed."
  fi
}

function do_mpfr() 
{
  # http://www.mpfr.org
  # http://www.mpfr.org/mpfr-3.1.6
  # https://git.archlinux.org/svntogit/packages.git/tree/trunk/PKGBUILD?h=packages/mpfr

  # 7 September 2017
  local mpfr_version="3.1.6"

  local mpfr_folder_name="mpfr-${mpfr_version}"
  local mpfr_archive="${mpfr_folder_name}.tar.xz"
  # local mpfr_url="http://mpfr.net/abc/${mpfr_archive}"
  local mpfr_url="https://github.com/gnu-mcu-eclipse/files/raw/master/libs/${mpfr_archive}"

  local mpfr_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-mpfr-installed"
  if [ ! -f "${mpfr_stamp_file_path}" -o ! -d "${LIBS_BUILD_FOLDER_PATH}/${mpfr_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${mpfr_url}" "${mpfr_archive}" "${mpfr_folder_name}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${mpfr_folder_name}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${mpfr_folder_name}"

      xbb_activate_this

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS}"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_LIB}"

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running mpfr configure..."

          bash "${SOURCES_FOLDER_PATH}/${mpfr_folder_name}/configure" --help

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${mpfr_folder_name}/configure" \
            --prefix="${INSTALL_FOLDER_PATH}" 

          cp "config.log" "${LOGS_FOLDER_PATH}/config-mpfr-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-mpfr-output.txt"
      fi

      (
        echo
        echo "Running mpfr make..."

        # Build.
        make ${JOBS}
        make install-strip
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-mpfr-output.txt"
    )

    touch "${mpfr_stamp_file_path}"

  else
    echo "Library mpfr already installed."
  fi
}

function do_mpc() 
{
  # http://www.multiprecision.org/
  # ftp://ftp.gnu.org/gnu/mpc
  # https://git.archlinux.org/svntogit/packages.git/tree/trunk/PKGBUILD?h=packages/libmpc

  # February 2015
  local mpc_version="1.0.3"

  local mpc_folder_name="mpc-${mpc_version}"
  local mpc_archive="${mpc_folder_name}.tar.gz"
  local mpc_url="ftp://ftp.gnu.org/gnu/mpc/${mpc_archive}"

  local mpc_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-mpc-installed"
  if [ ! -f "${mpc_stamp_file_path}" -o ! -d "${LIBS_BUILD_FOLDER_PATH}/${mpc_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${mpc_url}" "${mpc_archive}" "${mpc_folder_name}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${mpc_folder_name}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${mpc_folder_name}"

      xbb_activate_this

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS}"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_LIB}"

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running mpc configure..."

          bash "${SOURCES_FOLDER_PATH}/${mpc_folder_name}/configure" --help

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${mpc_folder_name}/configure" \
            --prefix="${INSTALL_FOLDER_PATH}" 

          cp "config.log" "${LOGS_FOLDER_PATH}/config-mpc-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-mpc-output.txt"
      fi

      (
        echo
        echo "Running mpc make..."

        # Build.
        make ${JOBS}
        make install-strip
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-mpc-output.txt"
    )

    touch "${mpc_stamp_file_path}"

  else
    echo "Library mpc already installed."
  fi
}

function do_isl() 
{
  # http://isl.gforge.inria.fr
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=isl

  # 2016-12-20
  local isl_version="0.18"

  local isl_folder_name="isl-${isl_version}"
  local isl_archive="${isl_folder_name}.tar.xz"
  # local isl_url="ftp://ftp.gnu.org/gnu/isl/${isl_archive}"
  local isl_url="https://github.com/gnu-mcu-eclipse/files/raw/master/libs/${isl_archive}"

  local isl_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-isl-installed"
  if [ ! -f "${isl_stamp_file_path}" -o ! -d "${LIBS_BUILD_FOLDER_PATH}/${isl_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${isl_url}" "${isl_archive}" "${isl_folder_name}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${isl_folder_name}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${isl_folder_name}"

      xbb_activate_this

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS}"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_LIB}"

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running isl configure..."

          bash "${SOURCES_FOLDER_PATH}/${isl_folder_name}/configure" --help

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${isl_folder_name}/configure" \
            --prefix="${INSTALL_FOLDER_PATH}" 

          cp "config.log" "${LOGS_FOLDER_PATH}/config-isl-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-isl-output.txt"
      fi

      (
        echo
        echo "Running isl make..."

        # Build.
        make ${JOBS}
        make install-strip
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-isl-output.txt"
    )

    touch "${isl_stamp_file_path}"

  else
    echo "Library isl already installed."
  fi
}

function do_nettle() 
{
  # https://www.lysator.liu.se/~nisse/nettle/
  # https://ftp.gnu.org/gnu/nettle/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=nettle-git

  # 2017-11-19
  local nettle_version="3.4"

  local nettle_folder_name="nettle-${nettle_version}"
  local nettle_archive="${nettle_folder_name}.tar.gz"
  local nettle_url="ftp://ftp.gnu.org/gnu/nettle/${nettle_archive}"

  local nettle_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-nettle-installed"
  if [ ! -f "${nettle_stamp_file_path}" -o ! -d "${LIBS_BUILD_FOLDER_PATH}/${nettle_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${nettle_url}" "${nettle_archive}" "${nettle_folder_name}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${nettle_folder_name}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${nettle_folder_name}"

      xbb_activate_this

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS}"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_LIB}"

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running nettle configure..."

          bash "${SOURCES_FOLDER_PATH}/${nettle_folder_name}/configure" --help

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${nettle_folder_name}/configure" \
            --prefix="${INSTALL_FOLDER_PATH}" \
            --disable-documentation

          cp "config.log" "${LOGS_FOLDER_PATH}/config-nettle-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-nettle-output.txt"
      fi

      (
        echo
        echo "Running nettle make..."

        # Build.
        make ${JOBS}
        # make install-strip
        # For unknown reasons, on 32-bits make install-info fails 
        # (`install-info --info-dir="/opt/xbb/share/info" nettle.info` returns 1)
        # Make the other install targets.
        make install-headers install-static install-pkgconfig install-shared-nettle  install-shared-hogweed
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-nettle-output.txt"
    )

    touch "${nettle_stamp_file_path}"

  else
    echo "Library nettle already installed."
  fi
}

function do_tasn1() 
{
  # https://www.gnu.org/software/libtasn1/
  # http://ftp.gnu.org/gnu/libtasn1/
  # https://ftp.gnu.org/gnu/libtasn1/libtasn1-4.12.tar.gz
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=libtasn1-git

  # 2017-11-19
  local tasn1_version="4.12"

  local tasn1_folder_name="libtasn1-${tasn1_version}"
  local tasn1_archive="${tasn1_folder_name}.tar.gz"
  local tasn1_url="ftp://ftp.gnu.org/gnu/libtasn1/${tasn1_archive}"

  local tasn1_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-tasn1-installed"
  if [ ! -f "${tasn1_stamp_file_path}" -o ! -d "${LIBS_BUILD_FOLDER_PATH}/${tasn1_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${tasn1_url}" "${tasn1_archive}" "${tasn1_folder_name}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${tasn1_folder_name}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${tasn1_folder_name}"

      xbb_activate_this

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS} -Wno-logical-op -Wno-missing-prototypes -Wno-implicit-fallthrough -Wno-format-truncation"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_LIB}"

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running tasn1 configure..."

          bash "${SOURCES_FOLDER_PATH}/${tasn1_folder_name}/configure" --help

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${tasn1_folder_name}/configure" \
            --prefix="${INSTALL_FOLDER_PATH}" 

          cp "config.log" "${LOGS_FOLDER_PATH}/config-tasn1-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-tasn1-output.txt"
      fi

      (
        echo
        echo "Running tasn1 make..."

        # Build.
        make ${JOBS}
        make install-strip
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-tasn1-output.txt"
    )

    touch "${tasn1_stamp_file_path}"

  else
    echo "Library tasn1 already installed."
  fi
}

function do_expat() 
{
  # https://libexpat.github.io
  # https://github.com/libexpat/libexpat/releases
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=expat-git

  local expat_version="2.2.5"

  local expat_folder_name="expat-${expat_version}"
  local expat_archive="${expat_folder_name}.tar.bz2"
  local expat_release="R_$(echo ${expat_version} | sed -e 's|[.]|_|g')"
  # local expat_url="ftp://ftp.gnu.org/gnu/expat/${expat_archive}"
  local expat_url="https://github.com/libexpat/libexpat/releases/download/${expat_release}/${expat_archive}"

  local expat_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-expat-installed"
  if [ ! -f "${expat_stamp_file_path}" -o ! -d "${LIBS_BUILD_FOLDER_PATH}/${expat_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${expat_url}" "${expat_archive}" "${expat_folder_name}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${expat_folder_name}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${expat_folder_name}"

      xbb_activate_this

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS}"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_LIB}"

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running expat configure..."

          bash "${SOURCES_FOLDER_PATH}/${expat_folder_name}/configure" --help

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${expat_folder_name}/configure" \
            --prefix="${INSTALL_FOLDER_PATH}" 

          cp "config.log" "${LOGS_FOLDER_PATH}/config-expat-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-expat-output.txt"
      fi

      (
        echo
        echo "Running expat make..."

        # Build.
        make ${JOBS}
        make install-strip
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-expat-output.txt"
    )

    touch "${expat_stamp_file_path}"

  else
    echo "Library expat already installed."
  fi
}

function do_libffi() 
{
  # https://sourceware.org/libffi/
  # https://sourceware.org/pub/libffi/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=libffi-git

  # 12-Nov-2014
  local libffi_version="3.2.1"

  local libffi_folder_name="libffi-${libffi_version}"
  # .gz only.
  local libffi_archive="${libffi_folder_name}.tar.gz"
  # local libffi_url="ftp://ftp.gnu.org/gnu/libffi/${libffi_archive}"
  local libffi_url="https://sourceware.org/pub/libffi/${libffi_archive}"

  local libffi_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-libffi-installed"
  if [ ! -f "${libffi_stamp_file_path}" -o ! -d "${LIBS_BUILD_FOLDER_PATH}/${libffi_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${libffi_url}" "${libffi_archive}" "${libffi_folder_name}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${libffi_folder_name}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${libffi_folder_name}"

      xbb_activate_this

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS}"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_LIB}"

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running libffi configure..."

          bash "${SOURCES_FOLDER_PATH}/${libffi_folder_name}/configure" --help

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${libffi_folder_name}/configure" \
            --prefix="${INSTALL_FOLDER_PATH}" \
            --enable-pax_emutramp

          cp "config.log" "${LOGS_FOLDER_PATH}/config-libffi-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-libffi-output.txt"
      fi

      (
        echo
        echo "Running libffi make..."

        # Build.
        make ${JOBS}
        make install-strip
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-libffi-output.txt"
    )

    touch "${libffi_stamp_file_path}"

  else
    echo "Library libffi already installed."
  fi
}

function do_pkg_config() 
{
  # https://www.freedesktop.org/wiki/Software/pkg-config/
  # https://pkgconfig.freedesktop.org/releases/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=pkg-config-git

  # 2017-03-20
  local pkg_config_version="0.29.2"

  local pkg_config_folder_name="pkg-config-${pkg_config_version}"
  local pkg_config_archive="${pkg_config_folder_name}.tar.gz"
  # local pkg_config_url="https://ftp.gnu.org/gnu/pkg_config/${pkg_config_archive}"
  local pkg_config_url="https://github.com/gnu-mcu-eclipse/files/raw/master/libs/${pkg_config_archive}"

  local pkg_config_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-pkg_config-installed"
  if [ ! -f "${pkg_config_stamp_file_path}" -o ! -d "${BUILD_FOLDER_PATH}/${pkg_config_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${pkg_config_url}" "${pkg_config_archive}" "${pkg_config_folder_name}"

    (
      mkdir -p "${BUILD_FOLDER_PATH}/${pkg_config_folder_name}"
      cd "${BUILD_FOLDER_PATH}/${pkg_config_folder_name}"

      xbb_activate_this

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS}"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_APP}"

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running pkg_config configure..."

          bash "${SOURCES_FOLDER_PATH}/${pkg_config_folder_name}/configure" --help
          bash "${SOURCES_FOLDER_PATH}/${pkg_config_folder_name}/glib/configure" --help

          # --with-internal-glib fails with
          # gconvert.c:61:2: error: #error GNU libiconv not in use but included iconv.h is from libiconv          
          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${pkg_config_folder_name}/configure" \
            --prefix="${INSTALL_FOLDER_PATH}" \
            --with-internal-glib

          cp "config.log" "${LOGS_FOLDER_PATH}/config-pkg_config-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-pkg_config-output.txt"
      fi

      (
        echo
        echo "Running pkg_config make..."

        # Build.
        make ${JOBS}
        make install-strip
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-pkg_config-output.txt"
    )

    (
      echo
      "${INSTALL_FOLDER_PATH}/bin/pkg-config" --version
    )

    hash -r

    touch "${pkg_config_stamp_file_path}"

  else
    echo "Component pkg_config already installed."
  fi
}

function do_libiconv() 
{
  # https://www.gnu.org/software/libiconv/
  # https://ftp.gnu.org/pub/gnu/libiconv/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=libiconv

  # 2017-02-02
  local libiconv_version="1.15"

  local libiconv_folder_name="libiconv-${libiconv_version}"
  local libiconv_archive="${libiconv_folder_name}.tar.gz"
  local libiconv_url="ftp://ftp.gnu.org/gnu/libiconv/${libiconv_archive}"

  local libiconv_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-libiconv-installed"
  if [ ! -f "${libiconv_stamp_file_path}" -o ! -d "${LIBS_BUILD_FOLDER_PATH}/${libiconv_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${libiconv_url}" "${libiconv_archive}" "${libiconv_folder_name}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${libiconv_folder_name}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${libiconv_folder_name}"

      xbb_activate_this

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS}"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_LIB}"

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running libiconv configure..."

          bash "${SOURCES_FOLDER_PATH}/${libiconv_folder_name}/configure" --help

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${libiconv_folder_name}/configure" \
            --prefix="${INSTALL_FOLDER_PATH}" 

          cp "config.log" "${LOGS_FOLDER_PATH}/config-libiconv-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-libiconv-output.txt"
      fi

      (
        echo
        echo "Running libiconv make..."

        # Build.
        make ${JOBS}
        make install-strip

        # Does not leave a pkgconfig/iconv.pc;
        # Pass -liconv explicitly.
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-libiconv-output.txt"
    )

    touch "${libiconv_stamp_file_path}"

  else
    echo "Library libiconv already installed."
  fi
}

function do_gnutls() 
{
  # http://www.gnutls.org/
  # https://www.gnupg.org/ftp/gcrypt/gnutls/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=gnutls-git

  # 2017-10-21
  # XBB_GNUTLS_MAJOR_VERSION="3.5"
  # XBB_GNUTLS_VERSION="${XBB_GNUTLS_MAJOR_VERSION}.16"

  # 2017-10-21
  local gnutls_version_major="3.6"
  local gnutls_version="${gnutls_version_major}.1"

  local gnutls_folder_name="gnutls-${gnutls_version}"
  local gnutls_archive="${gnutls_folder_name}.tar.xz"
  local gnutls_url="https://www.gnupg.org/ftp/gcrypt/gnutls/v${gnutls_version_major}/${gnutls_archive}"

  local gnutls_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-gnutls-installed"
  if [ ! -f "${gnutls_stamp_file_path}" -o ! -d "${LIBS_BUILD_FOLDER_PATH}/${gnutls_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${gnutls_url}" "${gnutls_archive}" "${gnutls_folder_name}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${gnutls_folder_name}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${gnutls_folder_name}"

      xbb_activate_this

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS} -Wno-parentheses -Wno-bad-function-cast -Wno-unused-macros -Wno-bad-function-cast -Wno-unused-variable -Wno-pointer-sign -Wno-implicit-fallthrough -Wno-format-truncation -Wno-missing-prototypes -Wno-missing-declarations -Wno-shadow -Wno-sign-compare -Wno-unknown-warning-option -Wno-static-in-inline -Wno-implicit-function-declaration -Wno-strict-prototypes -Wno-tautological-pointer-compare"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_LIB}"

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running gnutls configure..."

          bash "${SOURCES_FOLDER_PATH}/${gnutls_folder_name}/configure" --help

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${gnutls_folder_name}/configure" \
            --prefix="${INSTALL_FOLDER_PATH}" \
            --without-p11-kit \
            --enable-guile \
            --with-guile-site-dir=no \
            --with-included-unistring

          cp "config.log" "${LOGS_FOLDER_PATH}/config-gnutls-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-gnutls-output.txt"
      fi

      (
        echo
        echo "Running gnutls make..."

        # Build.
        make ${JOBS}
        make install-strip
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-gnutls-output.txt"
    )

    touch "${gnutls_stamp_file_path}"

  else
    echo "Library gnutls already installed."
  fi
}

function do_m4() 
{
  # https://www.gnu.org/software/m4/
  # https://ftp.gnu.org/gnu/m4/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=m4-git

  # 2016-12-31
  local m4_version="1.4.18"

  local m4_folder_name="m4-${m4_version}"
  local m4_archive="${m4_folder_name}.tar.xz"
  local m4_url="https://ftp.gnu.org/gnu/m4/${m4_archive}"

  local m4_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-m4-installed"
  if [ ! -f "${m4_stamp_file_path}" -o ! -d "${BUILD_FOLDER_PATH}/${m4_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${m4_url}" "${m4_archive}" "${m4_folder_name}"

    (
      mkdir -p "${BUILD_FOLDER_PATH}/${m4_folder_name}"
      cd "${BUILD_FOLDER_PATH}/${m4_folder_name}"

      xbb_activate_this

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS}"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_APP}"

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running m4 configure..."

          bash "${SOURCES_FOLDER_PATH}/${m4_folder_name}/configure" --help

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${m4_folder_name}/configure" \
            --prefix="${INSTALL_FOLDER_PATH}" \
            --disable-dependency-tracking

          cp "config.log" "${LOGS_FOLDER_PATH}/config-m4-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-m4-output.txt"
      fi

      (
        echo
        echo "Running m4 make..."

        # Build.
        make ${JOBS}
        make install-strip
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-m4-output.txt"
    )

    (
      echo
      "${INSTALL_FOLDER_PATH}/bin/m4" --version
    )

    hash -r

    touch "${m4_stamp_file_path}"

  else
    echo "Component m4 already installed."
  fi
}


function do_gawk() 
{
  # https://www.gnu.org/software/gawk/
  # https://ftp.gnu.org/gnu/gawk/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=gawk-git

  # 2017-10-19
  local gawk_version="4.2.0"

  local gawk_folder_name="gawk-${gawk_version}"
  local gawk_archive="${gawk_folder_name}.tar.xz"
  local gawk_url="https://ftp.gnu.org/gnu/gawk/${gawk_archive}"

  local gawk_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-gawk-installed"
  if [ ! -f "${gawk_stamp_file_path}" -o ! -d "${BUILD_FOLDER_PATH}/${gawk_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${gawk_url}" "${gawk_archive}" "${gawk_folder_name}"

    (
      mkdir -p "${BUILD_FOLDER_PATH}/${gawk_folder_name}"
      cd "${BUILD_FOLDER_PATH}/${gawk_folder_name}"

      xbb_activate_this

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS}"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_APP}"

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running gawk configure..."

          bash "${SOURCES_FOLDER_PATH}/${gawk_folder_name}/configure" --help

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${gawk_folder_name}/configure" \
            --prefix="${INSTALL_FOLDER_PATH}" \
            --without-libsigsegv

          cp "config.log" "${LOGS_FOLDER_PATH}/config-gawk-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-gawk-output.txt"
      fi

      (
        echo
        echo "Running gawk make..."

        # Build.
        make ${JOBS}
        make install-strip
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-gawk-output.txt"
    )

    (
      echo
      "${INSTALL_FOLDER_PATH}/bin/awk" --version
    )

    hash -r

    touch "${gawk_stamp_file_path}"

  else
    echo "Component gawk already installed."
  fi
}

function do_autoconf() 
{
  # https://www.gnu.org/software/autoconf/
  # https://ftp.gnu.org/gnu/autoconf/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=autoconf-git

  # 2012-04-24
  local autoconf_version="2.69"

  local autoconf_folder_name="autoconf-${autoconf_version}"
  local autoconf_archive="${autoconf_folder_name}.tar.xz"
  local autoconf_url="https://ftp.gnu.org/gnu/autoconf/${autoconf_archive}"

  local autoconf_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-autoconf-installed"
  if [ ! -f "${autoconf_stamp_file_path}" -o ! -d "${BUILD_FOLDER_PATH}/${autoconf_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${autoconf_url}" "${autoconf_archive}" "${autoconf_folder_name}"

    (
      mkdir -p "${BUILD_FOLDER_PATH}/${autoconf_folder_name}"
      cd "${BUILD_FOLDER_PATH}/${autoconf_folder_name}"

      xbb_activate_this

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS}"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_APP}"

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running autoconf configure..."

          bash "${SOURCES_FOLDER_PATH}/${autoconf_folder_name}/configure" --help

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${autoconf_folder_name}/configure" \
            --prefix="${INSTALL_FOLDER_PATH}" 

          cp "config.log" "${LOGS_FOLDER_PATH}/config-autoconf-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-autoconf-output.txt"
      fi

      (
        echo
        echo "Running autoconf make..."

        # Build.
        make ${JOBS}
        make install-strip
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-autoconf-output.txt"
    )

    (
      echo
      "${INSTALL_FOLDER_PATH}/bin/autoconf" --version
    )

    hash -r

    touch "${autoconf_stamp_file_path}"

  else
    echo "Component autoconf already installed."
  fi
}

function do_automake() 
{
  # https://www.gnu.org/software/automake/
  # https://ftp.gnu.org/gnu/automake/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=automake-git

  # 2015-01-05
  local automake_version="1.15"

  local automake_folder_name="automake-${automake_version}"
  local automake_archive="${automake_folder_name}.tar.xz"
  local automake_url="https://ftp.gnu.org/gnu/automake/${automake_archive}"

  local automake_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-automake-installed"
  if [ ! -f "${automake_stamp_file_path}" -o ! -d "${BUILD_FOLDER_PATH}/${automake_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${automake_url}" "${automake_archive}" "${automake_folder_name}"

    (
      mkdir -p "${BUILD_FOLDER_PATH}/${automake_folder_name}"
      cd "${BUILD_FOLDER_PATH}/${automake_folder_name}"

      xbb_activate_this

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS}"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_APP}"

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running automake configure..."

          bash "${SOURCES_FOLDER_PATH}/${automake_folder_name}/configure" --help

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${automake_folder_name}/configure" \
            --prefix="${INSTALL_FOLDER_PATH}" 

          cp "config.log" "${LOGS_FOLDER_PATH}/config-automake-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-automake-output.txt"
      fi

      (
        echo
        echo "Running automake make..."

        # Build.
        make ${JOBS}
        make install-strip
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-automake-output.txt"
    )

    (
      echo
      "${INSTALL_FOLDER_PATH}/bin/automake" --version
    )

    hash -r

    touch "${automake_stamp_file_path}"

  else
    echo "Component automake already installed."
  fi
}

function do_libtool() 
{
  # https://www.gnu.org/software/libtool/
  # http://gnu.mirrors.linux.ro/libtool/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=libtool-git

  # 15-Feb-2015
  local libtool_version="2.4.6"

  local libtool_folder_name="libtool-${libtool_version}"
  local libtool_archive="${libtool_folder_name}.tar.xz"
  # local libtool_url="https://ftp.gnu.org/gnu/libtool/${libtool_archive}"
  local libtool_url="https://github.com/gnu-mcu-eclipse/files/raw/master/libs/${libtool_archive}"

  local libtool_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-libtool-installed"
  if [ ! -f "${libtool_stamp_file_path}" -o ! -d "${BUILD_FOLDER_PATH}/${libtool_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${libtool_url}" "${libtool_archive}" "${libtool_folder_name}"

    (
      mkdir -p "${BUILD_FOLDER_PATH}/${libtool_folder_name}"
      cd "${BUILD_FOLDER_PATH}/${libtool_folder_name}"

      xbb_activate_this

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS}"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_APP}"

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running libtool configure..."

          bash "${SOURCES_FOLDER_PATH}/${libtool_folder_name}/configure" --help

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${libtool_folder_name}/configure" \
            --prefix="${INSTALL_FOLDER_PATH}" 

          cp "config.log" "${LOGS_FOLDER_PATH}/config-libtool-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-libtool-output.txt"
      fi

      (
        echo
        echo "Running libtool make..."

        # Build.
        make ${JOBS}
        make install-strip
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-libtool-output.txt"
    )

    (
      echo
      "${INSTALL_FOLDER_PATH}/bin/libtool" --version
    )

    hash -r

    touch "${libtool_stamp_file_path}"

  else
    echo "Component libtool already installed."
  fi
}

function do_gettext() 
{
  # https://www.gnu.org/software/gettext/
  # https://ftp.gnu.org/gnu/gettext/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=gettext-git

  # 2016-06-09
  local gettext_version="0.19.8"

  local gettext_folder_name="gettext-${gettext_version}"
  local gettext_archive="${gettext_folder_name}.tar.xz"
  local gettext_url="https://ftp.gnu.org/gnu/gettext/${gettext_archive}"

  local gettext_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-gettext-installed"
  if [ ! -f "${gettext_stamp_file_path}" -o ! -d "${BUILD_FOLDER_PATH}/${gettext_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${gettext_url}" "${gettext_archive}" "${gettext_folder_name}"

    (
      mkdir -p "${BUILD_FOLDER_PATH}/${gettext_folder_name}"
      cd "${BUILD_FOLDER_PATH}/${gettext_folder_name}"

      xbb_activate_this

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS}"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_APP}"

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running gettext configure..."

          bash "${SOURCES_FOLDER_PATH}/${gettext_folder_name}/configure" --help

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${gettext_folder_name}/configure" \
            --prefix="${INSTALL_FOLDER_PATH}" 

          cp "config.log" "${LOGS_FOLDER_PATH}/config-gettext-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-gettext-output.txt"
      fi

      (
        echo
        echo "Running gettext make..."

        # Build.
        make ${JOBS}
        make install-strip
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-gettext-output.txt"
    )

    (
      echo
      "${INSTALL_FOLDER_PATH}/bin/gettext" --version
    )

    hash -r

    touch "${gettext_stamp_file_path}"

  else
    echo "Component gettext already installed."
  fi
}

function do_patch() 
{
  # https://www.gnu.org/software/patch/
  # https://ftp.gnu.org/gnu/patch/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=patch-git

  # 2015-03-06
  local patch_version="2.7.5"

  local patch_folder_name="patch-${patch_version}"
  local patch_archive="${patch_folder_name}.tar.xz"
  local patch_url="https://ftp.gnu.org/gnu/patch/${patch_archive}"

  local patch_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-patch-installed"
  if [ ! -f "${patch_stamp_file_path}" -o ! -d "${BUILD_FOLDER_PATH}/${patch_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${patch_url}" "${patch_archive}" "${patch_folder_name}"

    (
      mkdir -p "${BUILD_FOLDER_PATH}/${patch_folder_name}"
      cd "${BUILD_FOLDER_PATH}/${patch_folder_name}"

      xbb_activate_this

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS}"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_APP}"

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running patch configure..."

          bash "${SOURCES_FOLDER_PATH}/${patch_folder_name}/configure" --help

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${patch_folder_name}/configure" \
            --prefix="${INSTALL_FOLDER_PATH}" 

          cp "config.log" "${LOGS_FOLDER_PATH}/config-patch-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-patch-output.txt"
      fi

      (
        echo
        echo "Running patch make..."

        # Build.
        make ${JOBS}
        make install-strip
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-patch-output.txt"
    )

    (
      echo
      "${INSTALL_FOLDER_PATH}/bin/patch" --version
    )

    hash -r

    touch "${patch_stamp_file_path}"

  else
    echo "Component patch already installed."
  fi
}

function do_diffutils() 
{
  # https://www.gnu.org/software/diffutils/
  # https://ftp.gnu.org/gnu/diffutils/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=diffutils-git

  # 2017-05-21
  local diffutils_version="3.6"

  local diffutils_folder_name="diffutils-${diffutils_version}"
  local diffutils_archive="${diffutils_folder_name}.tar.xz"
  local diffutils_url="https://ftp.gnu.org/gnu/diffutils/${diffutils_archive}"

  local diffutils_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-diffutils-installed"
  if [ ! -f "${diffutils_stamp_file_path}" -o ! -d "${BUILD_FOLDER_PATH}/${diffutils_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${diffutils_url}" "${diffutils_archive}" "${diffutils_folder_name}"

    (
      mkdir -p "${BUILD_FOLDER_PATH}/${diffutils_folder_name}"
      cd "${BUILD_FOLDER_PATH}/${diffutils_folder_name}"

      xbb_activate_this

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS}"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_APP}"

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running diffutils configure..."

          bash "${SOURCES_FOLDER_PATH}/${diffutils_folder_name}/configure" --help

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${diffutils_folder_name}/configure" \
            --prefix="${INSTALL_FOLDER_PATH}" 

          cp "config.log" "${LOGS_FOLDER_PATH}/config-diffutils-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-diffutils-output.txt"
      fi

      (
        echo
        echo "Running diffutils make..."

        # Build.
        make ${JOBS}
        make install-strip
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-diffutils-output.txt"
    )

    (
      echo
      "${INSTALL_FOLDER_PATH}/bin/diff" --version
    )

    hash -r

    touch "${diffutils_stamp_file_path}"

  else
    echo "Component diffutils already installed."
  fi
}

function do_bison() 
{
  # https://www.gnu.org/software/bison/
  # https://ftp.gnu.org/gnu/bison/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=bison-git

  # 2015-01-23
  local bison_version="3.0.4"

  local bison_folder_name="bison-${bison_version}"
  local bison_archive="${bison_folder_name}.tar.xz"
  local bison_url="https://ftp.gnu.org/gnu/bison/${bison_archive}"

  local bison_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-bison-installed"
  if [ ! -f "${bison_stamp_file_path}" -o ! -d "${BUILD_FOLDER_PATH}/${bison_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${bison_url}" "${bison_archive}" "${bison_folder_name}"

    (
      mkdir -p "${BUILD_FOLDER_PATH}/${bison_folder_name}"
      cd "${BUILD_FOLDER_PATH}/${bison_folder_name}"

      xbb_activate_this

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS}"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_APP}"

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running bison configure..."

          bash "${SOURCES_FOLDER_PATH}/${bison_folder_name}/configure" --help

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${bison_folder_name}/configure" \
            --prefix="${INSTALL_FOLDER_PATH}" 

          cp "config.log" "${LOGS_FOLDER_PATH}/config-bison-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-bison-output.txt"
      fi

      (
        echo
        echo "Running bison make..."

        # Build.
        make ${JOBS}
        make install-strip
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-bison-output.txt"
    )

    (
      echo
      "${INSTALL_FOLDER_PATH}/bin/bison" --version
    )

    hash -r

    touch "${bison_stamp_file_path}"

  else
    echo "Component bison already installed."
  fi
}

function do_make() 
{
  # https://www.gnu.org/software/make/
  # https://ftp.gnu.org/gnu/make/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=make-git

  # 2016-06-10
  local make_version="4.2.1"

  local make_folder_name="make-${make_version}"
  local make_archive="${make_folder_name}.tar.bz2"
  local make_url="https://ftp.gnu.org/gnu/make/${make_archive}"

  local make_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-make-installed"
  if [ ! -f "${make_stamp_file_path}" -o ! -d "${BUILD_FOLDER_PATH}/${make_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${make_url}" "${make_archive}" "${make_folder_name}"

    (
      mkdir -p "${BUILD_FOLDER_PATH}/${make_folder_name}"
      cd "${BUILD_FOLDER_PATH}/${make_folder_name}"

      xbb_activate_this

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS}"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_APP}"

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running make configure..."

          bash "${SOURCES_FOLDER_PATH}/${make_folder_name}/configure" --help

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${make_folder_name}/configure" \
            --prefix="${INSTALL_FOLDER_PATH}" \
            --with-guile

          cp "config.log" "${LOGS_FOLDER_PATH}/config-make-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-make-output.txt"
      fi

      (
        echo
        echo "Running make make..."

        # Build.
        make ${JOBS}
        make install-strip
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-make-output.txt"
    )

    (
      echo
      "${INSTALL_FOLDER_PATH}/bin/make" --version
    )

    hash -r

    touch "${make_stamp_file_path}"

  else
    echo "Component make already installed."
  fi
}

function do_wget() 
{
  # https://www.gnu.org/software/wget/
  # https://ftp.gnu.org/gnu/wget/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=wget-git

  # 2016-06-10
  local wget_version="1.19"

  local wget_folder_name="wget-${wget_version}"
  local wget_archive="${wget_folder_name}.tar.xz"
  local wget_url="https://ftp.gnu.org/gnu/wget/${wget_archive}"

  local wget_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-wget-installed"
  if [ ! -f "${wget_stamp_file_path}" -o ! -d "${BUILD_FOLDER_PATH}/${wget_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${wget_url}" "${wget_archive}" "${wget_folder_name}"

    (
      mkdir -p "${BUILD_FOLDER_PATH}/${wget_folder_name}"
      cd "${BUILD_FOLDER_PATH}/${wget_folder_name}"

      xbb_activate_this

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS} -Wno-implicit-function-declaration"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_APP}"
      export LIBS="-liconv"

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running wget configure..."

          bash "${SOURCES_FOLDER_PATH}/${wget_folder_name}/configure" --help

          # libpsl is not available anyway.
          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${wget_folder_name}/configure" \
            --prefix="${INSTALL_FOLDER_PATH}" \
            --without-libpsl \
            --without-included-regex \
            --enable-nls \
            --enable-dependency-tracking \
            --with-ssl=gnutls \
            --with-metalink \
            --disable-debug \
            --disable-pcre \
            --disable-pcre2 

          cp "config.log" "${LOGS_FOLDER_PATH}/config-wget-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-wget-output.txt"
      fi

      (
        echo
        echo "Running wget make..."

        # Build.
        make ${JOBS} V=1
        make install-strip
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-wget-output.txt"
    )

    (
      echo
      "${INSTALL_FOLDER_PATH}/bin/wget" --version
    )

    hash -r

    touch "${wget_stamp_file_path}"

  else
    echo "Component wget already installed."
  fi
}

function do_texinfo() 
{
  # https://www.gnu.org/software/texinfo/
  # https://ftp.gnu.org/gnu/texinfo/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=texinfo-svn

  # 2017-09-12
  local texinfo_version="6.5"

  local texinfo_folder_name="texinfo-${texinfo_version}"
  local texinfo_archive="${texinfo_folder_name}.tar.gz"
  local texinfo_url="https://ftp.gnu.org/gnu/texinfo/${texinfo_archive}"

  local texinfo_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-texinfo-installed"
  if [ ! -f "${texinfo_stamp_file_path}" -o ! -d "${BUILD_FOLDER_PATH}/${texinfo_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${texinfo_url}" "${texinfo_archive}" "${texinfo_folder_name}"

    (
      mkdir -p "${BUILD_FOLDER_PATH}/${texinfo_folder_name}"
      cd "${BUILD_FOLDER_PATH}/${texinfo_folder_name}"

      xbb_activate_this

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS}"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_APP}"

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running texinfo configure..."

          bash "${SOURCES_FOLDER_PATH}/${texinfo_folder_name}/configure" --help

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${texinfo_folder_name}/configure" \
            --prefix="${INSTALL_FOLDER_PATH}" 

          cp "config.log" "${LOGS_FOLDER_PATH}/config-texinfo-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-texinfo-output.txt"
      fi

      (
        echo
        echo "Running texinfo make..."

        # Build.
        make ${JOBS}
        make install-strip
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-texinfo-output.txt"
    )

    (
      echo
      "${INSTALL_FOLDER_PATH}/bin/texi2pdf" --version
    )

    hash -r

    touch "${texinfo_stamp_file_path}"

  else
    echo "Component texinfo already installed."
  fi
}

# =============================================================================

# WARNING: the order is important, since some of the builds depend
# on previous ones.

# New zlib, used in most of the tools.
do_zlib

do_openssl

do_curl
do_xz
do_tar

do_coreutils

do_gmp
do_mpfr
do_mpc
do_isl

do_nettle
do_tasn1
do_expat
do_libffi

do_pkg_config
do_libiconv

do_gnutls

do_gawk
do_autoconf
do_automake
do_libtool

# Abort trap: 6
# do_m4

do_gettext

do_patch
do_diffutils

# Abort trap: 6
# do_bison

do_make

# error: no member named 'rpl_unlink' in 'struct options'
# do_wget

do_texinfo
# do_patchelf
# do_dos2unix
# do_flex

# do_git

# do_perl
# do_cmake
# do_python
# do_scons
# do_python3

# do_binutils
# do_gcc

# do_ninja
# do_meson

echo
echo Done
say done

# -----------------------------------------------------------------------------
