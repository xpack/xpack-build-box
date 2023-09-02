# The Ubuntu XBB - production Docker images

Note: This page is dedicated to the production version of the
Ubuntu XBB, used for building distribution packages.
The Ubuntu XBB used for native builds is documented in the
separate [README-NATIVE](README-NATIVE.md) page.

The production Ubuntu XBB consists of multiple Docker images,
in pairs of 32/64-bit, for each platform and version.

The images are published on
[Docker Hub](https://hub.docker.com/repository/docker/ilegeul/ubuntu)
(pulling can be done anonymously, pushing requires login).

Intel Ubuntu

- `ilegeul/ubuntu:amd64-18.04-xbb-v5.1.0`

Arm Ubuntu

- `ilegeul/ubuntu:arm64v8-18.04-xbb-v5.1.0`
- `ilegeul/ubuntu:arm32v7-18.04-xbb-v5.1.0`

Each of these images are built upon multiple layers,
starting from a base archive,
updating it, installing development tools, tex, the bootstrap and
finally the XBB itself.

To be sure Docker will not run out of space while building the images,
before each build step it is recommended
to clean possible dangling images:

```bash
docker system prune -f
```

## Intel Linux

The following sequences of commands were used on a Debian 10 Intel
Linux (x86_64):

### Ubuntu 12 Intel (precise)

No longer maintained (since 2022).

### Ubuntu 14 Intel (trusty)

No longer maintained.

### Ubuntu 16 Intel (xenial)

No longer maintained.

### Ubuntu 18 Intel (bionic)

```sh
set -o errexit
docker system prune -f

time ( bash ${HOME}/Work/xpack-build-box.git/ubuntu/18-node/build-v16.20.2.sh && \
bash ${HOME}/Work/xpack-build-box.git/ubuntu/18-xbb/amd64-build-v5.1.0.sh && \
docker images )

docker push "ilegeul/ubuntu:amd64-18.04-node-v16.20.2" && \
docker push "ilegeul/ubuntu:amd64-18.04-xbb-v5.1.0"
```

The build takes about 3h30m on an Intel NUC.

```console
REPOSITORY          TAG                              IMAGE ID            CREATED             SIZE
ilegeul/ubuntu      amd64-18.04-xbb-v5.1.0             ace5ae2e98e5        3 hours ago         5.11GB
ilegeul/ubuntu      amd64-18.04-xbb-bootstrap-v5.1.0   89f21dc5910b        5 hours ago         2.5GB
ilegeul/ubuntu      amd64-18.04-develop-v5.1.0         a497f8c756d0        7 hours ago         1.73GB
ilegeul/ubuntu      amd64-18.04-node-v16.20.2               5c5aee6b1e9c        7 hours ago         524MB
```

## Arm Linux

The following sequences of commands were used on a Raspberry Pi OS
Linux (AArch64):

### Ubuntu 16 Arm (xenial)

No longer maintained (since 2022).

### Ubuntu 18 Arm (bionic)

### 64-bit

It is recommended to run the entire build on a Raspberry Pi OS 64-bit machine.

```sh
set -o errexit
docker system prune -f

time ( bash ${HOME}/Work/xpack-build-box.git/ubuntu/18-node/build-v16.20.2.sh && \
bash ${HOME}/Work/xpack-build-box.git/ubuntu/18-xbb/arm64v8-build-v5.1.0.sh && \
docker images )

docker push "ilegeul/ubuntu:arm64v8-18.04-node-v16.20.2" && \
docker push "ilegeul/ubuntu:arm64v8-18.04-xbb-v5.1.0"
```

The build takes about 12-13 hours on a Raspberry Pi CM4 at 2 GHz.

```console
REPOSITORY            TAG                                IMAGE ID       CREATED         SIZE
ilegeul/ubuntu        arm64v8-18.04-xbb-v5.1.0             4e7f14f6c886   4 minutes ago   3.29GB
ilegeul/ubuntu        arm64v8-18.04-xbb-bootstrap-v5.1.0   73236acbf759   17 hours ago    2.37GB
ilegeul/ubuntu        arm64v8-18.04-develop-v5.1.0         52bd854ba0a7   22 hours ago    1.63GB
ilegeul/ubuntu        arm64v8-18.04-node-v16.20.2               9402f66ed1ac   23 hours ago    491MB
```

#### 32-bit

It is recommended to run the entire build on a Raspberry Pi OS 32-bit machine.

Note: the 32-bit `18-node` build **must** be performed on a 32-bit machine,
otherwise `nvm` will try to incorectly install the 64-bit node/npm.

```bash
set -o errexit
docker system prune -f

time ( bash ${HOME}/Work/xpack-build-box.git/ubuntu/18-node/build-v16.20.2.sh && \
bash ${HOME}/Work/xpack-build-box.git/ubuntu/18-xbb/arm32v7-build-v5.1.0.sh && \
docker images )

docker push "ilegeul/ubuntu:arm32v7-18.04-node-v16.20.2" && \
docker push "ilegeul/ubuntu:arm32v7-18.04-xbb-v5.1.0"
```

The build takes almost 17 hours on a Raspberry Pi4.

```console
REPOSITORY       TAG                                IMAGE ID       CREATED          SIZE
ilegeul/ubuntu   arm32v7-18.04-xbb-v5.1.0             a3718a8e6d0f   22 minutes ago   2.92GB
ilegeul/ubuntu   arm32v7-18.04-xbb-bootstrap-v5.1.0   1d8cefc4597a   10 hours ago     2.11GB
ilegeul/ubuntu   arm32v7-18.04-develop-v5.1.0         1ebe67caa5b8   17 hours ago     1.47GB
ilegeul/ubuntu   arm32v7-18.04-node-v16.20.2               a72f247d197c   17 hours ago     437MB
```

## Testing

For such a complex project, which brings together multiple separate
projects, testing is quite a challenge, and was addressed at several
levels.

First, the project tests were executed. Unfortunately some projects
were not ready to run in a custom environment like XBB, and some of
the tests had to be disabled.

Then, a quick test to check that the executables start properly was
performed right during the build.

At the end of the script, those tests were executed again, to check
that adding more libraries and binaries did not damage anything.

For Linux, all binaries using dynamically linked libraries were
checked for all dependencies to be in the hardcoded RPATH.

As a final functional step, a separate XBB test image was built
with the actual XBB Docker image. In other words, XBB can build
itself, which is quite a tough functional test.
