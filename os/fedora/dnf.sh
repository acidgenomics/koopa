#!/usr/bin/env bash
set -Eeu -o pipefail

# """
# What's up with this:
# sudo: setrlimit(RLIMIT_CORE): Operation not permitted
#
# Missing: top, uptime
# """

dnf -y update
dnf -y install \
    R \
    curl \
    fish \
    git \
    hostname \
    man \
    parallel \
    tree \
    util-linux-user \
    wget \
    which \
    zsh

rm -fr /usr/local/koopa
curl -sSL https://koopa.acidgenomics.com/install \
    | bash -s -- --shared --test
