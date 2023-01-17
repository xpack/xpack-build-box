
# 10-xbb

## Build Docker images

There are several scripts:

- `build-v5.0.0.sh`

```sh
bash ~/Work/xpack-build-box.git/debian/10-xbb/build-v5.0.0.sh

docker images
```

## Test

The following tests were performed on a Debian 11
running on an GIGABYTE motherboard with AMD 5600G.

```sh
docker run --interactive --tty ilegeul/debian:amd64-10-xbb-v5.0.0
```

The following tests were performed on two Raspberry Pi
running Raspberry Pi OS 64/32:

```sh
docker run --interactive --tty ilegeul/debian:arm64v8-10-xbb-v5.0.0
docker run --interactive --tty ilegeul/debian:arm32v7-10-xbb-v5.0.0
```

## Publish

To publish, use:

```sh
docker push "ilegeul/debian:amd64-10-xbb-v5.0.0"

docker push "ilegeul/debian:arm64v8-10-xbb-v5.0.0"
docker push "ilegeul/debian:arm32v7-10-xbb-v5.0.0"
```

## Notes

The unpublished 3.4.1 version, directly derived from 3.4,
was a failed attempt to fix the GCC tests by updating wine to 7.15.
