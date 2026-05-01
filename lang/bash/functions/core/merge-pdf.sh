#!/usr/bin/env bash

_koopa_merge_pdf() {
    # """
    # Merge PDF files, preserving hyperlinks.
    # @note Updated 2022-06-20.
    #
    # @usage _koopa_merge_pdf FILE...
    #
    # @seealso
    # - https://github.com/mathiasbynens/dotfiles/blob/main/.aliases
    # """
    local -A app
    _koopa_assert_has_args "$#"
    app['gs']="$(_koopa_locate_gs)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_assert_is_file "$@"
    "${app['gs']}" \
        -dBATCH \
        -dNOPAUSE \
        -q \
        -sDEVICE='pdfwrite' \
        -sOutputFile='merge.pdf' \
        "$@"
    return 0
}
