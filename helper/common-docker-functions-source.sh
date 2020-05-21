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

function host_init_docker_env()
{
  WORK_FOLDER_PATH="${HOME}/Work"
  CACHE_FOLDER_PATH="${WORK_FOLDER_PATH}/cache"

  docker system prune -f

  if [ "$(uname)" == "Linux" ]
  then
    NPROC=$(nproc)
  elif [ "$(uname)" == "Darwin" ]
  then
    NPROC=$(sysctl hw.ncpu | sed 's/hw.ncpu: //')
  fi

  export NPROC

  cd "${script_folder_path}"
}

function host_init_docker_input()
{
  rm -rf "${script_folder_path}/input"
  mkdir -pv "${script_folder_path}/input/helper/patches"

  if [ -d "${script_folder_path}/container-scripts" ]
  then
    ln -v "${script_folder_path}/container-scripts"/*.sh "${script_folder_path}/input"
  fi

  # Using hard links simplifies development, since edits will no longer 
  # need to be propagated back.

  # Hard link the entire content of the helper folder.
  ln -v "${helper_folder_path}"/*.sh "${script_folder_path}/input/helper"
  ln -v "${helper_folder_path}"/pkg-config-verbose "${script_folder_path}/input/helper"

  ln -v "${helper_folder_path}/patches"/*.patch "${script_folder_path}/input/helper/patches"
  
  # Possibly hard link additional files.
  while [ $# -gt 0 ]
  do
    if [ -f "$1" ]
    then
      ln -v "$1" "${script_folder_path}/input/helper"
    elif [ -d "$1" ]
    then
      local subfolder=$(basename "$1")
      mkdir -pv "${script_folder_path}/input/helper/${subfolder}"
      ln -v "$1"/* "${script_folder_path}/input/helper/${subfolder}"
    fi

    shift
  done
}

function host_clean_docker_input()
{
  rm -rf "${script_folder_path}/input"
}

function host_run_docker_it()
{
  # Warning: do not use HOST_MACHINE!
  out="${HOME}/opt/${name}-${distro}-${release}-${arch}"
  mkdir -pv "${out}"
  bootstrap_path="${HOME}/opt/${name}-bootstrap-${distro}-${release}-${arch}"

  echo 
  echo "Running parent Docker image ${from}..."

  if [[ "${name}" == *-bootstrap ]]
  then
    docker run \
      --interactive \
      --tty \
      --hostname "${name}-${arch}" \
      --workdir="/root" \
      --env DEBUG="${DEBUG}" \
      --env JOBS="${JOBS:-${NPROC}}" \
      --env XBB_VERSION="${version}" \
      --env RUN_LONG_TESTS="${RUN_LONG_TESTS:-""}" \
      --volume="${WORK_FOLDER_PATH}:/root/Work" \
      --volume="${script_folder_path}/input:/input" \
      --volume="${out}:/opt/${name}" \
      ${from}
  else
    if [ ! -d "${bootstrap_path}" ]
    then
      echo "Missing bootstrap folder ${bootstrap_path}."
      exit 1
    fi

    docker run \
      --interactive \
      --tty \
      --hostname "${name}-${arch}" \
      --workdir="/root" \
      --env DEBUG="${DEBUG}" \
      --env JOBS="${JOBS:-${NPROC}}" \
      --env XBB_VERSION="${version}" \
      --env RUN_LONG_TESTS="${RUN_LONG_TESTS:-""}" \
      --volume="${WORK_FOLDER_PATH}:/root/Work" \
      --volume="${script_folder_path}/input:/input" \
      --volume="${out}:/opt/${name}" \
      --volume="${bootstrap_path}:/opt/${name}-bootstrap" \
      ${from}
  fi
}

function host_run_docker_it_bs()
{
  # Warning: do not use HOST_MACHINE!
  out="${HOME}/opt/${name}-${distro}-${release}-${arch}"
  mkdir -pv "${out}"

  echo 
  echo "Running parent Docker image ${from}..."

    docker run \
      --interactive \
      --tty \
      --hostname "${name}-${arch}" \
      --workdir="/root" \
      --env DEBUG="${DEBUG}" \
      --env JOBS="${JOBS:-${NPROC}}" \
      --env XBB_VERSION="${version}" \
      --env RUN_LONG_TESTS="${RUN_LONG_TESTS:-""}" \
      --volume="${WORK_FOLDER_PATH}:/root/Work" \
      --volume="${script_folder_path}/input:/input" \
      --volume="${out}:/opt/${name}" \
      ${from}
}

function host_run_docker_build()
{
  local version="$1"
  local tag="$2"
  local dockerfile="$3"

  set +e
  docker rmi "${tag}"
  set -e

  echo 
  echo "Building Docker image ${tag}..."
  docker build \
    --build-arg DEBUG="${DEBUG}" \
    --build-arg JOBS="${JOBS:-${NPROC}}" \
    --build-arg XBB_VERSION="${version}" \
    --build-arg RUN_LONG_TESTS="${RUN_LONG_TESTS:-""}" \
    --tag "${tag}" \
    --file "${dockerfile}" \
    .
}

# =============================================================================

function xbb_activate()
{
  :
}

# =============================================================================

# Used in tex images.
function docker_prepare_env()
{
  if [ ! -d "${WORK_FOLDER_PATH}" ]
  then
    mkdir -pv "${WORK_FOLDER_PATH}"
    touch "${WORK_FOLDER_PATH}/.dockerenv"
  fi
  
  IS_BOOTSTRAP=${IS_BOOTSTRAP:-""}
  # XBB_BOOTSTRAP_FOLDER_PATH=${XBB_BOOTSTRAP_FOLDER_PATH:-""}
  # RUN_LONG_TESTS=${RUN_LONG_TESTS:=""}

  # The place where files are downloaded.
  CACHE_FOLDER_PATH="${WORK_FOLDER_PATH}/cache"

  # Make all tools choose gcc, not the old cc.
  export CC=gcc
  export CXX=g++

  export IS_BOOTSTRAP

  echo
  echo "docker env..."
  env | sort
}

function docker_download_rootfs()
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

  docker_download_rootfs "${archive_name}"

  # Assume "input" was created by init_input().
  cp "${CACHE_FOLDER_PATH}/${archive_name}" "input"

  echo 
  echo "Building Docker image ${tag}..."
  docker build --tag "${tag}" -f "${arch}-Dockerfile" .
}

# =============================================================================

function docker_replace_source_list()
{
  local url=$1
  local name=$2

  echo
  echo "The orginal /etc/apt/sources.list"
  cat "/etc/apt/sources.list"
  echo "---"

  # -----------------------------------------------------------------------------

  echo "Creating new sources.list..."

# Note: __EOF__ is not quoted to allow substitutions here.
cat <<__EOF__  >"/etc/apt/sources.list"
# https://help.ubuntu.com/community/Repositories/Ubuntu
# See http://help.ubuntu.com/community/UpgradeNotes for how to upgrade to
# newer versions of the distribution.

deb ${url} ${name} main restricted
# deb-src ${url} ${name} main restricted
deb ${url} ${name}-security main restricted
# deb-src ${url} ${name}-security main restricted

## Major bug fix updates produced after the final release of the
## distribution.
deb ${url} ${name}-updates main restricted
# deb-src ${url} ${name}-updates main restricted

deb ${url} ${name}-backports main restricted 
# deb-src ${url} ${name}-backports main restricted 

## N.B. software from this repository is ENTIRELY UNSUPPORTED by the Ubuntu
## team. Also, please note that software in universe WILL NOT receive any
## review or updates from the Ubuntu security team.
deb ${url} ${name} universe
# deb-src ${url} ${name} universe
deb ${url} ${name}-security universe
# deb-src ${url} ${name}-security universe

deb ${url} ${name}-updates universe
# deb-src ${url} ${name}-updates universe

deb ${url} ${name}-backports universe 
# deb-src ${url} ${name}-backports universe 

## N.B. software from this repository is ENTIRELY UNSUPPORTED by the Ubuntu 
## team, and may not be under a free licence. Please satisfy yourself as to 
## your rights to use the software. Also, please note that software in 
## multiverse WILL NOT receive any review or updates from the Ubuntu
## security team.
deb ${url} ${name} multiverse
# deb-src ${url} ${name} multiverse
deb ${url} ${name}-security multiverse
# deb-src ${url} ${name}-security multiverse

deb ${url} ${name}-updates multiverse
# deb-src ${url} ${name}-updates multiverse

deb ${url} ${name}-backports multiverse
# deb-src ${url} ${name}-backports multiverse
__EOF__

  echo
  echo "The resulting /etc/apt/sources.list"
  cat "/etc/apt/sources.list" | egrep '^deb '
  echo "---"

  apt-get update 
  apt-get upgrade --yes 

  apt-get install --yes lsb-release

  # ---------------------------------------------------------------------------

  apt-get clean
  apt-get autoclean
  apt-get autoremove

  # ---------------------------------------------------------------------------

  echo
  uname -a
  lsb_release -a
}


function ubuntu_install_develop()
{
  # lsb_release must be present from upgrade.
  local release="$(lsb_release -r | sed 's/Release:[^0-9]*//')"
  local release_major=$(echo ${release} | sed -e 's|\([0-9][0-9]*\)\.[0-9].*|\1|')

  local machine="$(uname -m)"

  # ---------------------------------------------------------------------------

  echo "docker env..."
  env | sort
  # Be sure no tool will senter a curses mode.
  unset TERM

  # These tools should be enough to build the bootstrap tools.

  apt-get update
   
  apt-get install --yes \
  \
  autoconf \
  automake \
  bison \
  bzip2 \
  ca-certificates \
  cmake \
  cpio \
  curl \
  diffutils \
  file \
  flex \
  gawk \
  gcc \
  g++ \
  gettext \
  git \
  libc6-dev \
  libtool \
  m4 \
  make \
  patch \
  perl \
  pkg-config \
  python \
  python3 \
  re2c \
  rhash \
  rsync \
  tcl \
  time \
  unzip \
  wget \
  xz-utils \
  zip \
  zlib1g-dev \

  # Without it, building GCC on Arm 32-bit fails.
  # https://askubuntu.com/questions/1202249/c-compilng-failed
  if [ "${machine}" == "armv8l" -o "${machine}" == "armv7l" ]
  then
    apt-get install --yes g++-multilib
  fi

  # libtool-bin - not present in precise

  # For QEMU
  apt-get install --yes \
  libx11-dev \
  libxext-dev \
  mesa-common-dev \

  # For QEMU & OpenOCD
  apt-get install --yes \
  libudev-dev

  # From  (universe)
  apt-get install --yes \
  texinfo \
  help2man \

  # Not available on Ubuntu 16.
  if [ "${release}" != "16.04" ]
  then
    apt-get install --yes dos2unix
  fi

  # patchelf - not present in 14 trusty, 16 precise

  # Starting with 16.04, it is part of coreutils.
  if [ "${release}" == "12.04" -o "${release}" == "14.04" ]
  then
    apt-get install --yes realpath
  fi

  # ---------------------------------------------------------------------------

  # For add-apt-repository
  apt-get install --yes software-properties-common
  if [ "${release}" == "12.04" ]
  then
    # Only needed on old distributions.
    apt-get install --yes python-software-properties
  fi

  add-apt-repository --yes ppa:ubuntu-toolchain-r/test 
  add-apt-repository --yes ppa:openjdk-r/ppa

  apt-get update

  gcc --version

  local gcc_version="$(gcc -dumpversion)"
  local gcc_version_major=$(echo ${gcc_version} | sed -e 's|\([0-9][0-9]*\)\.[0-9].*|\1|')

  # Ubuntu 18 is already 7.4, no need to install 6.x.
  if [ ${gcc_version_major} -le 6 ]
  then
    # Install 6.x.
    apt-get install --yes \
    gcc-6 \
    g++-6 \

    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-6 60 --slave /usr/bin/g++ g++ /usr/bin/g++-6
    if [ "${release}" == "12.04" ]
    then
      update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.6 60 --slave /usr/bin/g++ g++ /usr/bin/g++-4.6
    elif [ "${release}" == "14.04" ]
    then
      update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 60 --slave /usr/bin/g++ g++ /usr/bin/g++-4.6
    elif [ "${release}" == "16.04" ]
    then
      update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 60 --slave /usr/bin/g++ g++ /usr/bin/g++-5
    fi

    echo 2 | update-alternatives --config gcc
  fi

  apt-get install --yes gdb

  # ---------------------------------------------------------------------------

  apt-get install --yes openjdk-8-jdk

  apt-get install --yes ant

  # maven not available in Ubuntu 14, and not needed so far.
  # apt-get install --yes maven

  # ---------------------------------------------------------------------------

  # https://www.thomas-krenn.com/en/wiki/Configure_Locales_in_Ubuntu
  apt-get install --yes locales
  locale-gen en_US.UTF-8
  update-locale LANG=en_US.UTF-8

  # ---------------------------------------------------------------------------

  echo
  uname -a
  lsb_release -a

  ant -version
  autoconf --version
  bison --version
  cmake --version
  curl --version
  flex --version
  g++ --version
  gawk --version
  gdb --version
  git --version
  java -version
  m4 --version
  # mvn -version
  make --version
  patch --version
  perl --version
  pkg-config --version
  python --version
  python3 --version

}

function ubuntu_clean()
{
  apt-get clean --yes
  apt-get autoclean --yes
  apt-get autoremove --yes
}

# =============================================================================
