## 6-xbb

### Overview

Dockerfile to create a Docker image based on the latest CentOS 6 32/64-bit 
development image, plus selected new tools.

### Changes

Using the bootstrap development tools, build final, most recent, versions 
of the tools from sources. 

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
$ docker build --tag "ilegeul/centos:6-xbb-v1" -f Dockerfile-v1 .
$ docker build --tag "ilegeul/centos32:6-xbb-v1" -f Dockerfile32-v1 .
```

On macOS, to prevent entering sleep, use:

```console
$ caffeinate docker build --tag "ilegeul/centos:6-xbb-v1" -f Dockerfile-v1 .
$ caffeinate docker build --tag "ilegeul/centos32:6-xbb-v1" -f Dockerfile32-v1 .
```

To create a second, third, etc version:

```console
$ caffeinate docker build --tag "ilegeul/centos:6-xbb-v2.1" -f Dockerfile-v2.1 .
$ caffeinate docker build --tag "ilegeul/centos32:6-xbb-v2.1" -f Dockerfile32-v2.1 .
```

```console
$ caffeinate docker build --tag "ilegeul/centos:6-xbb-v2.2" -f Dockerfile-v2.2 .
$ caffeinate docker build --tag "ilegeul/centos32:6-xbb-v2.2" -f Dockerfile32-v2.2 .
```

#### Test

To test the image:

```console
$ docker run --interactive --tty ilegeul/centos:6-xbb-v1
$ docker run --interactive --tty ilegeul/centos32:6-xbb-v1
```

```console
$ docker run --interactive --tty ilegeul/centos:6-xbb-v2.1
$ docker run --interactive --tty ilegeul/centos32:6-xbb-v2.1
```

#### Publish

To publish, use:

```console
$ docker push "ilegeul/centos:6-xbb-v1"
$ docker push "ilegeul/centos32:6-xbb-v1"
```

```console
$ docker push "ilegeul/centos:6-xbb-v2.1"
$ docker push "ilegeul/centos32:6-xbb-v2.1"
```

```console
$ docker push "ilegeul/centos:6-xbb-v2.2"
$ docker push "ilegeul/centos32:6-xbb-v2.2"
```

### Credits

The design was heavily inspired by 
[Holy Build Box](http://phusion.github.io/holy-build-box/), available from 
[GitHub](https://github.com/phusion/holy-build-box).
