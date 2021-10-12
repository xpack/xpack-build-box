
# 18-xbb-bootstrap

## Build Docker images

There are several scripts:

- `amd64-build-v3.3.sh` -> `ilegeul/ubuntu:amd64-18.04-bootstrap-v3.3`
- `i386-build-v3.3.sh` -> `ilegeul/ubuntu:i386-18.04-bootstrap-v3.3`
- `arm64v8-build-v3.3.sh` -> `ilegeul/ubuntu:arm64v8-18.04-bootstrap-v3.3`
- `arm32v7-build-v3.3.sh` -> `ilegeul/ubuntu:arm32v7-18.04-bootstrap-v3.3`

```sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-xbb-bootstrap/amd64-build-v3.3.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-xbb-bootstrap/i386-build-v3.3.sh

bash ~/Downloads/xpack-build-box.git/ubuntu/18-xbb-bootstrap/arm64v8-build-v3.3.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-xbb-bootstrap/arm32v7-build-v3.3.sh

docker images
```

## Development

During development, it is possible to run the build inside a container,
but with the Work folder on the host, to allow to resume an interrupted
build.

The following commands can be used to create the docker container:

```sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-xbb-bootstrap/amd64-run-v3.3.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-xbb-bootstrap/i386-run-v3.3.sh

bash ~/Downloads/xpack-build-box.git/ubuntu/18-xbb-bootstrap/arm64v8-run-v3.3.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-xbb-bootstrap/arm32v7-run-v3.3.sh
```

Inside the container, run the build script:

```console
# RUN_LONG_TESTS=y bash /input/build-v3.sh
```

There are several other environment variables that can be passed to the script:

```console
# JOBS=1 bash /input/build-v3.sh
# DEBUG=-x bash /input/build-v3.sh
```

## Test

The following tests were performed on a Debian 10
running on an Intel NUC.

```sh
docker run --interactive --tty ilegeul/ubuntu:amd64-18.04-bootstrap-v3.3
docker run --interactive --tty ilegeul/ubuntu:i386-18.04-bootstrap-v3.3

docker run --interactive --tty ilegeul/ubuntu:amd64-18.04-xbb-bootstrap-v3.3
docker run --interactive --tty ilegeul/ubuntu:i386-18.04-xbb-bootstrap-v3.3
```

The following tests were performed on a Raspberry Pi OS
running on a Raspberry CM4 with 8 GB RAM.

```sh
docker run --interactive --tty ilegeul/ubuntu:arm64v8-18.04-bootstrap-v3.3
docker run --interactive --tty ilegeul/ubuntu:arm32v7-18.04-bootstrap-v3.3

docker run --interactive --tty ilegeul/ubuntu:arm64v8-18.04-xbb-bootstrap-v3.3
docker run --interactive --tty ilegeul/ubuntu:arm32v7-18.04-xbb-bootstrap-v3.3
```

## Publish

To publish, use:

```sh
docker push "ilegeul/ubuntu:amd64-18.04-bootstrap-v3.3"
docker push "ilegeul/ubuntu:i386-18.04-bootstrap-v3.3"

docker push "ilegeul/ubuntu:arm64v8-18.04-bootstrap-v3.3"
docker push "ilegeul/ubuntu:arm32v7-18.04-bootstrap-v3.3"
```
