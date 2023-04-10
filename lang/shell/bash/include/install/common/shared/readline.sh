#!/usr/bin/env bash

main() {
    # """
    # Install readline.
    # @note Updated 2023-04-10.
    #
    # Check linkage on Linux with:
    # ldd -r /opt/koopa/opt/readline/lib/libreadline.so
    #
    # @seealso
    # - https://github.com/conda-forge/readline-feedstock
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     readline.rb
    # - https://stackoverflow.com/a/34723695/3911732
    # - https://github.com/archlinux/svntogit-packages/blob/master/readline/
    #     repos/core-x86_64/PKGBUILD
    # - https://www.linuxfromscratch.org/lfs/view/11.1-systemd/chapter08/
    #     readline.html
    # """
    local -A app dict
    local -a conf_args make_args
    koopa_activate_app --build-only 'make' 'pkg-config'
    koopa_activate_app 'ncurses'
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['gnu_mirror']="$(koopa_gnu_mirror_url)"
    dict['jobs']="$(koopa_cpu_count)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-static'
        '--enable-shared'
        "--prefix=${dict['prefix']}"
        '--with-curses'
    )
    make_args=(
        'SHLIB_LIBS=-lncursesw'
        'VERBOSE=1'
    )
    CFLAGS="-fPIC ${CFLAGS:-}"
    export CFLAGS
    dict['url']="${dict['gnu_mirror']}/readline/\
readline-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
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
    "${app['make']}" "${make_args[@]}" --jobs="${dict['jobs']}"
    "${app['make']}" "${make_args[@]}" install
    koopa_check_shared_object \
        --name='libreadline' \
        --prefix="${dict['prefix']}/lib"
    return 0
}
