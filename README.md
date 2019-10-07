# XBB (xPack Build Box)

The xPack Build Box is an elaborated build environment focused on
obtaining repeatable and consistent results while building applications
on GNU/Linux and macOS.

It does so by compiling from sources, in a separate folder, all tools
required for the package builds. 

By strictly controlling the versions of the compiled sources, it is 
possible to create build environments that use about the same tools
on both GNU/Linux and macOS, helping to obtain consistent results.

## Overview

There are two types of builds:

- local/native builds, intended for development and running on the local 
  machine (see the `ubuntu` folder)
- distribution builds, intended for xPack binary distributions and running 
  on most modern machines

Generally, xPack binaries are available for the following platforms:

- Windows 32-bit
- Windows 64-bit
- GNU/Linux 32-bit
- GNU/Linux 64-bit
- macOS (Intel, 64-bit)

For a repetitive and controllable build process, the Windows and GNU/Linux 
binaries are built using two Docker images (32/64-bit).

- ilegeul/centos:6-xbb-v2.2
- ilegeul/centos32:6-xbb-v2.2

The images are based on CentOS 6 (glibc 2.12), and the GNU/Linux binaries 
should run on most modern distributions.

The Windows executables are created with mingw-w64 v5.0.4 and the 
mingw-w64 GCC 7.4, available from the same Docker images.

The macOS binaries are generated on a macOS 10.10.5, plus a set of new 
GNU tools, installed in a separate folder. The TeX tools 
are also installed in a custom folder.

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
source "${HOME}"/opt/xbb/xbb-source.sh
...
(
  xbb_activate

  ...
)
```

### Hacks

Note: deprecated in recent XBB versions 

The GCC 7 available from Homebrew has a problem and building GDB generates 
faulty binaries (`set language auto` results in `SIGABRT`).

ARMs solution is to use a patched version of GCC 7.2.0; this separate GCC is 
built with `install-patched-gcc.sh`; binaries are suffixed with 
`-7.2.0-patched`.

## The `xbb-source.sh` script

The build environment includes two more scripts.

The first script is `xbb-source.sh`, which, if available, should be included 
with `source` by the build scripts, to define more bash functions to 
the shell.

These functions are used to extend the environment with resources available
in the XBB folders.

The `xbb_activate` function is used to extend the `PATH` and the 
`LD_LIBRARY_PATH` with folders in the XBB folders, in front of existing
folders, so that the XBB executables are preferred over the system ones.

The `xbb_activate_this` function is used to further extend the environment
with other definitions, like `PKG_CONFIG_PATH`, the path where `pkg-config`
searches for resources, if it is necessary to search for the XBB 
folders. There are also custom variables that can be used as
CPPFLAGS and LDFLAGS, that add the XBB folders to the include paths and 
the library path.

## The `pkg-config-verbose` script

While running the configuration step, it is sometimes useful to trace
how `pkg-config` identifies resources to be used during the build.

The standard `pkg-config` does not have an option to increase verbosity.

The workaround is to use a separate script that displays the received command
and the response on the stderr stream.

This script is not specific to XBB, and can be used with any build.

For this, copy the file into `.../xbb/bin` or any other folder present 
in the PATH and pass the script name via the environment.

```console
$ chmod +x /opt/xbb/bin/pkg-config-verbose
$ export PKG_CONFIG=pkg-config-verbose
```

## End-of-support schedule

According to the 
[CentOS schedule](https://en.wikipedia.org/wiki/CentOS#End-of-support_schedule),
version 6 will be supported up to Nov. 2020.

After this date XBB will be updated, probably to CentOS 7 or Debian 8.

## 32-bit support

Existing support for 32-bit builds will be preserved for the moment, 
but will probably be dropped in one of the future version, possibly
after the upgrade to CentOS 7 or Debian 8.

If you still need the 32-bit binaries after 2020, please open an issue 
in the specific build script repository, and the request will be
analysed. 

A multi-step approach would be to drop only support for GNU/Linux,
and keep support for Windows 32, at least while Node.js still supports it.

This would require the mingw-w64 to be compiled with multilib support, and
the build scripts to be slightly reworked, especially the GCC ones.

## Debian?

A possible alternate solution is Debian 8 Jessie,
discontinued as of June 17th, 2018, and supported until the end of June 2020. 

It provides GCC 4.9, thus a bootstrap will most probably be needed to
compile GCC 8.3 and the latest tools.

https://www.debian.org/releases/jessie/
https://packages.debian.org/jessie/
https://wiki.debian.org/LTS


