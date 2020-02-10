# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (http://xpack.github.io)
# Copyright (c) 2019 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software 
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

function do_zlib() 
{
  # http://zlib.net
  # http://zlib.net/fossils/
  # http://zlib.net/fossils/zlib-1.2.11.tar.gz

  # https://archlinuxarm.org/packages/aarch64/zlib/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=zlib-static
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=zlib-git

  # 2017-01-15 "1.2.11" (latest)

  local zlib_version="$1"

  local zlib_folder_name="zlib-${zlib_version}"
  local zlib_archive="${zlib_folder_name}.tar.gz"
  local zlib_url="http://zlib.net/fossils/${zlib_archive}"
  # local zlib_url="https://github.com/gnu-mcu-eclipse/files/raw/master/libs/${zlib_archive}"

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

      xbb_activate

      # -fPIC makes possible to include static libs in shared libs.
      export CPPFLAGS="${XBB_CPPFLAGS}" 
      export CFLAGS="${XBB_CFLAGS} -fPIC"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_LIB}"

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
        make # -j ${JOBS}

        make test

        make install
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-zlib-output.txt"
    )

    touch "${zlib_stamp_file_path}"

  else
    echo "Library zlib already installed."
  fi
}

function do_gmp() 
{
  # https://gmplib.org
  # https://gmplib.org/download/gmp/
  # https://gmplib.org/download/gmp/gmp-6.1.2.tar.xz

  # https://archlinuxarm.org/packages/aarch64/gmp/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=gmp-hg

  # 16-Dec-2016 "6.1.2"
  # 17-Jan-2020 "6.2.0"

  local gmp_version="$1"

  local gmp_folder_name="gmp-${gmp_version}"
  local gmp_archive="${gmp_folder_name}.tar.xz"
  local gmp_url="https://gmplib.org/download/gmp/${gmp_archive}"
  # local gmp_url="https://github.com/gnu-mcu-eclipse/files/raw/master/libs/${gmp_archive}"

  local gmp_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-gmp-${gmp_version}-installed"
  if [ ! -f "${gmp_stamp_file_path}" -o ! -d "${LIBS_BUILD_FOLDER_PATH}/${gmp_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${gmp_url}" "${gmp_archive}" "${gmp_folder_name}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${gmp_folder_name}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${gmp_folder_name}"

      xbb_activate

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS} -Wno-unused-value -Wno-empty-translation-unit -Wno-tautological-compare -Wno-overflow"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_LIB}"

      # Mandatory, it fails on 32-bits. 
      # export ABI="${HOST_BITS}"

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running gmp configure..."

          bash "${SOURCES_FOLDER_PATH}/${gmp_folder_name}/configure" --help

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${gmp_folder_name}/configure" \
            --prefix="${INSTALL_FOLDER_PATH}" \
            \
            --build="${BUILD}" \
            \
            --enable-cxx \
            --enable-fat

          cp "config.log" "${LOGS_FOLDER_PATH}/config-gmp-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-gmp-output.txt"
      fi

      (
        echo
        echo "Running gmp make..."

        # Build.
        make -j ${JOBS}

        make check

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
  # https://ftp.gnu.org/gnu/mpfr/
  # http://www.mpfr.org/mpfr-3.1.6
  # https://www.mpfr.org/mpfr-4.0.2/mpfr-4.0.2.tar.xz

  # https://archlinuxarm.org/packages/aarch64/mpfr/files/PKGBUILD
  # https://git.archlinux.org/svntogit/packages.git/tree/trunk/PKGBUILD?h=packages/mpfr

  # 7 September 2017 "3.1.6"
  # 31 January 2019 "4.0.2" Fails mpc

  local mpfr_version="$1"

  local mpfr_folder_name="mpfr-${mpfr_version}"
  local mpfr_archive="${mpfr_folder_name}.tar.xz"
  local mpfr_url="https://www.mpfr.org/${mpfr_folder_name}/${mpfr_archive}"
  # local mpfr_url="https://github.com/gnu-mcu-eclipse/files/raw/master/libs/${mpfr_archive}"

  local mpfr_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-mpfr-${mpfr_version}-installed"
  if [ ! -f "${mpfr_stamp_file_path}" -o ! -d "${LIBS_BUILD_FOLDER_PATH}/${mpfr_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${mpfr_url}" "${mpfr_archive}" "${mpfr_folder_name}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${mpfr_folder_name}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${mpfr_folder_name}"

      xbb_activate

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
            --prefix="${INSTALL_FOLDER_PATH}" \
            \
            --enable-thread-safe \
            --enable-shared \

          cp "config.log" "${LOGS_FOLDER_PATH}/config-mpfr-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-mpfr-output.txt"
      fi

      (
        echo
        echo "Running mpfr make..."

        # Build.
        make -j ${JOBS}

        # Fails.
        # make check
        # Not available in 3.x
        # make check-exported-symbols

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
  # https://ftp.gnu.org/gnu/mpc
  # https://ftp.gnu.org/gnu/mpc/mpc-1.0.3.tar.gz

  # https://archlinuxarm.org/packages/aarch64/mpc/files/PKGBUILD
  # https://git.archlinux.org/svntogit/packages.git/tree/trunk/PKGBUILD?h=packages/libmpc

  # 2015-02-20 "1.0.3"
  # 2018-01-11 "1.1.0"

  local mpc_version="$1"

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

      xbb_activate

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
        make -j ${JOBS}

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
  # http://isl.gforge.inria.fr/isl-0.21.tar.xz

  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=isl

  # 2016-12-20 "0.18"
  # 2019-03-26 "0.21"
  # 2020-01-16 "0.22"

  local isl_version="$1"

  local isl_folder_name="isl-${isl_version}"
  local isl_archive="${isl_folder_name}.tar.xz"
  local isl_url="http://isl.gforge.inria.fr/${isl_archive}"
  # local isl_url="https://github.com/gnu-mcu-eclipse/files/raw/master/libs/${isl_archive}"

  local isl_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-isl-${isl_version}-installed"
  if [ ! -f "${isl_stamp_file_path}" -o ! -d "${LIBS_BUILD_FOLDER_PATH}/${isl_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${isl_url}" "${isl_archive}" "${isl_folder_name}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${isl_folder_name}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${isl_folder_name}"

      xbb_activate

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
        make -j ${JOBS}

        make check

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

  # https://archlinuxarm.org/packages/aarch64/nettle/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=nettle-git

  # 2017-11-19, "3.4"
  # 2018-12-04, "3.4.1"
  # 2019-06-27, "3.5.1"

  local nettle_version="$1"

  local nettle_folder_name="nettle-${nettle_version}"
  local nettle_archive="${nettle_folder_name}.tar.gz"
  local nettle_url="ftp://ftp.gnu.org/gnu/nettle/${nettle_archive}"

  local nettle_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-nettle-${nettle_version}-installed"
  if [ ! -f "${nettle_stamp_file_path}" -o ! -d "${LIBS_BUILD_FOLDER_PATH}/${nettle_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${nettle_url}" "${nettle_archive}" "${nettle_folder_name}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${nettle_folder_name}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${nettle_folder_name}"

      xbb_activate

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS}  -Wno-deprecated-declarations"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_LIB}"

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running nettle configure..."

          bash "${SOURCES_FOLDER_PATH}/${nettle_folder_name}/configure" --help

          # -disable-static

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${nettle_folder_name}/configure" \
            --prefix="${INSTALL_FOLDER_PATH}" \
            \
            --enable-mini-gmp \
            --disable-documentation \
            --disable-arm-neon \
            --disable-assembler

          cp "config.log" "${LOGS_FOLDER_PATH}/config-nettle-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-nettle-output.txt"
      fi

      (
        echo
        echo "Running nettle make..."

        # Build.
        make -j ${JOBS}

        make -k check

        # make install-strip
        # For unknown reasons, on 32-bits make install-info fails 
        # (`install-info --info-dir="/opt/xbb/share/info" nettle.info` returns 1)
        # Make the other install targets.
        make install-headers install-static install-pkgconfig install-shared-nettle install-shared-hogweed
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

  # https://archlinuxarm.org/packages/aarch64/libtasn1/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=libtasn1-git

  # 2017-11-19, "4.12"
  # 2018-01-16, "4.13"
  # 2019-11-21, "4.15.0"

  local tasn1_version="$1"

  local tasn1_folder_name="libtasn1-${tasn1_version}"
  local tasn1_archive="${tasn1_folder_name}.tar.gz"
  local tasn1_url="ftp://ftp.gnu.org/gnu/libtasn1/${tasn1_archive}"

  local tasn1_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-tasn1-${tasn1_version}-installed"
  if [ ! -f "${tasn1_stamp_file_path}" -o ! -d "${LIBS_BUILD_FOLDER_PATH}/${tasn1_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${tasn1_url}" "${tasn1_archive}" "${tasn1_folder_name}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${tasn1_folder_name}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${tasn1_folder_name}"

      xbb_activate

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS} -Wno-logical-op -Wno-missing-prototypes  -Wno-format-truncation"
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
        CODE_COVERAGE_LDFLAGS=${LDFLAGS} make -j ${JOBS}

        make check

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

  # https://archlinuxarm.org/packages/aarch64/expat/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=expat-git

  # Nov 1, 2017, "2.2.5"
  # Aug 15, 2018, "2.2.6"
  # 26 Sep 2019, "2.2.9"

  local expat_version="$1"

  local expat_folder_name="expat-${expat_version}"
  local expat_archive="${expat_folder_name}.tar.bz2"
  local expat_release="R_$(echo ${expat_version} | sed -e 's|[.]|_|g')"
  # local expat_url="ftp://ftp.gnu.org/gnu/expat/${expat_archive}"
  local expat_url="https://github.com/libexpat/libexpat/releases/download/${expat_release}/${expat_archive}"

  local expat_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-expat-${expat_version}-installed"
  if [ ! -f "${expat_stamp_file_path}" -o ! -d "${LIBS_BUILD_FOLDER_PATH}/${expat_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${expat_url}" "${expat_archive}" "${expat_folder_name}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${expat_folder_name}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${expat_folder_name}"

      xbb_activate

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
        make -j ${JOBS}

        make check

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

  # https://archlinuxarm.org/packages/aarch64/libffi/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=libffi-git

  # 12-Nov-2014, "3.2.1", latest

  local libffi_version="$1"

  local libffi_folder_name="libffi-${libffi_version}"
  # .gz only.
  local libffi_archive="${libffi_folder_name}.tar.gz"
  # local libffi_url="ftp://ftp.gnu.org/gnu/libffi/${libffi_archive}"
  local libffi_url="https://sourceware.org/pub/libffi/${libffi_archive}"

  local libffi_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-libffi-${libffi_version}-installed"
  if [ ! -f "${libffi_stamp_file_path}" -o ! -d "${LIBS_BUILD_FOLDER_PATH}/${libffi_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${libffi_url}" "${libffi_archive}" "${libffi_folder_name}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${libffi_folder_name}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${libffi_folder_name}"

      xbb_activate

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

          #  --disable-static

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${libffi_folder_name}/configure" \
            --prefix="${INSTALL_FOLDER_PATH}" \
            \
            --enable-pax_emutramp \

          cp "config.log" "${LOGS_FOLDER_PATH}/config-libffi-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-libffi-output.txt"
      fi

      (
        echo
        echo "Running libffi make..."

        # Build.
        make -j ${JOBS}

        make check

        make install-strip
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-libffi-output.txt"
    )

    touch "${libffi_stamp_file_path}"

  else
    echo "Library libffi already installed."
  fi
}

function do_libiconv() 
{
  # https://www.gnu.org/software/libiconv/
  # https://ftp.gnu.org/pub/gnu/libiconv/

  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=libiconv

  # 2017-02-02, "1.15"
  # 2019-04-26, "1.16"

  # Warning, GCC 9.2 gets confused by it. If really needed, it must
  # be installed in a separate folder. See --prefix below.

  local libiconv_version="$1"

  local libiconv_folder_name="libiconv-${libiconv_version}"
  local libiconv_archive="${libiconv_folder_name}.tar.gz"
  local libiconv_url="ftp://ftp.gnu.org/gnu/libiconv/${libiconv_archive}"

  local libiconv_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-libiconv-${libiconv_version}-installed"
  if [ ! -f "${libiconv_stamp_file_path}" -o ! -d "${LIBS_BUILD_FOLDER_PATH}/${libiconv_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${libiconv_url}" "${libiconv_archive}" "${libiconv_folder_name}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${libiconv_folder_name}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${libiconv_folder_name}"

      xbb_activate

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
            --prefix="${INSTALL_FOLDER_PATH}/libiconv" 

          cp "config.log" "${LOGS_FOLDER_PATH}/config-libiconv-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-libiconv-output.txt"
      fi

      (
        echo
        echo "Running libiconv make..."

        # Build.
        make -j ${JOBS}

        make check

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
  # https://www.gnupg.org/ftp/gcrypt/gnutls/v3.6/gnutls-3.6.7.tar.xz

  # https://archlinuxarm.org/packages/aarch64/gnutls/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=gnutls-git

  # 2017-10-21, "3.6.1"
  # 2019-03-27, "3.6.7"
  # 2019-12-02, "3.6.11.1"

  local gnutls_version="$1"
  local gnutls_version_major="$(echo ${gnutls_version} | sed -e 's|\([0-9][0-9]*\.[0-9][0-9]*\)\.[0-9].*|\1|')"

  local gnutls_folder_name="gnutls-${gnutls_version}"
  local gnutls_archive="${gnutls_folder_name}.tar.xz"
  local gnutls_url="https://www.gnupg.org/ftp/gcrypt/gnutls/v${gnutls_version_major}/${gnutls_archive}"

  local gnutls_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-gnutls-${gnutls_version}-installed"
  if [ ! -f "${gnutls_stamp_file_path}" -o ! -d "${LIBS_BUILD_FOLDER_PATH}/${gnutls_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${gnutls_url}" "${gnutls_archive}" "${gnutls_folder_name}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${gnutls_folder_name}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${gnutls_folder_name}"

      xbb_activate

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS} -Wno-parentheses -Wno-bad-function-cast -Wno-unused-macros -Wno-bad-function-cast -Wno-unused-variable -Wno-pointer-sign  -Wno-format-truncation -Wno-missing-prototypes -Wno-missing-declarations -Wno-shadow -Wno-sign-compare -Wno-unknown-warning-option -Wno-static-in-inline -Wno-implicit-function-declaration -Wno-strict-prototypes -Wno-tautological-pointer-compare"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_LIB}"

      if [ "${HOST_UNAME}" == "Darwin" ]
      then
        # lib/system/certs.c:49 error: variably modified 'bytes' at file scope
        export CC=clang
        export CXX=clang++
      fi
      
      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running gnutls configure..."

          bash "${SOURCES_FOLDER_PATH}/${gnutls_folder_name}/configure" --help

          # --disable-static 

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${gnutls_folder_name}/configure" \
            --prefix="${INSTALL_FOLDER_PATH}" \
            \
            --with-guile-site-dir=no \
            --with-included-unistring \
            --without-p11-kit \
            \
            --enable-guile \

          cp "config.log" "${LOGS_FOLDER_PATH}/config-gnutls-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-gnutls-output.txt"
      fi

      (
        echo
        echo "Running gnutls make..."

        # Build.
        make -j ${JOBS}

        # Takes too long.
        # make check

        make install-strip
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-gnutls-output.txt"
    )

    touch "${gnutls_stamp_file_path}"

  else
    echo "Library gnutls already installed."
  fi
}

function do_util_macros() 
{
  # http://www.linuxfromscratch.org/blfs/view/
  # http://www.linuxfromscratch.org/blfs/view/7.4/x/util-macros.html

  # http://xorg.freedesktop.org/releases/individual/util
  # http://xorg.freedesktop.org/releases/individual/util/util-macros-1.17.1.tar.bz2

  # https://archlinuxarm.org/packages/any/xorg-util-macros/files/PKGBUILD

  # 2013-09-07, "1.17.1"
  # 2018-03-05, "1.19.2"

  local util_macros_version="$1"

  local util_macros_folder_name="util-macros-${util_macros_version}"
  local util_macros_archive="${util_macros_folder_name}.tar.bz2"
  local util_macros_url="http://xorg.freedesktop.org/releases/individual/util/${util_macros_archive}"

  local util_macros_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-util_macros-${util_macros_version}-installed"
  if [ ! -f "${util_macros_stamp_file_path}" -o ! -d "${LIBS_BUILD_FOLDER_PATH}/${util_macros_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${util_macros_url}" "${util_macros_archive}" "${util_macros_folder_name}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${util_macros_folder_name}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${util_macros_folder_name}"

      xbb_activate

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS}"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_LIB}"

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running util_macros configure..."

          bash "${SOURCES_FOLDER_PATH}/${util_macros_folder_name}/configure" --help

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${util_macros_folder_name}/configure" \
            --prefix="${INSTALL_FOLDER_PATH}" 

          cp "config.log" "${LOGS_FOLDER_PATH}/config-util_macros-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-util_macros-output.txt"
      fi

      (
        echo
        echo "Running util_macros make..."

        # Build.
        make -j ${JOBS}

        make install-strip
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-util_macros-output.txt"
    )

    touch "${util_macros_stamp_file_path}"

  else
    echo "Library util_macros already installed."
  fi
}

function do_xorg_xproto() 
{
  # https://www.x.org/releases/individual/proto/
  # https://www.x.org/releases/individual/proto/xproto-7.0.31.tar.bz2
  
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=xorgproto-git

  # 2016-09-23, "7.0.31" (latest)

  local xorg_xproto_version="$1"

  local xorg_xproto_folder_name="xproto-${xorg_xproto_version}"
  local xorg_xproto_archive="${xorg_xproto_folder_name}.tar.bz2"
  local xorg_xproto_url="https://www.x.org/releases/individual/proto/${xorg_xproto_archive}"

  # Add aarch64 to the list of Arm architectures.
  local  xorg_xproto_patch_file_path="${helper_folder_path}/patches/${xorg_xproto_folder_name}.patch"

  local xorg_xproto_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-xorg_xproto-${xorg_xproto_version}-installed"
  if [ ! -f "${xorg_xproto_stamp_file_path}" -o ! -d "${LIBS_BUILD_FOLDER_PATH}/${xorg_xproto_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${xorg_xproto_url}" "${xorg_xproto_archive}" "${xorg_xproto_folder_name}" "${xorg_xproto_patch_file_path}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${xorg_xproto_folder_name}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${xorg_xproto_folder_name}"

      xbb_activate

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS}"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_LIB}"

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running xorg_xproto configure..."

          bash "${SOURCES_FOLDER_PATH}/${xorg_xproto_folder_name}/configure" --help

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${xorg_xproto_folder_name}/configure" \
            --prefix="${INSTALL_FOLDER_PATH}" \
            \
            --build="${BUILD}" \
            \
            --without-xmlto \
            --without-xsltproc \
            --without-fop

          cp "config.log" "${LOGS_FOLDER_PATH}/config-xorg_xproto-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-xorg_xproto-output.txt"
      fi

      (
        echo
        echo "Running xorg_xproto make..."

        # Build.
        make -j ${JOBS}

        make install-strip
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-xorg_xproto-output.txt"
    )

    touch "${xorg_xproto_stamp_file_path}"

  else
    echo "Library xorg_xproto already installed."
  fi
}

function do_libpng()
{
  # To ensure builds stability, use slightly older releases.
  # https://sourceforge.net/projects/libpng/files/libpng16/
  # https://sourceforge.net/projects/libpng/files/libpng16/older-releases/

  # https://archlinuxarm.org/packages/aarch64/libpng/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=libpng-git
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-libpng

  # 2017-09-16
  # 2018-12-01, "1.6.36"
  # 2019-04-14, "1.6.3"

  local libpng_version="$1"

  local libpng_folder_name="libpng-${libpng_version}"
  local libpng_archive="${libpng_folder_name}.tar.gz"
  local libpng_url="https://sourceforge.net/projects/libpng/files/libpng16/${libpng_version}/${libpng_archive}"

  local libpng_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-libpng-${libpng_version}-installed"
  if [ ! -f "${libpng_stamp_file_path}" -o ! -d "${LIBS_BUILD_FOLDER_PATH}/${libpng_folder_name}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${libpng_url}" "${libpng_archive}" "${libpng_folder_name}"

    (
      mkdir -p "${LIBS_BUILD_FOLDER_PATH}/${libpng_folder_name}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${libpng_folder_name}"

      xbb_activate

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS}"
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_LIB}"

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running libpng configure..."

          bash "${SOURCES_FOLDER_PATH}/${libpng_folder_name}/configure" --help

          # --disable-static

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${libpng_folder_name}/configure" \
            --prefix="${INSTALL_FOLDER_PATH}" \
            \
            --enable-arm-neon=no \

          cp "config.log" "${LOGS_FOLDER_PATH}/config-libpng-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-libpng-output.txt"
      fi

      (
        echo
        echo "Running libpng make..."

        # Build.
        make -j ${JOBS}

        make check

        make install-strip
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-libpng-output.txt"
    )

    touch "${libpng_stamp_file_path}"

  else
    echo "Library libpng already installed."
  fi
}

function do_libmpdec()
{
  # http://www.bytereef.org/mpdecimal/index.html
  # https://www.bytereef.org/mpdecimal/download.html
  # https://www.bytereef.org/software/mpdecimal/releases/mpdecimal-2.4.2.tar.gz

  # https://archlinuxarm.org/packages/aarch64/mpdecimal/files/PKGBUILD

  # 2016-02-28, "2.4.2"

  local libmpdec_version="$1"

  local libmpdec_folder_name="mpdecimal-${libmpdec_version}"
  local libmpdec_archive="${libmpdec_folder_name}.tar.gz"
  local libmpdec_url="https://www.bytereef.org/software/mpdecimal/releases/${libmpdec_archive}"

  local libmpdec_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-libmpdec-${libmpdec_version}-installed"
  if [ ! -f "${libmpdec_stamp_file_path}" -o ! -d "${LIBS_BUILD_FOLDER_PATH}/${libmpdec_folder_name}" ]
  then

    # In-source build
    cd "${LIBS_BUILD_FOLDER_PATH}"

    download_and_extract "${libmpdec_url}" "${libmpdec_archive}" "${libmpdec_folder_name}"

    (
      cd "${LIBS_BUILD_FOLDER_PATH}/${libmpdec_folder_name}"

      xbb_activate

      export CPPFLAGS="${XBB_CPPFLAGS}"
      export CFLAGS="${XBB_CFLAGS} "
      export CXXFLAGS="${XBB_CXXFLAGS}"
      export LDFLAGS="${XBB_LDFLAGS_LIB}"

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running libmpdec configure..."

          bash "configure" --help

          bash ${DEBUG} "configure" \
            --prefix="${INSTALL_FOLDER_PATH}" 

          cp "config.log" "${LOGS_FOLDER_PATH}/config-libmpdec-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-libmpdec-output.txt"
      fi

      (
        echo
        echo "Running libmpdec make..."

        # Build.
        make -j ${JOBS}

        # make install-strip
        make install
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-libmpdec-output.txt"
    )

    touch "${libmpdec_stamp_file_path}"

  else
    echo "Library libmpdec already installed."
  fi
}

# -----------------------------------------------------------------------------
