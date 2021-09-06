# 10-npm

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
