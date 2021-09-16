# Maintainer info

## Clone

To clone the repo with its submodule:

```sh
rm -rf ~/Downloads/xpack-build-box.git; \
git clone https://github.com/xpack/xpack-build-box.git \
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
