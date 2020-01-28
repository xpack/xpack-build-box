## 8-xbb

### Overview

Dockerfile to create a Docker image based on the Debian 8 image,
development tools and new tools like GCC 8.

### Changes

This step installs the newly created tools in `/opt/xbb`, using several 
temporary folders.

To use the new tools, add `/opt/xpp/bin` to the path and adjust the include 
and library search paths.

To simplify things, use the functions provided by the `xbb-source.sh` bash 
script (was previously named `xbb.sh`):

```console
$ source /opt/xbb/xbb-source.sh
$ xbb_activate
```

### Developer

### Clone the repository

```console
$ rm -rf "${HOME}/Downloads/xpack-build-box.git"
$ git clone --recurse-submodules https://github.com/xpack/xpack-build-box.git \
  "${HOME}/Downloads/xpack-build-box.git"
```

Note: the repository uses submodules, and if updated manually, the
submodules must also be updated.

#### Create

To create the Docker image locally, use:

```console
$ cd ...
$ docker build --tag "ilegeul/debian:8-xbb-v1.1" -f Dockerfile-v1.1 .
```

On macOS, to prevent entering sleep, use:

```console
$ caffeinate docker build --tag "ilegeul/debian:8-xbb-v1.1" -f Dockerfile-v1.1 .
```

#### Test

To test the image:

```console
$ docker run --interactive --tty ilegeul/debian:8-xbb-v1.1
```

#### Publish

To publish, use:

```console
$ docker push "ilegeul/debian:8-xbb-v1.1"
```

#### Copy & Paste

```bash
caffeinate docker build --tag "ilegeul/debian:8-xbb-v1.1" -f Dockerfile-v1.1 .

docker push "ilegeul/debian:8-xbb-v1.1"
```

### Credits

The design was heavily inspired by
[Holy Build Box](http://phusion.github.io/holy-build-box/), available from
[GitHub](https://github.com/phusion/holy-build-box).
