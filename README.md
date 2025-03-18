# TuxKart 0.4.0 for Win32

TuxKart is the predecessor to [SuperTuxKart](https://supertuxkart.net/Main_Page), an open-source arcade racing game. Development on the original TuxKart stalled in 2004. [The TuxKart website](https://tuxkart.sourceforge.net/) is still online on Sourceforge.

There has never been official Windows support for TuxKart, but it could run if compiled with Cygwin. From the [Requirements page](https://tuxkart.sourceforge.net/requirements.html):

> Right now, TuxKart only runs under Linux - and under Windoze using the CygWin package. I anticipate MSVC/Windoze, MacOS, BSD, BeOS, Solaris and IRIX ports to follow very soon. 

Even on a native Linux install, sound is unlikely to work due to TuxKart's usage of the all-but-dead OSS. OSS compatibility exists through ALSA, but I'm unsure how well it would work within a WSL environment.

However, there is good news: PLIB, the gaming library used by TuxKart, supports Windows Multimedia, and ancient-but-somehow-still-hanging-on set of APIs that happens to provide support for sound! This is how sound works with Cygwin, after all. But we can do one better: native Win32 TuxKart using MinGW.


## Building

### The easy way (Docker)

You'll need the following:

* Docker
* A bash shell
* Linux (native or WSL is fine)

Just run `./build.sh` from the cloned repository directory, and wait. Hopefully by the end, you'll have a `tuxkart.exe` and related directories in the `out/` subdirectory.


### The harder way

If you can't (or don't want to) use Docker, store-bought MinGW toolchain is fine too.

You'll need:

* A bash shell
* A `i686-w64-mingw32` G++ toolchain
* Lots of patience

First, run `build.sh` without the build steps. This will download and extract the tarballs, and apply the required patches.

```
NOBUILD=1 ./build.sh
```

The source trees are now available in `./build`. The rest of the steps are normal enough for a MinGW cross-compilation:

```sh
# Set a prefix so it doesn't end up in /usr!
prefix=/tmp/tuxkart

cd build/plib-1.8.5-rc1
./configure --host=i686-w64-mingw32 --prefix=$prefix
make && make install

# Ok, now build TuxKart:
cd ../tuxkart-0.4.0
# Static link everything
LDFLAGS="-static-libgcc -static-libstdc++" \
    ./configure --host=i686-w64-mingw32 --prefix=$prefix
make && make install
```

At this point, the game should be at `$prefix/games/tuxkart.exe`. The last step is to put all the datafiles in the same place, so tuxkart.exe looks in the right place:

```
mv $prefix/share/games/tuxkart/* $prefix/games/
```
