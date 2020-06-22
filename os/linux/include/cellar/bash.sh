#!/usr/bin/env bash
# shellcheck disable=SC2154

minor_version="$(_koopa_major_minor_version "$version")"
file="${name}-${minor_version}.tar.gz"
url="${gnu_mirror}/${name}/${file}"
_koopa_download "$url"
_koopa_extract "$file"
cd "${name}-${minor_version}" || exit 1
# Apply patches. 
patches="$(_koopa_print "$version" | cut -d '.' -f 3)"
(
    mkdir -pv patches
    cd patches || exit 1
    # Note that GNU mirror doesn't seem to work correctly here.
    base_url="https://ftp.gnu.org/gnu/${name}/${name}-${minor_version}-patches"
    mv_tr="$(_koopa_print "$minor_version" | tr -d '.')"
    range="$(printf "%03d-%03d" "1" "$patches")"
    request="${base_url}/${name}${mv_tr}-[${range}]"
    curl "$request" -O
    cd .. || exit 1
    for file in patches/*
    do
        _koopa_info "Applying patch '${file}'."
        # Alternatively, can pipe curl call directly to 'patch -p0'.
        # https://stackoverflow.com/questions/14282617
        patch -p0 --ignore-whitespace --input="$file"
    done
)
./configure --prefix="$prefix"
make --jobs="$jobs"
# > make test
make install

_koopa_enable_shell "$name"
