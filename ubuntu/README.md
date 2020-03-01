# The Ubuntu XBB

The Ubuntu XBB consists of multiple Docker images, in pairs of 32/64-bit, 
for each platform and version.

Intel Ubuntu

- `ilegeul/ubuntu:amd64-12.04-xbb-v3.1`
- `ilegeul/ubuntu:i386-12.04-xbb-v3.1`

Arm Ubuntu

- `ilegeul/ubuntu:arm64-14.04-xbb-v3.1`
- `ilegeul/ubuntu:armhf-14.04-xbb-v3.1`

Each of these images are built upon multple layers,
starting from a base archive,
updating it, installing development tools, tex, the bootstrap and
finally the XBB itself.

To be sure there is enough space, before each step it is recommended
to clean possible dangling images:

```
docker system prune -f
```

## Intel Linux

The following sequences of commands were used on an Ubuntu 18.04 LTS
Linux (x86_64):

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

## Arm Linux

The following sequences of commands were used on a Manjaro 20.02 Arm
Linux (Aarch64):

```bash
set -o errexit
docker system prune -f
bash ~/Downloads/xpack-build-box.git/ubuntu/14/arm64-build.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/14-updated/arm64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/14-develop/arm64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/14-tex/arm64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/14-bootstrap/arm64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/14-xbb/arm64-build-v3.1.sh

docker push "ilegeul/ubuntu:arm64-14.04"
docker push "ilegeul/ubuntu:arm64-14.04-updated-v3.1"
docker push "ilegeul/ubuntu:arm64-14.04-develop-v3.1"
docker push "ilegeul/ubuntu:arm64-14.04-tex-v3.1"
docker push "ilegeul/ubuntu:arm64-14.04-bootstrap-v3.1"
docker push "ilegeul/ubuntu:arm64-14.04-xbb-v3.1"
```

```bash
set -o errexit
docker system prune -f
bash ~/Downloads/xpack-build-box.git/ubuntu/14/armhf-build.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/14-updated/armhf-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/14-develop/armhf-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/14-tex/armhf-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/14-bootstrap/armhf-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/14-xbb/armhf-build-v3.1.sh

docker push "ilegeul/ubuntu:armhf-14.04"
docker push "ilegeul/ubuntu:armhf-14.04-updated-v3.1"
docker push "ilegeul/ubuntu:armhf-14.04-develop-v3.1"
docker push "ilegeul/ubuntu:armhf-14.04-tex-v3.1"
docker push "ilegeul/ubuntu:armhf-14.04-bootstrap-v3.1"
docker push "ilegeul/ubuntu:armhf-14.04-xbb-v3.1"
```

```bash
set -o errexit
docker system prune -f
bash ~/Downloads/xpack-build-box.git/ubuntu/16/arm64-build.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-updated/arm64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-develop/arm64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-tex/arm64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-bootstrap/arm64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-xbb/arm64-build-v3.1.sh

docker push "ilegeul/ubuntu:arm64-16.04"
docker push "ilegeul/ubuntu:arm64-16.04-updated-v3.1"
docker push "ilegeul/ubuntu:arm64-16.04-develop-v3.1"
docker push "ilegeul/ubuntu:arm64-16.04-tex-v3.1"
docker push "ilegeul/ubuntu:arm64-16.04-bootstrap-v3.1"
docker push "ilegeul/ubuntu:arm64-16.04-xbb-v3.1"
```

```bash
set -o errexit
docker system prune -f
bash ~/Downloads/xpack-build-box.git/ubuntu/16/armhf-build.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-updated/armhf-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-develop/armhf-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-tex/armhf-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-bootstrap/armhf-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-xbb/armhf-build-v3.1.sh

docker push "ilegeul/ubuntu:armhf-16.04"
docker push "ilegeul/ubuntu:armhf-16.04-updated-v3.1"
docker push "ilegeul/ubuntu:armhf-16.04-develop-v3.1"
docker push "ilegeul/ubuntu:armhf-16.04-tex-v3.1"
docker push "ilegeul/ubuntu:armhf-16.04-bootstrap-v3.1"
docker push "ilegeul/ubuntu:armhf-16.04-xbb-v3.1"
```
