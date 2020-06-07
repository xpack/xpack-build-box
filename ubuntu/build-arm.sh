set -o errexit
docker system prune -f

# ubuntu:10.04 - lucy - 2010-2015, 2.11.1
# ubuntu:12.04 - precise - 2012-2019, 2.15
# ubuntu:14.04 - trusty - 2014-2022, 2.19
# ubuntu:16.04 - xenial - 2016-2024, 2.23
# ubuntu:18.04 - bionic - 2018-2028, 2.27
# ubuntu:20.04 - focal - 2020-2-30, ?

function do_one()
{
  local version=$1
  local arch=$2

  if true
  then
    bash ~/Downloads/xpack-build-box.git/ubuntu/${version}/${arch}-build.sh
    docker push "ilegeul/ubuntu:${arch}-${version}.04"
    bash ~/Downloads/xpack-build-box.git/ubuntu/${version}-updated/${arch}-build-v3.1.sh
    docker push "ilegeul/ubuntu:${arch}-${version}.04-updated-v3.1"
    bash ~/Downloads/xpack-build-box.git/ubuntu/${version}-develop/${arch}-build-v3.1.sh
    docker push "ilegeul/ubuntu:${arch}-${version}.04-develop-v3.1"
    bash ~/Downloads/xpack-build-box.git/ubuntu/${version}-tex/${arch}-build-v3.1.sh
    docker push "ilegeul/ubuntu:${arch}-${version}.04-tex-v3.1"
  fi

  bash ~/Downloads/xpack-build-box.git/ubuntu/${version}-xbb-bootstrap/${arch}-build-v3.2.sh
  docker push "ilegeul/ubuntu:${arch}-${version}.04-xbb-bootstrap-v3.2"
  bash ~/Downloads/xpack-build-box.git/ubuntu/${version}-xbb/${arch}-build-v3.2.sh
  docker push "ilegeul/ubuntu:${arch}-${version}.04-xbb-v3.2"
}

time do_one 16 arm64v8
time do_one 16 arm32v7

if false
then
  time do_one 18 arm64v8
  time do_one 18 arm32v7
fi