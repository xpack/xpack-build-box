
# 9-develop

## Build Docker images

There are several scripts:

- `arm32v6-build-v3.4.sh` -> `ilegeul/rpi:arm32v6-9-develop-v3.4`

```sh
bash ${HOME}/Work/xpack-build-box.git/rpi/9-develop/arm32v6-build-v3.4.sh

docker images
```

FAILURE!:
E: Unable to locate package gcc-8
E: Unable to locate package g++-8

END OF GAME

## Test

The following tests were performed on a Raspberry Pi OS
running on a Raspberry CM4 with 8 GB RAM.

```sh
docker run --interactive --tty ilegeul/ubuntu:arm32v6-9-develop-v3.4
```

## Publish

To publish, use:

```sh
docker push "ilegeul/ubuntu:arm32v6-9-develop-v3.4"
```
