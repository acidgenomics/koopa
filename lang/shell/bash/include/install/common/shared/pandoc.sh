#!/usr/bin/env bash

# FIXME Need to change ghcup prefix.
# FIXME Consider just adjusting the cabal global store.
# https://cabal.readthedocs.io/en/latest/nix-local-build.html
# configurable via global 'store-dir' option

main() {
    # """
    # Install Pandoc.
    # @note Updated 2023-01-25.
    #
    # @seealso
    # - https://hackage.haskell.org/package/pandoc
    # - https://hackage.haskell.org/package/pandoc-cli
    # - https://github.com/jgm/pandoc/blob/main/CONTRIBUTING.md
    # - https://github.com/jgm/pandoc/blob/main/INSTALL.md
    # - https://cabal.readthedocs.io/
    # - https://cabal.readthedocs.io/en/latest/nix-local-build-overview.html
    # - https://cabal.readthedocs.io/en/stable/cabal-project.html
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/pandoc.rb
    # """
    local app build_deps dict
    koopa_assert_is_not_aarch64
    build_deps=('git' 'pkg-config')
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app 'zlib'
    declare -A app=(
        ['cabal']="$(koopa_locate_cabal)"
        ['ghcup']="$(koopa_locate_ghcup)"
    )
    [[ -x "${app['cabal']}" ]] || return 1
    [[ -x "${app['ghcup']}" ]] || return 1
    declare -A dict=(
        ['ghc_version']='9.4.4'
        ['jobs']="$(koopa_cpu_count)"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
        ['zlib']="$(koopa_app_prefix 'zlib')"
    )
    case "${dict['version']}" in
        '3.0')
            dict['cli_version']='0.1'
            ;;
    esac
    koopa_assert_is_dir "${dict['zlib']}"
    dict['cabal_dir']="$(koopa_init_dir "${dict['prefix']}/libexec/cabal")"
    export CABAL_DIR="${dict['cabal_dir']}"
    dict['ghc_prefix']="$(koopa_init_dir "ghc-${dict['ghc_version']}")"
    "${app['ghcup']}" install \
        'ghc' "${dict['ghc_version']}" \
            --isolate "${dict['ghc_prefix']}"
    koopa_assert_is_dir "${dict['ghc_prefix']}/bin"
    koopa_add_to_path_start "${dict['ghc_prefix']}/bin"
    koopa_init_dir "${dict['prefix']}/bin"
    koopa_print_env
    "${app['cabal']}" v2-update
    # NOTE Consider version pinning pandoc-cli to 0.1 here.
    "${app['cabal']}" v2-install \
        --extra-include-dirs="${dict['zlib']}/include" \
        --extra-lib-dirs="${dict['zlib']}/lib" \
        --install-method='copy' \
        --installdir="${dict['prefix']}/bin" \
        --jobs="${dict['jobs']}" \
        --verbose \
        "pandoc-${dict['version']}" \
        "pandoc-cli-${dict['cli_version']}"
    return 0
}
