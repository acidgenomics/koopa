#!/usr/bin/env bash

main() {
    # """
    # Install hadolint.
    # @note Updated 2023-01-19.
    #
    # @seealso
    # - https://github.com/hadolint/hadolint
    # - https://cabal.readthedocs.io/
    # - https://cabal.readthedocs.io/en/stable/installing-packages.html
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     hadolint.rb
    # - https://github.com/hadolint/hadolint/issues/904
    # """
    local app build_deps dict
    koopa_assert_is_not_aarch64
    build_deps=('git' 'pkg-config')
    koopa_activate_app --build-only "${build_deps[@]}"
    declare -A app=(
        ['cabal']="$(koopa_locate_cabal)"
        ['ghcup']="$(koopa_locate_ghcup)"
    )
    [[ -x "${app['cabal']}" ]] || return 1
    [[ -x "${app['ghcup']}" ]] || return 1
    declare -A dict=(
        ['cabal_dir']="$(koopa_init_dir 'cabal')"
        ['ghc_version']='9.2.5'
        ['jobs']="$(koopa_cpu_count)"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    # Avoid wasting space in '~/.cabal'.
    export CABAL_DIR="${dict['cabal_dir']}"
    dict['ghc_prefix']="$(koopa_init_dir "ghc-${dict['ghc_version']}")"
    "${app['ghcup']}" install \
        'ghc' "${dict['ghc_version']}" \
            --isolate "${dict['ghc_prefix']}"
    koopa_assert_is_dir "${dict['ghc_prefix']}/bin"
    koopa_add_to_path_start "${dict['ghc_prefix']}/bin"
    koopa_print_env
    koopa_init_dir "${dict['prefix']}/bin"
    "${app['cabal']}" v2-update
    "${app['cabal']}" v2-install \
        --install-method='copy' \
        --installdir="${dict['prefix']}/bin" \
        --jobs="${dict['jobs']}" \
        --verbose \
        "hadolint-${dict['version']}"
    return 0
}
