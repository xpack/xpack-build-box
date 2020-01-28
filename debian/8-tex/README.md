## 8-tex

### Overview

Dockerfile to create a Docker image based on the Debian 8 image and TexLive.

### Changes

None.

To use the new tools, add `/opt/texlive/bin/<arch>` to the path.

### Developer

#### Create

To create the Docker image locally, use:

```console
$ cd ...
$ docker build --tag "ilegeul/debian:8-tex-v1.1" -f Dockerfile-v1.1 .
```

On macOS, to prevent entering sleep, use:

```console
$ caffeinate docker build --tag "ilegeul/debian:8-tex-v1.1" -f Dockerfile-v1.1 .
```

#### Test

To test the image:

```console
$ docker run --interactive --tty ilegeul/debian:8-tex-v1.1
```

#### Publish

To publish, use:

```console
$ docker push "ilegeul/debian:8-tex-v1.1"
```

#### Copy & Paste

```bash
caffeinate docker build --tag "ilegeul/debian:8-tex-v1.1" -f Dockerfile-v1.1 .

docker push "ilegeul/debian:8-tex-v1.1"
```
