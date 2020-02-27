
## The root file systems

The Arm root file systems were created with `debootstrap` on an Ubuntu Server
18.04 running on a Raspberry Pi 4B.

```console
$ sudo apt install debootstrap
```

The Ubuntu 14 (trusty) distribution binaries are available
from the current ports server http://ports.ubuntu.com/.

```console
$ mkdir -p "${HOME}/tmp/arm64-ubu14-rootfs"
$ sudo debootstrap --verbose --arch=arm64 --variant=minbase trusty "${HOME}/tmp/arm64-ubu14-rootfs" http://ports.ubuntu.com/
$ sudo tar cJvf "${HOME}/tmp/arm64-ubu14-rootfs.xz" -C "${HOME}/tmp/arm64-ubu14-rootfs" .
```

```console
$ mkdir -p "${HOME}/tmp/armhf-ubu14-rootfs"
$ sudo debootstrap --verbose --arch=armhf --variant=minbase trusty "${HOME}/tmp/armhf-ubu14-rootfs" http://ports.ubuntu.com/
$ sudo tar cJvf "${HOME}/tmp/armhf-ubu14-rootfs.xz" -C "${HOME}/tmp/armhf-ubu14-rootfs" .
```

The result are two archives that were published at
https://github.com/xpack/xpack-build-box/releases/tag/rootfs:

- https://github.com/xpack/xpack-build-box/releases/download/rootfs/arm64-ubu14-rootfs.xz
- https://github.com/xpack/xpack-build-box/releases/download/rootfs/armhf-ubu14-rootfs.xz

## Build Docker images

There are two scripts:

- `arm64-build.sh` -> `ilegeul/ubuntu:arm64-14.04`
- `armhf-build.sh` -> `ilegeul/ubuntu:armhf-14.04`

```console
$ bash ~/Downloads/xpack-build-box.git/ubuntu/14/arm64-build.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/14/armhf-build.sh

$ docker images
```

## Test

The test was performed on an Ubuntu Server 18.04 running on a Raspberry Pi 4B.

```console
$ docker run --interactive --tty ilegeul/ubuntu:arm64-14.04
root@8794a63812ce:/# lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 14.04 LTS
Release:	14.04
Codename:	trusty
root@8794a63812ce:/# uname -a
Linux 8794a63812ce 5.3.0-1014-raspi2 #14-Ubuntu SMP Tue Nov 26 11:18:23 UTC 2019 aarch64 aarch64 aarch64 GNU/Linux
root@8794a63812ce:/# exit
exit
```

```console
$ docker run --interactive --tty ilegeul/ubuntu:armhf-14.04
root@8c51e141d37f:/# lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 14.04 LTS
Release:	14.04
Codename:	trusty
root@8c51e141d37f:/# uname -a
Linux 8c51e141d37f 5.3.0-1014-raspi2 #14-Ubuntu SMP Tue Nov 26 11:18:23 UTC 2019 armv8l armv8l armv8l GNU/Linux
root@8c51e141d37f:/# exit
exit
```

## Publish

To publish, use:

```console
$ docker push "ilegeul/ubuntu:arm64-14.04"
$ docker push "ilegeul/ubuntu:armhf-14.04"
```
