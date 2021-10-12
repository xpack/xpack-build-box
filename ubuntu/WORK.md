# Notes for future versions

## TeX

For v4.x, which will be based on Ubuntu 18.04, TeX 6.2.3 can be installed
from the distribution:

```console
% docker run -it ubuntu:18.04

# apt-get update
# apt-get install -y texlive
# tex --version
TeX 3.14159265 (TeX Live 2017/Debian)
kpathsea version 6.2.3
Copyright 2017 D.E. Knuth.
There is NO warranty.  Redistribution of this software is
covered by the terms of both the TeX copyright and
the Lesser GNU General Public License.
For more information about these matters, see the file
named COPYING and the TeX source.
Primary author of TeX: D.E. Knuth.
```

Notes:

- the TeX version on Ubuntu 16.04 was 6.2.1
- the TeX version on TeX Live 2018 was 6.3.3

## npm

Normally the Linux images should replicate the macOS configuration, where
Apple provides the basic tools and everything else is provided by xPacks.

The stack would be:

- upgraded
- develop+tex (install via package manager)
- npm (compile latest LTS from sources)

There is no need for a separate bootstrap.

One challenge will be to install npm in such a way that in further runs
all users will be able to install packages.

- <https://github.com/nodejs/node/blob/master/.github/workflows/build-tarball.yml>
