## The macOS XBB
## Deprecated Homebrew solution

The first version of the macOS XBB used Homebrew, but it was soon discovered
that Homebrew was not designed to facilitate the version locking required
by XBB, because changes to the Ruby core are quite often, sometimes
incompatible, and support for older macOS versions, like 10.10, was 
discontinued.

### Patches

**Normally this step should not be needed**, but on some system versions and/or
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

The result of this step is a folder in user home (`${HOME}/opt/homebrew/xbb-bootstrap`).
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

Warning: Since `brew` automatically updates itself to the latest version,
it is not guaranteed that the build succeeds. This is
one more reason why the non Homebrew version of the macOS XBB was preferred.

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
