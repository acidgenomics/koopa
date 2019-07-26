#!/usr/bin/env bash

## Install GNU core utilities.
## Updated 2019-06-25.

## See also:
## - https://ftp.gnu.org/gnu/coreutils/

_koopa_assert_has_no_environments

name="coreutils"
version="$(koopa variable "$name")"
prefix="$(koopa cellar-prefix)/${name}/${version}"
tmp_dir="$(koopa tmp-dir)/${name}"
build_os_string="$(koopa build-os-string)"
exe_file="${prefix}/bin/env"

printf "Installing %s %s.\n" "$name" "$version"

(
    rm -rf "$tmp_dir"
    mkdir -p "$tmp_dir"
    cd "$tmp_dir" || exit 1
    wget "https://ftp.gnu.org/gnu/coreutils/coreutils-${version}.tar.xz"
    tar -xJvf "coreutils-${version}.tar.xz"
    cd "coreutils-${version}" || exit 1
    ./configure \
        --build="$build_os_string" \
        --prefix="$prefix"
    make
    ## > make check
    make install
    rm -rf "$tmp_dir"
)

link-cellar "$name" "$version"

if _koopa_has_sudo
then
    build_prefix="$(koopa build-prefix)"
    printf "Replacing '/usr/bin/env' with '/usr/local/bin/env'.\n"
    if [[ ! -L "/usr/bin/env" ]]
    then
        printf "System version will be renamed to 'env.bak'.\n"
        sudo mv "/usr/bin/env" "/usr/bin/env.bak"
    else
        sudo rm -f "/usr/bin/env"
    fi
    sudo ln -fns "${build_prefix}/bin/env" "/usr/bin/env"
fi

"$exe_file" --version
command -v "$exe_file"
