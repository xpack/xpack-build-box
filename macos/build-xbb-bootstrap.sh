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

XBB_FOLDER="${HOME}/opt/xbb-bootstrap"

DOWNLOAD_FOLDER_PATH="${HOME}/Library/Caches/XBB"
WORK_FOLDER_PATH="${HOME}/Work/darwin-$(basename "${XBB_FOLDER}")"

BUILD_FOLDER_PATH="${WORK_FOLDER_PATH}/build"
LIBS_BUILD_FOLDER_PATH="${WORK_FOLDER_PATH}/build/libs"
SOURCES_FOLDER_PATH="${WORK_FOLDER_PATH}/sources"
STAMPS_FOLDER_PATH="${WORK_FOLDER_PATH}/stamps"
LOGS_FOLDER_PATH="${WORK_FOLDER_PATH}/logs"

if true
then
  INSTALL_FOLDER_PATH="${XBB_FOLDER}"
else
  INSTALL_FOLDER_PATH="${WORK_FOLDER_PATH}/install"
fi

JOBS=-j1

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

export CC=gcc
export CXX=g++

# -----------------------------------------------------------------------------

XBB_CPPFLAGS=""

XBB_CFLAGS="-pipe"
XBB_CXXFLAGS="-pipe"

XBB_LDFLAGS=""
XBB_LDFLAGS_LIB="${XBB_LDFLAGS}"
XBB_LDFLAGS_APP="${XBB_LDFLAGS}"

PATH=${PATH:-""}
export PATH

PKG_CONFIG_PATH=${PKG_CONFIG_PATH:-":"}
export PKG_CONFIG_PATH

# Prevent pkg-config to search the system folders (configured in the
# pkg-config at build time).
PKG_CONFIG_LIBDIR=${PKG_CONFIG_LIBDIR:-":"}
export PKG_CONFIG_LIBDIR

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

  PKG_CONFIG_PATH=${PKG_CONFIG_PATH:=""}
  PKG_CONFIG_PATH="${INSTALL_FOLDER_PATH}/lib/pkgconfig:${PKG_CONFIG_PATH}"
}


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
          local patch_path="${script_folder_path}/patches/${patch_file_name}"
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

  local zlib_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-zlib-${zlib_version}-installed"
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

function do_coreutils() 
{
  # https://ftp.gnu.org/gnu/coreutils/
  local coreutils_version="8.31"

  local coreutils_folder_name="coreutils-${coreutils_version}"
  local coreutils_archive="${coreutils_folder_name}.tar.xz"
  local coreutils_url="https://ftp.gnu.org/gnu/coreutils/${coreutils_archive}"

  local coreutils_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-coreutils-${coreutils_version}-installed"
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

          # The GNU ar breaks the macOS builds with
          # 'file was built for x86_64 which is not the architecture being linked (x86_64)'
          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${coreutils_folder_name}/configure" \
            --prefix="${INSTALL_FOLDER_PATH}" \
            --enable-no-install-program=ar

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

  local gmp_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-gmp-${gmp_version}-installed"
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

  local mpfr_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-mpfr-${mpfr_version}-installed"
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

  local mpc_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-mpc-${mpc_version}-installed"
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

  local isl_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-isl-${isl_version}-installed"
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

  local pkg_config_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-pkg_config-${pkg_config_version}-installed"
  if [ ! -f "${pkg_config_stamp_file_path}" -o ! -d "${BUILD_FOLDER_PATH}/${pkg_config_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${pkg_config_url}" "${pkg_config_archive}" "${pkg_config_folder_name}"

    (
      mkdir -p "${BUILD_FOLDER_PATH}/${pkg_config_folder_name}"
      cd "${BUILD_FOLDER_PATH}/${pkg_config_folder_name}"

      xbb_activate_this

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS} -Wno-int-conversion -Wno-unused-value -Wno-unused-function -Wno-deprecated-declarations -Wno-return-type -Wno-tautological-constant-out-of-range-compare -Wno-sometimes-uninitialized -arch x86_64"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_APP} -v -arch x86_64"

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
            --with-internal-glib \
            --enable-static \
            --disable-debug \
            --disable-host-tool \
            --with-pc-path=""

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
  local m4_patch="m4-${m4_version}.patch"

  local m4_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-m4-${m4_version}-installed"
  if [ ! -f "${m4_stamp_file_path}" -o ! -d "${BUILD_FOLDER_PATH}/${m4_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${m4_url}" "${m4_archive}" "${m4_folder_name}" "${m4_patch}"

    (
      mkdir -p "${BUILD_FOLDER_PATH}/${m4_folder_name}"
      cd "${BUILD_FOLDER_PATH}/${m4_folder_name}"

      xbb_activate_this

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS} -Wno-incompatible-pointer-types"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_APP}"

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running m4 configure..."

          bash "${SOURCES_FOLDER_PATH}/${m4_folder_name}/configure" --help

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${m4_folder_name}/configure" \
            --prefix="${INSTALL_FOLDER_PATH}" 

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

  local gawk_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-gawk-${gawk_version}-installed"
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

  local autoconf_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-autoconf-${autoconf_version}-installed"
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

  local automake_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-automake-${automake_version}-installed"
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

  local libtool_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-libtool-${libtool_version}-installed"
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

  local make_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-make-${make_version}-installed"
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
            --prefix="${INSTALL_FOLDER_PATH}" 

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

BINUTILS_SUFFIX="-7bs"

function do_binutils() 
{
  # https://www.gnu.org/software/binutils/
  # https://ftp.gnu.org/gnu/binutils/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=gdb-git

  # 2017-07-24
  local binutils_version="2.29"
  # 2019-02-02
  # local binutils_version="2.32"

  local binutils_folder_name="binutils-${binutils_version}"
  local binutils_archive="${binutils_folder_name}.tar.xz"
  local binutils_url="https://ftp.gnu.org/gnu/binutils/${binutils_archive}"
  
  local binutils_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-binutils-${binutils_version}-installed"
  if [ ! -f "${binutils_stamp_file_path}" -o ! -d "${BUILD_FOLDER_PATH}/${binutils_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${binutils_url}" "${binutils_archive}" "${binutils_folder_name}"

    (
      mkdir -p "${BUILD_FOLDER_PATH}/${binutils_folder_name}"
      cd "${BUILD_FOLDER_PATH}/${binutils_folder_name}"

      xbb_activate_this

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS} -Wno-sign-compare"
      export CXXFLAGS="${XBB_CXXFLAGS} -Wno-sign-compare"
      export LDFLAGS="${XBB_LDFLAGS_APP}"

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running binutils configure..."

          bash "${SOURCES_FOLDER_PATH}/${binutils_folder_name}/configure" --help

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${binutils_folder_name}/configure" \
            --prefix="${INSTALL_FOLDER_PATH}" \
            --program-suffix="${BINUTILS_SUFFIX}" \
            \
            --disable-shared \
            --enable-static \
            --enable-threads \
            --enable-deterministic-archives \
            --disable-gdb

          cp "config.log" "${LOGS_FOLDER_PATH}/config-binutils-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-binutils-output.txt"
      fi

      (
        echo
        echo "Running binutils make..."

        # Build.
        make ${JOBS}
        make install-strip
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-binutils-output.txt"
    )

    (
      echo
      "${INSTALL_FOLDER_PATH}/bin/size${BINUTILS_SUFFIX}" --version
      "${INSTALL_FOLDER_PATH}/bin/nm${BINUTILS_SUFFIX}" --version
      "${INSTALL_FOLDER_PATH}/bin/objcopy${BINUTILS_SUFFIX}" --version
    )

    hash -r

    touch "${binutils_stamp_file_path}"

  else
    echo "Component binutils already installed."
  fi
}

GCC_SUFFIX="-7bs"

function do_gcc() 
{
  # https://gcc.gnu.org
  # https://ftp.gnu.org/gnu/gcc/
  # https://gcc.gnu.org/wiki/InstallingGCC
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=gcc-git

  # 2018-12-06
  local gcc_version="7.4.0"

  local gcc_folder_name="gcc-${gcc_version}"
  local gcc_archive="${gcc_folder_name}.tar.xz"
  local gcc_url="https://ftp.gnu.org/gnu/gcc/gcc-${gcc_version}/${gcc_archive}"
  local gcc_branding="xPack Build Box Bootstrap GCC\x2C 64-bit"
  local gcc_patch="gcc-${gcc_version}.patch"

  local gcc_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-gcc-${gcc_version}-installed"
  if [ ! -f "${gcc_stamp_file_path}" -o ! -d "${BUILD_FOLDER_PATH}/${gcc_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${gcc_url}" "${gcc_archive}" "${gcc_folder_name}" "${gcc_patch}"

    (
      mkdir -p "${BUILD_FOLDER_PATH}/${gcc_folder_name}"
      cd "${BUILD_FOLDER_PATH}/${gcc_folder_name}"

      xbb_activate_this

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS} -Wno-sign-compare -Wno-varargs -Wno-tautological-compare  "
      export CXXFLAGS="${XBB_CXXFLAGS} -Wno-sign-compare -Wno-varargs -Wno-tautological-compare"
      export LDFLAGS="${XBB_LDFLAGS_APP}"

      # If configure picks the binutils ar or ranlib, the static
      # libraries are damaged and the build fails.
      export AR="/usr/bin/ar"
      export AR_FOR_TARGET="/usr/bin/ar"
      export RANLIB="/usr/bin/ranlib"
      export RANLIB_FOR_TARGET="/usr/bin/ranlib"
      export STRIP="/usr/bin/strip"
      export STRIP_FOR_TARGET="/usr/bin/strip"

      export NM="nm${BINUTILS_SUFFIX}"
      export STRIP="strip${BINUTILS_SUFFIX}"
      export OBJCOPY="objcopy${BINUTILS_SUFFIX}"
      export OBJDUMP="objdump${BINUTILS_SUFFIX}"
      export READELF="readelf${BINUTILS_SUFFIX}"

      # TODO: update for 10.10
      local sdk_path="$(xcode-select -print-path)/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running gcc configure..."

          bash "${SOURCES_FOLDER_PATH}/${gcc_folder_name}/configure" --help

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${gcc_folder_name}/configure" \
            --prefix="${INSTALL_FOLDER_PATH}" \
            --program-suffix="${GCC_SUFFIX}" \
            --with-pkgversion="${gcc_branding}" \
            --with-native-system-header-dir="/usr/include" \
            --with-sysroot="${sdk_path}" \
            \
            --enable-languages=c,c++ \
            --enable-checking=release \
            --disable-multilib \
            --disable-werror 

          cp "config.log" "${LOGS_FOLDER_PATH}/config-gcc-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-gcc-output.txt"
      fi

      (
        echo
        echo "Running gcc make..."

        # Build.
        make ${JOBS}
        make install-strip
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-gcc-output.txt"
    )

    (
      echo
      "${INSTALL_FOLDER_PATH}/bin/g++${GCC_SUFFIX}" --version

      mkdir -p "${HOME}"/tmp
      cd "${HOME}"/tmp

      # Note: __EOF__ is quoted to prevent substitutions here.
      cat <<'__EOF__' > hello.cpp
#include <iostream>

int
main(int argc, char* argv[])
{
  std::cout << "Hello" << std::endl;
}
__EOF__

      if true
      then

        "${XBB}/bin/g++${GCC_SUFFIX}" hello.cpp -o hello
        "${XBB}/bin/readelf${BINUTILS_SUFFIX}" -d hello

        if [ "x$(./hello)x" != "xHellox" ]
        then
          exit 1
        fi

      fi

      rm -rf hello.cpp hello
    )

    hash -r

    touch "${gcc_stamp_file_path}"

  else
    echo "Component gcc already installed."
  fi
}

# =============================================================================

# WARNING: the order is important, since some of the builds depend
# on previous ones.

if false
then

# New zlib, used in most of the tools.
do_zlib

do_coreutils

do_pkg_config

do_m4

do_gawk
do_autoconf
do_automake
do_libtool
do_make

fi

do_gmp
do_mpfr
do_mpc
do_isl

do_binutils
# TODO: /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk for 10.10!
do_gcc

echo chmod -R +w "${INSTALL_FOLDER_PATH}"

echo
echo Done
say done

echo chmod -R +w "${INSTALL_FOLDER_PATH}"

# -----------------------------------------------------------------------------
