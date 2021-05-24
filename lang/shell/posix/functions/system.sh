#!/bin/sh

_koopa_add_config_link() { # {{{1
    # """
    # Add a symlink into the koopa configuration directory.
    # @note Updated 2021-05-24.
    # """
    local config_prefix dest_file dest_name ln mkdir rm source_file
    [ "$#" -eq 2 ] || return 1
    source_file="${1:?}"
    dest_name="${2:?}"
    config_prefix="$(_koopa_config_prefix)"
    dest_file="${config_prefix}/${dest_name}"
    [ -L "$dest_file" ] && return 0
    ln="$(_koopa_locate_ln)"
    mkdir="$(_koopa_locate_mkdir)"
    rm="$(_koopa_locate_rm)"
    "$mkdir" -p "$config_prefix"
    "$rm" -fr "$dest_file"
    "$ln" -fns "$source_file" "$dest_file"
    return 0
}

_koopa_check_os() {
    # """
    # Check that operating system is supported.
    # @note Updated 2021-05-07.
    # """
    case "$(uname -s)" in
        Darwin | \
        Linux)
            ;;
        *)
            _koopa_warning 'Unsupported operating system.'
            return 1
            ;;
    esac
    return 0
}

_koopa_check_shell() { # {{{1
    # """
    # Check that current shell is supported, and export 'KOOPA_SHELL' variable.
    # @note Updated 2021-05-24.
    # """
    local shell
    shell="$(_koopa_locate_shell)"
    case "$(basename "$shell")" in
        ash | \
        bash | \
        busybox | \
        dash | \
        zsh)
            ;;
        *)
            if _koopa_is_interactive
            then
                >&2 cat << END
WARNING: Failed to activate koopa in the current shell.

    Recommended: Bash or Zsh.
    Also supported: Ash, Busybox, Dash.

    KOOPA_SHELL : '${shell}'
          SHELL : '${SHELL:-}'
              - : '${-}'
              0 : '${0}'
              \$ : '${$}'

    Change to Bash:
        > chsh -s /bin/bash

    Change to Zsh:
        > chsh -s /bin/zsh

END
            fi
            return 1
            ;;
    esac
    KOOPA_SHELL="$shell"
    export KOOPA_SHELL
    return 0
}

_koopa_duration_start() { # {{{1
    # """
    # Start activation duration timer.
    # @note Updated 2021-05-24.
    # """
    local bc date
    bc="$(_koopa_locate_bc)"
    date="$(_koopa_locate_date)"
    KOOPA_DURATION_START="$("$date" -u '+%s%3N')"
    export KOOPA_DURATION_START
    return 0
}

_koopa_duration_stop() { # {{{1
    # """
    # Stop activation duration timer.
    # @note Updated 2021-05-24.
    # """
    local bc date duration start stop
    bc="$(_koopa_locate_bc)"
    date="$(_koopa_locate_date)"
    start="${KOOPA_DURATION_START:?}"
    stop="$("$date" -u '+%s%3N')"
    duration="$( \
        _koopa_print "${stop}-${start}" \
        | "$bc" \
    )"
    _koopa_dl 'duration' "${duration} ms"
    unset -v KOOPA_DURATION_START
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
    # @note Updated 2021-05-24.
    #
    # This approach handles inline comments.
    # """
    local cut file grep head include_prefix key value
    # > cut="$(_koopa_locate_cut)"  # FIXME
    cut='cut'
    # > grep="$(_koopa_locate_grep)"  # FIXME
    grep='grep'
    # > head="$(_koopa_locate_head)"  # FIXME
    head='head'
    key="${1:?}"
    include_prefix="$(_koopa_include_prefix)"
    file="${include_prefix}/variables.txt"
    [ -f "$file" ] || return 1
    value="$( \
        "$grep" -Eo "^${key}=\"[^\"]+\"" "$file" \
        || _koopa_stop "'${key}' not defined in '${file}'." \
    )"
    value="$( \
        _koopa_print "$value" \
            | "$head" -n 1 \
            | "$cut" -d '"' -f 2 \
    )"
    [ -n "$value" ] || return 1
    _koopa_print "$value"
    return 0
}
