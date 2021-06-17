#!/usr/bin/env bash

koopa::macos_merge_pdf() { # {{{1
    # """
    # Merge PDF files, preserving hyperlinks
    # @note Updated 2020-07-16.
    #
    # @usage merge-pdf input{1,2,3}.pdf
    #
    # Modified version of:
    # https://github.com/mathiasbynens/dotfiles/blob/main/.aliases
    # """
    koopa::assert_has_args "$#"
    koopa::assert_is_installed 'gs'
    koopa::assert_is_file "$@"
    gs \
        -dBATCH \
        -dNOPAUSE \
        -q \
        -sDEVICE='pdfwrite' \
        -sOutputFile='merge.pdf' \
        "$@"
    return 0
}

