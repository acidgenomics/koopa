#!/usr/bin/env bash

main() {
    # """
    # Install lesspipe.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://github.com/wofr06/lesspipe
    # - https://github.com/Homebrew/homebrew-core/blob/master/
    #     Formula/lesspipe.rb
    # """
    local -A app dict
    local -a conf_args
    koopa_activate_app --build-only 'make'
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    dict['name']='lesspipe'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
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
