
# 18-node

## Build Docker images

There are several scripts, with respective node LTS versions:

- `build-v16.18.0.sh`

```sh
bash ~/Work/xpack-build-box.git/ubuntu/18-node/build-v16.18.0.sh

docker images

REPOSITORY       TAG                    IMAGE ID       CREATED          SIZE
ilegeul/ubuntu   amd64-18.04-node-v16.18.0     1dd88287986c   3 minutes ago    464MB
ilegeul/ubuntu   arm64v8-18.04-node-v16.18.0   287142edf484   12 minutes ago   491MB
ilegeul/ubuntu   arm32v7-18.04-node-v16.18.0   67417d00a35e   14 minutes ago   437MB

```

The images are based on the official `ubuntu:18.04` images.

Note: the arm32v7 script requires a 32-bit Arm machine.

## Test

The following tests were performed on a Debian 10
running on an Intel NUC.

```sh
docker run --interactive --tty ilegeul/ubuntu:amd64-18.04-node-v16.18.0
```

The following tests were performed on a Raspberry Pi OS
running on a Raspberry CM4 with 8 GB RAM.

```sh
docker run --interactive --tty ilegeul/ubuntu:arm64v8-18.04-node-v16.18.0
docker run --interactive --tty ilegeul/ubuntu:arm32v7-18.04-node-v16.18.0
```

## Publish

To publish, use:

```sh
docker push "ilegeul/ubuntu:amd64-18.04-node-v16.18.0"

docker push "ilegeul/ubuntu:arm64v8-18.04-node-v16.18.0"
docker push "ilegeul/ubuntu:arm32v7-18.04-node-v16.18.0"
```
