#!/usr/bin/env bash

koopa_merge_pdf() {
    # """
    # Merge PDF files, preserving hyperlinks.
    # @note Updated 2022-06-20.
    #
    # @usage koopa_merge_pdf FILE...
    #
    # @seealso
    # - https://github.com/mathiasbynens/dotfiles/blob/main/.aliases
    # """
    local -A app
    koopa_assert_has_args "$#"
    app['gs']="$(koopa_locate_gs)"
    koopa_assert_is_executable "${app[@]}"
    koopa_assert_is_file "$@"
    "${app['gs']}" \
        -dBATCH \
        -dNOPAUSE \
        -q \
        -sDEVICE='pdfwrite' \
        -sOutputFile='merge.pdf' \
        "$@"
    return 0
}
