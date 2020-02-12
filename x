
/bin/bash ../libtool  --tag=CC   --mode=link gcc-8bs  -pipe -no-install -L../src/.libs -L/opt/xbb/lib  -v -Wl,--disable-new-dtags -o tversion tversion.o libfrtests.la -lm -lquadmath ../src/libmpfr.la -lgmp 

libtool: link: gcc-8bs 
-pipe 
-v 
-Wl,--disable-new-dtags 
-o tversion 
tversion.o  
-L../src/.libs 
-L/opt/xbb/lib 
./.libs/libfrtests.a 
-lm 
/opt/xbb-bootstrap/lib/libquadmath.so 
../src/.libs/libmpfr.so 
/opt/xbb/lib/libgmp.so 
-Wl,-rpath -Wl,/opt/xbb-bootstrap/lib 
-Wl,-rpath -Wl,/root/Work/xbb-3.1-ubuntu-i686/build/libs/mpfr-4.0.2/src/.libs 
-Wl,-rpath -Wl,/opt/xbb/lib 
-Wl,-rpath -Wl,/opt/xbb-bootstrap/lib 
-Wl,-rpath -Wl,/opt/xbb/lib

Using built-in specs.
COLLECT_GCC=gcc-8bs
COLLECT_LTO_WRAPPER=/opt/xbb-bootstrap/libexec/gcc/i686-pc-linux-gnu/8.3.0/lto-wrapper
Target: i686-pc-linux-gnu
Configured with: /root/Work/xbb-bootstrap-3.1-ubuntu-i686/sources/gcc-8.3.0/configure --prefix=/opt/xbb-bootstrap --program-suffix=-8bs --with-pkgversion='xPack Build Box Bootstrap GCC\x2C 32-bit' --enable-languages=c,c++ --with-linker-hash-style=gnu --with-system-zlib --with-isl --enable-shared --enable-checking=release --enable-threads=posix --enable-__cxa_atexit --enable-clocale=gnu --enable-gnu-unique-object --enable-linker-build-id --enable-lto --enable-plugin --enable-install-libiberty --enable-gnu-indirect-function --enable-default-pie --enable-default-ssp --disable-libunwind-exceptions --disable-libstdcxx-pch --disable-libssp --disable-multilib --disable-werror --disable-bootstrap
Thread model: posix
gcc version 8.3.0 (xPack Build Box Bootstrap GCC, 32-bit) 

COMPILER_PATH=
/opt/xbb-bootstrap/libexec/gcc/i686-pc-linux-gnu/8.3.0/:
/opt/xbb-bootstrap/libexec/gcc/i686-pc-linux-gnu/8.3.0/:
/opt/xbb-bootstrap/libexec/gcc/i686-pc-linux-gnu/:
/opt/xbb-bootstrap/lib/gcc/i686-pc-linux-gnu/8.3.0/:
/opt/xbb-bootstrap/lib/gcc/i686-pc-linux-gnu/:
/opt/xbb-bootstrap/lib/gcc/i686-pc-linux-gnu/8.3.0/../../../../i686-pc-linux-gnu/bin/

LIBRARY_PATH=
/opt/xbb-bootstrap/lib/gcc/i686-pc-linux-gnu/8.3.0/:
/opt/xbb-bootstrap/lib/gcc/i686-pc-linux-gnu/8.3.0/../../../../i686-pc-linux-gnu/lib/:
/opt/xbb-bootstrap/lib/gcc/i686-pc-linux-gnu/8.3.0/../../../:
/lib/i386-linux-gnu/:
/lib/:
/usr/lib/i386-linux-gnu/:
/usr/lib/

COLLECT_GCC_OPTIONS='-pipe' '-v' '-o' 'tversion' '-L../src/.libs' '-L/opt/xbb/lib' '-mtune=generic' '-march=pentiumpro'
 
/opt/xbb-bootstrap/libexec/gcc/i686-pc-linux-gnu/8.3.0/collect2 
-plugin /opt/xbb-bootstrap/libexec/gcc/i686-pc-linux-gnu/8.3.0/liblto_plugin.so 
-plugin-opt=/opt/xbb-bootstrap/libexec/gcc/i686-pc-linux-gnu/8.3.0/lto-wrapper 
-plugin-opt=-fresolution=/tmp/ccpLYMPm.res 
-plugin-opt=-pass-through=-lgcc 
-plugin-opt=-pass-through=-lgcc_s 
-plugin-opt=-pass-through=-lc 
-plugin-opt=-pass-through=-lgcc 
-plugin-opt=-pass-through=-lgcc_s 
--build-id 
--eh-frame-hdr 
--hash-style=gnu 
-m elf_i386 
-dynamic-linker 
/lib/ld-linux.so.2 
-pie 
-o tversion 
/usr/lib/i386-linux-gnu/Scrt1.o 
/usr/lib/i386-linux-gnu/crti.o 
/opt/xbb-bootstrap/lib/gcc/i686-pc-linux-gnu/8.3.0/crtbeginS.o 
-L../src/.libs 
-L/opt/xbb/lib 
-L/opt/xbb-bootstrap/lib/gcc/i686-pc-linux-gnu/8.3.0 
-L/opt/xbb-bootstrap/lib/gcc/i686-pc-linux-gnu/8.3.0/../../../../i686-pc-linux-gnu/lib 
-L/opt/xbb-bootstrap/lib/gcc/i686-pc-linux-gnu/8.3.0/../../.. 
-L/lib/i386-linux-gnu 
-L/usr/lib/i386-linux-gnu 
--disable-new-dtags 
tversion.o 
./.libs/libfrtests.a 
-lm 
/opt/xbb-bootstrap/lib/libquadmath.so 
../src/.libs/libmpfr.so 
/opt/xbb/lib/libgmp.so 
-rpath /opt/xbb-bootstrap/lib 
-rpath /root/Work/xbb-3.1-ubuntu-i686/build/libs/mpfr-4.0.2/src/.libs 
-rpath /opt/xbb/lib 
-rpath /opt/xbb-bootstrap/lib 
-rpath /opt/xbb/lib 
-lgcc 
--as-needed -lgcc_s 
--no-as-needed -lc 
-lgcc 
--as-needed -lgcc_s 
--no-as-needed /opt/xbb-bootstrap/lib/gcc/i686-pc-linux-gnu/8.3.0/crtendS.o 
/usr/lib/i386-linux-gnu/crtn.o

COLLECT_GCC_OPTIONS='-pipe' '-v' '-o' 'tversion' '-L../src/.libs' '-L/opt/xbb/lib' '-mtune=generic' '-march=pentiumpro'
