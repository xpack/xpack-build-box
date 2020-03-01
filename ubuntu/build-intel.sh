set -o errexit
docker system prune -f

# ubuntu:10.04 - lucy - 2010-2015, 2.11.1
# ubuntu:12.04 - precise - 2012-2019, 2.15
# ubuntu:14.04 - trusty - 2014-2022, 2.19
# ubuntu:16.04 - xenial - 2016-2024, 2.23
# ubuntu:18.04 - bionic - 2018-2028, 2.27
# ubuntu:20.04 - focal - 2020-2-30, ?

bash ~/Downloads/xpack-build-box.git/ubuntu/12/amd64-build.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12/i386-build.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/14/amd64-build.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/14/i386-build.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16/amd64-build.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16/i386-build.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18/amd64-build.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18/i386-build.sh

bash ~/Downloads/xpack-build-box.git/ubuntu/12-updated/amd64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12-updated/i386-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/14-updated/amd64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/14-updated/i386-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-updated/amd64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-updated/i386-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-updated/amd64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-updated/i386-build-v3.1.sh

bash ~/Downloads/xpack-build-box.git/ubuntu/12-develop/amd64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12-develop/i386-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/14-develop/amd64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/14-develop/i386-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-develop/amd64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-develop/i386-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-develop/amd64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-develop/i386-build-v3.1.sh

bash ~/Downloads/xpack-build-box.git/ubuntu/12-tex/amd64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12-tex/i386-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/14-tex/amd64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/14-tex/i386-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-tex/amd64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-tex/i386-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-tex/amd64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-tex/i386-build-v3.1.sh

bash ~/Downloads/xpack-build-box.git/ubuntu/12-bootstrap/amd64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12-bootstrap/i386-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/14-bootstrap/amd64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/14-bootstrap/i386-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-bootstrap/amd64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-bootstrap/i386-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-bootstrap/amd64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-bootstrap/i386-build-v3.1.sh

bash ~/Downloads/xpack-build-box.git/ubuntu/12-xbb/amd64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12-xbb/i386-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/14-xbb/amd64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/14-xbb/i386-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-xbb/amd64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/16-xbb/i386-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-xbb/amd64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/18-xbb/i386-build-v3.1.sh
