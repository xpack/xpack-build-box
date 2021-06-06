
# 16-tex

## Build Docker images

There are several scripts:

- `amd64-build-v3.1.sh` -> `ilegeul/ubuntu:amd64-16.04-tex-v3.1`
- `i386-build-v3.1.sh` -> `ilegeul/ubuntu:i386-16.04-tex-v3.1`
- `arm64v8-build-v3.1.sh` -> `ilegeul/ubuntu:arm64v8-16.04-tex-v3.1`
- `arm32v7-build-v3.1.sh` -> `ilegeul/ubuntu:arm32v7-16.04-tex-v3.1`

```sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-tex/amd64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-tex/i386-build-v3.1.sh

bash ~/Downloads/xpack-build-box.git/ubuntu/16-tex/arm64v8-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-tex/arm32v7-build-v3.1.sh

docker images
```

## Test

The following tests were performed on an Ubuntu Server
18.04 running on an Intel NUC.

```sh
docker run --interactive --tty ilegeul/ubuntu:amd64-16.04-tex-v3.1
docker run --interactive --tty ilegeul/ubuntu:i386-16.04-tex-v3.1
```

The following tests were performed on a Debian 9
running on a ROCK Pi 4.

```sh
docker run --interactive --tty ilegeul/ubuntu:arm64v8-16.04-tex-v3.1
docker run --interactive --tty ilegeul/ubuntu:arm32v7-16.04-tex-v3.1
```

## Publish

To publish, use:

```sh
docker push "ilegeul/ubuntu:amd64-16.04-tex-v3.1"
docker push "ilegeul/ubuntu:i386-16.04-tex-v3.1"

docker push "ilegeul/ubuntu:arm64v8-16.04-tex-v3.1"
docker push "ilegeul/ubuntu:arm32v7-16.04-tex-v3.1"
```
