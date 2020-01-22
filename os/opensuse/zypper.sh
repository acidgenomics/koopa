#!/usr/bin/env bash
set -Eeu -o pipefail

# openSUSE uses zypper package manager by default.
# zypper cheat sheet:
# https://en.opensuse.org/images/1/17/Zypper-cheat-sheet-1.pdf

zypper refresh
zypper --non-interactive update
zypper --non-interactive install \
    R-base \
    R-base-devel \
    curl \
    fish \
    git \
    gnu_parallel \
    sudo \
    tree \
    wget \
    which \
    zsh

rm -fr /usr/local/koopa

curl -sSL https://koopa.acidgenomics.com/install | bash -s -- --shared
