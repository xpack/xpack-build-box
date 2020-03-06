
## Build Docker images

There are several scripts:

- `amd64-build-v3.1.sh` -> `ilegeul/ubuntu:amd64-14.04-updated-v3.1`
- `i386-build-v3.1.sh` -> `ilegeul/ubuntu:i386-14.04-updated-v3.1`
- `arm64v8-build-v3.1.sh` -> `ilegeul/ubuntu:arm64v8-14.04-updated-v3.1`
- `arm32v7-build-v3.1.sh` -> `ilegeul/ubuntu:arm32v7-14.04-updated-v3.1`

```console
$ bash ~/Downloads/xpack-build-box.git/ubuntu/14-updated/amd64-build-v3.1.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/14-updated/i386-build-v3.1.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/14-updated/arm64v8-build-v3.1.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/14-updated/arm32v7-build-v3.1.sh

$ docker images
```

## Test

The following tests were performed on an Ubuntu Server
18.04 running on an Intel NUC.

```console
$ docker run --interactive --tty ilegeul/ubuntu:amd64-14.04-updated-v3.1
$ docker run --interactive --tty ilegeul/ubuntu:i386-14.04-updated-v3.1
```

The following tests were performed on an Ubuntu Server
18.04 running on a Raspberry Pi 4B.

```console
$ docker run --interactive --tty ilegeul/ubuntu:arm64v8-14.04-updated-v3.1
$ docker run --interactive --tty ilegeul/ubuntu:arm32v7-14.04-updated-v3.1
```

## Publish

To publish, use:

```console
$ docker push "ilegeul/ubuntu:amd64-14.04-updated-v3.1"
$ docker push "ilegeul/ubuntu:i386-14.04-updated-v3.1"
$ docker push "ilegeul/ubuntu:arm64v8-14.04-updated-v3.1"
$ docker push "ilegeul/ubuntu:arm32v7-14.04-updated-v3.1"
```
