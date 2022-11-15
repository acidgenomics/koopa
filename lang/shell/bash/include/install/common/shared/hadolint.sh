#!/usr/bin/env bash

# FIXME Need to rework target prefix handling...cabal is annoying with this.
# Symlinking 'hadolint' to '/Users/mike/.cabal/bin/hadolint'
# FIXME Can we increase verbosity?

# FIXME Rework using sandbox approach:
# cabal sandbox init                   # Initialise the sandbox
# $ cabal install --only-dependencies    # Install dependencies into the sandbox
# $ cabal build                          # Build your package inside the sandbox

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
    # - https://cabal.readthedocs.io/en/3.2/installing-packages.html
    # """
    local app build_deps dict
    build_deps=('git' 'pkg-config')
    koopa_activate_app --build-only "${build_deps[@]}"
    declare -A app=(
        ['cabal']="$(koopa_locate_cabal)"
        ['ghcup']="$(koopa_locate_ghcup)"
    )
    [[ -x "${app['cabal']}" ]] || return 1
    [[ -x "${app['ghcup']}" ]] || return 1
    declare -A dict=(
        ['ghc_version']='9.0.2'
        ['jobs']="$(koopa_cpu_count)"
        ['name']='hadolint'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['ghc_prefix']="$(koopa_init_dir "ghc-${dict['ghc_version']}")"
    "${app['ghcup']}" install \
        'ghc' "${dict['ghc_version']}" \
            --isolate "${dict['ghc_prefix']}"
    koopa_assert_is_dir "${dict['ghc_prefix']}/bin"
    koopa_add_to_path_start "${dict['ghc_prefix']}/bin"
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/${dict['name']}/${dict['name']}/\
archive/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    koopa_print_env
    "${app['cabal']}" update
    "${app['cabal']}" configure \
        --jobs="${dict['jobs']}" \
        --verbose
    "${app['cabal']}" build \
        --jobs="${dict['jobs']}" \
        --verbose
    "${app['cabal']}" install \
        --install-method='copy' \
        --installdir="${dict['prefix']}" \
        --jobs="${dict['jobs']}" \
        --verbose
    return 0
}
