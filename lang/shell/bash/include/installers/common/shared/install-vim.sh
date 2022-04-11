#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install Vim.
    # @note Updated 2022-04-11.
    #
    # On Ubuntu, '--enable-rubyinterp' currently causing a false positive error
    # related to ncurses, even when '--with-tlib' is correctly set.
    #
    # @seealso
    # - https://github.com/vim/vim/issues/1081
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_opt_prefix 'ncurses' 'python'
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='vim'
        [opt_prefix]="$(koopa_opt_prefix)"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    # FIXME Need to create directory or set '--allow-missing' here.
    dict[vim_rpath]="${dict[prefix]}/lib"
    dict[python_rpath]="${dict[opt_prefix]}/python/lib"
    koopa_assert_is_dir "${dict[python_rpath]}"
    app[python]="${dict[opt_prefix]}/python/bin/python3"
    app[python_config]="${app[python]}-config"
    koopa_assert_is_installed "${app[python]}" "${app[python_config]}"
    dict[python_config_dir]="$("${app[python_config]}" --configdir)"
    koopa_assert_is_dir "${dict[python_config_dir]}"
    dict[file]="v${dict[version]}.tar.gz"
    dict[url]="https://github.com/${dict[name]}/${dict[name]}/\
archive/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    conf_args=(
        "--prefix=${dict[prefix]}"
        # > '--enable-cscope'
        # > '--enable-luainterp'
        # > '--enable-perlinterp'
        # > '--enable-rubyinterp'
        '--enable-multibyte'
        '--enable-python3interp'
        '--enable-terminal'
        '--with-tlib=ncurses'
        "--with-python3-command=${app[python]}"
        "--with-python3-config-dir=${dict[python_config_dir]}"
    )
    if koopa_is_macos
    then
        conf_args+=(
            '--enable-gui=no'
            '--without-x'
        )
    fi
    koopa_add_to_ldflags_start \
        --allow-missing \
        "${dict[python_rpath]}" \
        "${dict[vim_rpath]}"
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" test
    "${app[make]}" install
    return 0
}
