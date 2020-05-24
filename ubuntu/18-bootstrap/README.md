
## Build Docker images

There are several scripts:

- `amd64-build-v3.1.sh` -> `ilegeul/ubuntu:amd64-18.04-bootstrap-v3.1`
- `i386-build-v3.1.sh` -> `ilegeul/ubuntu:i386-18.04-bootstrap-v3.1`
- `arm64v8-build-v3.1.sh` -> `ilegeul/ubuntu:arm64v8-18.04-bootstrap-v3.1`
- `arm32v7-build-v3.1.sh` -> `ilegeul/ubuntu:arm32v7-18.04-bootstrap-v3.1`

```console
$ bash ~/Downloads/xpack-build-box.git/ubuntu/18-bootstrap/amd64-build-v3.1.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/18-bootstrap/i386-build-v3.1.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/18-bootstrap/arm64v8-build-v3.1.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/18-bootstrap/arm32v7-build-v3.1.sh

$ bash ~/Downloads/xpack-build-box.git/ubuntu/18-bootstrap/amd64-build-v3.2.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/18-bootstrap/i386-build-v3.2.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/18-bootstrap/arm64v8-build-v3.2.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/18-bootstrap/arm32v7-build-v3.2.sh

$ docker images
```

## Development

During development, it is possible to run the build inside a container,
but with the Work folder on the host, to allow to resume an interrupted
build.

The following commands can be used to create the docker container:

```console
$ bash ~/Downloads/xpack-build-box.git/ubuntu/18-bootstrap/amd64-run-v3.1.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/18-bootstrap/i386-run-v3.1.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/18-bootstrap/arm64v8-run-v3.1.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/18-bootstrap/arm32v7-run-v3.1.sh

$ bash ~/Downloads/xpack-build-box.git/ubuntu/18-bootstrap/amd64-run-v3.2.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/18-bootstrap/i386-run-v3.2.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/18-bootstrap/arm64v8-run-v3.2.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/18-bootstrap/arm32v7-run-v3.2.sh
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

The following tests were performed on an Ubuntu Server
18.04 running on an Intel NUC.

```console
$ docker run --interactive --tty ilegeul/ubuntu:amd64-18.04-bootstrap-v3.1
$ docker run --interactive --tty ilegeul/ubuntu:i386-18.04-bootstrap-v3.1

$ docker run --interactive --tty ilegeul/ubuntu:amd64-18.04-bootstrap-v3.2
$ docker run --interactive --tty ilegeul/ubuntu:i386-18.04-bootstrap-v3.2
```

The following tests were performed on an Ubuntu Server
18.04 running on a Raspberry Pi 4B.

```console
$ docker run --interactive --tty ilegeul/ubuntu:arm64v8-18.04-bootstrap-v3.1
$ docker run --interactive --tty ilegeul/ubuntu:arm32v7-18.04-bootstrap-v3.1

$ docker run --interactive --tty ilegeul/ubuntu:arm64v8-18.04-bootstrap-v3.2
$ docker run --interactive --tty ilegeul/ubuntu:arm32v7-18.04-bootstrap-v3.2
```

## Publish

To publish, use:

```console
$ docker push "ilegeul/ubuntu:amd64-18.04-bootstrap-v3.1"
$ docker push "ilegeul/ubuntu:i386-18.04-bootstrap-v3.1"
$ docker push "ilegeul/ubuntu:arm64v8-18.04-bootstrap-v3.1"
$ docker push "ilegeul/ubuntu:arm32v7-18.04-bootstrap-v3.1"

$ docker push "ilegeul/ubuntu:amd64-18.04-bootstrap-v3.2"
$ docker push "ilegeul/ubuntu:i386-18.04-bootstrap-v3.2"
$ docker push "ilegeul/ubuntu:arm64v8-18.04-bootstrap-v3.2"
$ docker push "ilegeul/ubuntu:arm32v7-18.04-bootstrap-v3.2"
```
