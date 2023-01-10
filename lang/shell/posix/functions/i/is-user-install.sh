#!/bin/sh

koopa_is_user_install() {
    # """
    # Is koopa installed only for the current user?
    # @note Updated 2023-01-10.
    # """
    koopa_str_detect_posix "$(koopa_koopa_prefix)" "${HOME:?}"
}
