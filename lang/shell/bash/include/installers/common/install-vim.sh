#!/usr/bin/env bash

install_vim() { # {{{1
    # """
    # Install Vim.
    # @note Updated 2021-12-01.
    #
    # On Ubuntu, '--enable-rubyinterp' currently causing a false positive error
    # related to ncurses, even when '--with-tlib' is correctly set.
    #
    # @seealso
    # - https://github.com/vim/vim/issues/1081
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa_locate_make)"
        [python]="$(koopa_locate_python)"
    )
    app[python]="$(koopa_realpath "${app[python]}")"
    app[python_config]="${app[python]}-config"
    koopa_assert_is_installed "${app[python]}" "${app[python_config]}"
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='vim'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="v${dict[version]}.tar.gz"
    dict[url]="https://github.com/${dict[name]}/${dict[name]}/\
archive/${dict[file]}"
    dict[python_config_dir]="$("${app[python_config]}" --configdir)"
    koopa_assert_is_dir "${dict[python_config_dir]}"
    conf_args=(
        "--prefix=${dict[prefix]}"
        "--with-python3-command=${app[python]}"
        "--with-python3-config-dir=${dict[python_config_dir]}"
        '--enable-python3interp'
    )
    dict[vim_rpath]="${dict[prefix]}/lib"
    dict[python_rpath]="$(koopa_parent_dir --num=2 "${app[python]}")/lib"
    koopa_assert_is_dir "${dict[python_rpath]}"
    if koopa_is_linux
    then
        conf_args+=(
            "LDFLAGS=-Wl,-rpath=${dict[vim_rpath]},-rpath=${dict[python_rpath]}"
        )
    elif koopa_is_macos
    then
        conf_args+=(
            '--enable-cscope'
            '--enable-gui=no'
            '--enable-luainterp'
            '--enable-multibyte'
            '--enable-perlinterp'
            '--enable-rubyinterp'
            '--enable-terminal'
            '--with-tlib=ncurses'
            '--without-x'
        )
    fi
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" test
    "${app[make]}" install
    return 0
}
