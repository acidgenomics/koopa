#!/usr/bin/env bash

# NOTE Seeing warnings on macOS from ranlib, regarding no symbols for some
# GHC 8.10.7 files

main() {
    # """
    # Install Pandoc.
    # @note Updated 2022-06-14.
    #
    # @seealso
    # - stack install --help
    # - https://hackage.haskell.org/package/pandoc-1.16/src/INSTALL
    # - https://github.com/jgm/pandoc/wiki/
    #     Installing-the-development-version-of-pandoc
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/pandoc.rb
    # - https://github.com/commercialhaskell/stack/issues/342
    # """
    local app dict stack_args
    koopa_activate_opt_prefix 'haskell-stack'
    declare -A app=(
        [stack]="$(koopa_locate_stack)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='pandoc'
        [opt_prefix]="$(koopa_opt_prefix)"
        [prefix]="${INSTALL_PREFIX:?}"
        [stack_root]="$(koopa_init_dir 'stack')"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="https://hackage.haskell.org/package/\
${dict[name]}-${dict[version]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    stack_args=(
        "--jobs=${dict[jobs]}"
        "--stack-root=${dict[stack_root]}"
    )
    "${app[stack]}" "${stack_args[@]}" \
        install --local-bin-path="${dict[prefix]}/bin"
    return 0
}
