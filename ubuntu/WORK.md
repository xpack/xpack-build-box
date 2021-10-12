# Notes for future versions

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
