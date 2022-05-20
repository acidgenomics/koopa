#!/usr/bin/env bash

main() {
    # """
    # Install ncurses.
    # @note Updated 2022-04-25.
    #
    # @seealso
    # - https://github.com/archlinux/svntogit-packages/blob/master/ncurses/
    #     repos/core-x86_64/PKGBUILD
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/ncurses.rb
    # - https://github.com/microsoft/vcpkg/issues/22654
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [prefix]="${INSTALL_PREFIX:?}"
    )
    dict[pkgconfig_dir]="${dict[prefix]}/lib/pkgconfig"
    koopa_mkdir "${dict[pkgconfig_dir]}"
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
}
