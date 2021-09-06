# 10-npm

Debian 10 buster with npm.

- `ilegeul/debian:i386-10-npm-v1`
- `ilegeul/debian:arm32v7-10-npm-v1`

Built from `debian:buster`, with node compiled from sources via nvm.

Currently node 14.17.6.

## Build

```sh
cd ~/Downloads/xpack-build-box.git/debian/10-npm

docker build \
  --tag "ilegeul/debian:i386-10-npm-v1" \
  --file "i386-Dockerfile" \
  .

docker build \
  --tag "ilegeul/debian:arm32v7-10-npm-v1" \
  --file "arm32v7-Dockerfile" \
  .
```

## Publish

```sh
docker push "ilegeul/debian:i386-10-npm-v1"
docker push "ilegeul/debian:arm32v7-10-npm-v1"
```
