FROM debian:latest

RUN apt-get update &&           \
    apt-get -y install          \
        binutils-mingw-w64-i686 \
        g++-mingw-w64-i686      \
        gcc-mingw-w64-i686      \
        make

COPY entrypoint.sh /

RUN chmod +x /entrypoint.sh

CMD '/entrypoint.sh'
