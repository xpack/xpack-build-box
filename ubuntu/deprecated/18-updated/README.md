
# 18-updated

## Build Docker images

There are several scripts:

- `amd64-build-v3.3.sh` -> `ilegeul/ubuntu:amd64-18.04-updated-v3.3`
- `i386-build-v3.3.sh` -> `ilegeul/ubuntu:i386-18.04-updated-v3.3`
- `arm64v8-build-v3.3.sh` -> `ilegeul/ubuntu:arm64v8-18.04-updated-v3.3`
- `arm32v7-build-v3.3.sh` -> `ilegeul/ubuntu:arm32v7-18.04-updated-v3.3`

```sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-updated/amd64-build-v3.3.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-updated/i386-build-v3.3.sh

bash ~/Downloads/xpack-build-box.git/ubuntu/18-updated/arm64v8-build-v3.3.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-updated/arm32v7-build-v3.3.sh

docker images
```

## Test

The following tests were performed on a Debian 10
running on an Intel NUC.

```sh
docker run --interactive --tty ilegeul/ubuntu:amd64-18.04-updated-v3.3
docker run --interactive --tty ilegeul/ubuntu:i386-18.04-updated-v3.3
```

The following tests were performed on a Raspberry Pi OS
running on a Raspberry CM4 with 8 GB RAM.

```sh
docker run --interactive --tty ilegeul/ubuntu:arm64v8-18.04-updated-v3.3
docker run --interactive --tty ilegeul/ubuntu:arm32v7-18.04-updated-v3.3
```

## Publish

To publish, use:

```sh
docker push "ilegeul/ubuntu:amd64-18.04-updated-v3.3"
docker push "ilegeul/ubuntu:i386-18.04-updated-v3.3"

docker push "ilegeul/ubuntu:arm64v8-18.04-updated-v3.3"
docker push "ilegeul/ubuntu:arm32v7-18.04-updated-v3.3"
```
