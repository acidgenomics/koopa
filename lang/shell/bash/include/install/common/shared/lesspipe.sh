#!/usr/bin/env bash

main() {
    # """
    # Install lesspipe.
    # @note Updated 2022-07-15.
    #
    # @seealso
    # - https://github.com/wofr06/lesspipe
    # - https://github.com/Homebrew/homebrew-core/blob/master/
    #     Formula/lesspipe.rb
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'make'
    declare -A app
    app['make']="$(koopa_locate_make)"
    [[ -x "${app['make']}" ]] || exit 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='lesspipe'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/wofr06/lesspipe/archive/refs/\
tags/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    # Refer to line 62.
    # shellcheck disable=SC2016
    koopa_find_and_replace_in_file \
        --fixed \
        --pattern='\$(DESTDIR)/etc/bash_completion.d' \
        --replacement='\$(DESTDIR)\$(PREFIX)/etc/bash_completion.d' \
        'configure'
    conf_args=("--prefix=${dict['prefix']}")
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    # > "${app['make']}" test
    "${app['make']}" install
    return 0
}
