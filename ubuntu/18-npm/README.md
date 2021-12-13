
## Build Docker images (experimental)

There are several scripts:

- `amd64-build-v1.sh` -> `ilegeul/ubuntu:amd64-18.04-npm-v1`
- `i386-build-v1.sh` -> `ilegeul/ubuntu:i386-18.04-npm-v1`
- `arm64v8-build-v1.sh` -> `ilegeul/ubuntu:arm64v8-18.04-npm-v1`
- `arm32v7-build-v1.sh` -> `ilegeul/ubuntu:arm32v7-18.04-npm-v1`

```console
$ bash ~/Downloads/xpack-build-box.git/ubuntu/18-npm/amd64-build-v1.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/18-npm/i386-build-v1.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/18-npm/arm64v8-build-v1.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/18-npm/arm32v7-build-v1.sh

$ docker images
```

## Test

The following tests were performed on a Debian 10
running on an Intel NUC.

```console
$ docker run --interactive --tty ilegeul/ubuntu:amd64-18.04-npm-v1
$ docker run --interactive --tty ilegeul/ubuntu:i386-18.04-npm-v1
```

The following tests were performed on an Ubuntu Server
18.04 running on a Raspberry Pi 4B.

```console
$ docker run --interactive --tty ilegeul/ubuntu:arm64v8-18.04-npm-v1
$ docker run --interactive --tty ilegeul/ubuntu:arm32v7-18.04-npm-v1
```

## Publish

To publish, use:

```console
$ docker push "ilegeul/ubuntu:amd64-18.04-npm-v1"
$ docker push "ilegeul/ubuntu:i386-18.04-npm-v1"
$ docker push "ilegeul/ubuntu:arm64v8-18.04-npm-v1"
$ docker push "ilegeul/ubuntu:arm32v7-18.04-npm-v1"
```
