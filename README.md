# XBB (xPack Build Box)

Tools to build the xPack binary distributions.

## Overview

Generally, xPack binaries are available for the following platforms:

- Windows 32-bits
- Windows 64-bits
- GNU/Linux 32-bits
- GNU/Linux 64-bits
- macOS (Intel, 64-bits)

For a repetitive and controllable build process, the Windows and GNU/Linux binaries are built using two Docker images (32/64-bits).

- ilegeul/centos:6-xbb-v1
- ilegeul/centos32:6-xbb-v1

The images are based on CentOS 6 (glibc 2.12), and the GNU/Linux binaries should run on most modern distributions.

The Windows executables are created with mingw-w64 v5.0.3 and the mingw-w64 GCC 7.2, available from the same Docker images.

The macOS binaries are generated on a macOS 10.10.5, plus a set of new GNU tools, installed in a custom instance of Homebrew. The TeX tools are also installed in a custom instance.

## How to use?

Both on GNU/Linux and macOS, the XBB tools are installed in separate folders, and are fully distinct from the system tools.

To access them, the application should update the `PATH` and `LD_LIBRARY_PATH` to prefer the newer XBB tools. 

Scripts defining some helper functions are available.

### GNU/Linux

The recommended use on GNU/Linux is:

```bash
source "/opt/xbb/xhh.sh"
xbb_activate
```

The `xbb_activate` function can be called either for the entire lifespan of the script, or, for a better isolation, in inner scripts when the new tools are really needed.

```bash
source "/opt/xbb/xbb.sh"
...
if [ -f some_file ]
then
  (
    xbb_activate

    tar xvf ...
  )
fi
```

### macOS

For macOS the recommended use case is similar, except the XBB tools are installed in the user HOME folder:

```bash
source ${HOME}/opt/homebrew/xbb/xbb-source.sh
xbb_activate
```

















