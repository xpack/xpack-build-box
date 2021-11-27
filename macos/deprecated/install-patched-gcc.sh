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

WORK_FOLDER_PATH="$(mktemp -d /tmp/xbb-patched-XXXXXX)"
rm -rf "${WORK_FOLDER_PATH}"
mkdir -p "${WORK_FOLDER_PATH}"

DOWNLOAD_FOLDER_PATH="${HOME}/Library/Caches/XBB"

function extract()
{
  local archive_name="$1"
  local folder_name="$2"
  local pwd="$(pwd)"

  if [ ! -d "${folder_name}" ]
  then
    (
      xbb_activate

      echo
      echo "Extracting \"${archive_name}\"..."
      if [[ "${archive_name}" == *zip ]]
      then
        unzip "${archive_name}" -d "$(basename ${archive_name} ".zip")"
      else
        tar xf "${archive_name}"
      fi
    )
  else
    echo "Folder \"$(pwd)/${folder_name}\" already present."
  fi
}

function download()
{
  local url="$1"
  local archive_name="$2"

  if [ ! -f "${DOWNLOAD_FOLDER_PATH}/${archive_name}" ]
  then
    (
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
  extract "${DOWNLOAD_FOLDER_PATH}/${archive_name}" "${folder_name}"
}

source "$HOME/opt/homebrew/xbb/bin/xbb-source.sh"

set +e
xcode-select --install
set -e

GCC_VERSION="7.2.0"
GCC_FOLDER_NAME="gcc-${GCC_VERSION}"
GCC_ARCHIVE="${GCC_FOLDER_NAME}.tar.xz"
GCC_URL="https://ftp.gnu.org/gnu/gcc/${GCC_FOLDER_NAME}/${GCC_ARCHIVE}"

if [ ! -f "${WORK_FOLDER_PATH}/${GCC_FOLDER_NAME}" ]
then
  (
    xbb_activate

    cd "${WORK_FOLDER_PATH}"
    download_and_extract "${GCC_URL}" "${GCC_ARCHIVE}" "${GCC_FOLDER_NAME}"

    cd "${WORK_FOLDER_PATH}"
    wget https://gcc.gnu.org/ml/gcc-patches/2017-09/txtd196Be63lt.txt -O txtd196Be63lt.txt

    cd "${GCC_FOLDER_NAME}"
    patch -p1 < ../txtd196Be63lt.txt

    if [ "$(uname -r)" == "17.4.0" ]
    then
      cd "${WORK_FOLDER_PATH}"
      wget "https://raw.githubusercontent.com/Homebrew/formula-patches/df0465c02a/gcc/apfs.patch" -O apfs.patch

      patch -p0 < apfs.patch
    fi
  )
fi


INSTALL_FOLDER_PATH="${HOME}/opt/homebrew/xbb/Cellar/gcc/${GCC_VERSION}-patched"
rm -rf "${INSTALL_FOLDER_PATH}"
mkdir -p "${INSTALL_FOLDER_PATH}"

BUILD_FOLDER_PATH="${WORK_FOLDER_PATH}"/build

bash "${WORK_FOLDER_PATH}/${GCC_FOLDER_NAME}"/configure --help

export CFLAGS="-O2"
export CXXFLAGS="-O2"
export CPPFLAGS="-I${HOME}/opt/homebrew/xbb/include"
export LDFLAGS="-L${HOME}/opt/homebrew/xbb/lib"

echo "${WORK_FOLDER_PATH}"

PROGRAM_SUFFIX="-${GCC_VERSION}-patched"
(
  xbb_activate

  rm -rf "${BUILD_FOLDER_PATH}"
  mkdir -p "${BUILD_FOLDER_PATH}"
  cd "${BUILD_FOLDER_PATH}"

  case "$(uname -r)" in
  "17.4.0" | "17.7.0" )
    bash ../${GCC_FOLDER_NAME}/configure \
      --prefix="${INSTALL_FOLDER_PATH}" \
      --with-gmp=${HOME}/opt/homebrew/xbb \
      --with-mpfr=${HOME}/opt/homebrew/xbb \
      --with-mpc=${HOME}/opt/homebrew/xbb \
      --with-isl=${HOME}/opt/homebrew/xbb \
      --with-libiconv-prefix=${HOME}/opt/homebrew/xbb \
      --disable-nls \
      --enable-languages=c,c++ \
      --enable-checking=release \
      --program-suffix="${PROGRAM_SUFFIX}" \
      --with-native-system-header-dir=/usr/include \
      --with-sysroot=$(xcode-select -print-path)/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
    ;;
  "14.5.0" )
    bash ../${GCC_FOLDER_NAME}/configure \
      --prefix="${INSTALL_FOLDER_PATH}" \
      --with-gmp=${HOME}/opt/homebrew/xbb \
      --with-mpfr=${HOME}/opt/homebrew/xbb \
      --with-mpc=${HOME}/opt/homebrew/xbb \
      --with-isl=${HOME}/opt/homebrew/xbb \
      --with-libiconv-prefix=${HOME}/opt/homebrew/xbb \
      --disable-nls \
      --enable-languages=c,c++ \
      --enable-checking=release \
      --program-suffix="${PROGRAM_SUFFIX}"
    ;;
  *)
    echo "Update script for other Darwin versions and rerun."
    exit 1
    ;;
  esac

  threads=$(sysctl -n hw.ncpu)
  caffeinate make -j${threads}

  make install

  "${INSTALL_FOLDER_PATH}/bin/gcc${PROGRAM_SUFFIX}" --version

  rm -f "${HOME}"/opt/homebrew/xbb/bin/*"${PROGRAM_SUFFIX}"

  ln -s "${INSTALL_FOLDER_PATH}"/bin/*"${PROGRAM_SUFFIX}" \
    "${HOME}"/opt/homebrew/xbb/bin
)

rm -rf "${WORK_FOLDER_PATH}"
