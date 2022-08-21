#!/usr/bin/env bash

main() {
    # """
    # Install Pandoc.
    # @note Updated 2022-08-11.
    #
    # This may require system zlib to be installed currently.
    #
    # @seealso
    # - stack install --help
    # - https://hackage.haskell.org/package/pandoc-1.16/src/INSTALL
    # - https://github.com/jgm/pandoc/wiki/
    #     Installing-the-development-version-of-pandoc
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/pandoc.rb
    # - https://github.com/commercialhaskell/stack/issues/342
    # """
    local app dict install_args stack_args
    koopa_activate_build_opt_prefix 'haskell-stack'
    koopa_activate_opt_prefix 'zlib'
    declare -A app=(
        [stack]="$(koopa_locate_stack)"
    )
    [[ -x "${app['stack']}" ]] || return 1
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='pandoc'
        [prefix]="${INSTALL_PREFIX:?}"
        [stack_root]="$(koopa_init_dir 'stack')"
        [version]="${INSTALL_VERSION:?}"
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
