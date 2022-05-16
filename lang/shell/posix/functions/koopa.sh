#!/bin/sh


koopa_ruby_packages_prefix() {
    # """
    # Ruby packags (gems) prefix.
    # @note Updated 2021-05-25.
    #
    # @usage koopa_ruby_packages_prefix [VERSION]
    # """
    __koopa_packages_prefix 'ruby' "$@"
}

koopa_rust_prefix() {
    # """
    # Rust (rustup) install prefix.
    # @note Updated 2021-05-25.
    # """
    koopa_print "$(koopa_opt_prefix)/rust"
    return 0
}

koopa_rust_packages_prefix() {
    # """
    # Rust packags prefix.
    # @note Updated 2022-04-09.
    #
    # @usage koopa_rust_packages_prefix [VERSION]
    # """
    __koopa_packages_prefix 'rust' "$@"
}

koopa_sbin_prefix() {
    # """
    # Koopa super user binary prefix.
    # @note Updated 2022-04-05.
    # """
    koopa_print "$(koopa_koopa_prefix)/sbin"
    return 0
}

koopa_scripts_private_prefix() {
    # """
    # Private scripts prefix.
    # @note Updated 2020-02-15.
    # """
    koopa_print "$(koopa_config_prefix)/scripts-private"
    return 0
}

koopa_shell_name() {
    # """
    # Current shell name.
    # @note Updated 2021-05-25.
    # """
    local shell str
    shell="$(koopa_locate_shell)"
    str="$(basename "$shell")"
    [ -n "$str" ] || return 1
    koopa_print "$str"
    return 0
}

koopa_spacemacs_prefix() {
    # """
    # Spacemacs prefix.
    # @note Updated 2021-06-07.
    # """
    koopa_print "$(koopa_xdg_data_home)/spacemacs"
    return 0
}

koopa_spacevim_prefix() {
    # """
    # SpaceVim prefix.
    # @note Updated 2021-06-07.
    # """
    koopa_print "$(koopa_xdg_data_home)/spacevim"
    return 0
}

koopa_str_detect_posix() {
    # """
    # Evaluate whether a string contains a desired value.
    # @note Updated 2022-02-15.
    #
    # We're unsetting 'test' here to ensure no variables/functions mask the
    # shell built-in.
    # """
    unset test
    test "${1#*"$2"}" != "$1"
}

koopa_today() {
    # """
    # Today string.
    # @note Updated 2021-05-26.
    # """
    local str
    str="$(date '+%Y-%m-%d')"
    [ -n "$str" ] || return 1
    koopa_print "$str"
    return 0
}

koopa_umask() {
    # """
    # Set default file permissions.
    # @note Updated 2020-06-03.
    #
    # - 'umask': Files and directories.
    # - 'fmask': Only files.
    # - 'dmask': Only directories.
    #
    # Use 'umask -S' to return 'u,g,o' values.
    #
    # - 0022: 'u=rwx,g=rx,o=rx'.
    #         User can write, others can read. Usually default.
    # - 0002: 'u=rwx,g=rwx,o=rx'.
    #         User and group can write, others can read.
    #         Recommended setting in a shared coding environment.
    # - 0077: 'u=rwx,g=,o='.
    #         User alone can read/write. More secure.
    #
    # Access control lists (ACLs) are sometimes preferable to umask.
    #
    # Here's how to use ACLs with setfacl.
    # > setfacl -d -m group:name:rwx /dir
    #
    # @seealso
    # - https://stackoverflow.com/questions/13268796
    # - https://askubuntu.com/questions/44534
    # """
    umask 0002
    return 0
}

koopa_user() {
    # """
    # Current user name.
    # @note Updated 2020-06-30.
    #
    # Alternatively, can use 'whoami' here.
    # """
    __koopa_id -un
    return 0
}

koopa_user_id() {
    # """
    # Current user ID.
    # @note Updated 2020-04-16.
    # """
    __koopa_id -u
    return 0
}

koopa_xdg_cache_home() {
    # """
    # XDG cache home.
    # @note Updated 2021-05-20.
    # """
    local x
    x="${XDG_CACHE_HOME:-}"
    if [ -z "$x" ]
    then
        x="${HOME:?}/.cache"
    fi
    koopa_print "$x"
    return 0
}

koopa_xdg_config_dirs() {
    # """
    # XDG config dirs.
    # @note Updated 2021-05-20.
    # """
    local x
    x="${XDG_CONFIG_DIRS:-}"
    if [ -z "$x" ] 
    then
        x='/etc/xdg'
    fi
    koopa_print "$x"
    return 0
}

koopa_xdg_config_home() {
    # """
    # XDG config home.
    # @note Updated 2021-05-20.
    # """
    local x
    x="${XDG_CONFIG_HOME:-}"
    if [ -z "$x" ]
    then
        x="${HOME:?}/.config"
    fi
    koopa_print "$x"
    return 0
}

