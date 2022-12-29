# Maintainer info

## Clone

To clone the repo with its submodule:

```sh
rm -rf ~/Work/xpack-build-box.git; \
git clone \
  --branch master \
  https://github.com/xpack/xpack-build-box.git \
  ~/Work/xpack-build-box.git; \
git -C ~/Work/xpack-build-box.git submodule update --init --recursive
```

For the development version use the `develop` branch:

```sh
rm -rf ~/Work/xpack-build-box.git; \
git clone \
  --branch develop \
  https://github.com/xpack/xpack-build-box.git \
  ~/Work/xpack-build-box.git; \
git -C ~/Work/xpack-build-box.git submodule update --init --recursive
```

To do a quick update:

```sh
git -C ~/Work/xpack-build-box.git pull
```

## TeX

TeX 2019 failed on Aarch64 with a CRC error.

TeX 2020 and 2021 failed with:

```console
re-running mktexlsr /opt/texlive/texmf-var /opt/texlive/texmf-config ...
setting up ConTeXt cache: running mtxrun --generate .../root/Work/install-tl-20210324/install-tl: mtxrun --generate failed (status 1):
failed
pre-generating all format files, be patient...
running fmtutil-sys --no-error-if-no-engine=luajithbtex,luajittex,mfluajit --no-strict --all ...done
running package-specific postactions

/root/Work/install-tl-20210324/install-tl: errors in installation reported above

Summary of warnings:
/root/Work/install-tl-20210324/install-tl: mtxrun --generate failed (status 1):
finished with package-specific postactions
```

TeX 2021 installer also complains if environment variables contain `tex`:

```console
Summary of warnings:
/root/Work/install-tl-20210324/install-tl: mtxrun --generate failed (status 1):

 ----------------------------------------------------------------------
 The following environment variables contain the string "tex"
 (case-independent).  If you're doing anything but adding personal
 directories to the system paths, they may well cause trouble somewhere
 while running TeX.  If you encounter problems, try unsetting them.
 Please ignore spurious matches unrelated to TeX.

    XBB_LAYER=tex
 ----------------------------------------------------------------------
```

## TODO

Things to be considered for future versions:

- add gdb (for macOS)
- add doxygen
- cleanup `man` folder
- investigate why isl_test_cpp fails
- gnutls requires several other libs
- gnutls certificates folder

- build nodejs

Fixed

- use patchelf 0.12 (in v3.3)
- use automake 1.16.2 (in v3.3)
- -D_FILE_OFFSET_BITS=64 for 32-bit machine
- libtool to use xbb gcc, not bootstrap
- rename gcc-xbb, gcc-xbs
- link gcc, cc, g++, c++
- add objc, objc++, fortran support to gcc
- build Python 3 in bootstrap
- guille (1 test disabled)
- autogen (1 test disabled)
- add bash

## Future work

XBB v4.x should be more modular, using binary xPacks.

### GNU/Linux

There will be 3 Docker images (no i386) with Ubuntu 16.04 LTS,
basic development tools and node/npm.

The toolchains will be installed as binary xPacks.

Planned xPacks:

- patchelf
- coreutils
- autoconf
- automake
- pkg_config
- python3
- mingw-gcc
- wine

Some may not be available for all platforms.

Possible future xPacks:

- curl
- wget
- tar
- m4
- gawk
- sed
- patch
- diffutils
- bison
- make
- bash
- texinfo
- dos2unix
- p7zip
- rhash
- re2c
- sphinx
- gnupg
- makedepend
- git

The strategy will be to try use the Ubuntu 16 versions first, and,
when not possible, add the xPacks for them.

### macOS

For macOS all needed tools not yet available as xPacks should be
compiled in a static XBB folder, as of now. For consistency,
the versions will replicate those available in Ubuntu 16.

macOS specific tools:

- realpath
