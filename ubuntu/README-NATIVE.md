# The Ubuntu XBB - native development

## Overview

This solution is intended mainly for development purposes, to create
applications that can be used in edit-compile-debug cycles, thus should
be as fast as reasonably possible.

For this, the build environment should use the tools and libraries
available in the host machine, even if the versions may be slightly
different from those used in the Docker images.

## Prerequisites

The current procedure was tested on an Ubuntu 18 LTS 64-bit.

For virtual machines, to keep the space requirements low, preferably
install a **minimal** system (select this during the install).

## How to install

```console
$ rm -rf "${HOME}/Work/xpack-build-box.git"
$ git clone --recurse-submodules https://github.com/xpack/xpack-build-box.git \
  "${HOME}"/Downloads/xpack-build-box.git

$ sudo bash "${HOME}/Work/xpack-build-box.git/ubuntu/install-native-xbb-v3.1.sh"
$ sudo bash "${HOME}/Work/xpack-build-box.git/ubuntu/add-native-extras-xbb-v3.1.sh"
```

It takes a few minutes to install all system requirements.

In addition to the minimal system, a modern graphical editor and a graphical
Git client are recommended, although none is mandatory, and for the
brave ones using the command line tools is perfectly possible.

### Visual Studio Code

The recommended editor is Visual Studio Code, which can be downloaded
for free from
[visualstudio.com](https://code.visualstudio.com/download).

Select the `.deb` file, and install it:

```console
$ sudo apt install --yes ${HOME}/Work/code_1.31.1-1549938243_amd64.deb
```

Preferably add it to the tool bar, for convenient access.

Some of the project Gits, like qemu.git, already includes
the `.vscode` folder with preconfigured
build and debug configurations.

This is an optional step. Any other editor is perfectly ok, but the
build and debug configurations must be recreated.

### Visual Studio Code - Git

Since SourceTree is not available for GNU/Linux, the second choice is
to use the VS Code Git plug-ins, which are doing a fair job.

In addition to the included Git functionality, there are several useful Git
plug-ins, like;

- GitLens
- Git Graph

### Git Kraken

A separate alternative is
Git Kraken, which can be downloaded for free from
[gitkraken.com](https://www.gitkraken.com/download).

Select the `.deb` file, and install it:

```console
$ sudo apt install --yes ${HOME}/Work/gitkraken-amd64.deb
```

Preferably add it to the tool bar, for convenient access.

This is an optional step. Any other Git client is perfectly ok,
even the command line one.

## How to use

The recommended use is similar to all other XBBs:

```bash
# At init time.
source "/opt/xbb/xbb-source.sh"

(
  # When needed; preferably in a sub-shell.
  xbb_activate

  ../configure
  make
)
```

# The `xbb-source.sh` script

See the parent [`README.md`](../README.md).

# The `pkg-config-verbose` script

See the parent [`README.md`](../README.md).

