#!/usr/bin/env bash

# FIXME Consider installing latest stable version of GHC.

main() {
    # """
    # Install hadolint.
    # @note Updated 2022-11-15.
    #
    # Recommended to use cabal instead of stack starting in 2022-11.
    #
    # @section Removal of 'stack.yaml' config in 2.11.0:
    # Manual 'stack.yaml' configuration is required for 2.11.0, 2.12.0.
    # Latest cabal configuration is here:
    # - https://github.com/hadolint/hadolint/blob/master/hadolint.cabal
    # Our current configuration is adapted from 2.10.0:
    # - https://github.com/hadolint/hadolint/tree/v2.10.0
    #
    # @section Hackage dependency info:
    # - https://hackage.haskell.org/package/ShellCheck
    # - https://hackage.haskell.org/package/colourista
    # - https://hackage.haskell.org/package/language-docker
    # - https://hackage.haskell.org/package/spdx
    # - https://hackage.haskell.org/package/hspec
    # - https://hackage.haskell.org/package/hspec-core
    # - https://hackage.haskell.org/package/hspec-discover
    # - https://hackage.haskell.org/package/stm
    #
    # @seealso
    # - https://github.com/hadolint/hadolint
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     hadolint.rb
    # - https://docs.haskellstack.org/en/stable/GUIDE/
    # - https://hackage.haskell.org/
    # - https://www.stackage.org/
    # - https://github.com/commercialhaskell/stack/issues/4408
    # - Last working stack config:
    #   https://github.com/hadolint/hadolint/blob/v2.10.0/stack.yaml
    # - https://github.com/hadolint/hadolint/blob/master/.github/
    #     workflows/haskell.yml
    # - https://github.com/hadolint/hadolint/issues/899
    # - Stack configuration removal:
    #   https://github.com/hadolint/hadolint/commit/
    #     12473f0317f35fb685c19caaac8a253d187a99c9
    # """
    local app dict
    declare -A app=(
        ['cabal']="$(koopa_locate_cabal)"
        ['ghcup']="$(koopa_locate_ghcup)"
    )
    [[ -x "${app['cabal']}" ]] || return 1
    [[ -x "${app['ghcup']}" ]] || return 1
    declare -A dict=(
        ['ghc_prefix']="$(koopa_init_dir 'ghc')"
        ['ghc_version']='9.0.2'
        ['jobs']="$(koopa_cpu_count)"
        ['name']='hadolint'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    "${app['ghcup']}" install \
        ghc "${dict['ghc_version']}" \
            --isolate "${dict['ghc_prefix']}"
    koopa_add_to_path_start "${dict['ghc_prefix']}/bin"
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/${dict['name']}/${dict['name']}/\
archive/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    koopa_print_env
    cabal configure \
        --jobs="${dict['jobs']}" \
        --prefix="${dict['prefix']}"
    cabal build
    cabal install \
        --jobs="${dict['jobs']}" \
        --prefix="${dict['prefix']}"
    return 0
}
