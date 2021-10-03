# XBB (xPack Build Box)

The xPack Build Box is an elaborated build environment focused on
obtaining repeatable and consistent results while building applications
on GNU/Linux and macOS.

It does so by compiling all tools
required for the package builds, from sources, in a separate folder.

By strictly controlling the versions of the compiled sources, it is
possible to create build environments that use about the same tools
on both GNU/Linux (Intel and Arm) and macOS, helping to obtain
consistent results.

## Overview

There are two types of builds:

- local/native builds, intended for development and running on the local
  machine (see the `ubuntu` folder)
- distribution builds, intended for xPack binary distributions and running
  on most modern machines

The main use cases of XBBs are distribution builds, but they can be used
for native builds as well.

Generally, xPack binaries are available for the following platforms:

- Windows 32-bit
- Windows 64-bit
- GNU/Linux Intel 32-bit (ldd >= 2.15)
- GNU/Linux Intel 64-bit (ldd >= 2.15)
- GNU/Linux Arm 32-bit (ldd >= 2.23)
- GNU/Linux Arm 64-bit (ldd >= 2.23)
- macOS (Intel, 64-bit, >= 10.10)

For a repetitive and controllable build process, the Windows and GNU/Linux
binaries are built using several Docker images (Intel/Arm, 32/64-bit).

The current version 3.3; older images are deprecated and should not be used
for newer projects.

- `ilegeul/ubuntu:amd64-12.04-xbb-v3.3`
- `ilegeul/ubuntu:i386-12.04-xbb-v3.3`
- `ilegeul/ubuntu:arm64v8-16.04-xbb-v3.3`
- `ilegeul/ubuntu:arm32v7-16.04-xbb-v3.3`

The Intel images are based on Ubuntu 12.04 (ldd 2.15), and the Arm images are
based on Ubuntu 16.04 (ldd 2.23); the resulting GNU/Linux binaries
should run on most modern distributions.

The Windows executables are created with **mingw-w64 v7.0.0** and
**mingw-w64 GCC 9.3**, available from the same Docker images; and should
run on Windows 10 and most modern Windows versions.

The macOS binaries are generated on a macOS 10.13, plus a set of new
GNU tools, installed in a separate folder.

### TeX

All images include the TeX tools (from 2018); on GNU/Linux, they are
installed in the system folders; on macOS, similarly to
XBB, they are installed in a custom folder (`${HOME}/.local/texlive`).

## Docker specifics

As with any Docker builds, the XBB builds run completely inside Docker
containers, which start afresh each time they are instantiated.

To pass the folder with the build scripts in and the results out,
it is usual to use a `Work` folder, for example:

```console
$ docker run -it --volume "${HOME}/Work:/Host/Work" ilegeul/ubuntu:amd64-12.04-xbb-v3.2
root@831bc35faf9f:/# ls -l /Host/Work
total 175320
drwxr-xr-x  14 root root       448 Mar  7 19:47 arm-none-eabi-gcc-9.2.1-1.2
drwxr-xr-x 144 root root      4608 Mar  9 13:15 cache
drwxr-xr-x  34 root root      1088 Mar 26 11:22 openocd-0.10.0-14
drwxr-xr-x  12 root root       384 Oct 30 19:00 riscv-none-embed-gcc-8.3.0-1.1
```

In this simple configuration, the builds run with root permissions; with
more elaborate configurations it is possible to start the Docker images
with user rights, but they are beyound the scope of this document.

## How to use the XBB tools

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
source "/opt/xbb/xbb-source.sh"
...
(
  xbb_activate

  ...
  ./configure
  make
)
```

### macOS

For macOS the recommended use case is similar, except the XBB tools
are installed in the user HOME folder:

```bash
source "${HOME}/.local/xbb/xbb-source.sh"
...
(
  xbb_activate

  ...
)
```

## The `xbb-source.sh` script

The build environment includes a helper script, `xbb-source.sh`,
which should be included
with `source` by the build scripts, to define more bash functions to
the shell.

These functions are used to extend the environment with resources available
in the XBB folders.

The `xbb_activate` function is used to extend the `PATH` with folders
in the XBB folders, in front of existing
folders, so that **the XBB executables are preferred over the system ones**.

## The `pkg-config-verbose` script

While running the configuration step, it is sometimes useful to trace
how `pkg-config` identifies resources to be used during the build.

The standard `pkg-config` does not have an option to increase verbosity.

The workaround is to use a separate script that displays the received command
and the response on the stderr stream.

This script is not specific to XBB, and can be used with any build.

For this, copy the file into `.../xbb/bin` or any other folder present
in the PATH and pass the script name via the environment.

```sh
chmod +x /opt/xbb/bin/pkg-config-verbose
export PKG_CONFIG=pkg-config-verbose
```

## End-of-support schedule

According to the
[CentOS schedule](https://en.wikipedia.org/wiki/CentOS#End-of-support_schedule),
version 6 will be supported up to Nov. 2020.

However, RHEL releases have a longer
[life cycle](https://access.redhat.com/support/policy/updates/errata/#Life_Cycle_Dates)
and RHEL 7 end of extended life-cycle support is 2024.

Due to maintenance issues, starting with XBB v3.1, support for CentOS/RHEL 6
was discontinued.

However support for RHEL 7 is very important, and will be preserved for
as long as possible. In practical terms, the ldd version must be
2.17 or lower.

## 32-bit support

Existing support for 32-bit builds will be preserved for the moment,
but might be dropped in one of the future version; for consistency
reasons, it is expected to continue to generate 32-bit binares
as long as Node.js still supports them via the
[unofficial builds](https://unofficial-builds.nodejs.org/download/)
(watch for the presence of `-linux-x86.tar.*` files).

## Arm binaries

Support for Arm binaries was added in v3.1, in early 2020.

The supported architectures are:

- `arm64v8` - the ARMv8 64-bit architecture Aarch64
- `arm32v7` - the ARMv7 32-bit architecture with hardware float (armhf)

## Distro versions

To better decide whch versions to support, below is a list of existing versions.

The names are in fact docker image names, and can be used directly to query
the `ldd --version`:

```sh
docker run -it <image> ldd --version
```

### [Debian](https://en.wikipedia.org/wiki/Debian_version_history)

- `debian:6` - squeeze - 2011-2016, 2.11.3, kernel 2.6.32
- `debian:7` - wheezy - 2013-2016, 2.13, kernel 3.2
- `debian:8` - jessie - 2015-2018, 2.19, kernel 3.16
- `debian:9` - stretch - 2017-2020, 2.24, kernel 4.9.0-6 (first with arm64) (next)
- `debian:10` - buster - 2019-2022, 2.28, kernel 4.19.0-6

### [Ubuntu](https://en.wikipedia.org/wiki/Ubuntu_version_history)

- `ubuntu:10.04` - lucy - 2010-2015, 2.11.1
- `ubuntu:12.04` - precise - 2012-2019, 2.15, kernel **3.2** <--- Intel Linux choice
- `ubuntu:14.04` - trusty - 2014-2022, 2.19, kernel 3.16
- `ubuntu:16.04` - xenial - 2016-2024, **2.23**, kernel 4.4 <--- Arm Linux choice, future Intel choice too
- `ubuntu:18.04` - bionic - 2018-2028, 2.27, kernel 4.15
- `ubuntu:20.04` - focal - 2020-2-30, 2.31, kernel 5.4

### [RHEL](https://access.redhat.com/support/policy/updates/errata/#Life_Cycle_Dates)

- `registry.access.redhat.com/rhel6` - 2.12 <--- no longer supported
- `registry.access.redhat.com/rhel7` - 2.17, kernel 3.10 <--- still supported, but not for long
- `registry.access.redhat.com/ubi8` - 2.28, kernel 5.10 (next)

### [CentOS](https://en.wikipedia.org/wiki/CentOS)

- `centos:6` - 2011-2020, 2.12 <--- no longer supported
- `centos:7` - 2014-2024, 2.17, kernel 3.10 <--- must be supported
- `centos:8` - 2019-2029, 2.28, kernel 4.18 (next)

### [Fedora](https://en.wikipedia.org/wiki/Fedora_version_history)

- `fedora:20` - 2013-12, 2.18, kernel 3.11 <-- Intel
- `fedora:21` - 2014-12, 2.20, kernel 3.17
- `fedora:22` - 2015-05, 2.21, kernel 4.0
- `fedora:23` - 2015-11, 2.22, kernel 4.2
- `fedora:24` - 2016-06, 2.23, kernel 4.5 <-- Arm (next Intel)
- `fedora:25` - 2016-11, 2.24, kernel 4.8
- `fedora:26` - 2017-07,
- `fedora:27` - 2017-11, 2.26, kernel 4.13
- `fedora:28` - 2018-05,
- `fedora:29` - 2018-10, 2.28, kernel 4.18
- `fedora:30` - 2019-05,
- `fedora:31` - 2019-10, 2.30, kernel 5.3
- `fedora:32` - 2020-04, 2.30, kernel 5.6

## Credits

The xPack Build Box is inspired by the 
[Holy Build Box](https://github.com/phusion/holy-build-box)

## Conclusions

For Intel Linux, to preserve support for older distributions,
the **Ubuntu 12 (precise)** (2.15) distribution was selected;
the resulting binaries should also run on RHEL 7 or newer;
support for RHEL 6 was discontinued.

For Arm binaries, the base distribution is **Ubuntu 16.04 LTS (xenial)**,
(2.23); the resulting binaries should run on all Raspberry Pi class
machines, or larger/newer.

## Future plans

RedHat extended support for RHEL 7 ends in Aug. 2023. However XBB support
for RHEL 7 is a tough requirement, and will probably be
dropped in 2022.

For future releases (2023-2024?), the plan is to move up to
Ubuntu 18 (GLIBC 2.27). This will also provide compatibility with
RedHat 8 / Debian 10, which both use GLIBC 2.28. The migration
path will probably take two steps, with an intermediate step
(in 2022?) at Ubuntu 16 (GlIBC 2.23) for both Intel and Arm Linux.
