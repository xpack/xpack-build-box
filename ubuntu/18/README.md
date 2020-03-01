
## The root file systems

The Arm root file systems were created with `debootstrap` on an Ubuntu Server
18.04 running on a Raspberry Pi 4B.

```console
$ sudo apt install debootstrap
```

The Ubuntu 18 (bionic) distribution binaries are available
from the current ports server http://ports.ubuntu.com/.

```console
$ mkdir -p "${HOME}/tmp/arm64-ubu18-rootfs"
$ sudo debootstrap --verbose --arch=arm64 --variant=minbase bionic "${HOME}/tmp/arm64-ubu18-rootfs" http://ports.ubuntu.com/
$ sudo tar cJvf "${HOME}/tmp/arm64-ubu18-rootfs.xz" -C "${HOME}/tmp/arm64-ubu18-rootfs" .
```

```console
$ mkdir -p "${HOME}/tmp/armhf-ubu18-rootfs"
$ sudo debootstrap --verbose --arch=armhf --variant=minbase bionic "${HOME}/tmp/armhf-ubu18-rootfs" http://ports.ubuntu.com/
$ sudo tar cJvf "${HOME}/tmp/armhf-ubu18-rootfs.xz" -C "${HOME}/tmp/armhf-ubu18-rootfs" .
```

The result are two archives that were published at
https://github.com/xpack/xpack-build-box/releases/tag/rootfs:

- https://github.com/xpack/xpack-build-box/releases/download/rootfs/arm64-ubu18-rootfs.xz
- https://github.com/xpack/xpack-build-box/releases/download/rootfs/armhf-ubu18-rootfs.xz

## Build Docker images

There are two scripts:

- `arm64-build.sh` -> `ilegeul/ubuntu:arm64-18.04`
- `armhf-build.sh` -> `ilegeul/ubuntu:armhf-18.04`

```console
$ bash ~/Downloads/xpack-build-box.git/ubuntu/18/arm64-build.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/18/armhf-build.sh

$ docker images
```

## Test

The test was performed on an Ubuntu Server 18.04 running on a Raspberry Pi 4B.

```console
$ docker run --interactive --tty ilegeul/ubuntu:arm64-18.04
root@8794a63812ce:/# lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 18.04 LTS
Release:	18.04
Codename:	bionic
root@8794a63812ce:/# uname -a
Linux 8794a63812ce 5.3.0-1014-raspi2 #18-Ubuntu SMP Tue Nov 26 11:18:23 UTC 2019 aarch64 aarch64 aarch64 GNU/Linux
root@8794a63812ce:/# exit
exit
```

```console
$ docker run --interactive --tty ilegeul/ubuntu:armhf-18.04
root@8c51e141d37f:/# lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 18.04 LTS
Release:	18.04
Codename:	bionic
root@8c51e141d37f:/# uname -a
Linux 8c51e141d37f 5.3.0-1014-raspi2 #18-Ubuntu SMP Tue Nov 26 11:18:23 UTC 2019 armv8l armv8l armv8l GNU/Linux
root@8c51e141d37f:/# exit
exit
```

## Publish

To publish, use:

```console
$ docker push "ilegeul/ubuntu:arm64-18.04"
$ docker push "ilegeul/ubuntu:armhf-18.04"
```
