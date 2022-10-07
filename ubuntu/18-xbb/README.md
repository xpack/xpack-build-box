
# 18-xbb

## Build Docker images

There are several scripts:

- `amd64-build-v4.0.sh` -> `ilegeul/ubuntu:amd64-18.04-xbb-v4.0`
- no i386 support
- `arm64v8-build-v4.0.sh` -> `ilegeul/ubuntu:arm64v8-18.04-xbb-v4.0`
- `arm32v7-build-v4.0.sh` -> `ilegeul/ubuntu:arm32v7-18.04-xbb-v4.0`

```sh
bash ${HOME}/Work/xpack-build-box.git/ubuntu/18-xbb/amd64-build-v4.0.sh

bash ${HOME}/Work/xpack-build-box.git/ubuntu/18-xbb/arm64v8-build-v4.0.sh
bash ${HOME}/Work/xpack-build-box.git/ubuntu/18-xbb/arm32v7-build-v4.0.sh

docker images
```

## Test

The following tests were performed on a Debian 11
running on an GIGABYTE motherboard with AMD 5600G.

```sh
docker run --interactive --tty ilegeul/ubuntu:amd64-18.04-xbb-v4.0
```

The following tests were performed on a Raspberry Pi OS
running on a Raspberry CM4 with 8 GB RAM.

```sh
docker run --interactive --tty ilegeul/ubuntu:arm64v8-18.04-xbb-v4.0
docker run --interactive --tty ilegeul/ubuntu:arm32v7-18.04-xbb-v4.0
```

## Publish

To publish, use:

```sh
docker push "ilegeul/ubuntu:amd64-18.04-xbb-v4.0"

docker push "ilegeul/ubuntu:arm64v8-18.04-xbb-v4.0"
docker push "ilegeul/ubuntu:arm32v7-18.04-xbb-v4.0"
```
