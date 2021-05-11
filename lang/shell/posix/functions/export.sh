#!/bin/sh

_koopa_export_cpu_count() { # {{{1
    # """
    # Export CPU_COUNT.
    # @note Updated 2021-05-07.
    # """
    [ -z "${CPU_COUNT:-}" ] || return 0
    CPU_COUNT="$(_koopa_cpu_count)"
    export CPU_COUNT
    return 0
}

_koopa_export_editor() { # {{{1
    # """
    # Export EDITOR.
    # @note Updated 2021-05-07.
    # """
    [ -z "${EDITOR:-}" ] && EDITOR='vim'
    VISUAL="$EDITOR"
    export EDITOR
    export VISUAL
    return 0
}

_koopa_export_git() { # {{{1
    # """
    # Export git configuration.
    # @note Updated 2021-05-07.
    #
    # @seealso
    # https://git-scm.com/docs/merge-options
    # """
    [ -z "${GIT_MERGE_AUTOEDIT:-}" ] || return 0
    GIT_MERGE_AUTOEDIT='no'
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
    # Standardize the history file name across shells.
    # Note that snake case is commonly used here across platforms.
    if [ -z "${HISTFILE:-}" ]
    then
        HISTFILE="${HOME}/.$(_koopa_shell)_history"
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

_koopa_export_hostname() { # {{{1
    # """
    # Export HOSTNAME.
    # @note Updated 2021-07-05.
    # """
    [ -z "${HOSTNAME:-}" ] || return 0
    HOSTNAME="$(_koopa_hostname)"
    export HOSTNAME
    return 0
}

_koopa_export_koopa_opt_prefix() { # {{{1
    # """
    # Export 'KOOPA_OPT_PREFIX' variable.
    # @note Updated 2021-05-07.
    #
    # This value is picked up in R configuration (for reticulate).
    # """
    [ -z "${KOOPA_OPT_PREFIX:-}" ] || return 0
    KOOPA_OPT_PREFIX="$(_koopa_opt_prefix)"
    export KOOPA_OPT_PREFIX
    return 0
}

_koopa_export_pager() { # {{{1
    # """
    # Export PAGER.
    # @note Updated 2021-05-07.
    # """
    [ -z "${PAGER:-}" ] || return 0
    PAGER='less'
    export PAGER
    return 0
}

_koopa_export_python() { # {{{1
    # """
    # Export Python settings.
    # @note Updated 2020-06-30.
    # """
    # Don't allow Python to change the prompt string by default.
    [ -z "${VIRTUAL_ENV_DISABLE_PROMPT:-}" ] && VIRTUAL_ENV_DISABLE_PROMPT=1
    export VIRTUAL_ENV_DISABLE_PROMPT
    return 0
}

_koopa_export_shell() { # {{{1
    # """
    # Export SHELL.
    # @note Updated 2021-05-07.
    #
    # Some POSIX shells, such as Dash, don't export this by default.
    # Note that this doesn't currently get set by RStudio terminal.
    # """
    [ -z "${SHELL:-}" ] && SHELL="$(_koopa_which "$(_koopa_shell)")"
    export SHELL
    return 0
}

_koopa_export_tmpdir() { # {{{1
    # """
    # Export TMPDIR.
    # @note Updated 2021-05-10.
    # """
    [ -z "${TMPDIR:-}" ] && TMPDIR='/tmp'
    export TMPDIR
    return 0
}

_koopa_export_today() { # {{{1
    # """
    # Export TODAY.
    # @note Updated 2021-05-07.
    #
    # Current date. Alternatively, can use '%F' shorthand.
    # """
    [ -z "${TODAY:-}" ] || return 0
    TODAY="$(_koopa_today)"
    export TODAY
    return 0
}

_koopa_export_user() { # {{{1
    # """
    # Export USER.
    # @note Updated 2021-05-07.
    # """
    [ -z "${USER:-}" ] || return 0
    USER="$(_koopa_user)"
    export USER
    return 0
}
