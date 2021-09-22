# The Ubuntu XBB - production Docker images

Note: This page is dedicated to the production version of the
Ubuntu XBB, used for building distribution packages.
The Ubuntu XBB used for native builds is docummented in the
separate [README-NATIVE](README-NATIVE.md) page.  

The production Ubuntu XBB consists of multiple Docker images,
in pairs of 32/64-bit, for each platform and version.

The images are published on
[Docker Hub](https://hub.docker.com/repository/docker/ilegeul/ubuntu)
(pulling can be done anonymously, pushing requires login).

Intel Ubuntu

- `ilegeul/ubuntu:amd64-12.04-xbb-v3.3`
- `ilegeul/ubuntu:i386-12.04-xbb-v3.3`

Arm Ubuntu

- `ilegeul/ubuntu:arm64v8-16.04-xbb-v3.3`
- `ilegeul/ubuntu:arm32v7-16.04-xbb-v3.3`

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

The following sequences of commands were used on a Debian 9 Intel
Linux (x86_64):

### Ubuntu 12 Intel (precise)

```bash
set -o errexit
docker system prune -f
bash ~/Downloads/xpack-build-box.git/ubuntu/12/amd64-build.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12-updated/amd64-build-v3.3.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12-develop/amd64-build-v3.3.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12-tex/amd64-build-v3.3.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12-xbb-bootstrap/amd64-build-v3.3.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12-xbb/amd64-build-v3.3.sh

docker push "ilegeul/ubuntu:amd64-12.04"
docker push "ilegeul/ubuntu:amd64-12.04-updated-v3.3"
docker push "ilegeul/ubuntu:amd64-12.04-develop-v3.3"
docker push "ilegeul/ubuntu:amd64-12.04-tex-v3.3"
docker push "ilegeul/ubuntu:amd64-12.04-xbb-bootstrap-v3.3"
docker push "ilegeul/ubuntu:amd64-12.04-xbb-v3.3"
```

```bash
set -o errexit
docker system prune -f
bash ~/Downloads/xpack-build-box.git/ubuntu/12/i386-build.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12-updated/i386-build-v3.3.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12-develop/i386-build-v3.3.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12-tex/i386-build-v3.3.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12-xbb-bootstrap/i386-build-v3.3.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12-xbb/i386-build-v3.3.sh

docker push "ilegeul/ubuntu:i386-12.04"
docker push "ilegeul/ubuntu:i386-12.04-updated-v3.3"
docker push "ilegeul/ubuntu:i386-12.04-develop-v3.3"
docker push "ilegeul/ubuntu:i386-12.04-tex-v3.3"
docker push "ilegeul/ubuntu:i386-12.04-xbb-bootstrap-v3.3"
docker push "ilegeul/ubuntu:i386-12.04-xbb-v3.3"
```

### Ubuntu 14 Intel (trusty)

No longer maintained.

### Ubuntu 16 Intel (xenial)

Temporarily not maintained, but planned for the next major release (v4.x).

### Ubuntu 18 Intel (bionic)

No longer maintained.

## Arm Linux

The following sequences of commands were used on a Raspberry Pi OS
Linux (Aarch64):

### Ubuntu 16 Arm (xenial)

```bash
set -o errexit
docker system prune -f
bash ~/Downloads/xpack-build-box.git/ubuntu/16/arm64v8-build.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-updated/arm64v8-build-v3.3.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-develop/arm64v8-build-v3.3.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-tex/arm64v8-build-v3.3.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-xbb-bootstrap/arm64v8-build-v3.3.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-xbb/arm64v8-build-v3.3.sh

docker push "ilegeul/ubuntu:arm64v8-16.04"
docker push "ilegeul/ubuntu:arm64v8-16.04-updated-v3.3"
docker push "ilegeul/ubuntu:arm64v8-16.04-develop-v3.3"
docker push "ilegeul/ubuntu:arm64v8-16.04-tex-v3.3"
docker push "ilegeul/ubuntu:arm64v8-16.04-xbb-bootstrap-v3.3"
docker push "ilegeul/ubuntu:arm64v8-16.04-xbb-v3.3"
```

```bash
set -o errexit
docker system prune -f
bash ~/Downloads/xpack-build-box.git/ubuntu/16/arm32v7-build.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-updated/arm32v7-build-v3.3.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-develop/arm32v7-build-v3.3.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-tex/arm32v7-build-v3.3.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-xbb-bootstrap/arm32v7-build-v3.3.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-xbb/arm32v7-build-v3.3.sh

docker push "ilegeul/ubuntu:arm32v7-16.04"
docker push "ilegeul/ubuntu:arm32v7-16.04-updated-v3.3"
docker push "ilegeul/ubuntu:arm32v7-16.04-develop-v3.3"
docker push "ilegeul/ubuntu:arm32v7-16.04-tex-v3.3"
docker push "ilegeul/ubuntu:arm32v7-16.04-xbb-bootstrap-v3.3"
docker push "ilegeul/ubuntu:arm32v7-16.04-xbb-v3.3"
```

### Ubuntu 18 Arm (bionic)

No longer maintained.

## Testing

For such a complex project, which brings together multiple separate
projects, testing is quite a challenge, and was addressed at several
levels.

First, the project tests were executed. Unfortunatelly some projects
were not ready to run in a custom environment like XBB, and some of
the tests had to be disabled.

Then, a quick test to check that the executables start properly was
performed right during the build.

At the end of the script, those tests were executed again, to check
that adding more libraries and binaries did not damage anything.

For Linux, all binaries using dinamically linked libraries were
checked for all dependencies to be in the hardcoded RPATH.

As a final functional step, a separate XBB test image was built
with the actual XBB Docker image. In other words, XBB can build
itself, which is quite a tough functional test.
