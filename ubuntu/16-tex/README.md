
## Build Docker images

There are two scripts:

- `arm64-build-v3.1.sh` -> `ilegeul/ubuntu:arm64-16.04-tex-v3.1`
- `armhf-build-v3.1.sh` -> `ilegeul/ubuntu:armhf-16.04-tex-v3.1`

```console
$ bash ~/Downloads/xpack-build-box.git/ubuntu/16-tex/arm64-build-v3.1.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/16-tex/armhf-build-v3.1.sh

$ docker images
```

## Test

The test was performed on a macOS.

```console
$ docker run --interactive --tty ilegeul/ubuntu:arm64-16.04-tex-v3.1
$ docker run --interactive --tty ilegeul/ubuntu:armhf-16.04-tex-v3.1
```

## Publish

To publish, use:

```console
$ docker push "ilegeul/ubuntu:arm64-16.04-tex-v3.1"
$ docker push "ilegeul/ubuntu:armhf-16.04-tex-v3.1"
```