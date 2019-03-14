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
$ caffeinate docker build --tag "ilegeul/centos:6-xbb-v2" -f Dockerfile-v2 .
$ caffeinate docker build --tag "ilegeul/centos:6-xbb-v3" -f Dockerfile-v3 .
$ caffeinate docker build --tag "ilegeul/centos:6-xbb-v4" -f Dockerfile-v4 .
$ caffeinate docker build --tag "ilegeul/centos32:6-xbb-v2" -f Dockerfile32-v2 .
$ caffeinate docker build --tag "ilegeul/centos32:6-xbb-v3" -f Dockerfile32-v3 .
```

#### Test

To test the image:

```console
$ docker run --interactive --tty ilegeul/centos:6-xbb-v1
$ docker run --interactive --tty ilegeul/centos:6-xbb-v2
$ docker run --interactive --tty ilegeul/centos:6-xbb-v3
$ docker run --interactive --tty ilegeul/centos:6-xbb-v4
$ docker run --interactive --tty ilegeul/centos32:6-xbb-v1
$ docker run --interactive --tty ilegeul/centos32:6-xbb-v2
```

#### Publish

To publish, use:

```console
$ docker push "ilegeul/centos:6-xbb-v1"
$ docker push "ilegeul/centos32:6-xbb-v1"
```

```console
$ docker push "ilegeul/centos:6-xbb-v2"
$ docker push "ilegeul/centos32:6-xbb-v2"
```

#### Copy & Paste

```bash
caffeinate docker build --tag "ilegeul/centos:6-xbb-v1" -f Dockerfile-v1 .
docker push "ilegeul/centos:6-xbb-v1"
caffeinate docker build --tag "ilegeul/centos32:6-xbb-v1" -f Dockerfile32-v1 .
docker push "ilegeul/centos32:6-xbb-v1"

```

### Credits

The design was heavily inspired by 
[Holy Build Box](http://phusion.github.io/holy-build-box/), available from 
[GitHub](https://github.com/phusion/holy-build-box).
