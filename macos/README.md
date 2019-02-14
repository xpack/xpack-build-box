
## The macOS XBB

When running on macOS, the build scripts do not use Docker; instead,
a custom Homebrew is expected in a specific folder 
(`${HOME}/opt/homebrew/xbb`), which includes the same tools as 
packed in the Docker images.

To build this Homebrew instance, clone the git and start the install scripts.

### Prerequisites

As usual with macOS, the compiler and other development tools are not
available in the base system and need to be installed as part of the
**Xcode Command Line Tools** package.

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
$ git clone https://github.com/xpack/xpack-build-box.git ${HOME}/Downloads/xpack-build-box.git
```

### Patches

To make the build pass, one of the system headers (`/usr/include/dispatch/object.h`) 
may require a small patch, to make it palatable for C too, not only for Objective-C.

Instead of:

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

This was true for macOS 10.13. More recent systems may have this already fixed.

Recent systems do not allow changes to system files; to fix this file it is
necessary to temporarily disable SIP by booting to the 
Recovery System (hold down Apple-R while booting), and issuing
`csrutil disable` in a terminal.

### Build Homebrew XBB

```console
$ caffeinate bash "${HOME}/Downloads/xpack-build-box.git/macos/install-homebrew-xbb.sh"
```

The build process takes quite a while. 

The result of this step is a folder in user home (`${HOME}/opt/homebrew/xbb`).
No files are stored in system locations.

Warning: Since brew automatically updates 
packages to the latest version, and there is no way to lock the build to
certain versions, it is not guaranteed that the build succeeds. (That's 
the reason why Docker builds are safer.)

### Build GCC 7

The current packages build scripts are based on GCC 7. Unfortunately, 
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

## Install TeX

TeX is used to generate the documentation. For development builds, to 
speed up things, the manuals can be skipped, so this step is not mandatory.

```console
$ caffeinate bash "${HOME}/Downloads/xpack-build-box.git/macos/install-texlive.sh"
```

The TeX install script is locked to a certain version, but depends on the
presence of that version on a certain server, which is also not guaranteed
to last forever.
