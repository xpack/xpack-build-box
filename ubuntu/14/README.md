
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
https://github.com/xpack/xpack-build-box/releases/tag/rootfs/

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
$ docker run --interactive --tty ilegeul/ubuntu:armhf-14.04
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
$ docker push "ilegeul/ubuntu:arm64-14.04"
$ docker push "ilegeul/ubuntu:armhf-14.04"
```
