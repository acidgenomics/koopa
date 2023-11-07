#!/usr/bin/env bash

koopa_install_haskell_package() {
    # """
    # Install a Haskell package using Cabal and GHCup.
    # @note Updated 2023-08-30.
    #
    # @seealso
    # - https://www.haskell.org/ghc/
    # - https://www.haskell.org/cabal/
    # - https://www.haskell.org/ghcup/
    # - https://hackage.haskell.org/
    # - https://cabal.readthedocs.io/
    # - https://cabal.readthedocs.io/en/latest/nix-local-build-overview.html
    # - https://cabal.readthedocs.io/en/stable/cabal-project.html
    # """
    local -A app dict
    local -a build_deps conf_args deps extra_pkgs install_args
    local dep
    koopa_assert_is_install_subshell
    build_deps=('git' 'pkg-config')
    koopa_activate_app --build-only "${build_deps[@]}"
    app['cabal']="$(koopa_locate_cabal)"
    app['ghcup']="$(koopa_locate_ghcup)"
    koopa_assert_is_executable "${app[@]}"
    dict['cabal_dir']="$(koopa_init_dir 'cabal')"
    dict['ghc_version']='9.4.7'
    dict['ghcup_prefix']="$(koopa_init_dir 'ghcup')"
    dict['jobs']="$(koopa_cpu_count)"
    dict['name']="${KOOPA_INSTALL_NAME?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['cabal_store_dir']="$(\
        koopa_init_dir "${dict['prefix']}/libexec/cabal/store" \
    )"
    deps=()
    extra_pkgs=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--dependency='*)
                deps+=("${1#*=}")
                shift 1
                ;;
            '--dependency')
                deps+=("${2:?}")
                shift 2
                ;;
            '--extra-package='*)
                extra_pkgs+=("${1#*=}")
                shift 1
                ;;
            '--extra-package')
                extra_pkgs+=("${2:?}")
                shift 2
                ;;
            '--ghc-version='*)
                dict['ghc_version']="${1#*=}"
                shift 1
                ;;
            '--ghc-version')
                dict['ghc_version']="${2:?}"
                shift 2
                ;;
            '--name='*)
                dict['name']="${1#*=}"
                shift 1
                ;;
            '--name')
                dict['name']="${2:?}"
                shift 2
                ;;
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            '--version='*)
                dict['version']="${1#*=}"
                shift 1
                ;;
            '--version')
                dict['version']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--ghc-version' "${dict['ghc_version']}" \
        '--name' "${dict['name']}" \
        '--prefix' "${dict['prefix']}" \
        '--version' "${dict['version']}"
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
    conf_args+=("store-dir: ${dict['cabal_store_dir']}")
    if koopa_is_array_non_empty "${deps[@]}"
    then
        for dep in "${deps[@]}"
        do
            local -A dict2
            dict2['prefix']="$(koopa_app_prefix "$dep")"
            koopa_assert_is_dir \
                "${dict2['prefix']}" \
                "${dict2['prefix']}/include" \
                "${dict2['prefix']}/lib"
            conf_args+=(
                "extra-include-dirs: ${dict2['prefix']}/include"
                "extra-lib-dirs: ${dict2['prefix']}/lib"
            )
        done
    fi
    dict['cabal_config_string']="$(koopa_print "${conf_args[@]}")"
    koopa_append_string \
        --file="${dict['cabal_config_file']}" \
        --string="${dict['cabal_config_string']}"
    install_args+=(
        '--install-method=copy'
        "--installdir=${dict['prefix']}/bin"
        "--jobs=${dict['jobs']}"
        '--verbose'
        "${dict['name']}-${dict['version']}"
    )
    if koopa_is_array_non_empty "${extra_pkgs[@]}"
    then
        install_args+=("${extra_pkgs[@]}")
    fi
    "${app['cabal']}" install "${install_args[@]}"
    return 0
}
