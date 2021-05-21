#!/bin/sh

# FIXME Need to harden the coreutils here...
_koopa_add_config_link() { # {{{1
    # """
    # Add a symlink into the koopa configuration directory.
    # @note Updated 2020-12-11.
    # """
    local config_prefix dest_file dest_name source_file
    source_file="${1:?}"
    [ -e "$source_file" ] || return 0
    dest_name="${2:-}"
    [ -z "$dest_name" ] && dest_name="$(basename "$source_file")"
    config_prefix="$(_koopa_config_prefix)"
    dest_file="${config_prefix}/${dest_name}"
    [ -L "$dest_file" ] && return 0
    mkdir -p "$config_prefix"
    rm -fr "$dest_file"
    ln -fns "$source_file" "$dest_file"
    return 0
}

_koopa_exec_dir() { # {{{1
    # """
    # Execute multiple shell scripts in a directory.
    # @note Updated 2020-07-23.
    # """
    local dir file
    dir="${1:?}"
    [ -d "$dir" ] || return 0
    for file in "${dir}/"*'.sh'
    do
        [ -x "$file" ] || continue
        # shellcheck source=/dev/null
        "$file"
    done
    return 0
}

_koopa_source_dir() { # {{{1
    # """
    # Source multiple shell scripts in a directory.
    # @note Updated 2020-07-23.
    # """
    local dir file
    dir="${1:?}"
    [ -d "$dir" ] || return 0
    for file in "${dir}/"*'.sh'
    do
        [ -f "$file" ] || continue
        # shellcheck source=/dev/null
        . "$file"
    done
    return 0
}

_koopa_umask() { # {{{1
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

_koopa_variable() { # {{{1
    # """
    # Return a variable stored 'variables.txt' include file.
    # @note Updated 2020-07-21.
    #
    # This approach handles inline comments.
    # """
    local file include_prefix key value
    key="${1:?}"
    include_prefix="$(_koopa_include_prefix)"
    file="${include_prefix}/variables.txt"
    [ -f "$file" ] || return 1
    value="$( \
        grep -Eo "^${key}=\"[^\"]+\"" "$file" \
        || _koopa_stop "'${key}' not defined in '${file}'." \
    )"
    value="$( \
        _koopa_print "$value" \
            | head -n 1 \
            | cut -d '"' -f 2 \
    )"
    [ -n "$value" ] || return 1
    _koopa_print "$value"
    return 0
}
