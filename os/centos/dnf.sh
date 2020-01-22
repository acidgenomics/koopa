#!/bin/sh

# fish isn't currently available.

# Need to fix this warning:
# Failed to set locale, defaulting to C.

# Koopa check warnings:
# Setting LC_* failed, using "C"

# Run this to enable EPEL 8, if necessary:
# > dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

dnf -y install \
    dnf-plugins-core \
    epel-release
dnf -y config-manager --set-enabled PowerTools
dnf -y update
dnf -y install \
    R \
    curl \
    git \
    hostname \
    man \
    parallel \
    sudo \
    tree \
    util-linux-user \
    wget \
    which \
    zsh
