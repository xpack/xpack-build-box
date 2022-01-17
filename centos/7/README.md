
## Build Docker images

There are several scripts:

- `amd64-build.sh` -> `ilegeul/centos:amd64-7.8`
- `i386-build.sh` -> `ilegeul/centos:i386-7.8`
- `arm64v8-build.sh` -> `ilegeul/centos:arm64v8-7.8`
- `arm32v7-build.sh` -> `ilegeul/centos:arm32v7-7.8`

```console
$ bash ${HOME}/Work/xpack-build-box.git/centos/7/amd64-build.sh
$ bash ${HOME}/Work/xpack-build-box.git/centos/7/i386-build.sh
$ bash ${HOME}/Work/xpack-build-box.git/centos/7/arm64v8-build.sh
$ bash ${HOME}/Work/xpack-build-box.git/centos/7/arm32v7-build.sh

$ docker images
```

## Test

The following tests were performed on an Ubuntu Server
18.04 running on an Intel NUC.

```console
$ docker run --interactive --tty ilegeul/centos:amd64-7.8
root@9096a2fdd659:/# apt-get install -y lsb-release
root@9096a2fdd659:/# lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 7.8 LTS
Release:	7.8
Codename:	xenial
root@9096a2fdd659:/# uname -a
Linux 9096a2fdd659 5.3.0-40-generic #32~18.04.1-Ubuntu SMP Mon Feb 3 14:05:59 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux
root@9096a2fdd659:/# exit
exit
```

```console
$ docker run --interactive --tty ilegeul/centos:i386-7.8
root@556059ae4b51:/# apt-get install -y lsb-release
root@556059ae4b51:/# lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 7.8 LTS
Release:	7.8
Codename:	xenial
root@556059ae4b51:/# uname -a
Linux 556059ae4b51 5.3.0-40-generic #32~18.04.1-Ubuntu SMP Mon Feb 3 14:05:59 UTC 2020 i686 i686 i686 GNU/Linux
root@556059ae4b51:/# exit
exit
```

The following tests were performed on an Debian 9
running on a ROCK Pi 4.

```console
$ docker run --interactive --tty ilegeul/centos:arm64v8-7.8
[root@d8b3605db2d2 /]# yum -y install redhat-lsb-core
...
[root@d8b3605db2d2 /]# lsb_release -a
LSB Version:	:core-4.1-aarch64:core-4.1-noarch
Distributor ID:	CentOS
Description:	CentOS Linux release 7.8.2003 (AltArch)
Release:	7.8.2003
Codename:	AltArch
[root@d8b3605db2d2 /]# uname -a
Linux d8b3605db2d2 4.19.76-linuxkit #1 SMP Tue May 26 11:42:35 UTC 2020 aarch64 aarch64 aarch64 GNU/Linux
[root@d8b3605db2d2 /]# exit
exit
```

```console
$ docker run --interactive --tty ilegeul/centos:arm32v7-7.8
root@7ec385ddeb43:/# apt-get install -y lsb-release
root@7ec385ddeb43:/# lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 7.8 LTS
Release:	7.8
Codename:	xenial
root@7ec385ddeb43:/# uname -a
Linux 7ec385ddeb43 5.3.0-1018-raspi2 #20-Ubuntu SMP Mon Feb 3 19:45:46 UTC 2020 armv8l armv8l armv8l GNU/Linux
root@7ec385ddeb43:/# exit
exit
```

## Publish

To publish, use:

```console
$ docker push "ilegeul/centos:amd64-7.8"
$ docker push "ilegeul/centos:i386-7.8"
$ docker push "ilegeul/centos:arm64v8-7.8"
$ docker push "ilegeul/centos:arm32v7-7.8"
```
