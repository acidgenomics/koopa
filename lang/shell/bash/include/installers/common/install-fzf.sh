#!/usr/bin/env bash

# NOTE Safe to ignore this warning/error:
# fatal: not a git repository (or any of the parent directories): .git

install_fzf() { # {{{1
    # """
    # Install fzf.
    # @note Updated 2022-03-30.
    # @seealso
    # - https://github.com/junegunn/fzf/blob/master/BUILD.md
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='fzf'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    koopa_activate_opt_prefix 'go'
    koopa_activate_go
    dict[file]="${dict[version]}.tar.gz"
    dict[url]="https://github.com/junegunn/${dict[name]}/archive/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    export FZF_VERSION="${dict[version]}"
    export FZF_REVISION='tarball'
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" test
    # This will copy fzf binary from 'target/' to 'bin/'.
    "${app[make]}" install
    # > ./install --help
    ./install --bin --no-update-rc
    koopa_cp \
        --target-directory="${dict[prefix]}" \
        'bin' 'doc' 'man' 'plugin' 'shell'
    return 0
}
