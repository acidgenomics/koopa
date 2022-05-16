#!/bin/sh

koopa_activate_make_paths() {
    # """
    # Activate standard Makefile paths.
    # @note Updated 2022-04-08.
    #
    # Note that here we're making sure local binaries are included.
    # Inspect '/etc/profile' if system PATH appears misconfigured.
    #
    # Note that macOS Big Sur includes '/usr/local/bin' automatically now,
    # resulting in a duplication. This is OK.
    # Refer to '/etc/paths.d' for other system paths.
    #
    # @seealso
    # - https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard
    # """
    local make_prefix_1 make_prefix_2
    make_prefix_1='/usr/local'
    make_prefix_2="$(koopa_make_prefix)"
    if [ -d "$make_prefix_1" ]
    then
        koopa_add_to_path_start \
            "${make_prefix_1}/bin" \
            "${make_prefix_1}/sbin"
        koopa_add_to_manpath_start \
            "${make_prefix_1}/man" \
            "${make_prefix_1}/share/man"
    fi
    if [ "$make_prefix_2" != "$make_prefix_1" ] && [ -d "$make_prefix_2" ]
    then
        koopa_add_to_path_start \
            "${make_prefix_2}/bin" \
            "${make_prefix_2}/sbin"
        koopa_add_to_manpath_start \
            "${make_prefix_2}/man" \
            "${make_prefix_2}/share/man"
    fi
    return 0
}
