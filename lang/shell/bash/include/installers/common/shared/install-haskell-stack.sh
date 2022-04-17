#!/usr/bin/env bash


main() { # {{{1
    # """
    # Install Haskell Stack.
    # @note Updated 2022-04-17.
    #
    # GHC will be installed at:
    # libexec/root/programs/x86_64-osx/ghc-9.0.2/bin
    #
    # Potentially useful arguments:
    # * '--allow-different-user'
    # * '--local-bin-path'
    # * '--stack-root'
    #
    # @seealso
    # - stack --help
    # - stack path
    # - stack exec env
    # - stack ghc, stack ghci, stack runghc, or stack exec
    # - https://docs.haskellstack.org/en/stable/install_and_upgrade/
    # - https://github.com/commercialhaskell/stack/releases
    # - https://github.com/commercialhaskell/stack/issues/2028
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app
    declare -A dict=(
        [arch]="$(koopa_arch)" # e.g. 'x86_64'.
        [jobs]="$(koopa_cpu_count)"
        [name]='stack'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    app[stack]="${dict[prefix]}/bin/stack"
    if koopa_is_linux
    then
        dict[platform]='linux'
    elif koopa_is_macos
    then
        dict[platform]='osx'
    fi
    dict[root]="${dict[prefix]}/libexec"
    dict[file]="${dict[name]}-${dict[version]}-${dict[platform]}-\
${dict[arch]}-bin"
    dict[url]="https://github.com/commercialhaskell/${dict[name]}/releases/\
download/v${dict[version]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_chmod 'u+x' "${dict[file]}"
    koopa_cp "${dict[file]}" "${app[stack]}"
    unset -v STACK_ROOT
    koopa_rm "${HOME:?}/.stack"
    "${app[stack]}" \
        --jobs="${dict[jobs]}" \
        --stack-root="${dict[root]}" \
        setup
    # NOTE Can install a specific GHC version here with:
    # > stack install ghc-9.0.2
    return 0
}
