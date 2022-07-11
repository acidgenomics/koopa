#!/usr/bin/env bash

# FIXME Now running into this issue on Ubuntu:
# checking --with-tlib argument... ncurses
# checking for linking with ncurses library... configure: error: FAILED


# FIXME Need to rework this:
# checking --with-tlib argument... empty: automatic terminal library selection
# checking for tgetent in -ltinfo... no
# checking for tgetent in -lncurses... no
# checking for tgetent in -ltermlib... no
# checking for tgetent in -ltermcap... no
# checking for tgetent in -lcurses... no
# no terminal library found

main() {
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
        '--enable-huge'
        '--enable-multibyte'
        '--enable-python3interp'
        '--enable-terminal'
        "--with-python3-command=${app[python]}"
        "--with-python3-config-dir=${dict[python_config_dir]}"
        '--with-tlib=ncurses'
    )
    if koopa_is_macos
    then
        conf_args+=(
            '--enable-gui=no'
            '--without-x'
        )
    fi
    koopa_add_rpath_to_ldflags "${dict[python_rpath]}" "${dict[vim_rpath]}"
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" test
    "${app[make]}" install
    return 0
}
