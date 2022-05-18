#!/usr/bin/env bash

koopa_macos_unlink_homebrew() {
    # """
    # Previously unlinked:
    # - 'R'
    # - 'Rscript'
    # """
    koopa_assert_has_no_args "$#"
    koopa_unlink_in_bin \
        'bbedit' \
        'code' \
        'emacs' \
        'gcloud' \
        'julia'
    return 0
}
