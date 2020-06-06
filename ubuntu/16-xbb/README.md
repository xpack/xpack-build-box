
## Build Docker images

There are several scripts:

- `amd64-build-v3.2.sh` -> `ilegeul/ubuntu:amd64-16.04-xbb-v3.2`
- `i386-build-v3.2.sh` -> `ilegeul/ubuntu:i386-16.04-xbb-v3.2`
- `arm64v8-build-v3.2.sh` -> `ilegeul/ubuntu:arm64v8-16.04-xbb-v3.2`
- `arm32v7-build-v3.2.sh` -> `ilegeul/ubuntu:arm32v7-16.04-xbb-v3.2`

```console
$ bash ~/Downloads/xpack-build-box.git/ubuntu/16-xbb/amd64-build-v3.2.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/16-xbb/i386-build-v3.2.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/16-xbb/arm64v8-build-v3.2.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/16-xbb/arm32v7-build-v3.2.sh

$ docker images
```

## Development

During development, it is possible to run the build inside a container,
but with the Work folder on the host, to allow to resume an interrupted
build.

The following commands can be used to create the docker container
based on the bootstrap image:

```console
$ bash ~/Downloads/xpack-build-box.git/ubuntu/16-xbb/amd64-run-with-image-v3.2.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/16-xbb/i386-run-with-image-v3.2.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/16-xbb/arm64v8-run-with-image-v3.2.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/16-xbb/arm32v7-run-with-image-v3.2.sh
```

The following commands can be used to create the docker container
with the bootstrap also mounted from the host:

```console
$ bash ~/Downloads/xpack-build-box.git/ubuntu/16-xbb/amd64-run-with-volume-v3.2.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/16-xbb/i386-run-with-volume-v3.2.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/16-xbb/arm64v8-run-with-volume-v3.2.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/16-xbb/arm32v7-run-with-volume-v3.2.sh
```

Inside the container, run the build script:

```console
# RUN_LONG_TESTS=y bash /input/build-v3.sh
```

There are several environment variables that can be passed to the script:

```console
# JOBS=1 bash /input/build-v3.sh
# DEBUG=-x bash /input/build-v3.sh
```

## Test

The following tests were performed on an Ubuntu Server
18.04 running on an Intel NUC.

```console
$ docker run --interactive --tty ilegeul/ubuntu:amd64-16.04-xbb-v3.2
$ docker run --interactive --tty ilegeul/ubuntu:i386-16.04-xbb-v3.2
```

The following tests were performed on an Debian 9
running on a ROCK Pi.

```console
$ docker run --interactive --tty ilegeul/ubuntu:arm64v8-16.04-xbb-v3.2
$ docker run --interactive --tty ilegeul/ubuntu:arm32v7-16.04-xbb-v3.2
```

## Publish

To publish, use:

```console
$ docker push "ilegeul/ubuntu:amd64-16.04-xbb-v3.2"
$ docker push "ilegeul/ubuntu:i386-16.04-xbb-v3.2"
$ docker push "ilegeul/ubuntu:arm64v8-16.04-xbb-v3.2"
$ docker push "ilegeul/ubuntu:arm32v7-16.04-xbb-v3.2"
```
