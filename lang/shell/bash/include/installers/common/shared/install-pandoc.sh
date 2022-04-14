#!/usr/bin/env bash

# NOTE Seeing warnings on macOS from ranlib, regarding no symbols for some
# GHC 8.10.7 files

main() { # {{{1
    # """
    # Install Pandoc.
    # @note Updated 2022-04-14.
    #
    # @seealso
    # - stack install --help
    # - https://hackage.haskell.org/package/pandoc-1.16/src/INSTALL
    # - https://github.com/jgm/pandoc/wiki/Installing-the-development-version-of-pandoc
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/pandoc.rb
    # - https://github.com/commercialhaskell/stack/issues/342
    # """
    local app dict
    koopa_activate_opt_prefix 'haskell-stack'
    declare -A app=(
        [stack]="$(koopa_locate_stack)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='pandoc'
        [opt_prefix]="$(koopa_opt_prefix)"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[stack_root]="${dict[opt_prefix]}/haskell-stack/libexec"
    koopa_assert_is_dir "${dict[stack_root]}"
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="https://hackage.haskell.org/package/\
${dict[name]}-${dict[version]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    "${app[stack]}" \
        --jobs="${dict[jobs]}" \
        --stack-root="${dict[stack_root]}" \
        install \
            --local-bin-path="${dict[prefix]}/bin"
    return 0
}
