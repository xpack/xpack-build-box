## The Ubuntu XBB

### Overview

This solution is intended mainly for development purposes, to create
applications that can be used in edit-compile-debug cycles, thus should
be as fast as reasonably possible.

For this, the build environment should use the tools and libraries 
available in the host machine and do not build any of them from sources.

### How to install?

The current procedure was tested on an Ubuntu 18LTS 64-bit virtual
machine running on VirtualBox, but should work with physical systems too.

For virtual machines, to keep the space requirements low, preferably 
install a **minimal** system (select this during the install).

```console
$ rm -rf ~/Downloads/xpack-build-box.git
$ git clone --recurse-submodules https://github.com/xpack/xpack-build-box.git \
  ~/Downloads/xpack-build-box.git
$ sudo bash ~/Downloads/xpack-build-box.git/ubuntu/install-xbb.sh
```

It takes a few minutes to install all system requirements.

#### Visual Studio Code

The recommended editor is Visual Studio Code, which can be downloaded 
for free from
[visualstudio.com](https://code.visualstudio.com/download).

Select the `.deb` file, and install it:

```console
$ sudo apt install --yes ~/Downloads/code_1.31.1-1549938243_amd64.deb
```

Preferably add it to the tool bar, for convenient access.

#### Git Kraken

Since SourceTree is not available for GNU/Linux, the second choice is
Git Kraken, which can be downloaded for free from 
[gitkraken.com](https://www.gitkraken.com/download).

Select the `.deb` file, and install it:

```console
$ sudo apt install --yes ~/Downloads/gitkraken-amd64.deb
```

Preferably add it to the tool bar, for convenient access.

### How to use?

The recommended use is similar to all other XBBs:

```bash
source "/opt/xbb/xbb-source.sh"
xbb_activate
```
