
## Build Docker images

There are several scripts:

- `amd64-build-v4.1.sh` -> `ilegeul/centos:amd64-7-develop-v4.1`
- `i386-build-v4.1.sh` -> `ilegeul/centos:i386-7-develop-v4.1`
- `arm64v8-build-v4.1.sh` -> `ilegeul/centos:arm64v8-7-develop-v4.1`
- `arm32v7-build-v4.1.sh` -> `ilegeul/centos:arm32v7-7-develop-v4.1`

```console
$ bash ~/Downloads/xpack-build-box.git/centos/7-develop/amd64-build-v4.1.sh
$ bash ~/Downloads/xpack-build-box.git/centos/7-develop/i386-build-v4.1.sh
$ bash ~/Downloads/xpack-build-box.git/centos/7-develop/arm64v8-build-v4.1.sh
$ bash ~/Downloads/xpack-build-box.git/centos/7-develop/arm32v7-build-v4.1.sh

$ docker images
```

## Test

The following tests were performed on an CentOS Server
18.04 running on an Intel NUC.

```console
$ docker run --interactive --tty ilegeul/centos:amd64-7-develop-v4.1
$ docker run --interactive --tty ilegeul/centos:i386-7-develop-v4.1
```

The following tests were performed on a Debian 9
running on a ROCK Pi 4.

```console
$ docker run --interactive --tty ilegeul/centos:arm64v8-7-develop-v4.1
$ docker run --interactive --tty ilegeul/centos:arm32v7-7-develop-v4.1
```

## Publish

To publish, use:

```console
$ docker push "ilegeul/centos:amd64-7-develop-v4.1"
$ docker push "ilegeul/centos:i386-7-develop-v4.1"
$ docker push "ilegeul/centos:arm64v8-7-develop-v4.1"
$ docker push "ilegeul/centos:arm32v7-7-develop-v4.1"
```
