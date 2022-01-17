# 18

## The root file systems

The Intel root file systems were created with `debootstrap` on an Ubuntu Server
18.04 running on an Intel NUC.

The Arm root file systems were created with `debootstrap` on an Ubuntu Server
18.04 running on a Raspberry Pi 4B.

```sh
sudo apt install debootstrap
```

The Intel Ubuntu 18 (bionic) distribution binaries are available
from the archive server http://archive.ubuntu.com/ubuntu/,
when the support period ends, they are moved to
http://old-releases.ubuntu.com/ubuntu/, see the Ubuntu 12 folder
on how to use them.

```sh
rm -rf "${HOME}/tmp/amd64-ubu18-rootfs"
mkdir -pv "${HOME}/tmp/amd64-ubu18-rootfs"
sudo debootstrap --verbose --arch=amd64 --variant=minbase bionic "${HOME}/tmp/amd64-ubu18-rootfs" http://archive.ubuntu.com/ubuntu/
sudo tar cJvf "${HOME}/tmp/amd64-ubu18-rootfs.xz" -C "${HOME}/tmp/amd64-ubu18-rootfs" .
```

```sh
rm -rf "${HOME}/tmp/i386-ubu18-rootfs"
mkdir -pv "${HOME}/tmp/i386-ubu18-rootfs"
sudo debootstrap --verbose --arch=i386 --variant=minbase bionic "${HOME}/tmp/i386-ubu18-rootfs" http://archive.ubuntu.com/ubuntu/
sudo tar cJvf "${HOME}/tmp/i386-ubu18-rootfs.xz" -C "${HOME}/tmp/i386-ubu18-rootfs" .
```

The Arm Ubuntu 18 (bionic) distribution binaries are available
from the ports server http://ports.ubuntu.com/.

```sh
rm -f "${HOME}/tmp/arm64v8-ubu18-rootfs"
mkdir -pv "${HOME}/tmp/arm64v8-ubu18-rootfs"
sudo debootstrap --verbose --arch=arm64 --variant=minbase bionic "${HOME}/tmp/arm64v8-ubu18-rootfs" http://ports.ubuntu.com/
sudo tar cJvf "${HOME}/tmp/arm64v8-ubu18-rootfs.xz" -C "${HOME}/tmp/arm64v8-ubu18-rootfs" .
```

```sh
rm -rf "${HOME}/tmp/arm32v7-ubu18-rootfs"
mkdir -pv "${HOME}/tmp/arm32v7-ubu18-rootfs"
sudo debootstrap --verbose --arch=armhf --variant=minbase bionic "${HOME}/tmp/arm32v7-ubu18-rootfs" http://ports.ubuntu.com/
sudo tar cJvf "${HOME}/tmp/arm32v7-ubu18-rootfs.xz" -C "${HOME}/tmp/arm32v7-ubu18-rootfs" .
```

The result are several archives that were published at
https://github.com/xpack/xpack-build-box/releases/tag/rootfs/

- https://github.com/xpack/xpack-build-box/releases/download/rootfs/amd64-ubu18-rootfs.xz
- https://github.com/xpack/xpack-build-box/releases/download/rootfs/i386-ubu18-rootfs.xz
- https://github.com/xpack/xpack-build-box/releases/download/rootfs/arm64v8-ubu18-rootfs.xz
- https://github.com/xpack/xpack-build-box/releases/download/rootfs/arm32v7-ubu18-rootfs.xz

## Build Docker images

There are several scripts:

- `amd64-build.sh` -> `ilegeul/ubuntu:amd64-18.04`
- `i386-build.sh` -> `ilegeul/ubuntu:i386-18.04`
- `arm64v8-build.sh` -> `ilegeul/ubuntu:arm64v8-18.04`
- `arm32v7-build.sh` -> `ilegeul/ubuntu:arm32v7-18.04`

```sh
bash ${HOME}/Work/xpack-build-box.git/ubuntu/18/amd64-build.sh
bash ${HOME}/Work/xpack-build-box.git/ubuntu/18/i386-build.sh
bash ${HOME}/Work/xpack-build-box.git/ubuntu/18/arm64v8-build.sh
bash ${HOME}/Work/xpack-build-box.git/ubuntu/18/arm32v7-build.sh

docker images
```

## Test

The following tests were performed on an Ubuntu Server
18.04 running on an Intel NUC.

```console
$ docker run --interactive --tty ilegeul/ubuntu:amd64-18.04
root@695f81dba033:/# apt-get install -y lsb-release
root@695f81dba033:/# lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 18.04 LTS
Release:	18.04
Codename:	bionic
root@695f81dba033:/# uname -a
Linux 695f81dba033 5.3.0-40-generic #32~18.04.1-Ubuntu SMP Mon Feb 3 14:05:59 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux
root@695f81dba033:/# exit
exit
```

```console
$ docker run --interactive --tty ilegeul/ubuntu:i386-18.04
root@e1e4eaf84a37:/# apt-get install -y lsb-release
root@e1e4eaf84a37:/# lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 18.04 LTS
Release:	18.04
Codename:	bionic
root@e1e4eaf84a37:/# uname -a
Linux e1e4eaf84a37 5.3.0-40-generic #32~18.04.1-Ubuntu SMP Mon Feb 3 14:05:59 UTC 2020 i686 i686 i686 GNU/Linux
root@e1e4eaf84a37:/# exit
exit
```

The following tests were performed on an Ubuntu Server
18.04 running on a Raspberry Pi 4B.

```console
$ docker run --interactive --tty ilegeul/ubuntu:arm64v8-18.04
root@f57a7ff91fce:/# apt-get install -y lsb-release
root@f57a7ff91fce:/# lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 18.04 LTS
Release:	18.04
Codename:	bionic
root@f57a7ff91fce:/# uname -a
Linux f57a7ff91fce 5.3.0-1018-raspi2 #20-Ubuntu SMP Mon Feb 3 19:45:46 UTC 2020 aarch64 aarch64 aarch64 GNU/Linux
root@f57a7ff91fce:/# exit
exit
```

```console
$ docker run --interactive --tty ilegeul/ubuntu:arm32v7-18.04
root@7ec385ddeb43:/# apt-get install -y lsb-release
root@7ec385ddeb43:/# lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 18.04 LTS
Release:	18.04
Codename:	bionic
root@7ec385ddeb43:/# uname -a
Linux 7ec385ddeb43 5.3.0-1018-raspi2 #20-Ubuntu SMP Mon Feb 3 19:45:46 UTC 2020 armv8l armv8l armv8l GNU/Linux
root@7ec385ddeb43:/# exit
exit
```

## Publish

To publish, use:

```sh
docker push "ilegeul/ubuntu:amd64-18.04"
docker push "ilegeul/ubuntu:i386-18.04"
docker push "ilegeul/ubuntu:arm64v8-18.04"
docker push "ilegeul/ubuntu:arm32v7-18.04"
```
