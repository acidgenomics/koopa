#!/usr/bin/env bash

# NOTE Safe to ignore this warning/error:
# fatal: not a git repository (or any of the parent directories): .git

koopa:::install_fzf() { # {{{1
    # """
    # Install fzf.
    # @note Updated 2021-06-08.
    # @seealso
    # - https://github.com/junegunn/fzf/blob/master/BUILD.md
    # """
    local file jobs make name prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    koopa::activate_go
    koopa::assert_is_installed 'go'
    jobs="$(koopa::cpu_count)"
    make="$(koopa::locate_make)"
    name='fzf'
    koopa::mkdir "$prefix"
    file="${version}.tar.gz"
    url="https://github.com/junegunn/${name}/archive/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    export FZF_VERSION="$version"
    export FZF_REVISION='tarball'
    "$make" --jobs="$jobs"
    # > "$make" test
    # This will copy fzf binary from 'target/' to 'bin/'.
    "$make" install
    # > ./install --help
    ./install --bin --no-update-rc
    koopa::cp \
        --target-directory="$prefix" \
        'bin' \
        'doc' \
        'man' \
        'plugin' \
        'shell'
    return 0
}
