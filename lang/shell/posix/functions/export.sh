#!/bin/sh

_koopa_export_cpu_count() { # {{{1
    # """
    # Export 'CPU_COUNT' variable.
    # @note Updated 2021-05-14.
    # """
    [ "$#" -eq 0 ] || return 1
    if [ -z "${CPU_COUNT:-}" ]
    then
        CPU_COUNT="$(_koopa_cpu_count)"
    fi
    export CPU_COUNT
    return 0
}

_koopa_export_editor() { # {{{1
    # """
    # Export 'EDITOR' variable.
    # @note Updated 2021-05-07.
    # """
    [ "$#" -eq 0 ] || return 1
    if [ -z "${EDITOR:-}" ]
    then
        EDITOR='vim'
    fi
    VISUAL="$EDITOR"
    export EDITOR VISUAL
    return 0
}

_koopa_export_git() { # {{{1
    # """
    # Export git configuration.
    # @note Updated 2021-05-14.
    #
    # @seealso
    # https://git-scm.com/docs/merge-options
    # """
    [ "$#" -eq 0 ] || return 1
    if [ -z "${GIT_MERGE_AUTOEDIT:-}" ]
    then
        GIT_MERGE_AUTOEDIT='no'
    fi
    export GIT_MERGE_AUTOEDIT
    return 0
}

_koopa_export_gnupg() { # {{{1
    # """
    # Export GnuPG settings.
    # @note Updated 2021-05-07.
    #
    # Enable passphrase prompting in terminal.
    # Useful for getting Docker credential store to work.
    # https://github.com/docker/docker-credential-helpers/issues/118
    # """
    [ "$#" -eq 0 ] || return 1
    [ -z "${GPG_TTY:-}" ] || return 0
    _koopa_is_tty || return 0
    GPG_TTY="$(tty || true)"
    export GPG_TTY
    return 0
}

_koopa_export_history() { # {{{1
    # """
    # Export history.
    # @note Updated 2020-06-30.
    #
    # See bash(1) for more options.
    # For setting history length, see HISTSIZE and HISTFILESIZE.
    # """
    local shell
    [ "$#" -eq 0 ] || return 1
    shell="$(_koopa_shell_name)"
    # Standardize the history file name across shells.
    # Note that snake case is commonly used here across platforms.
    if [ -z "${HISTFILE:-}" ]
    then
        HISTFILE="${HOME}/.${shell}_history"
    fi
    export HISTFILE
    # Create the history file, if necessary.
    # Note that the HOME check here hardens against symlinked data disk failure.
    if [ ! -f "$HISTFILE" ] && [ -e "${HOME:-}" ]
    then
        touch "$HISTFILE"
    fi
    # Don't keep duplicate lines in the history.
    # Alternatively, set 'ignoreboth' to also ignore lines starting with space.
    if [ -z "${HISTCONTROL:-}" ]
    then
        HISTCONTROL='ignoredups'
    fi
    export HISTCONTROL
    if [ -z "${HISTIGNORE:-}" ]
    then
        HISTIGNORE='&:ls:[bf]g:exit'
    fi
    export HISTIGNORE
    # Set the default history size.
    if [ -z "${HISTSIZE:-}" ] || [ "${HISTSIZE:-}" -eq 0 ]
    then
        HISTSIZE=1000
    fi
    export HISTSIZE
    # Add the date/time to 'history' command output.
    # Note that on macOS Bash will fail if 'set -e' is set.
    if [ -z "${HISTTIMEFORMAT:-}" ]
    then
        HISTTIMEFORMAT='%Y%m%d %T  '
    fi
    export HISTTIMEFORMAT
    # Ensure that HISTSIZE and SAVEHIST values match.
    if [ "${HISTSIZE:-}" != "${SAVEHIST:-}" ]
    then
        SAVEHIST="$HISTSIZE"
    fi
    export SAVEHIST
    return 0
}

_koopa_export_pager() { # {{{1
    # """
    # Export 'PAGER' variable.
    # @note Updated 2022-01-18.
    #
    # @seealso
    # - 'tldr --pager' (Rust tealdeer) requires the '-R' flag to be set here,
    #   otherwise will return without proper escape code handling.
    # """
    [ "$#" -eq 0 ] || return 1
    [ -n "${PAGER:-}" ] && return 0
    if _koopa_is_installed 'less'
    then
        export PAGER='less -R'
    fi
    return 0
}

_koopa_export_shell() { # {{{1
    # """
    # Export 'SHELL' variable.
    # @note Updated 2021-05-21.
    #
    # Some POSIX shells, such as Dash, don't export this by default.
    #
    # RStudio Server terminal also doesn't export this, and can cause a
    # warning to occur with dircolors.
    #
    # We are ensuring reexport here so that subshells contain the correct
    # value, e.g. running 'bash -il' inside a Zsh login shell.
    # """
    [ "$#" -eq 0 ] || return 1
    SHELL="$(_koopa_shell_name)"
    export SHELL
    return 0
}

_koopa_export_tmpdir() { # {{{1
    # """
    # Export 'TMPDIR' variable.
    # @note Updated 2021-05-14.
    # """
    [ "$#" -eq 0 ] || return 1
    if [ -z "${TMPDIR:-}" ]
    then
        TMPDIR='/tmp'
    fi
    export TMPDIR
    return 0
}

_koopa_export_user() { # {{{1
    # """
    # Export 'USER' variable.
    # @note Updated 2021-05-14.
    # """
    [ "$#" -eq 0 ] || return 1
    if [ -z "${USER:-}" ]
    then
        USER="$(_koopa_user)"
    fi
    export USER
    return 0
}
