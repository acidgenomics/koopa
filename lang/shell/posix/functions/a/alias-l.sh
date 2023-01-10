#!/bin/sh

koopa_alias_l() {
    # """
    # List files alias that uses 'exa' instead of 'ls', when possible.
    # @note Updated 2022-04-14.
    #
    # Use exa instead of ls, when possible.
    # https://the.exa.website/docs/command-line-options
    #
    # @secton Useful exa flags:
    # * -F, --classify
    #         Displays file type indicators by file names.
    # * -a, --all
    #         Shows hidden and ‘dot’ files.
    #         Use this twice to also show the . and .. directories.
    # * -g, --group
    #         Lists each file’s group.
    # * -l, --long
    #         Displays files in a table along with their metadata.
    # * -s, --sort=SORT_FIELD
    #         Configures which field to sort by.
    # *     --git-ignore
    #         Ignores files mentioned in .gitignore.
    # *     --group-directories-first
    #         Lists directories before other files when sorting.
    # @section Useful ls flags:
    # * -B, --ignore-backups
    #         do not list implied entries ending with ~
    # * -F, --classify
    #         append indicator (one of */=>@|) to entries
    # * -h, --human-readable
    #         with -l and -s, print sizes like 1K 234M 2G etc.
    # """
    if koopa_is_installed 'exa'
    then
        exa \
            --classify \
            --group \
            --group-directories-first \
            --sort='Name' \
            "$@"
    else
        ls -BFh "$@"
    fi
}
