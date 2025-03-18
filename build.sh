#!/usr/bin/env bash

DISTFILES=(
    'https://tuxkart.sourceforge.net/dist/tuxkart-0.4.0.tar.gz'
    'https://sourceforge.net/projects/plib/files/plib/1.8.5-rc1/plib-1.8.5-rc1.tar.gz'
)

DISTDIR="$PWD/dist"
BUILDDIR="$PWD/build"
OUTDIR="$PWD/out"

die() {
    printf 'err: %s\n' "$1" >&2
    exit 1
}

docker_detect() {
    command -v docker >/dev/null || die 'Docker executable not found!'
    if docker buildx version >/dev/null ; then
        echo 'Using docker-buildx.'
        BUILDCMD="buildx build --load"
    else
        echo 'Using legacy docker build.'
        BUILDCMD="build"
    fi
}

fetch_and_extract() {
    if [ ! -d "$DISTDIR" ] ; then
        mkdir "$DISTDIR"
    fi

    if [ ! -d "$BUILDDIR" ] ; then
        mkdir "$BUILDDIR"
    fi

    for url in "${DISTFILES[@]}" ; do
        name="$(basename "$url")"
        if [ ! -e "${DISTDIR}/${name}" ] ; then
            printf '>> Fetching %s\n' "${name}"
            curl -sSLo "${DISTDIR}/${name}" "$url" || die "Unable to download ${name}"
        fi
        printf '>> Extracting %s\n' "${name}"
        tar xf "${DISTDIR}/${name}" -C "${BUILDDIR}" || die "Unable to extract ${name}"
    done
}

apply_patches() {
    PATCHDIR="$PWD/patches"
    (
        cd "$BUILDDIR"
        for patch in "$PATCHDIR/"*.patch ; do
            printf '>> Applying patch %s\n' "$(basename "$path")"
            patch -p0 < $patch
        done
    )
}

make_dockerfile() {
    IMAGE="$(docker $BUILDCMD -q "$PWD")"
    if [ "$?" -ne 0 ] ; then
        die "Docker image build failed!"
    fi
}

[ -z "$NOBUILD" ] && docker_detect
fetch_and_extract
apply_patches
if [ -z "$NOBUILD" ] ; then
    make_dockerfile
    mkdir -p "${OUTDIR}"
    docker run --rm -v "${BUILDDIR}:/src" -v "${OUTDIR}:/out" "$IMAGE"
fi
