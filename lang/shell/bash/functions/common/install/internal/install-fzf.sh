#!/usr/bin/env bash

# NOTE Safe to ignore this warning/error:
# fatal: not a git repository (or any of the parent directories): .git

koopa:::install_fzf() { # {{{1
    # """
    # Install fzf.
    # @note Updated 2021-11-23.
    # @seealso
    # - https://github.com/junegunn/fzf/blob/master/BUILD.md
    # """
    local app dict
    declare -A app=(
        [make]="$(koopa::locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa::cpu_count)"
        [name]='fzf'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    koopa::activate_go
    koopa::assert_is_installed 'go'
    dict[file]="${dict[version]}.tar.gz"
    dict[url]="https://github.com/junegunn/${dict[name]}/archive/${dict[file]}"
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::extract "${dict[file]}"
    koopa::cd "${dict[name]}-${dict[version]}"
    export FZF_VERSION="${dict[version]}"
    export FZF_REVISION='tarball'
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" test
    # This will copy fzf binary from 'target/' to 'bin/'.
    "${app[make]}" install
    # > ./install --help
    ./install --bin --no-update-rc
    koopa::cp \
        --target-directory="${dict[prefix]}" \
        'bin' 'doc' 'man' 'plugin' 'shell'
    return 0
}
