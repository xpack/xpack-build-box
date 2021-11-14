# The macOS XBB

## Overview

When running on macOS, the build scripts cannot use Docker, since there
are no macOS Docker images; instead,
a custom set of tools is expected in a specific folder
(like `${HOME}/.local/xbb`),
which includes the same tools as
packed in the Docker images.

The reason for a separate folder is that, in order to achieve consistent and
reproducible results, the tools in the XBB folder must be locked to
certain versions, and no updates should be performed.

To build the macOS XBB, clone the git, run the the bootstrap script and
finally run the main XBB build script.

## Prerequisites

As usual with macOS, the compiler and other development tools are not
packed in the base system and need to be installed as part of the
**Xcode** package, available from
[Apple](https://developer.apple.com).

Although Xcode itself is not needed, it is prefered over the Command Line Tools,
since it guarantees a full SDK, not present on older versions of CLT.

## macOS 10.13

For the xPack binaries  to run on all macOS 10.13 or later, it is necessary to run
the builds on a macOS 10.13 machine.

The `-mmacosx-version-min=` clang option is useful, and must be added both while
compiling and linking, but does not guarantee that builds performed on a
recent system will run on older systems, and the safest solution is to run the
builds on a macOS 10.13 system using the 10.13 SDK, which is part of the
**Xcode 10.1**.

This version includes a quite old version of clang:

```console
$ clang --version
Apple LLVM version 10.0.0 (clang-1000.10.44.4)
Target: x86_64-apple-darwin17.7.0
Thread model: posix
InstalledDir: /Library/Developer/CommandLineTools/usr/bin
```

Some modern tools can no longer be compiled with this old version, and require 
the bootstrap tools, which will generally include reasonably recent tools that
can still be built with the native compiler.

As of now, the boostrap compiler is GCC 11.x, since older versions do
not compile on new M1 Macs.

## Remove macPorts or Homebrew from the PATH

To avoid unwanted versions of different programs to be inadvertently
used during builds, it is highly recommended to remove any additional
tools from the system PATH while running the XBB build script or the
later application build scripts.

Preferably temporarily set the path to the minimum:

```bash
export PATH=/usr/bin:/bin:/usr/sbin:/sbin
```

Note: strict control of the path is a hard requirement and should not
be treated lightly; failing to do so will probably result in broken
builds.

## Build the XBB bootstrap

For consistent results, the XBB tools are not compiled with the native Apple
compiler, but with a GCC. This first set of tools is called _the XBB
bootstrap_.

```bash
RUN_LONG_TESTS=y caffeinate bash "${HOME}/Downloads/xpack-build-box.git/macos/build-xbb-bootstrap-v3.3.sh"
```

There are several environment variables that can be passed to the script:

```bash
DEBUG=-x caffeinate bash "${HOME}/Downloads/xpack-build-box.git/macos/build-xbb-bootstrap-v3.3.sh"
```

The build process takes about 300 minutes on a MacBook Pro 2011; on a MacMini M1, the build took 60 min.

The build is performed in a folder like `${HOME}/Work/xbb-bootstrap-3.3-darwin-x86_64`
which can be removed after the build is completed.

The result of this step is a folder in user home (`${HOME}/.local/xbb-bootstrap`).
No files are stored in system locations.

This folder **should not** be removed after the final XBB tools are built,
since they may refer to bootstrap libraries.

## Build the XBB tools

The final XBB tools are compiled with the bootstrapped compiler.

```bash
RUN_LONG_TESTS=y caffeinate bash "${HOME}/Downloads/xpack-build-box.git/macos/build-xbb-v3.3.sh"
```

The build process takes about 450 minutes on a MacBook Pro 2011.

The build is performed in a folder like `${HOME}/Work/xbb-3.3-darwin-x86_64`
which can be removed after the build is completed.

The result of this step is a folder in user home (`${HOME}/.local/xbb`).
No files are stored in system locations.

## Protect the XBB folders

To prevent inadvertent changes, it is recommended to make the XBB folders
read-only.

```bash
chmod -R -w "${HOME}/.local/xbb-bootstrap"
chmod -R -w "${HOME}/.local/xbb"
```

## How to use

The recommended use is similar to all other XBBs:

```bash
# At init time.
source "${HOME}/.local/xbb/xbb-source.sh"

(
  # When needed; preferably in a sub-shell.
  xbb_activate

  ../configure
  make
)
```

## The `xbb-source.sh` script

See the parent [`README.md`](../README.md).

## The `pkg-config-verbose` script

See the parent [`README.md`](../README.md).

## Install TeX

TeX is used to generate the documentation. For development builds, to
speed up things, creating the manuals can be skipped, so this step is
not mandatory.

TeX is available in the [TeX Live](https://tug.org/texlive/) distribution.

```bash
caffeinate bash "${HOME}/Downloads/xpack-build-box.git/macos/install-texlive.sh" 2021
```

The TeX install script is locked to a certain version, but depends on the
presence of that version on a certain server, which is also not guaranteed
to last forever.

Note: on newer macOS releases, installing 2018 fails and the only one that
proved functional is 2021.

## Deprecated Homebrew solution

The first version of the macOS XBB used Homebrew, but it was soon discovered
that Homebrew was not designed to facilitate the version locking required
by XBB; changes to the Ruby core are quite often, sometimes
incompatible, and support for older macOS versions, like 10.10, was
discontinued, thus making Homebrew not a choice for XBB.

For more details, see the [README-DEPRECATED](README-DEPRECATED.md) file.

## Apple tricks

From https://stackoverflow.com/questions/52977581/why-isnt-mmacosx-version-min-10-10-preventing-use-of-a-function-tagged-as-star

- `-mmacosx-version-min=10.10` for the compilers
- `-Wl,-mmacosx-version-min=10.10`, for the linker
- `-Wunguarded-availability`

Apple clang

- https://en.wikipedia.org/wiki/Xcode#Xcode_7.0_-_12.x_(since_Free_On-Device_Development)

Apple clang 12.0.0 -> LLVM 10.0.0
