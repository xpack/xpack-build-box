
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
```

## Test

The test was performed on a macOS.

```console
$ docker run --interactive --tty ilegeul/ubuntu:arm64-16.04
...
```

```console
$ docker run --interactive --tty ilegeul/ubuntu:armhf-16.04
...
```

## Publish

To publish, use:

```console
$ docker push "ilegeul/ubuntu:arm64-16.04"
$ docker push "ilegeul/ubuntu:armhf-16.04"
```
