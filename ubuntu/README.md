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

- `ilegeul/ubuntu:amd64-12.04-xbb-v3.1`
- `ilegeul/ubuntu:i386-12.04-xbb-v3.1`
- `ilegeul/ubuntu:amd64-14.04-xbb-v3.1`
- `ilegeul/ubuntu:i386-14.04-xbb-v3.1`
- `ilegeul/ubuntu:amd64-16.04-xbb-v3.1`
- `ilegeul/ubuntu:i386-16.04-xbb-v3.1`
- `ilegeul/ubuntu:amd64-18.04-xbb-v3.1`
- `ilegeul/ubuntu:i386-18.04-xbb-v3.1`

Arm Ubuntu

- `ilegeul/ubuntu:arm64v8-14.04-xbb-v3.1`
- `ilegeul/ubuntu:arm32v7-14.04-xbb-v3.1`
- `ilegeul/ubuntu:arm64v8-16.04-xbb-v3.1`
- `ilegeul/ubuntu:arm32v7-16.04-xbb-v3.1`
- `ilegeul/ubuntu:arm64v8-18.04-xbb-v3.1`
- `ilegeul/ubuntu:arm32v7-18.04-xbb-v3.1`

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

The following sequences of commands were used on a Manjaro 20.02 Intel
Linux (x86_64):

### Ubuntu 12 (precise)

```bash
set -o errexit
docker system prune -f
bash ~/Downloads/xpack-build-box.git/ubuntu/12/amd64-build.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12-updated/amd64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12-develop/amd64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12-tex/amd64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12-bootstrap/amd64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12-xbb/amd64-build-v3.1.sh

docker push "ilegeul/ubuntu:amd64-12.04"
docker push "ilegeul/ubuntu:amd64-12.04-updated-v3.1"
docker push "ilegeul/ubuntu:amd64-12.04-develop-v3.1"
docker push "ilegeul/ubuntu:amd64-12.04-tex-v3.1"
docker push "ilegeul/ubuntu:amd64-12.04-bootstrap-v3.1"
docker push "ilegeul/ubuntu:amd64-12.04-xbb-v3.1"
```

```bash
set -o errexit
docker system prune -f
bash ~/Downloads/xpack-build-box.git/ubuntu/12/i386-build.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12-updated/i386-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12-develop/i386-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12-tex/i386-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12-bootstrap/i386-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12-xbb/i386-build-v3.1.sh

docker push "ilegeul/ubuntu:i386-12.04"
docker push "ilegeul/ubuntu:i386-12.04-updated-v3.1"
docker push "ilegeul/ubuntu:i386-12.04-develop-v3.1"
docker push "ilegeul/ubuntu:i386-12.04-tex-v3.1"
docker push "ilegeul/ubuntu:i386-12.04-bootstrap-v3.1"
docker push "ilegeul/ubuntu:i386-12.04-xbb-v3.1"
```

### Ubuntu 14 (trusty)

```bash
set -o errexit
docker system prune -f
bash ~/Downloads/xpack-build-box.git/ubuntu/14/amd64-build.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/14-updated/amd64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/14-develop/amd64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/14-tex/amd64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/14-bootstrap/amd64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/14-xbb/amd64-build-v3.1.sh

docker push "ilegeul/ubuntu:amd64-14.04"
docker push "ilegeul/ubuntu:amd64-14.04-updated-v3.1"
docker push "ilegeul/ubuntu:amd64-14.04-develop-v3.1"
docker push "ilegeul/ubuntu:amd64-14.04-tex-v3.1"
docker push "ilegeul/ubuntu:amd64-14.04-bootstrap-v3.1"
docker push "ilegeul/ubuntu:amd64-14.04-xbb-v3.1"
```

```bash
set -o errexit
docker system prune -f
bash ~/Downloads/xpack-build-box.git/ubuntu/14/i386-build.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/14-updated/i386-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/14-develop/i386-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/14-tex/i386-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/14-bootstrap/i386-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/14-xbb/i386-build-v3.1.sh

docker push "ilegeul/ubuntu:i386-14.04"
docker push "ilegeul/ubuntu:i386-14.04-updated-v3.1"
docker push "ilegeul/ubuntu:i386-14.04-develop-v3.1"
docker push "ilegeul/ubuntu:i386-14.04-tex-v3.1"
docker push "ilegeul/ubuntu:i386-14.04-bootstrap-v3.1"
docker push "ilegeul/ubuntu:i386-14.04-xbb-v3.1"
```

### Ubuntu 16 (xenial)

```bash
set -o errexit
docker system prune -f
bash ~/Downloads/xpack-build-box.git/ubuntu/16/amd64-build.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-updated/amd64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-develop/amd64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-tex/amd64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-bootstrap/amd64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-xbb/amd64-build-v3.1.sh

docker push "ilegeul/ubuntu:amd64-16.04"
docker push "ilegeul/ubuntu:amd64-16.04-updated-v3.1"
docker push "ilegeul/ubuntu:amd64-16.04-develop-v3.1"
docker push "ilegeul/ubuntu:amd64-16.04-tex-v3.1"
docker push "ilegeul/ubuntu:amd64-16.04-bootstrap-v3.1"
docker push "ilegeul/ubuntu:amd64-16.04-xbb-v3.1"
```

```bash
set -o errexit
docker system prune -f
bash ~/Downloads/xpack-build-box.git/ubuntu/16/i386-build.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-updated/i386-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-develop/i386-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-tex/i386-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-bootstrap/i386-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-xbb/i386-build-v3.1.sh

docker push "ilegeul/ubuntu:i386-16.04"
docker push "ilegeul/ubuntu:i386-16.04-updated-v3.1"
docker push "ilegeul/ubuntu:i386-16.04-develop-v3.1"
docker push "ilegeul/ubuntu:i386-16.04-tex-v3.1"
docker push "ilegeul/ubuntu:i386-16.04-bootstrap-v3.1"
docker push "ilegeul/ubuntu:i386-16.04-xbb-v3.1"
```

### Ubuntu 18 (bionic)

```bash
set -o errexit
docker system prune -f
bash ~/Downloads/xpack-build-box.git/ubuntu/18/amd64-build.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-updated/amd64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-develop/amd64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-tex/amd64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-bootstrap/amd64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-xbb/amd64-build-v3.1.sh

docker push "ilegeul/ubuntu:amd64-18.04"
docker push "ilegeul/ubuntu:amd64-18.04-updated-v3.1"
docker push "ilegeul/ubuntu:amd64-18.04-develop-v3.1"
docker push "ilegeul/ubuntu:amd64-18.04-tex-v3.1"
docker push "ilegeul/ubuntu:amd64-18.04-bootstrap-v3.1"
docker push "ilegeul/ubuntu:amd64-18.04-xbb-v3.1"
```

```bash
set -o errexit
docker system prune -f
bash ~/Downloads/xpack-build-box.git/ubuntu/18/i386-build.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-updated/i386-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-develop/i386-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-tex/i386-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-bootstrap/i386-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-xbb/i386-build-v3.1.sh

docker push "ilegeul/ubuntu:i386-18.04"
docker push "ilegeul/ubuntu:i386-18.04-updated-v3.1"
docker push "ilegeul/ubuntu:i386-18.04-develop-v3.1"
docker push "ilegeul/ubuntu:i386-18.04-tex-v3.1"
docker push "ilegeul/ubuntu:i386-18.04-bootstrap-v3.1"
docker push "ilegeul/ubuntu:i386-18.04-xbb-v3.1"
```

## Arm Linux

The following sequences of commands were used on a Manjaro 20.02 Arm
Linux (Aarch64):

### Ubuntu 16 (xenial)

```bash
set -o errexit
docker system prune -f
bash ~/Downloads/xpack-build-box.git/ubuntu/16/arm64v8-build.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-updated/arm64v8-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-develop/arm64v8-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-tex/arm64v8-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-bootstrap/arm64v8-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-xbb/arm64v8-build-v3.1.sh

docker push "ilegeul/ubuntu:arm64v8-16.04"
docker push "ilegeul/ubuntu:arm64v8-16.04-updated-v3.1"
docker push "ilegeul/ubuntu:arm64v8-16.04-develop-v3.1"
docker push "ilegeul/ubuntu:arm64v8-16.04-tex-v3.1"
docker push "ilegeul/ubuntu:arm64v8-16.04-bootstrap-v3.1"
docker push "ilegeul/ubuntu:arm64v8-16.04-xbb-v3.1"
```

```bash
set -o errexit
docker system prune -f
bash ~/Downloads/xpack-build-box.git/ubuntu/16/arm32v7-build.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-updated/arm32v7-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-develop/arm32v7-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-tex/arm32v7-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-bootstrap/arm32v7-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-xbb/arm32v7-build-v3.1.sh

docker push "ilegeul/ubuntu:arm32v7-16.04"
docker push "ilegeul/ubuntu:arm32v7-16.04-updated-v3.1"
docker push "ilegeul/ubuntu:arm32v7-16.04-develop-v3.1"
docker push "ilegeul/ubuntu:arm32v7-16.04-tex-v3.1"
docker push "ilegeul/ubuntu:arm32v7-16.04-bootstrap-v3.1"
docker push "ilegeul/ubuntu:arm32v7-16.04-xbb-v3.1"
```

### Ubuntu 18 (bionic)

```bash
set -o errexit
docker system prune -f
bash ~/Downloads/xpack-build-box.git/ubuntu/18/arm64v8-build.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-updated/arm64v8-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-develop/arm64v8-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-tex/arm64v8-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-bootstrap/arm64v8-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-xbb/arm64v8-build-v3.1.sh

docker push "ilegeul/ubuntu:arm64v8-18.04"
docker push "ilegeul/ubuntu:arm64v8-18.04-updated-v3.1"
docker push "ilegeul/ubuntu:arm64v8-18.04-develop-v3.1"
docker push "ilegeul/ubuntu:arm64v8-18.04-tex-v3.1"
docker push "ilegeul/ubuntu:arm64v8-18.04-bootstrap-v3.1"
docker push "ilegeul/ubuntu:arm64v8-18.04-xbb-v3.1"
```

```bash
set -o errexit
docker system prune -f
bash ~/Downloads/xpack-build-box.git/ubuntu/18/arm32v7-build.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-updated/arm32v7-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-develop/arm32v7-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-tex/arm32v7-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-bootstrap/arm32v7-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-xbb/arm32v7-build-v3.1.sh

docker push "ilegeul/ubuntu:arm32v7-18.04"
docker push "ilegeul/ubuntu:arm32v7-18.04-updated-v3.1"
docker push "ilegeul/ubuntu:arm32v7-18.04-develop-v3.1"
docker push "ilegeul/ubuntu:arm32v7-18.04-tex-v3.1"
docker push "ilegeul/ubuntu:arm32v7-18.04-bootstrap-v3.1"
docker push "ilegeul/ubuntu:arm32v7-18.04-xbb-v3.1"
```
