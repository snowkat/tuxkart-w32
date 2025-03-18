#!/usr/bin/env bash

set -e

cd /src/plib-1.8.5-rc1
./configure --host=i686-w64-mingw32 --prefix=/usr/local
# The configure script sometimes wants to use native 'ar' instead of the MinGW
# one, so we force it here
make AR=i686-w64-mingw32-ar && make install

# TuxKart time!
cd /src/tuxkart-0.4.0
# Statically compile everything
LDFLAGS="-static-libgcc -static-libstdc++" \
        ./configure --host=i686-w64-mingw32 --prefix=/usr/local
make
# Install to a temp root, we have to shuffle some files around to make it work
# on Win32
mkdir -p /tmp/out
make DESTDIR=/tmp/out install

# !! File Shuffling !!
# TuxKart expects the data dir to be in the same folder, or else it'll try to
# use /usr/local (which doesn't work on Win32 for obvious reasons).
mv /tmp/out/usr/local/share/games/tuxkart/* /out
mv /tmp/out/usr/local/games/tuxkart.exe /out
