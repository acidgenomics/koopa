#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install xtrans.
    # @note Updated 2022-04-25.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/xtrans.rb
    # - https://github.com/maxim-belkin/homebrew-xorg/issues/453
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'pkg-config'
    koopa_activate_opt_prefix 'xorgproto'
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='xtrans'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.bz2"
    dict[url]="https://www.x.org/archive/individual/lib/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    conf_args=(
        "--prefix=${dict[prefix]}"
        '--disable-dependency-tracking'
        '--disable-silent-rules'
        '--enable-docs=no'
    )
    # Refer to line 84.
    # NOTE We want to replace '<sys/stropts.h>' but not '<stropts.h>'.
    koopa_find_and_replace_in_file \
        --fixed \
        --pattern='# include <sys/stropts.h>' \
        --replacement='# include <sys/ioctl.h>' \
        'Xtranslcl.c'
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
