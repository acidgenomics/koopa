#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install lesspipe.
    # @note Updated 2022-01-19.
    #
    # @seealso
    # - https://github.com/wofr06/lesspipe
    # - https://github.com/Homebrew/homebrew-core/blob/master/
    #     Formula/lesspipe.rb
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='lesspipe'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="v${dict[version]}.tar.gz"
    dict[url]="https://github.com/wofr06/lesspipe/archive/refs/\
tags/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    # Refer to line 62.
    # shellcheck disable=SC2016
    koopa_find_and_replace_in_file \
        --fixed \
        --pattern='\$(DESTDIR)/etc/bash_completion.d' \
        --replacement='\$(DESTDIR)\$(PREFIX)/etc/bash_completion.d' \
        'configure'
    ./configure --prefix="${dict[prefix]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" test
    "${app[make]}" install
    return 0
}
