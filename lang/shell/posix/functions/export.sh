#!/bin/sh

# FIXME RETHINK THIS.
_koopa_export_cpu_count() { # {{{1
    # """
    # Export CPU_COUNT.
    # @note Updated 2020-06-30.
    # """
    [ -z "${CPU_COUNT:-}" ] && CPU_COUNT="$(_koopa_cpu_count)"
    export CPU_COUNT
    return 0
}

# FIXME RETHINK THIS.
_koopa_export_editor() { # {{{1
    # """
    # Export EDITOR.
    # @note Updated 2020-06-30.
    # """
    [ -z "${EDITOR:-}" ] && EDITOR='vim'
    VISUAL="$EDITOR"
    export EDITOR
    export VISUAL
    return 0
}

# FIXME RETHINK THIS.
_koopa_export_git() { # {{{1
    # """
    # Export git configuration.
    # @note Updated 2020-06-30.
    #
    # @seealso
    # https://git-scm.com/docs/merge-options
    # """
    [ -z "${GIT_MERGE_AUTOEDIT:-}" ] && GIT_MERGE_AUTOEDIT='no'
    export GIT_MERGE_AUTOEDIT
    return 0
}

# FIXME RETHINK THIS.
_koopa_export_gnupg() { # {{{1
    # """
    # Export GnuPG settings.
    # @note Updated 2020-06-30.
    #
    # Enable passphrase prompting in terminal.
    # Useful for getting Docker credential store to work.
    # https://github.com/docker/docker-credential-helpers/issues/118
    # """
    if [ -z "${GPG_TTY:-}" ] && _koopa_is_tty
    then
        GPG_TTY="$(tty || true)"
        export GPG_TTY
    fi
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
    # @note Updated 2020-07-04.
    # """
    [ -z "${HOSTNAME:-}" ] && HOSTNAME="$(_koopa_hostname)"
    export HOSTNAME
    return 0
}

_koopa_export_lesspipe() { # {{{
    # """
    # Export lesspipe settings.
    # @note Updated 2020-07-20.
    #
    # Preconfigured on some Linux systems at '/etc/profile.d/less.sh'.
    #
    # On some older Linux distros:
    # > eval $(/usr/bin/lesspipe)
    #
    # See also:
    # - https://github.com/wofr06/lesspipe
    # """
    local lesspipe
    lesspipe='lesspipe.sh'
    if [ -n "${LESSOPEN:-}" ] && _koopa_is_installed "$lesspipe"
    then
        export LESSOPEN="|${lesspipe} %s"
        export LESS_ADVANCED_PREPROCESSOR=1
    fi
    return 0
}

_koopa_export_pager() { # {{{1
    # """
    # Export PAGER.
    # @note Updated 2020-06-30.
    # """
    [ -z "${PAGER:-}" ] && PAGER='less'
    export PAGER
    return 0
}

_koopa_export_proj_lib() { # {{{1
    # """
    # Export PROJ_LIB.
    # @note Updated 2020-08-05.
    # """
    local make_prefix
    if [ -z "${PROJ_LIB:-}" ]
    then
        make_prefix="$(_koopa_make_prefix)"
        if [ -e "${make_prefix}/share/proj" ]
        then
            PROJ_LIB="${make_prefix}/share/proj"
            export PROJ_LIB
        elif [ -e '/usr/share/proj' ]
        then
            PROJ_LIB='/usr/share/proj'
            export PROJ_LIB
        fi
    fi
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
    # @note Updated 2020-06-30.
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
    # @note Updated 2020-06-30.
    # """
    [ -z "${TMPDIR:-}" ] && TMPDIR='/tmp'
    export TMPDIR
    return 0
}

_koopa_export_today() { # {{{1
    # """
    # Export TODAY.
    # @note Updated 2020-11-20.
    #
    # Current date. Alternatively, can use '%F' shorthand.
    # """
    [ -z "${TODAY:-}" ] && TODAY="$(_koopa_today)"
    export TODAY
    return 0
}

_koopa_export_user() { # {{{1
    # """
    # Export USER.
    # @note Updated 2021-03-18.
    # """
    [ -z "${USER:-}" ] && USER="$(_koopa_user)"
    export USER
    return 0
}
