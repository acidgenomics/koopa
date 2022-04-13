#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install PCRE.
    # @note Updated 2022-04-13.
    #
    # Note that this is the legacy version, not PCRE2!
    #
    # @seealso
    # - https://www.pcre.org/
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/pcre.rb
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_opt_prefix \
        'autoconf' \
        'automake' \
        'libtool' \
        'zlib'
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='pcre'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.bz2"
    dict[url]="https://downloads.sourceforge.net/project/${dict[name]}/\
${dict[name]}/${dict[version]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    conf_args=(
        "--prefix=${dict[prefix]}"
        '--disable-dependency-tracking'
        '--enable-pcre16'
        '--enable-pcre32'
        '--enable-pcre8'
        '--enable-pcregrep-libbz2'
        '--enable-pcregrep-libz'
        '--enable-unicode-properties'
        '--enable-utf8'
    )
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
