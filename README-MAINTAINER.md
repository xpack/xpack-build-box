# Maintainer info

## Clone

To clone the repo with its submodule:

```sh
rm -rf ~/Downloads/xpack-build-box.git; \
git clone \
  --branch master \
  https://github.com/xpack/xpack-build-box.git \
  ~/Downloads/xpack-build-box.git; \
git -C ~/Downloads/xpack-build-box.git submodule update --init --recursive 
```

For the development version use the `develop` branch:

```sh
rm -rf ~/Downloads/xpack-build-box.git; \
git clone \
  --branch develop \
  https://github.com/xpack/xpack-build-box.git \
  ~/Downloads/xpack-build-box.git; \
git -C ~/Downloads/xpack-build-box.git submodule update --init --recursive 
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

For macOS all needed toos not yet available as xPacks should be
compiled in a static XBB folder, as of now. For consistency,
the versions will replicate those available in Ubuntu 16.

macOS specific tools:

- realpath
