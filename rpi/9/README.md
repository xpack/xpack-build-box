# 9

## The root file systems

The Arm root file systems were created with `debootstrap` on a
Raspberry Pi OS 32 running on a Raspberry Pi 4B.

```sh
sudo apt install --yes debootstrap
```

The Arm Raspbian 9 (stretch) distribution binaries are available
from the ports server http://archive.raspbian.org/raspbian/.

```sh
rm -rf "${HOME}/Work/arm32v6-rpi9-rootfs"
mkdir -pv "${HOME}/Work/arm32v6-rpi9-rootfs"
sudo debootstrap --verbose --arch=armhf --variant=minbase stretch "${HOME}/Work/arm32v6-rpi9-rootfs" http://archive.raspbian.org/raspbian/
sudo tar cJvf "${HOME}/Work/arm32v6-rpi9-rootfs.xz" -C "${HOME}/Work/arm32v6-rpi9-rootfs" .
```

The result are several archives that were published at
https://github.com/xpack/xpack-build-box/releases/tag/rootfs/

- https://github.com/xpack/xpack-build-box/releases/download/rootfs/arm32v6-rpi9-rootfs.xz

## Build Docker images

There are several scripts:

- `arm32v6-build.sh` -> `ilegeul/rpi:arm32v6-9`

```sh
bash ${HOME}/Work/xpack-build-box.git/rpi/9/arm32v6-build.sh

docker images
```

## Test

The following tests were performed on a
Raspberry Pi OS 32 running on a Raspberry Pi 4B.

```console
$ docker run --interactive --tty ilegeul/rpi:arm32v6-9
root@87feafbdbf4c:/# apt-get install -y lsb-release
root@87feafbdbf4c:/# lsb_release -a
No LSB modules are available.
Distributor ID:	Raspbian
Description:	Raspbian GNU/Linux 9.13 (stretch)
Release:	9.13
Codename:	stretch
root@87feafbdbf4c:/# uname -a
Linux 87feafbdbf4c 5.15.32-v7l+ #1538 SMP Thu Mar 31 19:39:41 BST 2022 armv7l GNU/Linux
root@87feafbdbf4c:/#
exit
```

## Publish

To publish, use:

```sh
docker push "ilegeul/rpi:arm32v6-9"
```
