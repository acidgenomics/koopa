#!/usr/bin/env bash

# FIXME Do we need to install 'cabal-install' here?
# FIXME Is there a way to install a specific version of stack?
# FIXME Should we install ghc-8.10.7 here for pandoc?

main() { # {{{1
    # """
    # Install Haskell Stack.
    # @note Updated 2022-04-14.
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
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [prefix]="${INSTALL_PREFIX:?}"
    )
    dict[root]="${dict[prefix]}/libexec/root"
    dict[xdg_bin_dir]="$(koopa_xdg_local_home)/bin"
    koopa_mkdir "${dict[xdg_bin_dir]}"
    koopa_add_to_path_start "${dict[xdg_bin_dir]}"
    dict[file]='stack.sh'
    dict[url]='https://get.haskellstack.org/'
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_chmod 'u+x' "${dict[file]}"
    koopa_mkdir "${dict[prefix]}/bin"
    unset -v STACK_ROOT
    koopa_rm "${HOME:?}/.stack"
    ./"${dict[file]}" -f -d "${dict[prefix]}/bin"
    app[stack]="${dict[prefix]}/bin/stack"
    koopa_assert_is_installed "${app[stack]}"
    "${app[stack]}" \
        --jobs="${dict[jobs]}" \
        --stack-root="${dict[root]}" \
        setup
    # NOTE Consider checking that GHC gets installed where we're expecting.
    # NOTE Is there a way to populate the cabal files index here?
    return 0
}
