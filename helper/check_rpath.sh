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

  if [ -f "${bin}" ]
  then
    # Return 0 (true) if found.
    file ${bin} | egrep -q "( ELF )|( PE )|( PE32 )|( PE32\+ )|( Mach-O )"
  else
    return 1
  fi
}

function is_static()
{
  if [ $# -lt 1 ]
  then
    warning "is_static: Missing arguments"
    exit 1
  fi
  local bin="$1"

  # Symlinks do not match.
  if [ -L "${bin}" ]
  then
    return 1
  fi

  if [ -f "${bin}" ]
  then
    # Return 0 (true) if found.
    file ${bin} | egrep -q "statically linked"
  else
    return 1
  fi
}

function is_linux_sys_so() 
{
  local lib_name="$1"

  # Do not add these two, they are present if the toolchain is installed, 
  # but this is not guaranteed, so better copy them from the xbb toolchain.
  # libstdc++.so.6 
  # libgcc_s.so.1 

  # Shared libraries that are expected to be present on any Linux.
  # Note the X11 libraries.
if [ "${IS_BOOTSTRAP}" == "y" ]
then
  local sys_lib_names=(\
    librt.so.1 \
    libm.so.6 \
    libc.so.6 \
    libutil.so.1 \
    libpthread.so.0 \
    libgomp.so.1 \
    libdl.so.2 \
    ld-linux.so.2 \
    ld-linux.so.3 \
    ld-linux-x86-64.so.2 \
    ld-linux-armhf.so.3 \
    ld-linux-arm64.so.1 \
    ld-linux-aarch64.so.1 \
    libX11.so.6 \
    libXau.so.6 \
    libxcb.so.1 \
    libz.so.1 \
    \
    libgcc_s.so.1 \
    libstdc++.so.6 \
    libnsl.so.1 \
  )
else
  if [ ! -f "${BUILD_FOLDER_PATH}/.activate_installed_bin" ]
  then
    # For the moment they are the same, but a separate glibc may
    # have a different list.
    local sys_lib_names=(\
      libdl.so.2 \
      libc.so.6 \
      libm.so.6 \
      libpthread.so.0 \
      librt.so.1 \
      libgcc_s.so.1 \
      libstdc++.so.6 \
      libnsl.so.1 \
      libgomp.so.1 \
      libutil.so.1 \
      ld-linux.so.2 \
      ld-linux.so.3 \
      ld-linux-x86-64.so.2 \
      ld-linux-armhf.so.3 \
      ld-linux-arm64.so.1 \
      ld-linux-aarch64.so.1 \
    )
  else
    local sys_lib_names=(\
      "-"
    )
  fi
fi

  local sys_lib_name
  for sys_lib_name in "${sys_lib_names[@]}"
  do
    if [ "${lib_name}" == "${sys_lib_name}" ]
    then
      return 0 # True
    fi
  done
  return 1 # False
}

function run_app()
{
  # Does not include the .exe extension.
  local app_path=$1
  shift

  echo
  echo "${app_path} $@"
  "${app_path}" $@ 2>&1
}

# -----------------------------------------------------------------------------

function main()
{
  if [ $# -lt 1 ]
  then
    echo "Usage: check_rpath <file>"
    exit 1
  fi

  file_path="$1"

  if [[ "${file_path}" == *\.dll ]]
  then
    exit 0
  fi

  if ! is_elf "${file_path}"
  then
    exit 0
  fi

  if is_static "${file_path}"
  then
    exit 0
  fi

  if [ -L "${file_path}" ]
  then
    exit 0
  fi

  show_details=""

  # http://man7.org/linux/man-pages/man8/ld.so.8.html
  # RPATH if not RUNPATH
  # LD_LIBRARY_PATH
  # RUNPATH
  # /etc/ld.so.cache
  # /lib:/usr/lib or /lib64:/usr/lib64, if not -z nodeflib

  set +e

  shlibs="$(readelf -d "${file_path}" | grep '(NEEDED)' | sed -e 's|.*\[\(.*\)\].*|\1|')"
  if [ -z "${shlibs}" ]
  then
    # Has no dependencies.
    echo "  $(basename ${file_path}) -"
    exit 0
  fi

  shlibs_names=( $shlibs )
  found_names=()
  found_in_system_names=()

  runpath="$(readelf -d "${file_path}" | egrep '(RUNPATH)' | sed -e 's|.*\[\(.*\)\].*|\1|')"
  rpath="$(readelf -d "${file_path}" | egrep '(RPATH)' | sed -e 's|.*\[\(.*\)\].*|\1|')"
  interpreter="$(patchelf --print-interpreter "${file_path}" 2>/dev/null)"

  if [ -z "${runpath}${rpath}" ]
  then
    echo "  ${lib_name} has no rpath"
    folder_paths=()
    show_details="y"
  else
    save_ifs=${IFS}
    if [ -n "${runpath}" ]
    then
      IFS=: folder_paths=( ${runpath} )
    elif [ -n "${rpath}" ]
    then
      IFS=: folder_paths=( ${rpath} )
    fi
    IFS=${save_ifs}
  fi

  set -e

  if [ -x "/usr/share/libtool/build-aux/config.guess" ]
  then
    build="$(/usr/share/libtool/build-aux/config.guess)"
  else
    build="$(gcc -dumpmachine)"
  fi

  if [ "${build}" == "i686-linux-gnu" ]
  then
    build="i386-linux-gnu"
  fi

  sys_libs_folder_paths=(
    "/lib64" \
    "/lib" \
    "/usr/lib64" \
    "/usr/lib" \
    "/usr/${build}" \
    "/lib/${build}" \
    "/usr/lib/${build}" \
  )

  # echo ${shlibs_names[@]}
  # echo ${folder_paths[@]}
  errors=()

  for lib_name in ${shlibs_names[@]}
  do
    found=""
    found_in_sys=""

    for folder_path in ${folder_paths[@]}
    do
      if [[ "${folder_path}" == \$ORIGIN* ]]
      then
        local subst_path=$(echo "${folder_path}" | sed -e "s|\$ORIGIN|$(dirname ${file_path})|")
        if [ -f "${subst_path}/${lib_name}" ]
        then
          found="y"
          found_names+=( "${lib_name}" )
          break
        fi
      else
        if [ -f "${folder_path}/${lib_name}" ]
        then
          found="y"
          found_names+=( "${lib_name}" )
          break
        fi
      fi
    done

    if [ "${found}" != "y" ]
    then
      for folder_path in ${sys_libs_folder_paths[@]}
      do
        if [ -f "${folder_path}/${lib_name}" ]
        then
          found_in_sys="y"
          found_in_system_names+=( "${lib_name}" )
          break
        fi
      done

      if [ "${found_in_sys}" == "y" ]
      then
        if ! is_linux_sys_so "${lib_name}"
        then
          errors+=("    ${lib_name} not expected here")
          show_details="y"
        fi
      fi
    fi

    if [ "${found}" != "y" -a "${found_in_sys}" != "y" ]
    then
      errors+=("    ${lib_name} not found")
      show_details="y"
    fi

  done

  set +u
  msg="  $(basename ${file_path}) [$(IFS=" "; echo "${found_names[*]}")] [$(IFS=" "; echo "${found_in_system_names[*]}")]"
  if [ -n "${runpath}" ]
  then
    msg+=" RUNPATH=${runpath}"
  else
    msg+=" RPATH=${rpath}"
  fi
  if [ -n "${interpreter}" ]
  then
    msg+=" LD=${interpreter}"
  fi
  echo "${msg}"
  for err in ${errors[@]}
  do
    echo "${err}"
  done
  set -u

  if [ "${show_details}" == "y" ]
  then
    local readelf="$(which readelf)"
    local ldd="$(which ldd)"
    local patchelf="$(which patchelf)"
    if [ "${IS_BOOTSTRAP}" == "y" ]
    then
      patchelf="${INSTALL_FOLDER_PATH}/bin/patchelf"
    fi

    run_app "${patchelf}" --print-interpreter "${file_path}" || true
    run_app "${patchelf}" --print-rpath "${file_path}" || true
    run_app "${ldd}" -v "${file_path}"
    echo
  fi
}

# -----------------------------------------------------------------------------

main $@

exit 0
