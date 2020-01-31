
## Build Docker images

There are two scripts:

- `amd64-build-v3.1.sh` -> `ilegeul/ubuntu:amd64-12.04-develop-v3.1`
- `i386-build-v3.1.sh` -> `ilegeul/ubuntu:i386-12.04-develop-v3.1`

```console
$ bash ~/Downloads/xpack-build-box.git/ubuntu/12-develop/amd64-build-v3.1.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/12-develop/i386-build-v3.1.sh

$ docker images
```

## Test

The test was performed on a macOS.

```console
$ docker run --interactive --tty ilegeul/ubuntu:amd64-12.04-develop-v3.1
$ docker run --interactive --tty ilegeul/ubuntu:i386-12.04-develop-v3.1
```

## Publish

To publish, use:

```console
$ docker push "ilegeul/ubuntu:amd64-12.04-develop-v3.1"
$ docker push "ilegeul/ubuntu:i386-12.04-develop-v3.1"
```
