#!/bin/sh

_koopa_activate_xdg() {
    # """
    # Activate XDG base directory specification.
    # @note Updated 2023-03-30.
    #
    # @seealso
    # - https://developer.gnome.org/basedir-spec/
    # - https://specifications.freedesktop.org/basedir-spec/
    #     basedir-spec-latest.html#variables
    # - https://wiki.archlinux.org/index.php/XDG_Base_Directory
    # - https://unix.stackexchange.com/questions/476963/
    # """
    [ -z "${XDG_CACHE_HOME:-}" ] && XDG_CACHE_HOME="${HOME:?}/.cache"
    [ -z "${XDG_CONFIG_DIRS:-}" ] && XDG_CONFIG_DIRS='/etc/xdg'
    [ -z "${XDG_CONFIG_HOME:-}" ] && XDG_CONFIG_HOME="${HOME:?}/.config"
    [ -z "${XDG_DATA_DIRS:-}" ] && XDG_DATA_DIRS='/usr/local/share:/usr/share'
    [ -z "${XDG_DATA_HOME:-}" ] && XDG_DATA_HOME="${HOME:?}/.local/share"
    [ -z "${XDG_STATE_HOME:-}" ] && XDG_STATE_HOME="${HOME:?}/.local/state"
    export \
        XDG_CACHE_HOME \
        XDG_CONFIG_DIRS \
        XDG_CONFIG_HOME \
        XDG_DATA_DIRS \
        XDG_DATA_HOME \
        XDG_STATE_HOME
    return 0
}
