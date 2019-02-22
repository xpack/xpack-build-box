set +e

# Test to create a .dmg with a chroot jail.
# http://galvanist.com/post/56925855686/chroot-jails-on-os-x

cd /tmp

rm -rf dmg
mkdir dmg

cd dmg
mkdir -p bin usr/bin usr/lib usr/lib/system usr/lib/closure

for f in  bash cat chmod cp date echo expr hostname kill ln ls mkdir mv ps pwd rm rmdir test unlink
do 
  cp -p /bin/$f bin
done

for f in ar as awk basename bison diff dirname egrep env false fgrep file find flex grep lex m4  make mktemp more otool patch readlink sed sort touch tr true umask wc whatis whereis which who whoami xargs  yacc 
do 
  cp -p /usr/bin/$f usr/bin
done

for f in dyld libncurses.5.4.dylib libSystem.B.dylib
do 
  cp -p /usr/lib/$f usr/lib
done

for f in libcache.dylib libcommonCrypto.dylib libcompiler_rt.dylib libcopyfile.dylib libcorecrypto.dylib libdispatch.dylib libdyld.dylib
do 
  cp -p /usr/lib/system/$f usr/lib/system
done

cp /usr/lib/*.dylib usr/lib
cp /usr/lib/system/*.dylib usr/lib/system
cp /usr/lib/closure/*.dylib usr/lib/closure

ls -lLR .

echo "Creating dmg..."
rm -f /tmp/xbb-dev-root.dmg 

# -uid 0 -gid 0
hdiutil create -fs HFS+ -srcfolder . -volname XBB-Dev /tmp/xbb-dev-root.dmg -verbose

# To Mount the .dmg as RO:
# hdiutil attach /tmp/xbb-dev-root.dmg -readonly

# To run a bash in the jail:
# sudo chroot /Volumes/XBB-Dev /bin/bash

