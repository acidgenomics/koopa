#!/bin/sh

# FIXME We should possibly denote this as simple, and rework our
# bash 'koopa_activate_opt_prefix' to be more flexible here, adding pkg_config
# support...rethink.

koopa_activate_prefix() {
    # """
    # Automatically configure 'PATH' and 'MANPATH' for a
    # specified prefix.
    # @note Updated 2022-04-11.
    # """
    local prefix
    for prefix in "$@"
    do
        [ -d "$prefix" ] || continue
        koopa_add_to_path_start \
            "${prefix}/bin" \
            "${prefix}/sbin"
        koopa_add_to_manpath_start \
            "${prefix}/man" \
            "${prefix}/share/man"
    done
    return 0
}
