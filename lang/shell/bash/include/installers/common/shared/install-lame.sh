#!/usr/bin/env bash

main() {
    # """
    # Install LAME.
    # @note Updated 2022-05-31.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/lame.rb
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='lame'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="https://downloads.sourceforge.net/project/${dict[name]}/\
${dict[name]}/${dict[version]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    koopa_find_and_replace_in_file \
        --multiline \
        --pattern='lame_init_old\n' \
        --regex \
        --replacement='' \
        'include/libmp3lame.sym'
    conf_args=(
        "--prefix=${dict[prefix]}"
        '--disable-debug'
        '--disable-dependency-tracking'
        '--enable-nasm'
    )
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
