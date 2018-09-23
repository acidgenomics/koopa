#!/usr/bin/env bash

# koopa info box.
# 2018-09-23

# Can disable local message with `-n "$SSH_CLIENT"`.

# Padded strings in bash:
# https://stackoverflow.com/questions/4409399

# Don't redisplay for HPC interactive session.
if [[ -n "$KOOPA_INTERACTIVE_JOB" ]]; then
    exit 0
fi

array=()
array+=("koopa v${KOOPA_VERSION} (${KOOPA_DATE})")
array+=("https://github.com/steinbaugh/koopa")

# Alternatively, can use `$( uname -mnrs )`.
array+=("System: $KOOPA_SYSTEM")

aspera="$(which asperaconnect)"
if [[ -f "$aspera" ]]; then
    array+=("Aspera: ${aspera}")
fi
unset -v aspera

bcbio="$(which bcbio_nextgen.py)"
if [[ -f "$bcbio" ]]; then
    array+=("bcbio: ${bcbio}")
fi
unset -v bcbio

conda="$(which conda)"
if [[ -f "${conda}" ]]; then
    array+=("Conda: ${conda}")
fi
unset -v conda

r="$(which R)"
if [[ -f "$r" ]]; then
    array+=("R: ${r}")
fi
unset -v r

python="$(which python)"
if [[ -f "${python}" ]]; then
    array+=("Python: ${python}")
fi
unset -v python

perl="$(which perl)"
if [[ -f "$perl" ]]; then
    array+=("Perl: ${perl}")
fi
unset -v perl

ruby="$(which ruby)"
if [[ -f "$ruby" ]]; then
    array+=("Ruby: ${ruby}")
fi
unset -v ruby

git="$(which git)"
if [[ -f "$git" ]]; then
    array+=("Git: ${git}")
fi
unset -v git

openssl="$(which openssl)"
if [[ -f "$openssl" ]]; then
    array+=("OpenSSL: ${openssl}")
fi
unset -v openssl

gpg="$(which gpg)"
if [[ -f "$gpg" ]]; then
    array+=("GPG: ${gpg}")
fi
unset -v gpg

# Using unicode box drawings here.
barpad="$(printf "━%.0s" {1..70})"
printf "\n  %s%s%s  \n"  "┏" "$barpad" "┓"
for i in "${array[@]}"; do
    printf "  ┃ %-68s ┃  \n"  "$i"
done
printf "  %s%s%s  \n\n"  "┗" "$barpad" "┛"

unset -v array barpad
