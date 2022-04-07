#!/usr/bin/env bash

install_htop() { # {{{1
    # """
    # Install htop.
    # @note Updated 2021-12-07.
    #
    # Repo transferred from https://github.com/hishamhm/htop to
    # https://github.com/htop-dev/htop in 2020-08.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='htop'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[version]}.tar.gz"
    dict[url]="https://github.com/${dict[name]}-dev/${dict[name]}/\
archive/${dict[file]}"
    if koopa_is_macos
    then
        koopa_activate_opt_prefix 'autoconf' 'automake'
        koopa_macos_activate_python
    else
        koopa_activate_opt_prefix 'python'
    fi
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    ./autogen.sh
    conf_args=(
        "--prefix=${dict[prefix]}"
        '--disable-unicode'
    )
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" check
    "${app[make]}" install
    return 0
}
