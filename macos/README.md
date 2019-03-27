
## The macOS XBB

### Overview

When running on macOS, the build scripts do not use Docker, since there
are no macOS Docker images; instead,
a custom set of tools is expected in a specific folder 
(`${HOME}/opt/xbb`), which includes the same tools as 
packed in the Docker images.

The reason for a separate folder is that, in order to achieve consistent and 
reproducible results, the tools in the XBB instance must be locked to
certain versions, and no updates should be performed. 

To build these tools, clone the git and start the install scripts.

### Prerequisites

As usual with macOS, the compiler and other development tools are not
available in the base system and need to be installed as part of the
**Xcode Command Line Tools** package, available from Apple.

### Remove macPorts or Homebrew from PATH

To avoid unwanted versions of different programs to be inadvertently 
used during builds, it is highly recommended to remove any additional 
tools from the system PATH while running the XBB build script or the 
later application build scripts.

Preferably temporarily set the path to the minimum:

```console
$ export PATH=/usr/bin:/bin:/usr/sbin:/sbin
```

### Clone the repository

```console
$ rm -rf "${HOME}/Downloads/xpack-build-box.git"
$ git clone --recurse-submodules https://github.com/xpack/xpack-build-box.git \
  "${HOME}/Downloads/xpack-build-box.git"
```

### Build the XBB bootstrap

For consistent results, the XBB tools are not compiled with the native Apple 
compiler, but with a GCC 7.

```console
$ caffeinate bash "${HOME}/Downloads/xpack-build-box.git/macos/build-xbb-bootstrap.sh"
```

The build process takes quite a while. 

The build is performed in a folder like `${HOME}/Work/darwin-xbb-bootstrap` 
which can be removed after the build is completed.

The result of this step is a folder in user home (`${HOME}/opt/xbb-bootstrap`).
No files are stored in system locations.

This folder can also be removed after the final XBB tools are built.

### Build the XBB tools

The final XBB tools are compiled with the bootstrapped compiler.

```console
$ caffeinate bash "${HOME}/Downloads/xpack-build-box.git/macos/build-xbb.sh"
```

The build process takes quite a while. 

The build is performed in a folder like `${HOME}/Work/darwin-xbb` 
which can be removed after the build is completed.

The result of this step is a folder in user home (`${HOME}/opt/xbb`).
No files are stored in system locations.

### Protect the XBB folders

To prevent inadvertent changes, it is recommended to make the XBB folders 
read-only.

```console
$ chmod -R -w ${HOME}/opt/xbb
```

### How to use?

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
$ caffeinate bash "${HOME}"/Downloads/xpack-build-box.git/macos/install-texlive.sh
```

The TeX install script is locked to a certain version, but depends on the
presence of that version on a certain server, which is also not guaranteed
to last forever.

## macOS 10.10 problems

The `curl` program on this old system cannot download files from sites
with new certificates, so it must be helped, by manually downloading
the required files into `${HOME}/Library/Caches/Homebrew`.
 
- https://curl.haxx.se/download/curl-7.64.0.tar.bz2

## Obsolete Homebrew solution

### Patches

**This step should normally not be needed**, but on some system versions and/or
Homebrew versions, the Homebrew build fails with an error related to the 
system header `/usr/include/dispatch/object.h`, which has a bug, one of the 
definitions is available only for Objective-C, and not for C.

To make the build pass, the file must be edited, and instead of:

```c
typedef void (^dispatch_block_t)(void);
```

it must read:

```c
#if OS_OBJECT_USE_OBJC
typedef void (^dispatch_block_t)(void);
#else
typedef void (*dispatch_block_t)(void);
#endif
```

This was true for macOS 10.13. More recent systems may have this 
file already fixed.

#### SIP

Recent systems do not allow changes to system files; to fix this file it is
necessary to temporarily disable SIP by booting to the 
Recovery System (hold down Apple-R while booting), and issuing
`csrutil disable` in a terminal.

After fixing the file, be sure you restore the secure SIP setting 
(`csrutil enable`).

### Prevent auto-update

By default Homebrew updates its internal Git repositories to the latest
commits. For a controlled environment like XBB, this is a no-go. To
prevent it, add `HOMEBREW_NO_AUTO_UPDATE` to the environment:

```
export HOMEBREW_NO_AUTO_UPDATE=1
```

### Build the Homebrew XBB bootstrap

This step was superseded by the XBB bootstrap step not using Homebrew.

The bootstrap is basically a GCC 7 compiler used to build the final XBB tools.

```console
$ caffeinate bash "${HOME}/Downloads/xpack-build-box.git/macos/install-homebrew-xbb-bootstrap.sh"
```

The build process takes quite a while. 

The result of this step is a folder in user home (`${HOME}/opt/homebrew/xbb`).
No files are stored in system locations.

### Build the Homebrew XBB

```console
$ caffeinate bash "${HOME}/Downloads/xpack-build-box.git/macos/install-homebrew-xbb.sh"
$ bash "${HOME}/Downloads/xpack-build-box.git/macos/add-xbb-extras.sh
```

The build process takes quite a while. 

The result of this step is a folder in user home (`${HOME}/opt/homebrew/xbb`).
No files are stored in system locations.

Since Homebrew does not allow to explicitly install a specific version of 
a package, the workaround is to revert to a specific date which is known 
to have functional packages. This is done by checking out a specific 
commit id from the homebrew-core repository.

Warning: Since brew automatically updates itself to the latest version, 
it is not guaranteed that the build succeeds. (That's 
the reason why Docker builds are significantly much safer.)

### Build a patched GCC 7

This step is required only for building distribution builds on macOS 10.10;
for native builds on macOS 10.13, like for QEMU, the Homebrew GCC 7 proved 
to be ok.

The current xPack build scripts are based on GCC 7.2. Unfortunately, 
the standard version provided by Homebrew has a problem, and requires a patch.

To build the patched GCC 7, use the following script:

```console
$ caffeinate bash "${HOME}/Downloads/xpack-build-box.git/macos/install-patched-gcc.sh"
```

The result is also stored in the `${HOME}/opt/homebrew/xbb` folder.
