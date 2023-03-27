#!/usr/bin/env bash

main() {
    # """
    # Install readline.
    # @note Updated 2023-03-26.
    #
    # Check linkage on Linux with:
    # ldd -r /opt/koopa/opt/readline/lib/libreadline.so
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     readline.rb
    # - https://stackoverflow.com/a/34723695/3911732
    # - https://github.com/archlinux/svntogit-packages/blob/master/readline/
    #     repos/core-x86_64/PKGBUILD
    # - https://www.linuxfromscratch.org/lfs/view/11.1-systemd/chapter08/
    #     readline.html
    # """
    local app conf_args dict make_args
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'make' 'pkg-config'
    koopa_activate_app 'ncurses'
    declare -A app
    app['make']="$(koopa_locate_make)"
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['gnu_mirror']="$(koopa_gnu_mirror_url)"
        ['jobs']="$(koopa_cpu_count)"
        ['name']='readline'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    dict['url']="${dict['gnu_mirror']}/${dict['name']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--enable-shared'
        '--enable-static'
        '--with-curses'
    )
    CFLAGS="-fPIC ${CFLAGS:-}"
    export CFLAGS
    # There is no termcap.pc in the base system, so we have to comment out the
    # corresponding 'Requires.private' line. Otherwise, pkg-config will consider
    # the readline module unusable.
    koopa_find_and_replace_in_file \
        --regex \
        --pattern='^(Requires.private: .*)$' \
        --replacement='# \1' \
        'readline.pc.in'
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    make_args=(
        'SHLIB_LIBS=-lncursesw'
        'VERBOSE=1'
    )
    "${app['make']}" "${make_args[@]}" --jobs="${dict['jobs']}"
    "${app['make']}" "${make_args[@]}" install
    koopa_check_shared_object \
        --name='libreadline' \
        --prefix="${dict['prefix']}/lib"
    return 0
}
