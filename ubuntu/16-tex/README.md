
# 16-tex

## Build Docker images

There are several scripts:

- `amd64-build-v3.3.sh` -> `ilegeul/ubuntu:amd64-16.04-tex-v3.3`
- `i386-build-v3.3.sh` -> `ilegeul/ubuntu:i386-16.04-tex-v3.3`
- `arm64v8-build-v3.3.sh` -> `ilegeul/ubuntu:arm64v8-16.04-tex-v3.3`
- `arm32v7-build-v3.3.sh` -> `ilegeul/ubuntu:arm32v7-16.04-tex-v3.3`

```sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-tex/amd64-build-v3.3.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-tex/i386-build-v3.3.sh

bash ~/Downloads/xpack-build-box.git/ubuntu/16-tex/arm64v8-build-v3.3.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-tex/arm32v7-build-v3.3.sh

docker images
```

## Development

During development, it is possible to run the build inside a container,
but with the Work folder on the host, to allow to resume an interrupted
build.

The following commands can be used to create the docker container:

```sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-tex/amd64-run-with-image-v3.3.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-tex/i386-run-with-image-v3.3.sh

bash ~/Downloads/xpack-build-box.git/ubuntu/16-tex/arm64v8-run-with-image-v3.3.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-tex/arm32v7-run-with-image-v3.3.sh
```

Inside the container, run the build script:

```console
# bash /input/build-v3.sh 2021 medium
# bash /input/build-v3.sh 2021 basic
```

## Test

The following tests were performed on an Debian 10
running on an Intel NUC.

```sh
docker run --interactive --tty ilegeul/ubuntu:amd64-16.04-tex-v3.3
docker run --interactive --tty ilegeul/ubuntu:i386-16.04-tex-v3.3
```

The following tests were performed on a Raspberry Pi OS
running on a Raspberry CM4 with 8 GB RAM.

```sh
docker run --interactive --tty ilegeul/ubuntu:arm64v8-16.04-tex-v3.3
docker run --interactive --tty ilegeul/ubuntu:arm32v7-16.04-tex-v3.3
```

Inside the container, run the build script:

```console
# bash /input/build-v3.sh 2021 medium
```

## Publish

To publish, use:

```sh
docker push "ilegeul/ubuntu:amd64-16.04-tex-v3.3"
docker push "ilegeul/ubuntu:i386-16.04-tex-v3.3"

docker push "ilegeul/ubuntu:arm64v8-16.04-tex-v3.3"
docker push "ilegeul/ubuntu:arm32v7-16.04-tex-v3.3"
```
