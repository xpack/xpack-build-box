# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (http://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software 
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

function do_build_versions()
{
  if [ "${XBB_VERSION}" = "3.1" ]
  then

    # -------------------------------------------------------------------------

    # To differentiate the binaries from the XBB ones which use `-7`.
    XBB_GCC_SUFFIX="-7bs"
    XBB_GCC_BRANDING="xPack Build Box Bootstrap GCC\x2C 64-bit"

    # -------------------------------------------------------------------------
    # Libraries

    do_zlib "1.2.11"

    do_gmp "6.1.2"
    do_mpfr "3.1.6"
    do_mpc "1.1.0" # "1.0.3"
    do_isl "0.21"

    do_libiconv "1.16" # "1.15"

    # -------------------------------------------------------------------------
    # Applications

    do_coreutils "8.31"

    do_pkg_config "0.29.2"

    do_m4 "1.4.18"

    do_gawk "4.2.1"
    do_sed "4.7"
    do_autoconf "2.69"
    do_automake "1.16"
    do_libtool "2.4.6"

    do_gettext "0.19.8"

    do_diffutils "3.7"
    do_patch "2.7.6"

    do_bison "3.4.2" # "3.3.2"

    # macOS 10.10 uses 2.5.3, an update is not mandatory.
    do_flex "2.6.4"

    do_make "4.2.1"

    # macOS 10.10 uses 5.18.2, an update is not mandatory.
    do_perl "5.28.2"

    do_cmake "3.15.6" # "3.13.4"

    # makedepend is needed by openssl
    do_util_macros "1.19.2" # "1.17.1"
    do_xorg_xproto "7.0.31"
    do_makedepend "1.0.6" # "1.0.5"

    # By all means DO NOT build binutils, since this will override Apple 
    # specific tools (ar, strip, etc) and break the build in multiple ways.

    # Preferably leave it to the end, to benefit from all the goodies 
    # compiled so far.
    do_native_gcc "7.5.0" # "7.4.0"

    # -------------------------------------------------------------------------

  else
    echo 
    echo "Version not yet supported."
  fi
}