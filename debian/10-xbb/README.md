
# 10-xbb

## Build Docker images

There are several scripts:

- `build-v5.1.1.sh`

```sh
bash ~/Work/xpack-build-box.git/debian/10-xbb/build-v5.1.1.sh

docker images
```

## Test

The following tests were performed on a Debian 11
running on an GIGABYTE motherboard with AMD 5600G.

```sh
docker run --interactive --tty ilegeul/debian:amd64-10-xbb-v5.1.1
```

The following tests were performed on two Raspberry Pi
running Raspberry Pi OS 64/32:

```sh
docker run --interactive --tty ilegeul/debian:arm64v8-10-xbb-v5.1.1
docker run --interactive --tty ilegeul/debian:arm32v7-10-xbb-v5.1.1
```

## Publish

To publish, use:

```sh
docker push "ilegeul/debian:amd64-10-xbb-v5.1.1"

docker push "ilegeul/debian:arm64v8-10-xbb-v5.1.1"
docker push "ilegeul/debian:arm32v7-10-xbb-v5.1.1"
```

## Notes

This is currently an experimental build, to prepare for the next
release that will require Node 18.
