#!/usr/bin/env bash

main() {
    # """
    # Install hadolint.
    # @note Updated 2022-07-15.
    #
    # @seealso
    # - https://github.com/hadolint/hadolint
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     hadolint.rb
    # """
    local app dict install_args stack_args
    koopa_activate_build_opt_prefix 'haskell-stack'
    declare -A app=(
        ['stack']="$(koopa_locate_stack)"
    )
    [[ -x "${app['stack']}" ]] || return 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='hadolint'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['stack_root']="$(koopa_init_dir 'stack')"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/${dict['name']}/${dict['name']}/\
archive/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    stack_args=(
        "--jobs=${dict['jobs']}"
        "--stack-root=${dict['stack_root']}"
        '--verbose'
    )
    install_args=("--local-bin-path=${dict['prefix']}/bin")
    "${app['stack']}" "${stack_args[@]}" install "${install_args[@]}"
    return 0
}
