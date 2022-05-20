#!/bin/sh

koopa_is_local_install() {
    # """
    # Is koopa installed only for the current user?
    # @note Updated 2022-02-15.
    # """
    koopa_str_detect_posix "$(koopa_koopa_prefix)" "${HOME:?}"
}
