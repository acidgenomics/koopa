#!/usr/bin/env bash

# FIXME This is warning about '/opt/koopa/opt/chemacs' not existing, need
# to rethink this?
#
# FIXME Work on resolving this warning:
# 🧪 # Installing Chemacs at '/opt/koopa/app/chemacs/rolling'.
# !! Warning: Does not exist: '/opt/koopa/opt/chemacs'.
# → Deleting '/opt/koopa/app/chemacs/rolling/.git/branches'.

koopa:::install_chemacs() { # {{{1
    # """
    # Install Chemacs2.
    # @note Updated 2022-02-02.
    # """
    local dict
    koopa::assert_has_no_args "$#"
    declare -A dict=(
        [prefix]="${INSTALL_PREFIX:?}"
        [url]='https://github.com/plexus/chemacs2'
    )
    koopa::git_clone "${dict[url]}" "${dict[prefix]}"
    koopa::configure_chemacs
    return 0
}
