#!/bin/sh

# Perlbrew
# https://perlbrew.pl

# Installation instructions
# https://metacpan.org/pod/App::perlbrew
# https://github.com/gugod/App-perlbrew/wiki/Perlbrew-In-Shell-Scripts

# To install, run:
# curl -L https://install.perlbrew.pl | bash

[ -z "$PERLBREW_ROOT" ] && \
    export PERLBREW_ROOT="${HOME}/perl5/perlbrew"
[ -z "$PERLBREW_HOME" ] && \
    export PERLBREW_HOME="${HOME}/.perlbrew"

# Note that script is only compatible with bash and zsh.
file="${PERLBREW_ROOT}/etc/bashrc"
# shellcheck disable=SC1090
[ -f "$file" ] && . "$file"
unset -v file
