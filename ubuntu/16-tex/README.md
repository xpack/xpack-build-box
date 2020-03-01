
## Build Docker images

There are several scripts:

- `amd64-build-v3.1.sh` -> `ilegeul/ubuntu:amd64-16.04-tex-v3.1`
- `i386-build-v3.1.sh` -> `ilegeul/ubuntu:i386-16.04-tex-v3.1`
- `arm64-build-v3.1.sh` -> `ilegeul/ubuntu:arm64-16.04-tex-v3.1`
- `armhf-build-v3.1.sh` -> `ilegeul/ubuntu:armhf-16.04-tex-v3.1`

```console
$ bash ~/Downloads/xpack-build-box.git/ubuntu/16-tex/amd64-build-v3.1.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/16-tex/i386-build-v3.1.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/16-tex/arm64-build-v3.1.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/16-tex/armhf-build-v3.1.sh

$ docker images
```

## Test

The following tests were performed on an Ubuntu Server
18.04 running on an Intel NUC.

```console
$ docker run --interactive --tty ilegeul/ubuntu:amd64-16.04-tex-v3.1
$ docker run --interactive --tty ilegeul/ubuntu:i386-16.04-tex-v3.1
$ docker run --interactive --tty ilegeul/ubuntu:arm64-16.04-tex-v3.1
$ docker run --interactive --tty ilegeul/ubuntu:armhf-16.04-tex-v3.1
```

## Publish

To publish, use:

```console
$ docker push "ilegeul/ubuntu:amd64-16.04-tex-v3.1"
$ docker push "ilegeul/ubuntu:i386-16.04-tex-v3.1"
$ docker push "ilegeul/ubuntu:arm64-16.04-tex-v3.1"
$ docker push "ilegeul/ubuntu:armhf-16.04-tex-v3.1"
```
