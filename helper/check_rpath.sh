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

script_path="$0"
if [[ "${script_path}" != /* ]]
then
  # Make relative path absolute.
  script_path="$(pwd)/$0"
fi

script_name="$(basename "${script_path}")"

script_folder_path="$(dirname "${script_path}")"
script_folder_name="$(basename "${script_folder_path}")"

# -----------------------------------------------------------------------------

function is_elf()
{
  if [ $# -lt 1 ]
  then
    warning "is_elf: Missing arguments"
    exit 1
  fi
  local bin="$1"

  # Symlinks do not match.
  if [ -L "${bin}" ]
  then
    return 1
  fi

  if [ -f "${bin}" -a -x "${bin}" ]
  then
    # Return 0 (true) if found.
    file ${bin} | egrep -q "( ELF )|( PE )|( PE32 )|( PE32\+ )|( Mach-O )"
  else
    return 1
  fi
}

# -----------------------------------------------------------------------------

if [ $# -lt 1 ]
then
  echo "Usage: check_rpath <file>"
  exit 1
fi

# -----------------------------------------------------------------------------

file_path="$1"

if ! is_elf "${file_path}"
then
  exit 0
fi

# echo "${file_path}"

set +e
lines="$(readelf -d "${file_path}" | grep 'ibrary' | grep -v 'SONAME')"
set -e

if [ -z "${lines}" ]
then
  # echo "not shared"
  exit 0
fi

set +e
gcc_libs="$(printf "%b\n" "${lines}" | egrep -e 'libstdc++.so|libgcc_s.so')"
rpath_line="$(printf "%b\n" "${lines}" | grep 'rpath')"
libs="$(printf "%b\n" "${lines}" | grep -v 'libc.so' | grep -v 'libm.so' | grep -v 'libdl.so' | grep -v 'librt.so' | grep -v 'libpthread.so' | egrep -v 'ld-linux.*\.so')"
set -e

if [ -n "${gcc_libs}" ]
then
  echo
  echo "${file_path}"
  printf "%b\n" "${libs}"
fi

if [ -n "${rpath_line}" ]
then
  # echo "${file_path}"
  # printf "%b\n" "${rpath_line}"
  exit 0
fi

if [ -n "${libs}" ]
then
  echo
  echo "${file_path}"
  printf "%b\n" "${libs}"
fi

exit 0
