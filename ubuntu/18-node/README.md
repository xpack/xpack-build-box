
# 18-node

## End-of-life notice

Node.js 18 LTS support ends on April 2025.
Node.js 16 LTS support ends on April 2024.

- <https://nodejs.org/en/about/previous-releases>

Node 18 does not run on Ubuntu 18!

## Build Docker images

There are several scripts, with respective node LTS versions:

- `build-v16.20.2.sh`
- `build-v16.18.0.sh`

```sh
bash ~/Work/xpack-build-box.git/ubuntu/18-node/build-v16.20.2.sh
```

```sh
bash ~/Work/xpack-build-box.git/ubuntu/18-node/build-v16.18.0.sh
```

The images are based on the official `ubuntu:18.04` images.

Note: the arm32v7 script requires a 32-bit Arm machine.

## Test

The following tests were performed on a Debian 10
running on an Intel NUC.

```sh
docker run --interactive --tty ilegeul/ubuntu:amd64-18.04-node-v16.20.2
```

```sh
docker run --interactive --tty ilegeul/ubuntu:amd64-18.04-node-v16.18.0
```

The following tests were performed on a Raspberry Pi OS
running on a Raspberry CM4 with 8 GB RAM.

```sh
docker run --interactive --tty ilegeul/ubuntu:arm64v8-18.04-node-v16.20.2
docker run --interactive --tty ilegeul/ubuntu:arm32v7-18.04-node-v16.20.2
```

```sh
docker run --interactive --tty ilegeul/ubuntu:arm64v8-18.04-node-v16.18.0
docker run --interactive --tty ilegeul/ubuntu:arm32v7-18.04-node-v16.18.0
```

## Publish

To publish, use:

```sh
docker push "ilegeul/ubuntu:amd64-18.04-node-v16.20.2"

docker push "ilegeul/ubuntu:arm64v8-18.04-node-v16.20.2"
docker push "ilegeul/ubuntu:arm32v7-18.04-node-v16.20.2"
```

```sh
docker push "ilegeul/ubuntu:amd64-18.04-node-v16.18.0"

docker push "ilegeul/ubuntu:arm64v8-18.04-node-v16.18.0"
docker push "ilegeul/ubuntu:arm32v7-18.04-node-v16.18.0"
```
