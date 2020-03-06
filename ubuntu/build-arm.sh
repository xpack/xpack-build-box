set -o errexit
docker system prune -f

# ubuntu:10.04 - lucy - 2010-2015, 2.11.1
# ubuntu:12.04 - precise - 2012-2019, 2.15
# ubuntu:14.04 - trusty - 2014-2022, 2.19
# ubuntu:16.04 - xenial - 2016-2024, 2.23
# ubuntu:18.04 - bionic - 2018-2028, 2.27
# ubuntu:20.04 - focal - 2020-2-30, ?

bash ~/Downloads/xpack-build-box.git/ubuntu/16/arm64v8-build.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16/arm32v7-build.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18/arm64v8-build.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18/arm32v7-build.sh

bash ~/Downloads/xpack-build-box.git/ubuntu/16-updated/arm64v8-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-updated/arm32v7-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-updated/arm64v8-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-updated/arm32v7-build-v3.1.sh

bash ~/Downloads/xpack-build-box.git/ubuntu/16-develop/arm64v8-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-develop/arm32v7-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-develop/arm64v8-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-develop/arm32v7-build-v3.1.sh

bash ~/Downloads/xpack-build-box.git/ubuntu/16-tex/arm64v8-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-tex/arm32v7-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-tex/arm64v8-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-tex/arm32v7-build-v3.1.sh

bash ~/Downloads/xpack-build-box.git/ubuntu/16-bootstrap/arm64v8-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-bootstrap/arm32v7-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-bootstrap/arm64v8-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-bootstrap/arm32v7-build-v3.1.sh

bash ~/Downloads/xpack-build-box.git/ubuntu/16-xbb/arm64v8-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-xbb/arm32v7-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-xbb/arm64v8-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-xbb/arm32v7-build-v3.1.sh

