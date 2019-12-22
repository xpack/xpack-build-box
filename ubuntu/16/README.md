
## The root file systems

The Arm root file systems were created with `debootstrap` on an Ubuntu Server
18.04 running on a Raspberry Pi 4B.

```console
$ sudo apt install debootstrap
```

The Ubuntu 16 (xenial) distribution binaries are available
from the current ports server http://ports.ubuntu.com/.

```console
$ mkdir -p $HOME/tmp/arm64-ubu16-rootfs
$ sudo debootstrap --verbose --arch=arm64 xenial $HOME/tmp/arm64-ubu16-rootfs http://ports.ubuntu.com/
$ sudo tar cJvf $HOME/tmp/arm64-ubu16-rootfs.xz -C $HOME/tmp/arm64-ubu16-rootfs .
```

```console
$ mkdir -p $HOME/tmp/armhf-ubu16-rootfs
$ sudo debootstrap --verbose --arch=armhf xenial $HOME/tmp/armhf-ubu16-rootfs http://ports.ubuntu.com/
$ sudo tar cJvf $HOME/tmp/armhf-ubu16-rootfs.xz -C $HOME/tmp/armhf-ubu16-rootfs .
```
The result are two archives that were published at 
https://github.com/xpack/xpack-build-box/releases/download/rootfs/:

- https://github.com/xpack/xpack-build-box/releases/download/rootfs/arm64-ubu16-rootfs.xz
- https://github.com/xpack/xpack-build-box/releases/download/rootfs/armhf-ubu16-rootfs.xz

## Build Docker images

There are two scripts:

- `arm64-build.sh` -> `ilegeul/ubuntu:arm64-16.04`
- `armhf-build.sh` -> `ilegeul/ubuntu:armhf-16.04`

```console
$ bash ~/Downloads/xpack-build-box.git/ubuntu/16/arm64-build.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/16/armhf-build.sh

$ docker images
```

## Test

The test was performed on a macOS.

```console
$ docker run --interactive --tty ilegeul/ubuntu:arm64-16.04
root@8794a63812ce:/# lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 16.04 LTS
Release:	16.04
Codename:	xenial
root@8794a63812ce:/# uname -a
Linux 8794a63812ce 5.3.0-1014-raspi2 #16-Ubuntu SMP Tue Nov 26 11:18:23 UTC 2019 aarch64 aarch64 aarch64 GNU/Linux
root@8794a63812ce:/# exit
exit
```

```console
$ docker run --interactive --tty ilegeul/ubuntu:armhf-16.04
root@8c51e141d37f:/# lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 16.04 LTS
Release:	16.04
Codename:	xenial
root@8c51e141d37f:/# uname -a
Linux 8c51e141d37f 5.3.0-1014-raspi2 #16-Ubuntu SMP Tue Nov 26 11:18:23 UTC 2019 armv8l armv8l armv8l GNU/Linux
root@8c51e141d37f:/# exit
exit
```

## Publish

To publish, use:

```console
$ docker push "ilegeul/ubuntu:arm64-16.04"
$ docker push "ilegeul/ubuntu:armhf-16.04"
```
