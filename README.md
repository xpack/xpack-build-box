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
- GNU/Linux Intel 32-bit (ldd >= 2.15)
- GNU/Linux Intel 64-bit (ldd >= 2.15)
- GNU/Linux Arm 32-bit (ldd >= 2.23)
- GNU/Linux Arm 64-bit (ldd >= 2.23)
- macOS (Intel, 64-bit, >= 10.10)

For a repetitive and controllable build process, the Windows and GNU/Linux
binaries are built using two Docker images (32/64-bit).

- ilegeul/ubuntu:amd64-12.04-bootstrap-v3.1
- ilegeul/ubuntu:i386-12.04-bootstrap-v3.1

The images are based on Ubuntu 12 (ldd 2.15), and the GNU/Linux binaries
should run on most modern distributions.

The Windows executables are created with mingw-w64 v7.0.0 and the
mingw-w64 GCC 9.2, available from the same Docker images.

The macOS binaries are generated on a macOS 10.10.5, plus a set of new
GNU tools, installed in a separate folder. The TeX tools (from 2018)
are also installed in a custom folder.

## How to use?

Both on GNU/Linux and macOS, the XBB tools are installed in separate
folders, and are fully distinct from the system tools.

To access them, the application should update the `PATH` to prefer
the newer XBB tools.

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
source "${HOME}/opt/xbb/xbb-source.sh"
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

The build environment includes a helper script, `xbb-source.sh`, 
which should be included
with `source` by the build scripts, to define more bash functions to
the shell.

These functions are used to extend the environment with resources available
in the XBB folders.

The `xbb_activate` function is used to extend the `PATH` with folders
in the XBB folders, in front of existing
folders, so that the XBB executables are preferred over the system ones.

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

## C++ Standards Support in GCC

https://gcc.gnu.org/projects/cxx-status.html

## End-of-support schedule

According to the
[CentOS schedule](https://en.wikipedia.org/wiki/CentOS#End-of-support_schedule),
version 6 will be supported up to Nov. 2020.

However, RHEL releases have a longer
[life cycle](https://access.redhat.com/support/policy/updates/errata/#Life_Cycle_Dates)
and RHEL6 end of extended life-cycle support is 2024.

It is still debatable if supporting CentOS/RHEL 6 is it still worth the effort.

However support for RHEL 7 is very important, so the ldd version must be
2.17 or lower.

## 32-bit support

Existing support for 32-bit builds will be preserved for the moment,
but might be dropped in one of the future version; for consistency
reasons, it is expected to continue to generate 32-bit binares
as long as Node.js still supports them via the
[unofficial builds](https://unofficial-builds.nodejs.org/download/).

## Arm binaries

Support for Arm binaries was added in v3.1, in early 2020.

The supported architectures are:

- `arm64v8` - the ARMv8 64-bit architecture Aarch64
- `arm32v7` - the ARMv7 32-bit architecture with hardware float (armhf)

## Distro versions

To better decide whch versions to support, below is a list of existing versions.

The names are in fact docker image names, and can be used directly to query
the `ldd --version`:

```console
$ docker run -it <image> ldd --version
```

### [Debian](https://en.wikipedia.org/wiki/Debian_version_history)

- `debian:6` - squeeze - 2011-2016, 2.11.3
- `debian:7` - wheezy - 2013-2016, 2.13, kernel 3.10
- `debian:8` - jessie - 2015-2018, 2.19
- `debian:9` - stretch - 2017-2020, 2.24 (first with arm64)
- `debian:10` - buster - 2019-2022, 2.28

### [Ubuntu](https://en.wikipedia.org/wiki/Ubuntu_version_history)

- `ubuntu:10.04` - lucy - 2010-2015, 2.11.1
- `ubuntu:12.04` - precise - 2012-2019, 2.15 <--- Intel Linux choice
- `ubuntu:14.04` - trusty - 2014-2022, 2.19
- `ubuntu:16.04` - xenial - 2016-2024, 2.23 <--- Arm Linux choice
- `ubuntu:18.04` - bionic - 2018-2028, 2.27
- `ubuntu:20.04` - focal - 2020-2-30, ?

### [RHEL](https://access.redhat.com/support/policy/updates/errata/#Life_Cycle_Dates)

- `registry.access.redhat.com/rhel6` - 2.12
- `registry.access.redhat.com/rhel7` - 2.17 <--- supported

### [CentOS](https://en.wikipedia.org/wiki/CentOS)

- `centos:6` - 2011-2020, 2.12
- `centos:7` - 2014-2024, 2.17, kernel 3.10 <--- must be supported
- `centos:8` - 2019-2029, 2.28

### Maintainer info

```console
$ curl -L --fail https://raw.githubusercontent.com/xpack/xpack-build-box/master/git-clone.sh | bash -
```

which is the equivalent of:

```console
$ rm -rf ~/Downloads/xpack-build-box.git
$ git clone https://github.com/xpack/xpack-build-box.git \
  ~/Downloads/xpack-build-box.git
```

### TODO

- properly set the architecture for 32-bit images
- build nodejs
- build Python 3 in bootstrap

### Conclusions

For Intel Linux, to preserve support for older distributions,
the **Ubuntu 12 (precise)** (2.15) distribution was selected.

The binaries should also run on RHEL 7; support for RHEL 6 was discontinued.

For Arm binaries, the base distribution is **Ubuntu 16.04 LTS (xenial)**,
(2.23).
