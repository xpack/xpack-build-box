# 10-npm

Debian 10 buster.

## Create

```sh
cd ~/Downloads/xpack-build-box.git/debian/10-npm

docker build \
  --tag "ilegeul/debian:i386-10-npm-v1" \
  --file "i386-Dockerfile" \
  .

docker push "ilegeul/debian:i386-10-npm-v1"

```

Currently node 14.17.6.

```sh
docker build \
  --tag "ilegeul/debian:arm32v7-10-npm-v1" \
  --file "arm32v7-Dockerfile" \
  .

docker push "ilegeul/debian:arm32v7-10-npm-v1"
