# XBB (xPack Build Box)

There are two types of builds:

- local/native builds
- distribution builds
  
These tools were initially intended for the xPack binary distributions,
but later were extended to support native builds for development purposes
(see the `ubuntu` folder).

## Overview

Generally, xPack binaries are available for the following platforms:

- Windows 32-bits
- Windows 64-bits
- GNU/Linux 32-bits
- GNU/Linux 64-bits
- macOS (Intel, 64-bits)

For a repetitive and controllable build process, the Windows and GNU/Linux 
binaries are built using two Docker images (32/64-bits).

- ilegeul/centos:6-xbb-v1
- ilegeul/centos32:6-xbb-v1

The images are based on CentOS 6 (glibc 2.12), and the GNU/Linux binaries 
should run on most modern distributions.

The Windows executables are created with mingw-w64 v5.0.3 and the 
mingw-w64 GCC 7.2, available from the same Docker images.

The macOS binaries are generated on a macOS 10.10.5, plus a set of new 
GNU tools, installed in a custom instance of Homebrew. The TeX tools 
are also installed in a custom instance.

## How to use?

Both on GNU/Linux and macOS, the XBB tools are installed in separate 
folders, and are fully distinct from the system tools.

To access them, the application should update the `PATH` and 
`LD_LIBRARY_PATH` to prefer the newer XBB tools. 

Scripts defining some helper functions are available.

### GNU/Linux

The `xbb_activate` function can be called either for the entire lifespan 
of the script, or, for a better isolation, in inner shells when the new 
tools are really needed.

```bash
source "/opt/xbb/xbb.sh"
...
(
  xbb_activate

  .../configure
  make
)
```

### macOS

For macOS the recommended use case is similar, except the XBB tools 
are installed in the user HOME folder:

```bash
source "${HOME}"/opt/homebrew/xbb/xbb-source.sh
...
(
  xbb_activate

  ...
)
```

### Hacks

The GCC 7 available from Homebrew has a problem and building GDB generates 
faulty binaries (`set language auto` results in `SIGABRT`).

ARMs solution is to use a patched version of GCC 7.2.0; this separate GCC is 
built with `install-patched-gcc.sh`; binaries are suffixed with 
`-7.2.0-patched`.

## The `xbb-source.sh` script

The `add-xbb-extras.sh` script referred in the install sections
is used to add two more scripts to the build environment.

The first script is `xbb-source.sh`, which, if available, is included 
with `source` by the build scripts, to define more bash functions to 
the shell.

These functions are used to extend the environment with resources available
in the XBB folders.

The `xbb_activate` function is used to extend the `PATH` and the 
`LD_LIBRARY_PATH` with folders in the XBB folders, in front of existing
folders, so that the XBB executables are used instead of system ones.

The `xbb_activate_dev` function is used to further extend the environment
with other definitions, like `PKG_CONFIG_PATH`, the path where `pkgconfig`
searches for resources, if it is necessary to search for the XBB 
folders.

## The `pkg-config-verbose` script

While running the configuration step, it is sometimes useful to trace
how `pkgconfig` identifies resources to be used during the build.

The standard `pkgconfig` does not have an option to increase verbosity.

The solution is to use a separate script that displays the received command
and the response on the stderr stream.

This script is not specific to XBB, it can be used with any build.

For this, copy the file into `.../xbb/bin` or any other folder present 
in the PATH and pass the script name via the environment.

```console
$ chmod +x /opt/xbb/bin/pkg-config-verbose
$ export PKG_CONFIG=pkg-config-verbose
```

## End-of-support schedule

According to 
[CentOS schedule](https://en.wikipedia.org/wiki/CentOS#End-of-support_schedule)
version 6 will be supported up to Nov. 20120.

After this date XBB will probably be updated to CentOS 7.

## 32-bit support

Existing support for 32-bit builds will be preserved for moment, 
but most probably will no longer be present in the next version
using CentOS 7.
