
## Build Docker images

There are two scripts:

- `amd64-build-v3.1.sh` -> `ilegeul/ubuntu:amd64-18.04-xbb-v3.1`
- `i386-build-v3.1.sh` -> `ilegeul/ubuntu:i386-18.04-xbb-v3.1`
- `arm64v8-build-v3.1.sh` -> `ilegeul/ubuntu:arm64v8-18.04-xbb-v3.1`
- `arm32v7-build-v3.1.sh` -> `ilegeul/ubuntu:arm32v7-18.04-xbb-v3.1`

```console
$ bash ~/Downloads/xpack-build-box.git/ubuntu/18-xbb/amd64-build-v3.1.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/18-xbb/i386-build-v3.1.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/18-xbb/arm64v8-build-v3.1.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/18-xbb/arm32v7-build-v3.1.sh

$ docker images
```

## Test

The following tests were performed on an Ubuntu Server
18.04 running on an Intel NUC.

```console
$ docker run --interactive --tty ilegeul/ubuntu:amd64-18.04-xbb-v3.1
$ docker run --interactive --tty ilegeul/ubuntu:i386-18.04-xbb-v3.1
```

The following tests were performed on an Ubuntu Server
18.04 running on a Raspberry Pi 4B.

```console
$ docker run --interactive --tty ilegeul/ubuntu:arm64v8-18.04-xbb-v3.1
$ docker run --interactive --tty ilegeul/ubuntu:arm32v7-18.04-xbb-v3.1
```

## Publish

To publish, use:

```console
$ docker push "ilegeul/ubuntu:amd64-18.04-xbb-v3.1"
$ docker push "ilegeul/ubuntu:i386-18.04-xbb-v3.1"
$ docker push "ilegeul/ubuntu:arm64v8-18.04-xbb-v3.1"
$ docker push "ilegeul/ubuntu:arm32v7-18.04-xbb-v3.1"
```
