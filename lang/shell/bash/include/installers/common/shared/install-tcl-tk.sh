#!/usr/bin/env bash

main() {
    # """
    # Install Tcl/Tk.
    # @note Updated 2022-04-28.
    #
    # @seealso
    # - https://www.tcl.tk/software/tcltk/download.html
    # - https://www.tcl.tk/doc/howto/compile.html
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/tcl-tk.rb
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [prefix]="${INSTALL_PREFIX:?}"
        [url_stem]='https://prdownloads.sourceforge.net/tcl'
        [version]="${INSTALL_VERSION:?}"
    )
    conf_args=(
        "--prefix=${dict[prefix]}"
        '--enable-shared'
        '--enable-threads'
        '--enable-64bit'
    )
    dict[tcl_file]="tcl${dict[version]}-src.tar.gz"
    dict[tcl_url]="${dict[url_stem]}/${dict[tcl_file]}"
    koopa_download "${dict[tcl_url]}" "${dict[tcl_file]}"
    koopa_extract "${dict[tcl_file]}"
    (
        koopa_cd "tcl${dict[version]}/unix"
        if koopa_is_macos
        then
            koopa_find_and_replace_in_file \
                --pattern='^(Requires.private: zlib.*)$' \
                --replacement='# \1' \
                --regex \
                'tcl.pc.in'
        fi
        ./configure "${conf_args[@]}"
        "${app[make]}" --jobs="${dict[jobs]}"
        # > "${app[make]}" test
        "${app[make]}" install
        "${app[make]}" install-private-headers
    )
    dict[tk_file]="tk${dict[version]}-src.tar.gz"
    dict[tk_url]="${dict[url_stem]}/${dict[tk_file]}"
    koopa_download "${dict[tk_url]}" "${dict[tk_file]}"
    koopa_extract "${dict[tk_file]}"
    (
        koopa_cd "tk${dict[version]}/unix"
        ./configure "${conf_args[@]}"
        "${app[make]}" --jobs="${dict[jobs]}"
        # > "${app[make]}" test
        "${app[make]}" install
        "${app[make]}" install-private-headers
    )
    return 0
}
