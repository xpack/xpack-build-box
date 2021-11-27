# README-APPLE-SILICON

Notes on porting XBB to Apple Silicon, in reverse chronological order:

## 2021-11-27

- rebuild for macOS 11.6
- update to GCC 11.2 also available from @iains/@fxcoudert

## 2021-11-14

- update most packages to latest releases
- most projects have out-of-date config.sub; overwrite with 2021-08-14 from
  <https://git.savannah.gnu.org/cgit/config.git/plain/config.sub>
- only GCC 11.1 is available for Apple Silicon, maintained by @iains
  <https://github.com/iains/gcc-darwin-arm64>

## 2021-11-11

- install xbbma with macOS 11.6.1
- receive Mac Mini from MacStadium
