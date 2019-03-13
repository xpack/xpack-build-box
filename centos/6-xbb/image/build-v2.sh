#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Safety settings (see https://gist.github.com/ilg-ul/383869cbb01f61a51c4d).

if [[ ! -z ${DEBUG} ]]
then
  set ${DEBUG} # Activate the expand mode if DEBUG is -x.
else
  DEBUG=""
fi

set -o errexit # Exit if command failed.
set -o pipefail # Exit if pipe failed.
set -o nounset # Exit if variable not set.

# Remove the initial space and instead use '\n'.
IFS=$'\n\t'

# -----------------------------------------------------------------------------

# Script to build a subsequent version of a Docker image with the 
# xPack Build Box (xbb).

# To activate the new build environment, use:
#
#   $ source /opt/xbb/xbb-source.sh
#   $ xbb_activate

XBB_INPUT="/xbb-input"
source "${XBB_INPUT}/common-functions-source.sh"

prepare_env

cat <<'__EOF__' > "${XBB}/xbb-source.sh"

export XBB_FOLDER="/opt/xbb"

xbb_activate()
{
  UNAME_ARCH="$(uname -m)"

  PATH=${PATH:-""}
  if [ "${UNAME_ARCH}" == "x86_64" ]
  then
    PATH=/opt/texlive/bin/x86_64-linux:${PATH}
  elif [ "${UNAME_ARCH}" == "i686" ]
  then
    PATH=/opt/texlive/bin/i386-linux:${PATH}
  fi
  export PATH="${XBB_FOLDER}/bin":${PATH}

  LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-""}
  export LD_LIBRARY_PATH="${XBB_FOLDER}/lib:${LD_LIBRARY_PATH}"

  if [ "${UNAME_ARCH}" == "x86_64" ]
  then
    export LD_LIBRARY_PATH="${XBB_FOLDER}/lib64:${LD_LIBRARY_PATH}"
  fi
}

function xbb_activate_param()
{
  PREFIX_=${PREFIX_:-${XBB_FOLDER}}

  # Do not include -I... here, use CPPFLAGS.
  EXTRA_CFLAGS_=${EXTRA_CFLAGS_:-""}
  EXTRA_CXXFLAGS_=${EXTRA_CXXFLAGS_:-${EXTRA_CFLAGS_}}

  EXTRA_LDFLAGS_=${EXTRA_LDFLAGS_:-""}
  EXTRA_LDPATHFLAGS_=${EXTRA_LDPATHFLAGS_:-""}

  UNAME_ARCH="$(uname -m)"

  PATH=${PATH:-""}
  if [ "${UNAME_ARCH}" == "x86_64" ]
  then
    PATH=/opt/texlive/bin/x86_64-linux:${PATH}
  elif [ "${UNAME_ARCH}" == "i686" ]
  then
    PATH=/opt/texlive/bin/i386-linux:${PATH}
  fi

  LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-""}

  export PATH="${PREFIX_}/bin":${PATH}
  export C_INCLUDE_PATH="${PREFIX_}/include"
  export CPLUS_INCLUDE_PATH="${PREFIX_}/include"
  export LIBRARY_PATH="${PREFIX_}/lib"
  export CPPFLAGS="-I${PREFIX_}/include"

  export PKG_CONFIG_PATH="${PREFIX_}/lib/pkgconfig":/usr/lib/pkgconfig

  export LD_LIBRARY_PATH="${PREFIX_}/lib":${LD_LIBRARY_PATH}
  export LDPATHFLAGS="-L${PREFIX_}/lib ${EXTRA_LDPATHFLAGS_}"

  if [ "${UNAME_ARCH}" == "x86_64" ]
  then
    export PKG_CONFIG_PATH="${PREFIX_}/lib64/pkgconfig":${PKG_CONFIG_PATH}
    export LD_LIBRARY_PATH="${PREFIX_}/lib64":${LD_LIBRARY_PATH}
    export LDPATHFLAGS="-L${PREFIX_}/lib64 ${LDPATHFLAGS}"
  fi

  # Do not include -I... here, use CPPFLAGS.
  local COMMON_CFLAGS_=${COMMON_CFLAGS_:-"-g -O2"}
  local COMMON_CXXFLAGS_=${COMMON_CXXFLAGS_:-${COMMON_CFLAGS_}}

  export CFLAGS="${COMMON_CFLAGS_} ${EXTRA_CFLAGS_}"
	export CXXFLAGS="${COMMON_CXXFLAGS_} ${EXTRA_CXXFLAGS_}"
  export LDFLAGS="${LDPATHFLAGS} ${EXTRA_LDFLAGS_}"

  echo "xPack Build Box activated! $(lsb_release -is) $(lsb_release -rs), $(gcc --version | grep gcc), $(ldd --version | grep ldd)"
  echo
  echo PATH=${PATH}
  echo
  echo CFLAGS=${CFLAGS}
  echo CXXFLAGS=${CXXFLAGS}
  echo CPPFLAGS=${CPPFLAGS}
  echo LDFLAGS=${LDFLAGS}
  echo
  echo LD_LIBRARY_PATH=${LD_LIBRARY_PATH}
  echo PKG_CONFIG_PATH=${PKG_CONFIG_PATH}
}

xbb_activate_dev()
{
  PREFIX_="${XBB_FOLDER}"

  # `-pipe` should make things faster, by using more memory.
  EXTRA_CFLAGS_="-ffunction-sections -fdata-sections"
  EXTRA_CXXFLAGS_="-ffunction-sections -fdata-sections" 
  # Without -static-libstdc++ it'll pick up the out of date 
  # /usr/lib[64]/libstdc++.so.6
  EXTRA_LDFLAGS_="-static-libstdc++ -Wl,--gc-sections"

  xbb_activate_param
}

__EOF__
# The above marker must start in the first column.

# Remove the old name, to enforce using the new one.
rm -rf "${XBB}/xbb.sh"

# -----------------------------------------------------------------------------

# Make the functions available to the entire script.
source "${XBB}/xbb-source.sh"

# -----------------------------------------------------------------------------

function do_coreutils()
{
  # https://ftp.gnu.org/gnu/coreutils/

  XBB_COREUTILS_VERSION="8.31"

  XBB_COREUTILS_FOLDER="coreutils-${XBB_COREUTILS_VERSION}"
  XBB_COREUTILS_ARCHIVE="${XBB_COREUTILS_FOLDER}.tar.xz"
  XBB_COREUTILS_URL="https://ftp.gnu.org/gnu/coreutils/${XBB_COREUTILS_ARCHIVE}"

  echo
  echo "Building coreutils ${XBB_COREUTILS_VERSION}..."

  cd "${XBB_BUILD}"

  download_and_extract "${XBB_COREUTILS_ARCHIVE}" "${XBB_COREUTILS_URL}"

  (
    cd "${XBB_BUILD}/${XBB_COREUTILS_FOLDER}"

    xbb_activate_dev

    # error: you should not run configure as root (set FORCE_UNSAFE_CONFIGURE=1 
    # in environment to bypass this check
    export FORCE_UNSAFE_CONFIGURE=1

    bash ./configure --help

    bash ./configure \
      --prefix="${XBB}" 
    
    make -j${MAKE_CONCURRENCY}
    make install-strip
  )

  (
    xbb_activate

    "${XBB}/bin/realpath" --version
  )

  hash -r
}

function do_python3() 
{
  # https://www.python.org
  # https://www.python.org/downloads/source/
  
  # https://git.archlinux.org/svntogit/packages.git/tree/trunk/PKGBUILD?h=packages/python
  # https://git.archlinux.org/svntogit/packages.git/tree/trunk/PKGBUILD?h=packages/python-pip

  # 2018-12-24
  XBB_PYTHON_VERSION="3.7.2"

  XBB_PYTHON_FOLDER="Python-${XBB_PYTHON_VERSION}"
  XBB_PYTHON_ARCHIVE="${XBB_PYTHON_FOLDER}.tar.xz"
  XBB_PYTHON_URL="https://www.python.org/ftp/python/${XBB_PYTHON_VERSION}/${XBB_PYTHON_ARCHIVE}"

  echo
  echo "Installing python ${XBB_PYTHON_VERSION}..."

  cd "${XBB_BUILD}"

  download_and_extract "${XBB_PYTHON_ARCHIVE}" "${XBB_PYTHON_URL}"

  (
    cd "${XBB_BUILD}/${XBB_PYTHON_FOLDER}"

    xbb_activate_dev

    bash ./configure --help

    # Python is happier with dynamic zlib and curl.
    # Without --enabled-shared the build fails with
    # ImportError: No module named '_struct'
    # --enable-universalsdk is required by -arch.

    # --with-lto fails.
    # --with-system-expat fails.
    # https://github.com/python/cpython/tree/2.7

    export CFLAGS="${CFLAGS} -Wno-int-in-bool-context -Wno-maybe-uninitialized -Wno-nonnull -Wno-stringop-overflow"

    bash ./configure \
      --prefix="${XBB}" \
      --enable-shared \
      --with-universal-archs=${BITS}-bits \
      --enable-universalsdk \
      --with-computed-gotos \
      --enable-optimizations \
      --with-lto \
      --with-system-expat \
      --with-dbmliborder=gdbm:ndbm \
      --with-system-ffi \
      --with-system-libmpdec \
      --enable-loadable-sqlite-extensions \
      --without-ensurepip

    make -j${MAKE_CONCURRENCY} build_all
    make install

    strip --strip-all "${XBB}/bin/python3"
  )

  (
    xbb_activate

    "${XBB}/bin/python3" --version

    hash -r

    cd "${XBB_BUILD}/${XBB_PYTHON_FOLDER}"

    # Install setuptools and pip. Be sure the new version is used.
    # https://packaging.python.org/tutorials/installing-packages/
    echo
    echo "Installing setuptools and pip..."
    set +e
    "${XBB}/bin/pip3" --version
    # pip3: command not found
    set -e
    "${XBB}/bin/python3" -m ensurepip --default-pip
    "${XBB}/bin/python3" -m pip install --upgrade pip setuptools wheel
    "${XBB}/bin/pip3" --version
  )

  hash -r
}

# -----------------------------------------------------------------------------

function do_native_binutils() 
{
  # https://ftp.gnu.org/gnu/binutils/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=binutils-git
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=gdb-git

  # 2019-02-02
  XBB_BINUTILS_VERSION="2.32"

  XBB_BINUTILS_FOLDER="binutils-${XBB_BINUTILS_VERSION}"
  XBB_BINUTILS_ARCHIVE="${XBB_BINUTILS_FOLDER}.tar.xz"
  XBB_BINUTILS_URL="https://ftp.gnu.org/gnu/binutils/${XBB_BINUTILS_ARCHIVE}"

  # Requires gmp, mpfr, mpc, isl.
  echo
  echo "Building native binutils ${XBB_BINUTILS_VERSION}..."

  cd "${XBB_BUILD}"

  download_and_extract "${XBB_BINUTILS_ARCHIVE}" "${XBB_BINUTILS_URL}"

  (
    mkdir -p "${XBB_BUILD}/${XBB_BINUTILS_FOLDER}-native-build"
    cd "${XBB_BUILD}/${XBB_BINUTILS_FOLDER}-native-build"

    xbb_activate_dev

    export CFLAGS="${CFLAGS} -Wno-sign-compare"
    export CXXFLAGS="${CXXFLAGS} -Wno-sign-compare"
    # export LDFLAGS="-static-libstdc++ ${LDFLAGS}"

    bash "${XBB_BUILD}/${XBB_BINUTILS_FOLDER}/configure" --help

    bash "${XBB_BUILD}/${XBB_BINUTILS_FOLDER}/configure" \
      --prefix="${XBB}" \
      --build="${BUILD}" \
      --disable-shared \
      --enable-static \
      --enable-threads \
      --enable-deterministic-archives \
      --disable-gdb

    make -j${MAKE_CONCURRENCY}
    make install-strip
  )

  (
    xbb_activate

    "${XBB}/bin/size" --version
  )

  hash -r
}

# -----------------------------------------------------------------------------

function do_native_gcc() 
{
  # https://gcc.gnu.org
  # https://ftp.gnu.org/gnu/gcc/
  # https://gcc.gnu.org/wiki/InstallingGCC
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=gcc-git

  # 2018-12-06
  XBB_GCC_VERSION="7.4.0"

  XBB_GCC_FOLDER="gcc-${XBB_GCC_VERSION}"
  XBB_GCC_ARCHIVE="${XBB_GCC_FOLDER}.tar.xz"
  XBB_GCC_URL="https://ftp.gnu.org/gnu/gcc/gcc-${XBB_GCC_VERSION}/${XBB_GCC_ARCHIVE}"
  XBB_GCC_BRANDING="xPack Build Box GCC\x2C ${BITS}-bits"

  # Requires gmp, mpfr, mpc, isl.
  echo
  echo "Building native gcc ${XBB_GCC_VERSION}..."

  cd "${XBB_BUILD}"

  download_and_extract "${XBB_GCC_ARCHIVE}" "${XBB_GCC_URL}"

  (
    mkdir -p "${XBB_BUILD}/${XBB_GCC_FOLDER}-build"
    cd "${XBB_BUILD}/${XBB_GCC_FOLDER}-build"

    xbb_activate_dev

    export CFLAGS="${CFLAGS} -Wno-sign-compare"
    export CXXFLAGS="${CXXFLAGS} -Wno-sign-compare"
    # export LDFLAGS="-static-libstdc++ ${LDFLAGS}"

    bash "${XBB_BUILD}/${XBB_GCC_FOLDER}/configure" --help

    # --disable-shared failed with errors in libstdc++-v3
    # --build used conservatively.
    bash "${XBB_BUILD}/${XBB_GCC_FOLDER}/configure" \
      --prefix="${XBB}" \
      --build="${BUILD}" \
      --with-pkgversion="${XBB_GCC_BRANDING}" \
      --enable-languages=c,c++ \
      --enable-static \
      --enable-threads=posix \
      --enable-libmpx \
      --enable-__cxa_atexit \
      --disable-libunwind-exceptions \
      --enable-clocale=gnu \
      --disable-libstdcxx-pch \
      --disable-libssp \
      --enable-gnu-unique-object \
      --enable-linker-build-id \
      --enable-lto \
      --enable-plugin \
      --enable-install-libiberty \
      --with-linker-hash-style=gnu \
      --enable-gnu-indirect-function \
      --disable-multilib \
      --disable-werror \
      --enable-checking=release
    
    make -j${MAKE_CONCURRENCY}
    make install-strip
  )

  (
    xbb_activate

    "${XBB}/bin/g++" --version

    mkdir -p "${HOME}/tmp"
    cd "${HOME}/tmp"

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

      "${XBB}/bin/g++" hello.cpp -o hello
      "${XBB}/bin/readelf" -d hello

      if [ "x$(./hello)x" != "xHellox" ]
      then
        exit 1
      fi

    fi

    rm -rf hello.cpp hello
  )

  hash -r
}

function do_wine()
{
  # https://www.winehq.org
  # https://dl.winehq.org/wine/source/4.x/wine-4.3.tar.xz

  # 2017-09-16
  XBB_WINE_VERSION_MAJOR="4"
  XBB_WINE_VERSION_MINOR="3"
  XBB_WINE_VERSION="${XBB_WINE_VERSION_MAJOR}.${XBB_WINE_VERSION_MINOR}"

  XBB_WINE_FOLDER="wine-${XBB_WINE_VERSION}"
  XBB_WINE_ARCHIVE="${XBB_WINE_FOLDER}.tar.xz"
  XBB_WINE_URL="https://dl.winehq.org/wine/source/${XBB_WINE_VERSION_MAJOR}.x/${XBB_WINE_ARCHIVE}"

  echo
  echo "Installing win ${XBB_WINE_VERSION}..."

  cd "${XBB_BUILD}"

  download_and_extract "${XBB_WINE_ARCHIVE}" "${XBB_WINE_URL}"

  (
    cd "${XBB_BUILD}/${XBB_WINE_FOLDER}"

    xbb_activate_dev

    bash ./configure --help

    if [ "${BITS}" == "64" ]
    then
      ENABLE_64="--enable-win64"
    else
      ENABLE_64=""
    fi

    bash ./configure \
      --prefix="${XBB}" \
      \
      ${ENABLE_64} \
      --disable-win16 \
      --disable-tests \
      \
      --without-alsa \
      --without-capi \
      --without-cms \
      --without-coreaudio \
      --without-cups \
      --without-curses \
      --without-dbus \
      --without-faudio \
      --with-float-abi=abi \
      --without-fontconfig \
      --without-freetype \
      --without-gettext \
      --with-gettextpo \
      --without-glu \
      --without-gphoto \
      --without-gnutls \
      --without-gsm \
      --without-gstreamer \
      --without-gssapi \
      --without-hal \
      --without-jpeg \
      --without-krb5 \
      --without-ldap \
      --without-mpg123 \
      --without-netapi \
      --without-openal \
      --without-opencl \
      --without-opengl \
      --without-osmesa \
      --without-oss \
      --without-pcap \
      --without-png \
      --with-pthread \
      --without-pulse \
      --without-sane \
      --without-sdl \
      --without-tiff \
      --without-udev \
      --without-v4l \
      --without-vkd3d \
      --without-vulkan \
      --without-xcomposite \
      --without-xcursor \
      --without-xfixes \
      --without-xinput \
      --without-xinerama \
      --without-xinput2 \
      --without-xml \
      --without-xrender \
      --without-xrandr \
      --without-xshape \
      --without-xshm \
      --without-xslt \
      --without-xxf86vm \
      --without-x \
    
    make -j${MAKE_CONCURRENCY} STRIP=true
    make install

    if [ "${BITS}" == "64" ]
    then
      (cd "${XBB}/bin"; ln -s wine64 wine)
    fi
  )

  (
    xbb_activate

    "${XBB}/bin/wine" --version
  )

  hash -r
}

function do_ninja()
{
  # https://ninja-build.org
  # https://github.com/ninja-build/ninja/archive/v1.9.0.zip
  # https://github.com/ninja-build/ninja/archive/v1.9.0.tar.gz

  XBB_NINJA_VERSION="1.9.0"

  XBB_NINJA_FOLDER="ninja-${XBB_NINJA_VERSION}"
  XBB_NINJA_ARCHIVE="v${XBB_NINJA_VERSION}.tar.gz"
  XBB_NINJA_URL="https://github.com/ninja-build/ninja/archive/${XBB_NINJA_ARCHIVE}"

  echo
  echo "Installing ninja ${XBB_NINJA_VERSION}..."

  cd "${XBB_BUILD}"

  download_and_extract "${XBB_NINJA_ARCHIVE}" "${XBB_NINJA_URL}"

  (
    cd "${XBB_BUILD}/${XBB_NINJA_FOLDER}"

    xbb_activate_dev

    ./configure.py --help

    ./configure.py \
      --bootstrap \
      --verbose \
      --with-python=python2 \
      --platform=linux \

    install -m755 -t "${XBB}/bin" ninja
  )

  (
    xbb_activate

    "${XBB}/bin/ninja" --version
  )

  hash -r
}

function do_meson
{
  (
    xbb_activate

    pip3 install meson

    "${XBB}/bin/meson" --version
  )

  hash -r
}

# -----------------------------------------------------------------------------

# Needed by QEMU.
yum install -y libX11-devel libXext-devel mesa-libGL-devel

do_coreutils

do_ninja

if true
then
  do_python3
  do_meson
fi

if true
then
  do_native_binutils
  do_native_gcc
fi

# Lengthy...
if true
then
  do_wine
fi

# -----------------------------------------------------------------------------

if true
then
  do_strip_libs

  do_cleaunup
fi

