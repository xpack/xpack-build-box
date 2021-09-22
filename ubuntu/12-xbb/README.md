
# 12-xbb

## Build Docker images

There are several scripts:

- `amd64-build-v3.2.sh` -> `ilegeul/ubuntu:amd64-12.04-xbb-v3.2`
- `i386-build-v3.2.sh` -> `ilegeul/ubuntu:i386-12.04-xbb-v3.2`

- `amd64-build-v3.3.sh` -> `ilegeul/ubuntu:amd64-12.04-xbb-v3.3`
- `i386-build-v3.3.sh` -> `ilegeul/ubuntu:i386-12.04-xbb-v3.3`

```sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12-xbb/amd64-build-v3.2.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12-xbb/i386-build-v3.2.sh

bash ~/Downloads/xpack-build-box.git/ubuntu/12-xbb/amd64-build-v3.3.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12-xbb/i386-build-v3.3.sh

docker images
```

The two builds can be started in parallel and take about 180 minutes.

## Development

During development, it is possible to run the build inside a container,
but with the Work folder on the host, to allow to resume an interrupted
build.

The following commands can be used to create the docker container
based on the bootstrap image:

```sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12-xbb/amd64-run-with-image-v3.3.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12-xbb/i386-run-with-image-v3.3.sh
```

The following commands can be used to create the docker container
with the bootstrap also mounted from the host:

```sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12-xbb/amd64-run-with-volume-v3.3.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12-xbb/i386-run-with-volume-v3.3.sh
```

Inside the container, run the build script:

```console
# RUN_TESTS=n bash /input/build-v3.sh
# RUN_LONG_TESTS=y bash /input/build-v3.sh
```

There are several environment variables that can be passed to the script:

```console
# JOBS=1 bash /input/build-v3.sh
# DEBUG=-x bash /input/build-v3.sh
```

The two builds can be started in parallel and take about 200 minutes.

## Test

The following tests were performed on an Debian 10
running on an Intel NUC.

```sh
docker run --interactive --tty ilegeul/ubuntu:amd64-12.04-xbb-v3.3
docker run --interactive --tty ilegeul/ubuntu:i386-12.04-xbb-v3.3
```

## Publish

To publish, use:

```sh
docker push "ilegeul/ubuntu:amd64-12.04-xbb-v3.3"
docker push "ilegeul/ubuntu:i386-12.04-xbb-v3.3"
```
