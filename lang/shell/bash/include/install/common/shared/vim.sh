#!/usr/bin/env bash

main() {
    # """
    # Install Vim.
    # @note Updated 2022-08-12.
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
        [python]="$(koopa_locate_python)"
    )
    [[ -x "${app['make']}" ]] || return 1
    [[ -x "${app['python']}" ]] || return 1
    app['python']="$(koopa_realpath "${app['python']}")"
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='vim'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict['vim_rpath']="${dict['prefix']}/lib"
    dict['python']="$(koopa_app_prefix 'python')"
    app['python_config']="${app['python']}-config"
    koopa_assert_is_installed "${app['python']}" "${app['python_config']}"
    dict['python_config_dir']="$("${app['python_config']}" --configdir)"
    dict['python_rpath']="${dict['python']}/lib"
    koopa_assert_is_dir "${dict['python_config_dir']}" "${dict['python_rpath']}"
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/${dict['name']}/${dict['name']}/\
archive/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        # > '--enable-cscope'
        # > '--enable-luainterp'
        # > '--enable-perlinterp'
        # > '--enable-rubyinterp'
        '--enable-huge'
        '--enable-multibyte'
        '--enable-python3interp'
        '--enable-terminal'
        "--with-python3-command=${app['python']}"
        "--with-python3-config-dir=${dict['python_config_dir']}"
        '--with-tlib=ncurses'
    )
    if koopa_is_macos
    then
        conf_args+=(
            '--enable-gui=no'
            '--without-x'
        )
    fi
    koopa_add_rpath_to_ldflags "${dict['python_rpath']}" "${dict['vim_rpath']}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" --jobs="${dict['jobs']}"
    # > "${app['make']}" test
    "${app['make']}" install
    return 0
}
