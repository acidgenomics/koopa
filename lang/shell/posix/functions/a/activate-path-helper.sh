#!/bin/sh

koopa_activate_path_helper() {
    # """
    # Activate 'path_helper'.
    # @note Updated 2022-05-12.
    #
    # This will source '/etc/paths.d' on supported platforms (e.g. BSD/macOS).
    # """
    local path_helper
    path_helper='/usr/libexec/path_helper'
    [ -x "$path_helper" ] || return 0
    eval "$("$path_helper" -s)"
    return 0
}
