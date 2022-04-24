
# 9-npm

## Build Docker images (experimental)

There are several scripts:

- `arm32v6-build-v1.sh` -> `ilegeul/rpi:arm32v6-9-npm-v1`

```sh
bash ${HOME}/Work/xpack-build-box.git/rpi/9-npm/arm32v6-build-v1.sh

docker images

REPOSITORY               TAG                      IMAGE ID       CREATED        SIZE
ilegeul/rpi              arm32v6-9-npm-v1         b6547e328ecb   6 hours ago    604MB
ilegeul/rpi              arm32v6-9                76a5471197a4   7 hours ago    275MB

```

The images are based on our own images (like `ilegeul/rpi:arm32v6-9`).

Note: the arm32v6 script requires a 32-bit Arm machine, on a 64-bit machine
nvm messes versions.

## Test

The following tests were performed on a Raspberry Pi OS
running on a Raspberry CM4 with 8 GB RAM.

```sh
docker run --interactive --tty ilegeul/ubuntu:arm32v6-9-npm-v1
```

## Publish

To publish, use:

```sh
docker push "ilegeul/ubuntu:arm32v6-9-npm-v1"
```
