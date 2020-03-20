
## Build Docker images

There are several scripts:

- `amd64-build-v3.1.sh` -> `ilegeul/ubuntu:amd64-12.04-xbb-v3.1`
- `i386-build-v3.1.sh` -> `ilegeul/ubuntu:i386-12.04-xbb-v3.1`

```console
$ bash ~/Downloads/xpack-build-box.git/ubuntu/12-xbb/amd64-build-v3.1.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/12-xbb/i386-build-v3.1.sh

$ docker images
```

## Development

During development, it is possible to run the build inside a container,
but with the Work folder on the host, to allow to resume an interrupted
build.

The following commands can be used to create the docker container
based on the bootstrap image:

```console
$ bash ~/Downloads/xpack-build-box.git/ubuntu/12-xbb/amd64-run-bs-v3.1.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/12-xbb/i386-run-bs-v3.1.sh
```

The following commands can be used to create the docker container
with the bootstrap also mounted from the host:

```console
$ bash ~/Downloads/xpack-build-box.git/ubuntu/12-xbb/amd64-run-v3.1.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/12-xbb/i386-run-v3.1.sh
```

Inside the container, run the build script:

```console
# bash /input/build-v3.1.s
```

## Test

The following tests were performed on an Ubuntu Server
18.04 running on an Intel NUC.

```console
$ docker run --interactive --tty ilegeul/ubuntu:amd64-12.04-xbb-v3.1
$ docker run --interactive --tty ilegeul/ubuntu:i386-12.04-xbb-v3.1
```

## Publish

To publish, use:

```console
$ docker push "ilegeul/ubuntu:amd64-12.04-xbb-v3.1"
$ docker push "ilegeul/ubuntu:i386-12.04-xbb-v3.1"
```
