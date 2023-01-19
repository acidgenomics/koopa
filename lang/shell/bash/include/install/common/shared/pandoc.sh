#!/usr/bin/env bash

# NOTE pandoc 3.0 is currently failing to build with cabal or stack.
# https://github.com/jgm/pandoc/issues/8560
# https://github.com/Homebrew/homebrew-core/pull/120967

main() {
    # """
    # Install Pandoc.
    # @note Updated 2023-01-19.
    #
    # @seealso
    # - https://github.com/jgm/pandoc/blob/main/INSTALL.md
    # - https://github.com/jgm/pandoc/wiki/
    #     Installing-the-development-version-of-pandoc
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
        ['cabal_dir']="$(koopa_init_dir 'cabal')"
        ['ghc_version']='9.4.4'
        ['jobs']="$(koopa_cpu_count)"
        ['name']='pandoc'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
        ['zlib']="$(koopa_app_prefix 'zlib')"
    )
    koopa_assert_is_dir "${dict['zlib']}"
    # Avoid wasting space in '~/.cabal'.
    export CABAL_DIR="${dict['cabal_dir']}"
    dict['ghc_prefix']="$(koopa_init_dir "ghc-${dict['ghc_version']}")"
    "${app['ghcup']}" install \
        'ghc' "${dict['ghc_version']}" \
            --isolate "${dict['ghc_prefix']}"
    koopa_assert_is_dir "${dict['ghc_prefix']}/bin"
    koopa_add_to_path_start "${dict['ghc_prefix']}/bin"
    dict['file']="${dict['version']}.tar.gz"
    dict['url']="https://github.com/jgm/pandoc/archive/refs/\
tags/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    koopa_print_env
    koopa_init_dir "${dict['prefix']}/bin"
    "${app['cabal']}" v2-update
    "${app['cabal']}" v2-install \
        --extra-include-dirs="${dict['zlib']}/include" \
        --extra-lib-dirs="${dict['zlib']}/lib" \
        --install-method='copy' \
        --installdir="${dict['prefix']}/bin" \
        --jobs="${dict['jobs']}" \
        --verbose \
        'pandoc-cli'
    return 0
}
