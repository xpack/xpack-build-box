# XBB (xPack Build Box)

The [xPack Build Box](https://xpack.github.io/xbb/)
is an elaborated build environment focused on
obtaining reproducible builds while creating cross-platform standalone
binaries for GNU/Linux, macOS and Windows.

## Overview

This open source project is hosted on GitHub as
[`xpack/xpack-build-box`](https://github.com/xpack/xpack-build-box)
and provides the scripts to create the xPack build environments
(either Docker images on GNU/Linux or separate folders on macOS).

## More info

- [Homepage](https://xpack.github.io/xbb/)
- [Prerequisites](https://xpack.github.io/xbb/prerequisites/)
- [End of support](https://xpack.github.io/xbb/end-of-support/) schedule
  for various Linux distributions
- [Releases](https://xpack.github.io/xbb/releases/)

Starting with 2023, all builds will be performed with v5.0.0 or later,
which uses binary xPacks on top of simple npm images.

The current Docker images are:

- [ubuntu/18-xbb](ubuntu/18-xbb/)

## Credits

The xPack Build Box is inspired by the
[Holy Build Box](https://github.com/phusion/holy-build-box)

## License

The original content is released under the
[MIT License](https://opensource.org/licenses/MIT), with all rights
reserved to [Liviu Ionescu](https://github.com/ilg-ul/).
