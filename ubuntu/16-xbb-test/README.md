
# 16-xbb-test

## Build Docker images

There are several scripts:

- `amd64-build-v3.3.sh` -> `ilegeul/ubuntu:amd64-16.04-xbb-test-v3.3`
- `i386-build-v3.3.sh` -> `ilegeul/ubuntu:i386-16.04-xbb-test-v3.3`
- `arm64v8-build-v3.3.sh` -> `ilegeul/ubuntu:arm64v8-16.04-xbb-test-v3.3`
- `arm32v7-build-v3.3.sh` -> `ilegeul/ubuntu:arm32v7-16.04-xbb-test-v3.3`

```sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-xbb-test/amd64-build-v3.3.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-xbb-test/i386-build-v3.3.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-xbb-test/arm64v8-build-v3.3.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-xbb-test/arm32v7-build-v3.3.sh

docker images
```

However the images are not generally necessary, the development builds
should be enough to test the XBB images.

## Development

During development, it is possible to run the build inside a container,
but with the Work folder on the host, to allow to resume an interrupted
build.

The following commands can be used to create the docker container
based on the xbb image:

```sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-xbb-test/amd64-run-with-image-v3.3.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-xbb-test/i386-run-with-image-v3.3.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-xbb-test/arm64v8-run-with-image-v3.3.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-xbb-test/arm32v7-run-with-image-v3.3.sh
```

Inside the container, run the build script:

```console
# bash /input/build-v3.sh
# RUN_LONG_TESTS=y bash /input/build-v3.sh
```

There are several environment variables that can be passed to the script:

```console
# JOBS=1 bash /input/build-v3.sh
# DEBUG=-x bash /input/build-v3.sh
```

## Test

The following tests were performed on a Debian 10
running on an Intel NUC.

```sh
docker run --interactive --tty ilegeul/ubuntu:amd64-16.04-xbb-test-v3.3
docker run --interactive --tty ilegeul/ubuntu:i386-16.04-xbb-test-v3.3
```

The following tests were performed on a Raspberry Pi OS
running on a Raspberry CM4 with 8 GB RAM.

```console
docker run --interactive --tty ilegeul/ubuntu:arm64v8-16.04-xbb-test-v3.3
docker run --interactive --tty ilegeul/ubuntu:arm32v7-16.04-xbb-test-v3.3
```

## Publish

Does not apply.
