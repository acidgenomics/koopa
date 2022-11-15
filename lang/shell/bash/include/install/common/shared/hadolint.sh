#!/usr/bin/env bash

main() {
    # """
    # Install hadolint.
    # @note Updated 2022-11-15.
    #
    # @seealso
    # - https://github.com/hadolint/hadolint
    # - https://cabal.readthedocs.io/en/3.2/installing-packages.html
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     hadolint.rb
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
    koopa_init_dir "${dict['prefix']}/bin"
    # NOTE Can use 'v2-*' commands here instead.
    "${app['cabal']}" update
    "${app['cabal']}" configure \
        --jobs="${dict['jobs']}" \
        --verbose
    "${app['cabal']}" build \
        --jobs="${dict['jobs']}" \
        --verbose
    "${app['cabal']}" install \
        --install-method='copy' \
        --installdir="${dict['prefix']}/bin" \
        --jobs="${dict['jobs']}" \
        --verbose
    return 0
}
