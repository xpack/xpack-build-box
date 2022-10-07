
# 18-xbb

## Build Docker images

There are several scripts:

- `amd64-build-v3.4.sh` -> `ilegeul/ubuntu:amd64-18.04-xbb-v3.4`
- no i386 support
- `arm64v8-build-v3.4.sh` -> `ilegeul/ubuntu:arm64v8-18.04-xbb-v3.4`
- `arm32v7-build-v3.4.sh` -> `ilegeul/ubuntu:arm32v7-18.04-xbb-v3.4`

```sh
bash ${HOME}/Work/xpack-build-box.git/ubuntu/18-xbb/amd64-build-v3.4.sh

bash ${HOME}/Work/xpack-build-box.git/ubuntu/18-xbb/arm64v8-build-v3.4.sh
bash ${HOME}/Work/xpack-build-box.git/ubuntu/18-xbb/arm32v7-build-v3.4.sh

docker images
```

## Test

The following tests were performed on a Debian 10
running on an Intel NUC.

```sh
docker run --interactive --tty ilegeul/ubuntu:amd64-18.04-xbb-v3.4
```

The following tests were performed on a Raspberry Pi OS
running on a Raspberry CM4 with 8 GB RAM.

```sh
docker run --interactive --tty ilegeul/ubuntu:arm64v8-18.04-xbb-v3.4
docker run --interactive --tty ilegeul/ubuntu:arm32v7-18.04-xbb-v3.4
```

## Publish

To publish, use:

```sh
docker push "ilegeul/ubuntu:amd64-18.04-xbb-v3.4"

docker push "ilegeul/ubuntu:arm64v8-18.04-xbb-v3.4"
docker push "ilegeul/ubuntu:arm32v7-18.04-xbb-v3.4"
```
