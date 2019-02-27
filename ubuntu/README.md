## The Ubuntu XBB

### Overview

This solution is intended mainly for development purposes, to create
applications that can be used in edit-compile-debug cycles, thus should
be as fast as reasonably possible.

For this, the build environment should use the tools and libraries 
available in the host machine and do not build any of them from sources.

### Prerequisites

The current procedure was tested on an Ubuntu 18 LTS 64-bit virtual
machine running on VirtualBox, but should work on any virtualisation
platform, or even with a physical systems.

For virtual machines, to keep the space requirements low, preferably 
install a **minimal** system (select this during the install).

### How to install?

```console
$ rm -rf "${HOME}"/Downloads/xpack-build-box.git
$ git clone --recurse-submodules https://github.com/xpack/xpack-build-box.git \
  "${HOME}"/Downloads/xpack-build-box.git

$ sudo bash "${HOME}"/Downloads/xpack-build-box.git/ubuntu/install-xbb.sh
$ sudo bash "${HOME}"/Downloads/xpack-build-box.git/ubuntu/add-xbb-extras.sh
```

It takes a few minutes to install all system requirements.

In addition to the minimal system, a modern graphical editor and a graphical 
Git client are recommended, although none is mandatory, and for the
brave ones using the command line tools is perfectly possible.

#### Visual Studio Code

The recommended editor is Visual Studio Code, which can be downloaded 
for free from
[visualstudio.com](https://code.visualstudio.com/download).

Select the `.deb` file, and install it:

```console
$ sudo apt install --yes ~/Downloads/code_1.31.1-1549938243_amd64.deb
```

Preferably add it to the tool bar, for convenient access.

The QEMU git already includes the `.vscode` folder with preconfigured
build and debug configurations.

This is an optional step. Any other editor is perfectly ok, but the
build and debug configurations must be recreated.

#### Git Kraken

Since SourceTree is not available for GNU/Linux, the second choice is
Git Kraken, which can be downloaded for free from 
[gitkraken.com](https://www.gitkraken.com/download).

Select the `.deb` file, and install it:

```console
$ sudo apt install --yes ~/Downloads/gitkraken-amd64.deb
```

Preferably add it to the tool bar, for convenient access.

This is an optional step. Any other Git client is perfectly ok,
even the command line one.

### How to use?

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

## The `xbb-source.sh` script

See the parent [`README.md`](../README.md).

## The `pkg-config-verbose` script

See the parent [`README.md`](../README.md).


### Actual libraries versions

On Ubuntu 18LTS, the following packages were used for QEMU:

```console
$ dpkg -l \
libpng-dev \
libjpeg-dev \
libsdl2-dev \
libsdl2-image-dev \
libpixman-1-dev \
libglib2.0-dev \
zlib1g-dev \
libffi-dev \
libxml2-dev \
zlib1g-dev \


Desired=Unknown/Install/Remove/Purge/Hold
| Status=Not/Inst/Conf-files/Unpacked/halF-conf/Half-inst/trig-aWait/Trig-pend
|/ Err?=(none)/Reinst-required (Status,Err: uppercase=bad)
||/ Name           Version      Architecture Description
+++-==============-============-============-=================================
ii  libffi-dev:amd 3.2.1-8      amd64        Foreign Function Interface librar
ii  libglib2.0-dev 2.56.3-0ubun amd64        Development files for the GLib li
ii  libjpeg-dev:am 8c-2ubuntu8  amd64        Independent JPEG Group's JPEG run
ii  libpixman-1-de 0.34.0-2     amd64        pixel-manipulation library for X 
ii  libpng-dev:amd 1.6.34-1ubun amd64        PNG library - development (versio
ii  libsdl2-dev:am 2.0.8+dfsg1- amd64        Simple DirectMedia Layer developm
ii  libsdl2-image- 2.0.3+dfsg1- amd64        Image loading library for Simple 
ii  libxml2-dev:am 2.9.4+dfsg1- amd64        Development files for the GNOME X
ii  zlib1g-dev:amd 1:1.2.11.dfs amd64        compression library - development

```