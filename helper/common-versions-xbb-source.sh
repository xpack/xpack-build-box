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

    # The main characteristic of XBB is the compiler version.
    XBB_GCC_VERSION="9.2.0" # "8.3.0" # "7.4.0"
    XBB_GCC_SUFFIX="-$(echo ${XBB_GCC_VERSION} | sed -e 's|\([0-9][0-9]*\)\..*|\1|')"
    XBB_BINUTILS_VERSION="2.34" # "2.33.1"

    # 8.x fails to compile the libstdc++ new file system classes.
    # must be the same as native, otherwise shared libraries will bess versions.
    XBB_MINGW_GCC_VERSION="${XBB_GCC_VERSION}" # "9.2.0" # "8.3.0" # "7.4.0"
    XBB_MINGW_BINUTILS_VERSION="${XBB_BINUTILS_VERSION}" # "2.34" # "2.33.1"

    XBB_BINUTILS_BRANDING="xPack Build Box Binutils\x2C ${HOST_BITS}-bit"
    XBB_GCC_BRANDING="xPack Build Box GCC\x2C ${HOST_BITS}-bit"

    XBB_MINGW_BINUTILS_BRANDING="xPack Build Box Mingw-w64 Binutils\x2C ${HOST_BITS}-bit"
    XBB_MINGW_GCC_BRANDING="xPack Build Box Mingw-w64 GCC\x2C ${HOST_BITS}-bit"


    # -------------------------------------------------------------------------

    # New zlib, used in most of the tools.
    # depends=('glibc')
    do_zlib "1.2.11"

    # Replacement for the old libcrypt.so.1.
    do_libxcrypt "4.4.15"

    # depends=('perl')
    do_openssl "1.1.1d" # "1.0.2u" # "1.1.1d" # "1.0.2r" # "1.1.1b"

    # Libraries, required by gcc.
    # depends=('gcc-libs' 'sh')
    do_gmp "6.2.0" # "6.1.2"
    # depends=('gmp>=5.0')
    do_mpfr "4.0.2" # "3.1.6"
    # depends=('mpfr')
    do_mpc "1.1.0" # "1.0.3"
    # depends=('gmp')
    do_isl "0.22" # "0.21"

    # Libraries, required by gnutls.
    # depends=('glibc')
    do_tasn1 "4.15.0" # "4.13"
    # Library, required by Python.
    # depends=('glibc')
    do_expat "2.2.9" # "2.2.6"
    # depends=('glibc')
    do_libffi "3.2.1"

    # Required by Python
    do_libmpdec "2.4.2"

    # Libary, required by tar. 
    # depends=('sh')
    do_xz "5.2.4"

    # Requires openssl.
    # depends=('glibc' 'gmp')
    # PATCH!
    do_nettle "3.5.1" # "3.4.1"

    # Required by wine.
    do_libpng "1.6.37"

    # Library, required by wget.
    # depends=()
    # Harmful for GCC 9.
    # do_libiconv "1.16" # "1.15"

    # depends=('glibc' 'glib2 (internal)')
    do_pkg_config "0.29.2"

    # depends=('ca-certificates' 'krb5' 'libssh2' 'openssl' 'zlib' 'libpsl' 'libnghttp2')
    do_curl "7.68.0" # "7.64.1"

    # tar with xz support.
    # depends=('glibc')
    do_tar "1.32"

    # depends=('glibc' 'libidn2' 'libtasn1' 'libunistring' 'nettle' 'p11-kit' 'readline' 'zlib')
    do_gnutls "3.6.11.1" # "3.6.7"

    do_coreutils "8.31"

    # -------------------------------------------------------------------------
    # GNU tools

    # depends=('glibc')
    # PATCH!
    do_m4 "1.4.18"

    # depends=('glibc' 'mpfr')
    do_gawk "5.0.1" # "4.2.1"

    # depends ?
    do_sed "4.8" # "4.7"

    # depends=('sh' 'perl' 'awk' 'm4' 'texinfo')
    do_autoconf "2.69"
    # depends=('sh' 'perl')
    # PATCH!
    do_automake "1.16"

    # depends=('sh' 'tar' 'glibc')
    do_libtool "2.4.6"

    # depends=('glibc' 'glib2' 'libunistring' 'ncurses')
    do_gettext "0.20.1" # "0.19.8"

    # depends=('glibc' 'attr')
    do_patch "2.7.6"

    # depends=('libsigsegv')
    do_diffutils "3.7"

    # depends=('glibc')
    do_bison "3.5" # "3.3.2"

    # depends=('glibc' 'guile')
    # PATCH!
    do_make "4.2.1"

    # -------------------------------------------------------------------------
    # Third party tools

    # depends=('libutil-linux' 'gnutls' 'libidn' 'libpsl>=0.7.1-3' 'gpgme')
    do_wget "1.20.3" # "1.20.1"

    # Required to build PDF manuals.
    # depends=('coreutils')
    do_texinfo "6.7" # "6.6"
    # depends ?
    do_patchelf "0.10"
    # depends=('glibc')
    do_dos2unix "7.4.1" # "7.4.0"

    # macOS 10.10 uses 2.5.3, an update is not mandatory.
    # depends=('glibc' 'm4' 'sh')
    do_flex "2.6.4"

    if [ "${HOST_UNAME}" == "Linux" ]
    then
      # macOS 10.10 uses 5.18.2, an update is not mandatory.
      # depends=('gdbm' 'db' 'glibc')
      # For Linux, go back to the same version supported by macOS 10.10.
      # PATCH!
      do_perl "5.18.2" # "5.30.1" # "5.28.1"
    fi

    # Give other a chance to use it.
    # However some (like Python) test for Tk too.
    do_tcl "8.6.10"

    # depends=('curl' 'libarchive' 'shared-mime-info' 'jsoncpp' 'rhash')
    do_cmake "3.16.2" # "3.13.4"

    # On macOS use the official binaries, which install in:
    # 2.7.17 -> /Library/Frameworks/Python.framework/Versions/2.7
    # 3.7.6 -> /Library/Frameworks/Python.framework/Versions/3.7
    # 3.8.1 -> /Library/Frameworks/Python.framework/Versions/3.8 (too new)
    
    # pip3 install meson=="0.53.1"

    # Fails on Darwin.
    # 0:01:39 load avg: 1.70 [187/400] test_io
    # python.exe(15636,0x7fff75763300) malloc: *** mach_vm_map(size=9223372036854775808) failed (error code=3)
    # *** error: can't allocate region
    # *** set a breakpoint in malloc_error_break to debug
    # python.exe(15636,0x7fff75763300) malloc: *** mach_vm_map(size=9223372036854775808) failed (error code=3)
    # *** error: can't allocate region
    # *** set a breakpoint in malloc_error_break to debug
    # python.exe(15636,0x7fff75763300) malloc: *** mach_vm_map(size=9223372036854775808) failed (error code=3)
    # *** error: can't allocate region
    # *** set a breakpoint in malloc_error_break to debug

    # error: [Errno 54] Connection reset by peer
    # 0:05:27 load avg: 1.64 [311/400] test_startfile -- test_ssl failed (env changed)

    if [ "${HOST_UNAME}" == "Linux" ]
    then
      # There are several errors on macOS 10.10 and some tests fail.                                           
      # depends=('bzip2' 'gdbm' 'openssl' 'zlib' 'expat' 'sqlite' 'libffi')
      do_python2 "2.7.17" # "2.7.16" (2.7.17 is the final release)
      # Python build finished, but the necessary bits to build these modules were not found:
      # _bsddb             _curses            _curses_panel   
      # _sqlite3           _tkinter           bsddb185        
      # bz2                dbm                dl              
      # gdbm               imageop            readline        
      # sunaudiodev  
    fi

    if true # [ "${HOST_UNAME}" == "Linux" ]
    then
      # require xz, openssl
      do_python3 "3.7.6" # "3.8.1" # "3.7.3"
      # The necessary bits to build these optional modules were not found:
      # _bz2                  _curses               _curses_panel      
      # _dbm                  _gdbm                 _sqlite3           
      # _tkinter              _uuid                 readline 
                
      # depends=('python3')
      do_meson "0.53.1" # "0.50.0"
    fi

    # depends=('python2')
    do_scons "3.1.2" # "3.0.5"

    # Requires scons
    # depends=('python2')
    do_ninja "1.10.0" # "1.9.0"

    # depends=('curl' 'expat>=2.0' 'perl-error' 'perl>=5.14.0' 'openssl' 'pcre2' 'grep' 'shadow')
    do_git "2.25.0" # "2.21.0"

    do_p7zip "16.02"

    # -------------------------------------------------------------------------

    # $1=nvm_version
    # $2=node_version
    # $3=npm_version
    # do_nvm "0.35.2" "12.16.0" "6.13.7"

    do_libgpg_error "1.37"
    do_libgcrypt "1.8.5"
    do_libassuan "2.5.3"
    do_libksba "1.3.5"
    do_npth "1.6"

    do_gnupg "2.2.19"

    # -------------------------------------------------------------------------

    do_ant "1.10.7"

    do_maven "3.6.3"
    
    # Not ready, dependency libs not yet in.
    # do_nodejs "12.16.0"

    # -------------------------------------------------------------------------
    # Compilers, native & mingw

    # By all means DO NOT build binutils on macOS, since this will 
    # override Apple specific tools (ar, strip, etc) and break the
    # build in multiple ways.
    if [ "${HOST_UNAME}" == "Linux" ]
    then
      # Requires gmp, mpfr, mpc, isl.
      do_native_binutils "${XBB_BINUTILS_VERSION}" 
    fi

    # makedepends=('binutils>=2.26' 'libmpc' 'gcc-ada' 'doxygen' 'git')
    do_native_gcc "${XBB_GCC_VERSION}"
     
    # Build mingw-w64 binutils and gcc only on Intel Linux.
    if [ "${HOST_UNAME}" == "Linux" -a \( "${HOST_MACHINE}" == "x86_64" -o "${HOST_MACHINE}" == "i686" \) ]
    then
      # depends=('zlib')
      do_mingw_binutils "${XBB_MINGW_BINUTILS_VERSION}"
      # depends=('zlib' 'libmpc' 'mingw-w64-crt' 'mingw-w64-binutils' 'mingw-w64-winpthreads' 'mingw-w64-headers')
      do_mingw_all "7.0.0" "${XBB_MINGW_GCC_VERSION}" # "5.0.4" "7.4.0"
    fi

    # -------------------------------------------------------------------------

    # Build wine only on Intel Linux.
    # Benefits from having mingw in PATH.
    if [ "${HOST_UNAME}" == "Linux" -a \( "${HOST_MACHINE}" == "x86_64" -o "${HOST_MACHINE}" == "i686" \) ]
    then
      # depends=('libpng')
      do_wine "5.1" # "5.0" # "4.3"

      # configure: OpenCL 64-bit development files not found, OpenCL won't be supported.
      # configure: pcap 64-bit development files not found, wpcap won't be supported.
      # configure: libdbus 64-bit development files not found, no dynamic device support.
      # configure: lib(n)curses 64-bit development files not found, curses won't be supported.
      # configure: libsane 64-bit development files not found, scanners won't be supported.
      # configure: libv4l2 64-bit development files not found.
      # configure: libgphoto2 64-bit development files not found, digital cameras won't be supported.
      # configure: libgphoto2_port 64-bit development files not found, digital cameras won't be auto-detected.
      # configure: liblcms2 64-bit development files not found, Color Management won't be supported.
      # configure: libpulse 64-bit development files not found or too old, Pulse won't be supported.
      # configure: gstreamer-1.0 base plugins 64-bit development files not found, GStreamer won't be supported.
      # configure: OSS sound system found but too old (OSSv4 needed), OSS won't be supported.
      # configure: libudev 64-bit development files not found, plug and play won't be supported.
      # configure: libSDL2 64-bit development files not found, SDL2 won't be supported.
      # configure: libFAudio 64-bit development files not found, XAudio2 won't be supported.
      # configure: libcapi20 64-bit development files not found, ISDN won't be supported.
      # configure: libcups 64-bit development files not found, CUPS won't be supported.
      # configure: fontconfig 64-bit development files not found, fontconfig won't be supported.
      # configure: libgsm 64-bit development files not found, gsm 06.10 codec won't be supported.
      # configure: libkrb5 64-bit development files not found (or too old), Kerberos won't be supported.
      # configure: libtiff 64-bit development files not found, TIFF won't be supported.
      # configure: libmpg123 64-bit development files not found (or too old), mp3 codec won't be supported.
      # configure: libopenal 64-bit development files not found (or too old), OpenAL won't be supported.
      # configure: libvulkan and libMoltenVK 64-bit development files not found, Vulkan won't be supported.
      # configure: vkd3d 64-bit development files not found (or too old), Direct3D 12 won't be supported.
      # configure: libldap (OpenLDAP) 64-bit development files not found, LDAP won't be supported.

      # configure: WARNING: libxml2 64-bit development files not found (or too old), XML won't be supported.
      # configure: WARNING: libxslt 64-bit development files not found, xslt won't be supported.
      # configure: WARNING: libjpeg 64-bit development files not found, JPEG won't be supported.
      # configure: WARNING: No sound system was found. Windows applications will be silent.
    fi

    # -------------------------------------------------------------------------

  else
    echo 
    echo "Version ${XBB_VERSION} not yet supported."
  fi
}

# -----------------------------------------------------------------------------
