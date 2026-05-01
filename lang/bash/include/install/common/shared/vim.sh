#!/usr/bin/env bash

main() {
    # """
    # Install Vim.
    # @note Updated 2023-12-12.
    #
    # On Ubuntu, '--enable-rubyinterp' currently causing a false positive error
    # related to ncurses, even when '--with-tlib' is correctly set.
    #
    # @seealso
    # - https://github.com/vim/vim/issues/1081
    # """
    local -A app dict
    _koopa_activate_app --build-only 'pkg-config'
    _koopa_activate_app 'ncurses' 'python'
    app['python']="$(_koopa_locate_python --realpath)"
    app['python_config']="${app['python']}-config"
    _koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['python']="$(_koopa_app_prefix 'python')"
    dict['python_config_dir']="$("${app['python_config']}" --configdir)"
    dict['python_rpath']="${dict['python']}/lib"
    dict['vim_rpath']="${dict['prefix']}/lib"
    _koopa_assert_is_dir \
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
    if _koopa_is_macos
    then
        conf_args+=(
            '--enable-gui=no'
            '--without-x'
        )
    fi
    _koopa_add_rpath_to_ldflags \
        "${dict['python_rpath']}" \
        "${dict['vim_rpath']}"
    dict['url']="https://github.com/vim/vim/archive/v${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_make_build "${conf_args[@]}"
    return 0
}
