
## Build Docker images

There are two scripts:

- `amd64-build-v3.1.sh` -> `ilegeul/ubuntu:amd64-12.04-xbb-v3.1`
- `i386-build-v3.1.sh` -> `ilegeul/ubuntu:i386-12.04-xbb-v3.1`

```console
$ bash ~/Downloads/xpack-build-box.git/ubuntu/12-xbb/amd64-build-v3.1.sh
$ bash ~/Downloads/xpack-build-box.git/ubuntu/12-xbb/i386-build-v3.1.sh

$ docker images
```

As a shortcut, macOS users can double click the `.command` files in Finder.

## Test

The test was performed on a macOS.

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
