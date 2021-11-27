## 6-bootstrap

### Overview

Dockerfile to create a Docker image based on the latest CentOS 6 32/64-bits development image, plus selected new tools.

### Changes

Using the original development tools, build newer versions of the tools from sources.

Due to the limitations of the old GCC 4.4, they are not the final tools, but new enough to build a modern GCC, which will be used to build the final tools & libraries.

This step installs the newly created tools in `/opt/xbb-bootstrap`, using several temporary folders.

To use the bootstrap tools, add `/opt/xpp-bootstrap/bin` to the path:

```console
$ PATH=/opt/xbb-bootstrap/bin:$PATH
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
$ docker build --tag "ilegeul/centos:6-bootstrap-v1" -f Dockerfile-v1 .
$ docker build --tag "ilegeul/centos32:6-bootstrap-v1" -f Dockerfile32-v1 .
```

On macOS, to prevent entering sleep, use:

```console
$ caffeinate docker build --tag "ilegeul/centos:6-bootstrap-v1" -f Dockerfile-v1 .
$ caffeinate docker build --tag "ilegeul/centos32:6-bootstrap-v1" -f Dockerfile32-v1 .
```

To create a second version:

```console
$ caffeinate docker build --tag "ilegeul/centos:6-bootstrap-v2.1" -f Dockerfile-v2.1 .
$ caffeinate docker build --tag "ilegeul/centos32:6-bootstrap-v2.1" -f Dockerfile32-v2.1 .
```

#### Test

To test the images:

```console
$ docker run --interactive --tty ilegeul/centos:6-bootstrap-v1
$ docker run --interactive --tty ilegeul/centos32:6-bootstrap-v1
```

To test the images:

```console
$ docker run --interactive --tty ilegeul/centos:6-bootstrap-v2.1
$ docker run --interactive --tty ilegeul/centos32:6-bootstrap-v2.1
```

#### Publish

To publish, use:

```console
$ docker push "ilegeul/centos:6-bootstrap-v1"
$ docker push "ilegeul/centos32:6-bootstrap-v1"
```

```console
$ docker push "ilegeul/centos:6-bootstrap-v2.1"
$ docker push "ilegeul/centos32:6-bootstrap-v2.1"
```
