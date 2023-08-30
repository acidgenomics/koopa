#!/usr/bin/env bash

# FIXME Work on standardizing our cabal install code.

main() {
    # """
    # Install ShellCheck.
    # @note Updated 2023-04-12.
    #
    # @seealso
    # - https://hackage.haskell.org/package/ShellCheck
    # - https://github.com/koalaman/shellcheck/blob/master/ShellCheck.cabal
    # """
    local -A app dict
    local -a build_deps
    build_deps=('git' 'pkg-config')
    koopa_activate_app --build-only "${build_deps[@]}"
    app['cabal']="$(koopa_locate_cabal)"
    app['ghcup']="$(koopa_locate_ghcup)"
    koopa_assert_is_executable "${app[@]}"
    dict['cabal_dir']="$(koopa_init_dir 'cabal')"
    dict['ghc_version']='9.4.3'
    dict['ghcup_prefix']="$(koopa_init_dir 'ghcup')"
    dict['jobs']="$(koopa_cpu_count)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['cabal_store_dir']="$(\
        koopa_init_dir "${dict['prefix']}/libexec/cabal/store" \
    )"
    dict['ghc_prefix']="$(koopa_init_dir "ghc-${dict['ghc_version']}")"
    export CABAL_DIR="${dict['cabal_dir']}"
    export GHCUP_INSTALL_BASE_PREFIX="${dict['ghcup_prefix']}"
    koopa_print_env
    "${app['ghcup']}" install \
        'ghc' "${dict['ghc_version']}" \
            --isolate "${dict['ghc_prefix']}"
    koopa_assert_is_dir "${dict['ghc_prefix']}/bin"
    koopa_add_to_path_start "${dict['ghc_prefix']}/bin"
    koopa_init_dir "${dict['prefix']}/bin"
    "${app['cabal']}" update
    dict['cabal_config_file']="${dict['cabal_dir']}/config"
    koopa_assert_is_file "${dict['cabal_config_file']}"
    read -r -d '' "dict[cabal_config_string]" << END || true
store-dir: ${dict['cabal_store_dir']}
END
    koopa_append_string \
        --file="${dict['cabal_config_file']}" \
        --string="${dict['cabal_config_string']}"
    "${app['cabal']}" install \
        --install-method='copy' \
        --installdir="${dict['prefix']}/bin" \
        --jobs="${dict['jobs']}" \
        --verbose \
        "ShellCheck-${dict['version']}"
    return 0
}
