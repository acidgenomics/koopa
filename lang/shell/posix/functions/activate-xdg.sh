#!/bin/sh

koopa_activate_xdg() {
    # """
    # Activate XDG base directory specification.
    # @note Updated 2022-04-04.
    #
    # @seealso
    # - https://developer.gnome.org/basedir-spec/
    # - https://specifications.freedesktop.org/basedir-spec/
    #     basedir-spec-latest.html#variables
    # - https://wiki.archlinux.org/index.php/XDG_Base_Directory
    # - https://unix.stackexchange.com/questions/476963/
    # """
    if [ -z "${XDG_CACHE_HOME:-}" ]
    then
        XDG_CACHE_HOME="$(koopa_xdg_cache_home)"
    fi
    if [ -z "${XDG_CONFIG_DIRS:-}" ]
    then
        XDG_CONFIG_DIRS="$(koopa_xdg_config_dirs)"
    fi
    if [ -z "${XDG_CONFIG_HOME:-}" ]
    then
        XDG_CONFIG_HOME="$(koopa_xdg_config_home)"
    fi
    if [ -z "${XDG_DATA_DIRS:-}" ]
    then
        XDG_DATA_DIRS="$(koopa_xdg_data_dirs)"
    fi
    if [ -z "${XDG_DATA_HOME:-}" ]
    then
        XDG_DATA_HOME="$(koopa_xdg_data_home)"
    fi
    export XDG_CACHE_HOME XDG_CONFIG_DIRS XDG_CONFIG_HOME \
        XDG_DATA_DIRS XDG_DATA_HOME
    return 0
}
