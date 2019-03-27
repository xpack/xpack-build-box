# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (http://xpack.github.io)
# Copyright (c) 2019 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software 
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

function create_pkg_config_verbose()
{
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
}

function create_xbb_source()
{
  echo "Creating ${XBB_FOLDER}/xbb-source.sh..."
  cat <<'__EOF__' > "${INSTALL_FOLDER_PATH}/xbb-source.sh"

export XBB_FOLDER="${HOME}/opt/xbb"
export TEXLIVE_FOLDER="${HOME}"/opt/texlive

# Allow binaries from XBB to be found before all other.
# Includes and pkg_config should be enabled only when needed.
function xbb_activate()
{
  PATH=${PATH:-""}

  PATH="${TEXLIVE_FOLDER}/bin/$(uname -m)-darwin:${PATH}"

  export PATH="${XBB_FOLDER}/bin:${PATH}"
}

# Allow for pkg_config files to be found before all other.
function xbb_activate_pkgconfig()
{
  export PKG_CONFIG_PATH="${XBB_FOLDER}/lib/pkgconfig:${PKG_CONFIG_PATH}"

  export PKG_CONFIG=pkg-config-verbose
}

# Add the XBB include folders to the preprocessor defs.
function xbb_activate_includes()
{
  EXTRA_CPPFLAGS=${EXTRA_CPPFLAGS:-""}

  export EXTRA_CPPFLAGS="-I${XBB_FOLDER}/include ${EXTRA_CPPFLAGS}"
}

# Make the build use the XBB libs & includes.
function xbb_activate_dev()
{
  xbb_activate_pkgconfig
  xbb_activate_includes
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

function eval_bool()
{
  local VAL="$1"
  [[ "${VAL}" = 1 || "${VAL}" = true || "${VAL}" = yes || "${VAL}" = y ]]
}


function check_binaries()
{
  local folder_path
  if [ $# -ge 1 ]
  then
    folder_path="$1"
  else
    folder_path="${INSTALL_FOLDER_PATH}"
  fi

  local binaries

  binaries=$(find "${folder_path}" -name \* -perm +111 -and ! -type d)
  for bin in ${binaries} 
  do
    if is_elf "${bin}"
    then
      check_binary "${bin}"
    fi
  done
}

function is_elf()
{
  if [ $# -lt 1 ]
  then
    warning "is_elf: Missing arguments"
    exit 1
  fi
  local bin="$1"

  if [ -x "${bin}" ]
  then
    # Return 0 (true) if found.
    file ${bin} | egrep -q " Mach-O 64-bit"
  else
    return 1
  fi
}

function check_binary()
{
  local file_path="$1"

  if [ ! -x "${file_path}" ]
  then
    return 0
  fi

  if file --mime "${file_path}" | grep -q text
  then
    return 0
  fi

  echo
  otool -L "$1"
}

# -----------------------------------------------------------------------------
