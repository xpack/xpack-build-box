
## The macOS XBB

### Overview

When running on macOS, the build scripts do not use Docker, since there
are no macOS Docker images; instead,
a custom Homebrew is expected in a specific folder 
(`${HOME}/opt/homebrew/xbb`), which includes the same tools as 
packed in the Docker images.

The reason for a separate image is that, in order to achieve consistent and 
reproducible results, the tools in the XBB instance must be locked to
certain versions, and no updates should be performed. 

To build this Homebrew instance, clone the git and start the install scripts.

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
$ rm "${HOME}"/Downloads/xpack-build-box.git
$ git clone https://github.com/xpack/xpack-build-box.git \
  "${HOME}"/Downloads/xpack-build-box.git
```

### Patches

This step should normally not be needed, but on some system versions and/or
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

### Build Homebrew XBB

```console
$ caffeinate bash "${HOME}"/Downloads/xpack-build-box.git/macos/install-homebrew-xbb.sh
$ bash "${HOME}"/Downloads/xpack-build-box.git/macos/add-xbb-extras.sh
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

### Protect the XBB folder

To prevent inadvertent changes, it is recommended to make the XBB folder 
read-only.

```console
$ chmod -R -w ${HOME}/opt/homebrew/xbb
```

### How to use?

The recommended use is similar to all other XBBs:

```bash
# At init time.
source "${HOME}/opt/homebrew/xbb/xbb-source.sh"

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

The following packages were used for QEMU:

```console
$ brew list --versions \
libpng \
jpeg \
sdl2 \
sdl2_image \
pixman \
glib \
libffi \
libxml2 \
libiconv \

glib 2.58.3
jpeg 9c
libffi 3.2.1
libiconv 1.15
libpng 1.6.36
libxml2 2.9.9_2
pixman 0.38.0
sdl2 2.0.9
sdl2_image 2.0.4

```

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
