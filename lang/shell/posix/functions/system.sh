#!/bin/sh

_koopa_add_koopa_config_link() { # {{{1
    # """
    # Add a symlink into the koopa configuration directory.
    # @note Updated 2021-06-14.
    # """
    local brew_prefix config_prefix dest_file dest_name ln mkdir rm source_file
    [ "$#" -ge 2 ] || return 1
    ln='ln'
    mkdir='mkdir'
    rm='rm'
    if _koopa_is_macos
    then
        brew_prefix="$(_koopa_homebrew_prefix)"
        ln="${brew_prefix}/opt/coreutils/bin/gln"
        mkdir="${brew_prefix}/opt/coreutils/bin/gmkdir"
        rm="${brew_prefix}/opt/coreutils/bin/grm"
    fi
    config_prefix="$(_koopa_config_prefix)"
    while [ "$#" -ge 2 ]
    do
        source_file="${1:?}"
        dest_name="${2:?}"
        shift 2
        dest_file="${config_prefix}/${dest_name}"
        if [ -L "$dest_file" ] && [ -e "$dest_file" ]
        then
            continue
        fi
        "$mkdir" -p "$config_prefix"
        "$rm" -fr "$dest_file"
        "$ln" -fns "$source_file" "$dest_file"
    done
    return 0
}

_koopa_check_os() { # {{{1
    # """
    # Check that operating system is supported.
    # @note Updated 2021-05-07.
    # """
    [ "$#" -eq 0 ] || return 1
    case "$(uname -s)" in
        'Darwin' | \
        'Linux')
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
    # @note Updated 2021-09-21.
    # """
    local shell shell_name
    [ "$#" -eq 0 ] || return 1
    shell="$(_koopa_locate_shell)"
    shell_name="$(_koopa_shell_name)"
    KOOPA_SHELL="$shell"
    SHELL="$shell_name"
    export KOOPA_SHELL SHELL
    case "$shell_name" in
        'ash' | \
        'bash' | \
        'dash' | \
        'zsh')
            ;;
        *)
            >&2 cat << END
WARNING: Failed to activate koopa in the current shell.

    Recommended: Bash, Zsh.
    Also supported: Ash, Dash.

    KOOPA_SHELL : '${KOOPA_SHELL:-}'
          SHELL : '${SHELL:-}'
              - : '${-}'
              0 : '${0}'
              \$ : '${$}'

    Change to Bash:
        > chsh -s /bin/bash

    Change to Zsh:
        > chsh -s /bin/zsh

END
            return 1
            ;;
    esac
    return 0
}

_koopa_duration_start() { # {{{1
    # """
    # Start activation duration timer.
    # @note Updated 2021-06-17.
    # """
    local brew_prefix date
    [ "$#" -eq 0 ] || return 1
    date='date'
    if _koopa_is_macos
    then
        brew_prefix="$(_koopa_homebrew_prefix)"
        date="${brew_prefix}/opt/coreutils/bin/gdate"
    fi
    _koopa_is_installed "$date" || return 0
    KOOPA_DURATION_START="$("$date" -u '+%s%3N')"
    export KOOPA_DURATION_START
    return 0
}

_koopa_duration_stop() { # {{{1
    # """
    # Stop activation duration timer.
    # @note Updated 2021-06-17.
    # """
    local brew_prefix bc date duration key start stop
    [ "$#" -le 1 ] || return 1
    key="${1:-}"
    if [ -z "$key" ]
    then
        key='duration'
    else
        key="[${key}] duration"
    fi
    bc='bc'
    date='date'
    if _koopa_is_macos
    then
        brew_prefix="$(_koopa_homebrew_prefix)"
        bc="${brew_prefix}/opt/bc/bin/bc"
        date="${brew_prefix}/opt/coreutils/bin/gdate"
    fi
    _koopa_is_installed "$bc" "$date" || return 0
    start="${KOOPA_DURATION_START:?}"
    stop="$("$date" -u '+%s%3N')"
    duration="$( \
        _koopa_print "${stop}-${start}" \
        | "$bc" \
    )"
    [ -n "$duration" ] || return 1
    _koopa_dl "$key" "${duration} ms"
    unset -v KOOPA_DURATION_START
    return 0
}

_koopa_exec_dir() { # {{{1
    # """
    # Execute multiple shell scripts in a directory.
    # @note Updated 2020-07-23.
    # """
    local dir file
    [ "$#" -eq 1 ] || return 1
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
    [ "$#" -eq 1 ] || return 1
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
    [ "$#" -eq 0 ] || return 1
    umask 0002
    return 0
}
