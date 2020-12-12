
## DockerHub images (not functional due to faulty arm32 image)

- https://hub.docker.com/_/centos

- https://github.com/CentOS/sig-cloud-instance-images
- https://github.com/CentOS/sig-cloud-instance-build/

docker run -it -v $HOME/Work:/root/Work centos:7

yum -y install lorax anaconda-tui yum-langpacks git

cd

curl -L http://mirrors.nav.ro/centos-altarch/7.8.2003/isos/armhfp/CentOS-Userland-7-armv7hl-RootFS-Minimal-2003-sda.raw.xz -o sda.raw.xz
curl -L https://github.com/CentOS/sig-cloud-instance-build/raw/master/docker/centos-7-armhfp.ks -o centos-7-armhfp.ks

livemedia-creator \
--make-tar \
--fs-image=sda.raw.xz \
--ks=centos-7-armhfp.ks \
--image-name=centos-7-docker.tar.xz \
--no-virt \
--project "CentOS 7 Docker" \
--releasever "7" \

2020-08-12 10:05:37,441: livemedia-creator 19.7.26-1
2020-08-12 10:05:37,442: selinux is Disabled
2020-08-12 10:05:37,467: local variable 'disk_img' referenced before assignment


cd

curl -L http://mirrors.nav.ro/centos-altarch/7.8.2003/isos/armhfp/CentOS-Userland-7-armv7hl-RootFS-Minimal-2003-sda.raw.xz -o sda.raw.xz

xz --decompress sda.raw.xz

curl -L https://github.com/CentOS/sig-cloud-instance-build/raw/master/docker/centos-7-armhfp.ks -o centos-7-armhfp.ks

livemedia-creator \
--make-tar \
--iso=sda.raw \
--ks=centos-7-armhfp.ks \
--image-name=centos-7-docker.tar.xz \
--no-virt \
--project "CentOS 7 Docker" \
--releasever "7" \












curl -l http://mirrors.nav.ro/centos-altarch/7.8.2003/isos/armhfp/CentOS-Userland-7-armv7hl-RootFS-Minimal-2003-sda.raw.xz -o CentOS-Userland-7-armv7hl-RootFS-Minimal-2003-sda.raw.xz

cat <<'__EOF__' >Dockerfile
FROM scratch

LABEL description="Pristine CentOS 7.8.2003 arm32v7 image."
LABEL maintainer="Liviu Ionescu <ilg@livius.net>"
LABEL repository="https://github.com/xpack/xpack-build-box.git"
LABEL docs="https://github.com/xpack/xpack-build-box/tree/master/centos/7/README.md"

ENTRYPOINT ["linux32"]

ADD CentOS-Userland-7-armv7hl-RootFS-Minimal-2003-sda.raw.xz /
RUN linux32 yum -y update

CMD ["/bin/bash"]
__EOF__


docker build --tag "ilegeul/centos:arm32v7-7.8-b" -f "Dockerfile" .


------

Development blocked by the faulty arm32 image.

- https://github.com/CentOS/sig-cloud-instance-images/issues/171

---

[2020-08-26]

$basearch -> armhfp

for f in /etc/yum.repos.d/* /etc/yum.conf; do sed -i -e 's/\$basearch/armhfp/g' $f; sed -i -e 's/^\#baseurl/baseurl/' $f; done
