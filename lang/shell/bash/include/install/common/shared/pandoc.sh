#!/usr/bin/env bash

# FIXME Building of 3.0 is not currently supported by stack?
#2023-01-18 19:43:10.008732: [debug] (SQL) SELECT "id" FROM "last_performed" WHERE _ROWID_=last_insert_rowid(); []
#2023-01-18 19:43:10.009570: [debug] Not reading lock file
#2023-01-18 19:43:10.294177: [debug] Loaded snapshot from third party: https://raw.githubusercontent.com/commercialhaskell/stackage-snapshots/master/lts/20/6.yaml
#2023-01-18 19:43:10.492242: [error] /private/var/folders/l1/8y8sjzmn15v49jgrqglghcfr0000gn/T/koopa-501-20230118-194308-kN3Rp05IsE/pandoc-3.0/pandoc-cli: getDirectoryContents:openDirStream: does not exist (No such file or directory)
#
# FIXME Consider using ghcup / ghc / cabal approach instead?
# https://github.com/jgm/pandoc/blob/main/INSTALL.md

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
    # """
    local app dict install_args stack_args
    koopa_assert_is_not_aarch64
    koopa_activate_app --build-only 'haskell-stack'
    koopa_activate_app 'zlib'
    declare -A app=(
        ['stack']="$(koopa_locate_stack)"
    )
    [[ -x "${app['stack']}" ]] || return 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='pandoc'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['stack_root']="$(koopa_init_dir 'stack')"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    dict['url']="https://hackage.haskell.org/package/\
${dict['name']}-${dict['version']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    dict['zlib']="$(koopa_app_prefix 'zlib')"
    stack_args=(
        "--jobs=${dict['jobs']}"
        "--stack-root=${dict['stack_root']}"
        '--verbose'
        "--extra-include-dirs=${dict['zlib']}/include"
        "--extra-lib-dirs=${dict['zlib']}/lib"
    )
    install_args=(
        "--local-bin-path=${dict['prefix']}/bin"
    )
    "${app['stack']}" "${stack_args[@]}" install "${install_args[@]}"
    return 0
}
