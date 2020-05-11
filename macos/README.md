## The macOS XBB

### Overview

When running on macOS, the build scripts cannot use Docker, since there
are no macOS Docker images; instead,
a custom set of tools is expected in a specific folder
(`${HOME}/opt/xbb`), which includes the same tools as
packed in the Docker images.

The reason for a separate folder is that, in order to achieve consistent and
reproducible results, the tools in the XBB folder must be locked to
certain versions, and no updates should be performed.

To build the macOS XBB, clone the git, run the the bootstrap script and
finally run the main XBB build script.

### Prerequisites

As usual with macOS, the compiler and other development tools are not
packed in the base system and need to be installed as part of the
**Command Line Tools** package, available from
[Apple](https://developer.apple.com/downloads/index.action).

Xcode itself is not needed, it is even harmful for the Homebrew builds,
and should not be installed.

### Remove macPorts or Homebrew from the PATH

To avoid unwanted versions of different programs to be inadvertently
used during builds, it is highly recommended to remove any additional
tools from the system PATH while running the XBB build script or the
later application build scripts.

Preferably temporarily set the path to the minimum:

```console
$ export PATH=/usr/bin:/bin:/usr/sbin:/sbin
```

Note: strict control of the path is a hard requirement and should not
be treated lightly; failing to do so will probably result in broken
builds.

### Clone the repository

```console
$ rm -rf "${HOME}/Downloads/xpack-build-box.git"
$ git clone --recurse-submodules https://github.com/xpack/xpack-build-box.git \
  "${HOME}/Downloads/xpack-build-box.git"
```

Note: the repository uses submodules, and if updated manually, the
submodules must also be updated.

### Build the XBB bootstrap

For consistent results, the XBB tools are not compiled with the native Apple
compiler, but with a GCC 7. This first set of tools is called _the XBB
bootstrap_.

```console
$ JOBS=7 caffeinate bash "${HOME}/Downloads/xpack-build-box.git/macos/build-xbb-bootstrap-v3.1.sh"
```

The Finder command `build-xbb-bootstrap-v3.1.mac.command` can be used
as a shortcut.

The build process takes quite a while.

The build is performed in a folder like `${HOME}/Work/xbb-bootstrap-3.1-darwin-x86_64`
which can be removed after the build is completed.

The result of this step is a folder in user home (`${HOME}/opt/xbb-bootstrap`).
No files are stored in system locations.

This folder **should not** be removed after the final XBB tools are built,
since they may refer to bootstrap libraries.

### Build the XBB tools

The final XBB tools are compiled with the bootstrapped compiler.

```console
$ JOBS=7 caffeinate bash "${HOME}/Downloads/xpack-build-box.git/macos/build-xbb-v3.1.sh"
```

The Finder command `build-xbb-v3.1.mac.command` can be used
as a shortcut.

The build process takes quite a while. 

The build is performed in a folder like `${HOME}/Work/xbb-3.1-darwin-x86_64`
which can be removed after the build is completed.

The result of this step is a folder in user home (`${HOME}/opt/xbb`).
No files are stored in system locations.

### Protect the XBB folders

To prevent inadvertent changes, it is recommended to make the XBB folders
read-only.

```console
$ chmod -R -w "${HOME}/opt/xbb-bootstrap"
$ chmod -R -w "${HOME}/opt/xbb"
```

### How to use

The recommended use is similar to all other XBBs:

```bash
# At init time.
source "${HOME}/opt/xbb/xbb-source.sh"

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

```console
$ caffeinate bash "${HOME}/Downloads/xpack-build-box.git/macos/install-texlive.sh"
```

The Finder command `install-texlive.mac.command` can be used
as a shortcut.

The TeX install script is locked to a certain version, but depends on the
presence of that version on a certain server, which is also not guaranteed
to last forever.

## Deprecated Homebrew solution

The first version of the macOS XBB used Homebrew, but it was soon discovered
that Homebrew was not designed to facilitate the version locking required
by XBB; changes to the Ruby core are quite often, sometimes
incompatible, and support for older macOS versions, like 10.10, was
discontinued, thus making Homebrew not a choice for XBB.

For more details, see the [README-DEPRECATED](README-DEPRECATED.md) file.
