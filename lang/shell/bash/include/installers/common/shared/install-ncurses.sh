#!/usr/bin/env bash

# FIXME Need to symlink ncursesw.pc to ncurses.pc

main() {
    # """
    # Install ncurses.
    # @note Updated 2022-07-07.
    #
    # @seealso
    # - https://github.com/archlinux/svntogit-packages/blob/master/ncurses/
    #     repos/core-x86_64/PKGBUILD
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/ncurses.rb
    # - https://lists.gnu.org/archive/html/bug-ncurses/2019-07/msg00025.html
    # - https://github.com/microsoft/vcpkg/issues/22654
    # - https://stackoverflow.com/questions/6562403/
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [prefix]="${INSTALL_PREFIX:?}"
    )
    dict[pkgconfig_dir]="${dict[prefix]}/lib/pkgconfig"
    koopa_mkdir "${dict[pkgconfig_dir]}"
    koopa_add_rpath_to_ldflags "${dict[prefix]}/lib"
    koopa_install_app \
        --installer='gnu-app' \
        --name='ncurses' \
        --no-link-in-opt \
        --no-prefix-check \
        --quiet \
        -D '--enable-pc-files' \
        -D '--enable-widec' \
        -D '--with-cxx-binding' \
        -D '--with-cxx-shared' \
        -D '--with-manpage-format=normal' \
        -D "--with-pkg-config-libdir=${dict[pkgconfig_dir]}" \
        -D '--with-shared' \
        -D '--with-versioned-syms' \
        -D '--without-ada' \
        "$@"
    (
        koopa_cd "${dict[prefix]}/lib/pkgconfig"
        koopa_ln 'ncursesw.pc' 'ncurses.pc'
        koopa_ln 'ncurses++w.pc' 'ncurses++.pc'
    )
}
