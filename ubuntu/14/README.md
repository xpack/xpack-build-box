
## The root file systems

The Intel root file systems were created with `debootstrap` on an Ubuntu Server
18.04 running on an Intel NUC.

The Arm root file systems were created with `debootstrap` on an Ubuntu Server
18.04 running on a Raspberry Pi 4B.

```console
$ sudo apt install debootstrap
```

The Intel Ubuntu 14 (trusty) distribution binaries are available
from the archive server http://archive.ubuntu.com/ubuntu/,
when the support period ends, they are moved to
http://old-releases.ubuntu.com/ubuntu/, see the Ubuntu 12 folder
on how to use them.

```console
$ mkdir -p "${HOME}/tmp/amd64-ubu14-rootfs"
$ sudo debootstrap --verbose --arch=amd64 --variant=minbase trusty "${HOME}/tmp/amd64-ubu14-rootfs" http://archive.ubuntu.com/ubuntu/
$ sudo tar cJvf "${HOME}/tmp/amd64-ubu14-rootfs.xz" -C "${HOME}/tmp/amd64-ubu14-rootfs" .
```

```console
$ mkdir -p "${HOME}/tmp/i386-ubu14-rootfs"
$ sudo debootstrap --verbose --arch=i386 --variant=minbase trusty "${HOME}/tmp/i386-ubu14-rootfs" http://archive.ubuntu.com/ubuntu/
$ sudo tar cJvf "${HOME}/tmp/i386-ubu14-rootfs.xz" -C "${HOME}/tmp/i386-ubu14-rootfs" .
```

The Arm Ubuntu 14 (trusty) distribution binaries are available
from the ports server http://ports.ubuntu.com/.

```console
$ mkdir -p "${HOME}/tmp/arm64v8-ubu14-rootfs"
$ sudo debootstrap --verbose --arch=arm64 --variant=minbase trusty "${HOME}/tmp/arm64v8-ubu14-rootfs" http://ports.ubuntu.com/
$ sudo tar cJvf "${HOME}/tmp/arm64v8-ubu14-rootfs.xz" -C "${HOME}/tmp/arm64v8-ubu14-rootfs" .
```

```console
$ mkdir -p "${HOME}/tmp/arm32v7-ubu14-rootfs"
$ sudo debootstrap --verbose --arch=armhf --variant=minbase trusty "${HOME}/tmp/arm32v7-ubu14-rootfs" http://ports.ubuntu.com/
$ sudo tar cJvf "${HOME}/tmp/arm32v7-ubu14-rootfs.xz" -C "${HOME}/tmp/arm32v7-ubu14-rootfs" .
```

The result are several archives that were published at
https://github.com/xpack/xpack-build-box/releases/tag/rootfs/

- https://github.com/xpack/xpack-build-box/releases/download/rootfs/amd64-ubu14-rootfs.xz
- https://github.com/xpack/xpack-build-box/releases/download/rootfs/i386-ubu14-rootfs.xz
- https://github.com/xpack/xpack-build-box/releases/download/rootfs/arm64v8-ubu14-rootfs.xz
- https://github.com/xpack/xpack-build-box/releases/download/rootfs/arm32v7-ubu14-rootfs.xz

## Build Docker images

There are several scripts:

- `amd64-build.sh` -> `ilegeul/ubuntu:amd64-14.04`
- `i386-build.sh` -> `ilegeul/ubuntu:i386-14.04`
- `arm64v8-build.sh` -> `ilegeul/ubuntu:arm64v8-14.04`
- `arm32v7-build.sh` -> `ilegeul/ubuntu:arm32v7-14.04`

```console
$ bash ~/Downloads/xpack-build-box.git/ubuntu/14/amd64-build.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/14/i386-build.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/14/arm64v8-build.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/14/arm32v7-build.sh

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

The following tests were performed on an Ubuntu Server
18.04 running on a Raspberry Pi 4B.

```console
$ docker run --interactive --tty ilegeul/ubuntu:arm64v8-14.04
root@f57a7ff91fce:/# apt-get install -y lsb-release
root@f57a7ff91fce:/# lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 14.04 LTS
Release:	14.04
Codename:	trusty
root@f57a7ff91fce:/# uname -a
Linux f57a7ff91fce 5.3.0-1018-raspi2 #20-Ubuntu SMP Mon Feb 3 19:45:46 UTC 2020 aarch64 aarch64 aarch64 GNU/Linux
root@f57a7ff91fce:/# exit
exit
```

```console
$ docker run --interactive --tty ilegeul/ubuntu:arm32v7-14.04
root@7ec385ddeb43:/# apt-get install -y lsb-release
root@7ec385ddeb43:/# lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 14.04 LTS
Release:	14.04
Codename:	trusty
root@7ec385ddeb43:/# uname -a
Linux 7ec385ddeb43 5.3.0-1018-raspi2 #20-Ubuntu SMP Mon Feb 3 19:45:46 UTC 2020 armv8l armv8l armv8l GNU/Linux
root@7ec385ddeb43:/# exit
exit
```

## Publish

To publish, use:

```console
$ docker push "ilegeul/ubuntu:amd64-14.04"
$ docker push "ilegeul/ubuntu:i386-14.04"
$ docker push "ilegeul/ubuntu:arm64v8-14.04"
$ docker push "ilegeul/ubuntu:arm32v7-14.04"
```
