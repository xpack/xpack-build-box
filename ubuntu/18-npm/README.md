
# 18-npm

## Build Docker images (experimental)

There are several scripts:

- `amd64-build-v1.sh` -> `ilegeul/ubuntu:amd64-18.04-npm-v1`
- no i386 support
- `arm64v8-build-v1.sh` -> `ilegeul/ubuntu:arm64v8-18.04-npm-v1`
- `arm32v7-build-v1.sh` -> `ilegeul/ubuntu:arm32v7-18.04-npm-v1`

```sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-npm/amd64-build-v1.sh

bash ~/Downloads/xpack-build-box.git/ubuntu/18-npm/arm64v8-build-v1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-npm/arm32v7-build-v1.sh

docker images

REPOSITORY       TAG                    IMAGE ID       CREATED          SIZE
ilegeul/ubuntu   amd64-18.04-npm-v1     1dd88287986c   3 minutes ago    464MB
ilegeul/ubuntu   arm64v8-18.04-npm-v1   287142edf484   12 minutes ago   491MB
ilegeul/ubuntu   arm32v7-18.04-npm-v1   67417d00a35e   14 minutes ago   437MB

```

Note: the arm32v7 script requires a 32-bit Arm machine, on a 64-bit machine
nvm messes versions.

## Test

The following tests were performed on a Debian 10
running on an Intel NUC.

```sh
docker run --interactive --tty ilegeul/ubuntu:amd64-18.04-npm-v1
```

The following tests were performed on a Raspberry Pi OS
running on a Raspberry CM4 with 8 GB RAM.

```sh
docker run --interactive --tty ilegeul/ubuntu:arm64v8-18.04-npm-v1
docker run --interactive --tty ilegeul/ubuntu:arm32v7-18.04-npm-v1
```

## Publish

To publish, use:

```sh
docker push "ilegeul/ubuntu:amd64-18.04-npm-v1"

docker push "ilegeul/ubuntu:arm64v8-18.04-npm-v1"
docker push "ilegeul/ubuntu:arm32v7-18.04-npm-v1"
```
