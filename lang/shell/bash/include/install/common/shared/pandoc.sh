#!/usr/bin/env bash

main() {
    # """
    # Install Pandoc.
    # @note Updated 2023-01-18.
    #
    # This may require system zlib to be installed currently.
    #
    # @seealso
    # - https://github.com/jgm/pandoc/blob/main/INSTALL.md
    # - stack install --help
    # - https://hackage.haskell.org/package/pandoc-1.16/src/INSTALL
    # - https://github.com/jgm/pandoc/wiki/
    #     Installing-the-development-version-of-pandoc
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/pandoc.rb
    # - https://github.com/commercialhaskell/stack/issues/342
    # - https://github.com/jgm/pandoc/blob/main/pandoc.cabal
    # """
    local app dict
    koopa_assert_is_not_aarch64
    koopa_activate_app --build-only 'haskell-stack'
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
    )
    # Avoid wasting space in '~/.cabal'.
    export CABAL_DIR="${dict['cabal_dir']}"
    dict['ghc_prefix']="$(koopa_init_dir "ghc-${dict['ghc_version']}")"
    "${app['ghcup']}" install \
        'ghc' "${dict['ghc_version']}" \
            --isolate "${dict['ghc_prefix']}"
    koopa_assert_is_dir "${dict['ghc_prefix']}/bin"
    koopa_add_to_path_start "${dict['ghc_prefix']}/bin"
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    dict['url']="https://hackage.haskell.org/package/\
${dict['name']}-${dict['version']}/${dict['file']}"
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
