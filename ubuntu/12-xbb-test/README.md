
## Build Docker images

There are several scripts:

- `amd64-build-v3.1.sh` -> `ilegeul/ubuntu:amd64-12.04-xbb-test-v3.1`
- `i386-build-v3.1.sh` -> `ilegeul/ubuntu:i386-12.04-xbb-test-v3.1`

```console
$ bash ~/Downloads/xpack-build-box.git/ubuntu/12-xbb-test/amd64-build-v3.2.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/12-xbb-test/i386-build-v3.2.sh

$ docker images
```

However the images are not generally necessary, the development builds
should be enough to test the XBB images.

## Development

During development, it is possible to run the build inside a container,
but with the Work folder on the host, to allow to resume an interrupted
build.

The following commands can be used to create the docker container
based on the xbb image:

```console
$ bash ~/Downloads/xpack-build-box.git/ubuntu/12-xbb-test/amd64-run-with-image-v3.2.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/12-xbb-test/i386-run-with-image-v3.2.sh
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
$ docker run --interactive --tty ilegeul/ubuntu:amd64-12.04-xbb-test-v3.2
$ docker run --interactive --tty ilegeul/ubuntu:i386-12.04-xbb-test-v3.2
```

## Publish

Does not apply.
