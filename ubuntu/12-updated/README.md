
# 12-updated

## Build Docker images

There are several scripts:

- `amd64-build-v3.3.sh` -> `ilegeul/ubuntu:amd64-12.04-updated-v3.3`
- `i386-build-v3.3.sh` -> `ilegeul/ubuntu:i386-12.04-updated-v3.3`

```sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12-updated/amd64-build-v3.3.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12-updated/i386-build-v3.3.sh

docker images
```

## Test

The following tests were performed on an Debian 10
running on an Intel NUC.

```sh
docker run --interactive --tty ilegeul/ubuntu:amd64-12.04-updated-v3.3
docker run --interactive --tty ilegeul/ubuntu:i386-12.04-updated-v3.3
```

## Publish

To publish, use:

```sh
docker push "ilegeul/ubuntu:amd64-12.04-updated-v3.3"
docker push "ilegeul/ubuntu:i386-12.04-updated-v3.3"
```
