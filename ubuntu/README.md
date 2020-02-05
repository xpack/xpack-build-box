# The Ubuntu XBB

The Ubuntu XBB consists of four Docker images

- `ilegeul/ubuntu:amd64-12.04-xbb-v3.1`
- `ilegeul/ubuntu:i386-12.04-xbb-v3.1`

They are built upon multple layers, starting from a base archive,
updating it, installing development tools, tex, the bootstrap and
finally the XBB itself.

The following sequences of commands were used:

```bash
set -o errexit
bash ~/Downloads/xpack-build-box.git/ubuntu/12/amd64-build.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12-updated/amd64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12-develop/amd64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12-tex/amd64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12-bootstrap/amd64-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12-xbb/amd64-build-v3.1.sh
```

```bash
set -o errexit
bash ~/Downloads/xpack-build-box.git/ubuntu/12/i386-build.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12-updated/i386-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12-develop/i386-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12-tex/i386-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12-bootstrap/i386-build-v3.1.sh
bash ~/Downloads/xpack-build-box.git/ubuntu/12-xbb/i386-build-v3.1.sh
```
