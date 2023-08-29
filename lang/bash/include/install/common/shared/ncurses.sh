#!/usr/bin/env bash

# NOTE Consider building with '--with-termlib' enabled, to build libtinfo.
# This will get picked up in the Fish build configuration. Take a look at
# the conda-forge recipe for details.

main() {
    # """
    # Install ncurses.
    # @note Updated 2023-04-11.
    #
    # @seealso
    # - https://github.com/conda-forge/ncurses-feedstock
    # - https://github.com/archlinux/svntogit-packages/blob/master/ncurses/
    #     repos/core-x86_64/PKGBUILD
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/ncurses.rb
    # - https://www.linuxfromscratch.org/lfs/view/development/chapter06/
    #     ncurses.html
    # - https://lists.gnu.org/archive/html/bug-ncurses/2019-07/msg00025.html
    # - https://github.com/microsoft/vcpkg/issues/22654
    # - https://stackoverflow.com/questions/6562403/
    # """
    local -A dict
    local -a conf_args install_args
    local conf_arg
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(koopa_shared_ext)"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['maj_ver']="$(koopa_major_version "${dict['version']}")"
    dict['maj_min_ver']="$(koopa_major_minor_version "${dict['version']}")"
    dict['pkgconfig_dir']="${dict['prefix']}/lib/pkgconfig"
    koopa_mkdir "${dict['pkgconfig_dir']}"
    koopa_add_rpath_to_ldflags "${dict['prefix']}/lib"
    conf_args=(
        '--enable-pc-files'
        '--enable-sigwinch'
        '--enable-symlinks'
        '--enable-widec'
        '--with-cxx-binding'
        '--with-cxx-shared'
        '--with-gpm=no'
        '--with-manpage-format=normal'
        "--with-pkg-config-libdir=${dict['pkgconfig_dir']}"
        '--with-shared'
        '--with-versioned-syms'
        '--without-ada'
    )
    for conf_arg in "${conf_args[@]}"
    do
        install_args+=('-D' "$conf_arg")
    done
    koopa_install_gnu_app "${install_args[@]}"
    (
        koopa_cd "${dict['prefix']}/bin"
        koopa_ln \
            "ncursesw${dict['maj_ver']}-config" \
            "ncurses${dict['maj_ver']}-config"
    )
    (
        local -a names
        local name
        koopa_cd "${dict['prefix']}/include"
        koopa_ln 'ncursesw' 'ncurses'
        names=('curses' 'form' 'ncurses' 'panel' 'term' 'termcap')
        for name in "${names[@]}"
        do
            koopa_ln "ncursesw/${name}.h" "${name}.h"
        done
    )
    (
        local -a names
        local name
        koopa_cd "${dict['prefix']}/lib"
        # Manually delete static libraries.
        koopa_rm ./*.a
        names=('libform' 'libmenu' 'libncurses' 'libncurses++' 'libpanel')
        for name in "${names[@]}"
        do
            koopa_ln  \
                "${name}w.${dict['shared_ext']}" \
                "${name}.${dict['shared_ext']}"
            if koopa_is_linux
            then
                koopa_ln \
                    "${name}w.${dict['shared_ext']}.${dict['maj_ver']}" \
                    "${name}.${dict['shared_ext']}.${dict['maj_ver']}"
                koopa_ln \
                    "${name}w.${dict['shared_ext']}.${dict['maj_min_ver']}" \
                    "${name}.${dict['shared_ext']}.${dict['maj_min_ver']}"
            elif koopa_is_macos
            then
                koopa_ln \
                    "${name}w.${dict['maj_ver']}.${dict['shared_ext']}" \
                    "${name}.${dict['maj_ver']}.${dict['shared_ext']}"
            fi
        done
        koopa_ln \
            "libncurses.${dict['shared_ext']}" \
            "libcurses.${dict['shared_ext']}"
        koopa_ln \
            "libncurses.${dict['shared_ext']}" \
            "libtermcap.${dict['shared_ext']}"
        koopa_ln \
            "libncurses.${dict['shared_ext']}" \
            "libtinfo.${dict['shared_ext']}"
    )
    (
        local -a names
        local name
        koopa_cd "${dict['prefix']}/lib/pkgconfig"
        names=('form' 'menu' 'ncurses++' 'ncurses' 'panel')
        for name in "${names[@]}"
        do
            koopa_ln "${name}w.pc" "${name}.pc"
        done
    )
    (
        koopa_is_macos || return 0
        koopa_cd "${dict['prefix']}/share/man/man1"
        koopa_ln 'captoinfo.1m' 'captoinfo.1'
        koopa_ln 'infocmp.1m' 'infocmp.1'
        koopa_ln 'infotocap.1m' 'infotocap.1'
        koopa_ln 'tic.1m' 'tic.1'
        koopa_ln 'toe.1m' 'toe.1'
    )
    return 0
}
