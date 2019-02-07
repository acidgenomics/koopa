#!/bin/sh
# shellcheck disable=SC1090

# Perlbrew
# https://perlbrew.pl

if [ -f "${HOME}/perl5/perlbrew/etc/bashrc" ]; then
    . "${HOME}/perl5/perlbrew/etc/bashrc"
fi
