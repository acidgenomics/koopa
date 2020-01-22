#!/bin/sh

# Optional dependencies for r
#     tk: tcl/tk interface
#     texlive-bin: latex sty files
#     gcc-fortran: needed to compile some CRAN packages
#     openblas: faster linear algebra

# Note that Arch is currently overwriting PS1 for root.
# This is the source: /etc/profile
# > Source global bash config
# > if test "$PS1" && test "$BASH" && test -z ${POSIXLY_CORRECT+x} && 
# > test -r /etc/bash.bashrc; then
# >         . /etc/bash.bashrc
# > fi

pacman -Syyu --noconfirm && \
    pacman-db-upgrade && \
    pacman -S --noconfirm \
        awk \
        bash \
        fish \
        git \
        grep \
        man \
        parallel \
        r \
        sudo \
        tree \
        wget \
        which \
        zsh
