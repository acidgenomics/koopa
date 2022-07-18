#!/usr/bin/env bash

main() {
    # """
    # Install PCRE2.
    # @note Updated 2022-07-08.
    #
    # @seealso
    # - https://www.pcre.org/
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/pcre2.rb
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    if koopa_is_linux
    then
        koopa_activate_opt_prefix 'zlib'
    fi
    koopa_activate_build_opt_prefix \
        'autoconf' \
        'automake' \
        'libtool'
    koopa_activate_opt_prefix \
        'bzip2'
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    [[ -x "${app[make]}" ]] || return 1
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='pcre2'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.bz2"
    dict[url]="https://github.com/PhilipHazel/${dict[name]}/releases/\
download/${dict[name]}-${dict[version]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    conf_args=(
        "--prefix=${dict[prefix]}"
        '--disable-dependency-tracking'
        '--enable-jit'
        '--enable-pcre2-16'
        '--enable-pcre2-32'
        '--enable-pcre2grep-libbz2'
        '--enable-pcre2grep-libz'
    )
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
