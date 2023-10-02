#!/usr/bin/env bash

main() {
    # """
    # Install Vim.
    # @note Updated 2023-10-02.
    #
    # On Ubuntu, '--enable-rubyinterp' currently causing a false positive error
    # related to ncurses, even when '--with-tlib' is correctly set.
    #
    # @seealso
    # - https://github.com/vim/vim/issues/1081
    # """
    local -A app dict
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app 'ncurses' 'python3.11'
    app['python']="$(koopa_locate_python311 --realpath)"
    app['python_config']="${app['python']}-config"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['python']="$(koopa_app_prefix 'python3.12')"
    dict['python_config_dir']="$("${app['python_config']}" --configdir)"
    dict['python_rpath']="${dict['python']}/lib"
    dict['vim_rpath']="${dict['prefix']}/lib"
    koopa_assert_is_dir \
        "${dict['python_config_dir']}" \
        "${dict['python_rpath']}"
    conf_args=(
        # > '--enable-cscope'
        # > '--enable-luainterp'
        # > '--enable-perlinterp'
        # > '--enable-rubyinterp'
        '--enable-huge'
        '--enable-multibyte'
        '--enable-python3interp'
        '--enable-terminal'
        "--prefix=${dict['prefix']}"
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
    koopa_add_rpath_to_ldflags \
        "${dict['python_rpath']}" \
        "${dict['vim_rpath']}"
    dict['url']="https://github.com/vim/vim/archive/v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
