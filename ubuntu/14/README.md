
## The root file systems

The Intel root file systems were created with `debootstrap` on an Ubuntu Server
18.04 running on an Intel NUC.

```console
$ sudo apt install debootstrap
```

The Intel Ubuntu 14 (trusty) distribution binaries are available
from the archive server http://archive.ubuntu.com/ubuntu/,
when the support period ends, they are moved to
http://old-releases.ubuntu.com/ubuntu/, see the Ubuntu 12 folder
on how to use them.

```console
$ rm -rf "${HOME}/tmp/amd64-ubu14-rootfs"
$ mkdir -pv "${HOME}/tmp/amd64-ubu14-rootfs"
$ sudo debootstrap --verbose --arch=amd64 --variant=minbase trusty "${HOME}/tmp/amd64-ubu14-rootfs" http://archive.ubuntu.com/ubuntu/
$ sudo tar cJvf "${HOME}/tmp/amd64-ubu14-rootfs.xz" -C "${HOME}/tmp/amd64-ubu14-rootfs" .
```

```console
$ rm -rf "${HOME}/tmp/i386-ubu14-rootfs"
$ mkdir -pv "${HOME}/tmp/i386-ubu14-rootfs"
$ sudo debootstrap --verbose --arch=i386 --variant=minbase trusty "${HOME}/tmp/i386-ubu14-rootfs" http://archive.ubuntu.com/ubuntu/
$ sudo tar cJvf "${HOME}/tmp/i386-ubu14-rootfs.xz" -C "${HOME}/tmp/i386-ubu14-rootfs" .
```

The result are several archives that were published at
https://github.com/xpack/xpack-build-box/releases/tag/rootfs/

- https://github.com/xpack/xpack-build-box/releases/download/rootfs/amd64-ubu14-rootfs.xz
- https://github.com/xpack/xpack-build-box/releases/download/rootfs/i386-ubu14-rootfs.xz

## Build Docker images

There are several scripts:

- `amd64-build.sh` -> `ilegeul/ubuntu:amd64-14.04`
- `i386-build.sh` -> `ilegeul/ubuntu:i386-14.04`

```console
$ bash ~/Downloads/xpack-build-box.git/ubuntu/14/amd64-build.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/14/i386-build.sh

$ docker images
```

## Test

The following tests were performed on an Ubuntu Server
18.04 running on an Intel NUC.

```console
$ docker run --interactive --tty ilegeul/ubuntu:amd64-14.04
root@a7df3e752653:/# apt-get install -y lsb-release
root@a7df3e752653:/# lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 14.04 LTS
Release:	14.04
Codename:	trusty
root@a7df3e752653:/# uname -a
Linux a7df3e752653 5.3.0-40-generic #32~18.04.1-Ubuntu SMP Mon Feb 3 14:05:59 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux
root@a7df3e752653:/# exit
exit
```

```console
$ docker run --interactive --tty ilegeul/ubuntu:i386-14.04
root@328fe5771037:/# apt-get install -y lsb-release
root@328fe5771037:/# lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 14.04 LTS
Release:	14.04
Codename:	trusty
root@328fe5771037:/# uname -a
Linux 328fe5771037 5.3.0-40-generic #32~18.04.1-Ubuntu SMP Mon Feb 3 14:05:59 UTC 2020 i686 i686 i686 GNU/Linux
root@328fe5771037:/# exit
exit
```

## Publish

To publish, use:

```console
$ docker push "ilegeul/ubuntu:amd64-14.04"
$ docker push "ilegeul/ubuntu:i386-14.04"
```
