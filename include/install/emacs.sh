#!/usr/bin/env bash
# 
# https://github.com/Homebrew/homebrew-core/blob/master/Formula/emacs.rb

# Seeing this error on macOS:
# Nothing to be done for 'maybe-blessmail'.

file="emacs-${version}.tar.xz"
url="${gnu_mirror}/emacs/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "emacs-${version}"
flags=("--prefix=${prefix}")
if koopa::is_macos
then
    flags+=(
        '--disable-silent-rules'
        '--with-gnutls'
        '--with-modules'
        '--with-xml2'
        '--without-dbus'
        '--without-imagemagick'
        '--without-ns'
        '--without-x'
    )
else
    flags+=(
        '--with-x-toolkit=no'
        '--with-xpm=no'
    )
fi
./configure "${flags[@]}"
make --jobs="$jobs"
make install
