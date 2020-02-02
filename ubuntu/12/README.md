
## The root file systems

The Intel root file systems were created with `debootstrap` on an Ubuntu Server
18.04 running on an Intel NUC.

```console
$ sudo apt install debootstrap
```

The Ubuntu 12 (precise) distribution binaries are archived and available
from the separate server http://old-releases.ubuntu.com/ubuntu/.

```console
$ mkdir -p "${HOME}/tmp/amd64-ubu12-rootfs"
$ sudo debootstrap --verbose --arch=amd64 --keyring=/usr/share/keyrings/ubuntu-archive-removed-keys.gpg precise ’${HOME}/tmp/amd64-ubu12-rootfs" http://old-releases.ubuntu.com/ubuntu/
$ sudo tar cJvf "${HOME}/tmp/amd64-ubu12-rootfs.xz" -C "${HOME}/tmp/amd64-ubu12-rootfs" .
```

```console
$ mkdir -p "${HOME}/tmp/i386-ubu12-rootfs"
$ sudo debootstrap --verbose --arch=i386 --keyring=/usr/share/keyrings/ubuntu-archive-removed-keys.gpg precise "${HOME}/tmp/i386-ubu12-rootfs" http://old-releases.ubuntu.com/ubuntu/
$ sudo tar cJvf "${HOME}/tmp/i386-ubu12-rootfs.xz" -C "${HOME}/tmp/i386-ubu12-rootfs" .
```

The result are two archives that were published at
https://github.com/xpack/xpack-build-box/releases/tag/rootfs/:

- https://github.com/xpack/xpack-build-box/releases/download/rootfs/amd64-ubu12-rootfs.xz
- https://github.com/xpack/xpack-build-box/releases/download/rootfs/i386-ubu12-rootfs.xz

## Build Docker images

There are two scripts:

- `amd64-build.sh` -> `ilegeul/ubuntu:amd64-12.04`
- `i386-build.sh` -> `ilegeul/ubuntu:i386-12.04`

```console
$ bash ~/Downloads/xpack-build-box.git/ubuntu/12/amd64-build.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/12/i386-build.sh

$ docker images
```

## Test

The test was performed on a macOS.

```console
$ docker run --interactive --tty ilegeul/ubuntu:amd64-12.04
root@724327ed4bc3:/# lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 12.04 LTS
Release:	12.04
Codename:	precise
root@724327ed4bc3:/# uname -a
Linux 724327ed4bc3 4.9.184-linuxkit #1 SMP Tue Jul 2 22:58:16 UTC 2019 x86_64 x86_64 x86_64 GNU/Linux
root@724327ed4bc3:/# exit
```

```console
$ docker run --interactive --tty ilegeul/ubuntu:i386-12.04
root@bf97fbbdd998:/# lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 12.04 LTS
Release:	12.04
Codename:	precise
root@bf97fbbdd998:/# uname -a
Linux bf97fbbdd998 4.9.184-linuxkit #1 SMP Tue Jul 2 22:58:16 UTC 2019 i686 i686 i386 GNU/Linux
root@bf97fbbdd998:/# exit
```

## Publish

To publish, use:

```console
$ docker push "ilegeul/ubuntu:amd64-12.04"
$ docker push "ilegeul/ubuntu:i386-12.04"
```
