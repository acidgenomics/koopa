#!/usr/bin/env bash

# NOTE Here is a bootstrap workaround for Bash 4+ on macOS:
# > /opt/koopa/include/bootstrap.sh
# > PATH="${TMPDIR}/koopa-bootstrap/bin:${PATH}"

__koopa_exit_trap() {
    # """
    # Kill all processes whose parent is this process.
    # @note Updated 2022-04-27.
    #
    # @seealso
    # - https://linuxize.com/post/kill-command-in-linux/
    # - https://stackoverflow.com/questions/28657676/
    # - https://stackoverflow.com/questions/41370092/
    # - https://stackoverflow.com/questions/65420781/
    # - https://unix.stackexchange.com/questions/222307/
    # - https://unix.stackexchange.com/questions/240723/
    # - https://unix.stackexchange.com/questions/256873/
    # - https://unix.stackexchange.com/questions/478281/
    # - https://www.networkworld.com/article/3174440/
    # - https://www.baeldung.com/linux/kill-members-process-group
    # - https://stackoverflow.com/questions/392022/
    # """
    if [[ "${?}" -gt 0 ]]
    then
        if [[ "${KOOPA_VERBOSE:-0}" -eq 1 ]]
        then
            local ps
            ps='/bin/ps'
            if [[ -x "$ps" ]]
            then
                "$ps" -p "${$}"
            fi
        fi
        local pkill
        pkill='/usr/bin/pkill'
        if [[ -x "$pkill" ]]
        then
            "$pkill" -P "${$}" # and/or "${PPID:?}"
        fi
    fi
    return 0
}

__koopa_is_installed() {
    # """
    # Are all of the requested programs installed?
    # @note Updated 2021-06-16.
    # """
    local cmd
    for cmd in "$@"
    do
        command -v "$cmd" >/dev/null || return 1
    done
    return 0
}

__koopa_print() {
    # """
    # Print a string.
    # @note Updated 2021-05-07.
    # """
    local string
    for string in "$@"
    do
        printf '%b\n' "$string"
    done
    return 0
}

__koopa_realpath() {
    # """
    # Resolve file path.
    # @note Updated 2022-08-26.
    #
    # macOS/BSD readlink now supports '-f' flag. Added in 2022?
    # """
    local x
    x="$(readlink -f "$@")"
    [[ -n "$x" ]] || return 1
    __koopa_print "$x"
    return 0
}

__koopa_source_functions() {
    # """
    # Source multiple Bash script files inside a directory.
    # @note Updated 2022-05-20.
    #
    # Note that macOS ships with an ancient version of Bash by default that
    # doesn't support readarray/mapfile.
    # """
    local cache_file file files prefix
    prefix="$(koopa_koopa_prefix)/lang/shell/bash/functions/${1:?}"
    [[ -d "$prefix" ]] || return 0
    cache_file="${prefix}.sh"
    if [[ -f "$cache_file" ]]
    then
        # shellcheck source=/dev/null
        source "$cache_file"
        return 0
    fi
    readarray -t files <<< "$( \
        find -L "$prefix" \
            -mindepth 1 \
            -type 'f' \
            -name '*.sh' \
            -print \
    )"
    for file in "${files[@]}"
    do
        # shellcheck source=/dev/null
        source "$file"
    done
    return 0
}

__koopa_warn() {
    # """
    # Print a warning message to the console.
    # @note Updated 2021-05-14.
    # """
    local string
    for string in "$@"
    do
        printf '%b\n' "$string" >&2
    done
    return 0
}

__koopa_bash_header() {
    # """
    # Bash header.
    # @note Updated 2022-08-23.
    #
    # @seealso
    # - shopt
    #   https://www.gnu.org/software/bash/manual/
    #     html_node/The-Shopt-Builtin.html
    # """
    case "${BASH_VERSION:-}" in
        '1.'* | '2.'* | '3.'*)
            return 1
            ;;
    esac
    local dict
    declare -A dict=(
        ['activate']=0
        ['checks']=1
        ['dev']=0
        ['minimal']=0
        ['test']=0
        ['verbose']=0
    )
    [[ -n "${KOOPA_ACTIVATE:-}" ]] && dict['activate']="$KOOPA_ACTIVATE"
    [[ -n "${KOOPA_CHECKS:-}" ]] && dict['checks']="$KOOPA_CHECKS"
    [[ -n "${KOOPA_DEV:-}" ]] && dict['dev']="$KOOPA_DEV"
    [[ -n "${KOOPA_MINIMAL:-}" ]] && dict['minimal']="$KOOPA_MINIMAL"
    [[ -n "${KOOPA_TEST:-}" ]] && dict['test']="$KOOPA_TEST"
    [[ -n "${KOOPA_VERBOSE:-}" ]] && dict['verbose']="$KOOPA_VERBOSE"
    if [[ "${dict['activate']}" -eq 1 ]] && \
        [[ "${dict['dev']}" -eq 0 ]] && \
        [[ "${dict['test']}" -eq 0 ]]
    then
        dict['checks']=0
    fi
    if [[ "${dict['activate']}" -eq 0 ]]
    then
        trap __koopa_exit_trap EXIT
        # Fix for RHEL/CentOS/Rocky Linux 'BASHRCSOURCED' unbound variable.
        # https://100things.wzzrd.com/2018/07/11/
        #   The-confusing-Bash-configuration-files.html
        [[ -z "${BASHRCSOURCED:-}" ]] && export BASHRCSOURCED='Y'
    fi
    if [[ "${dict['activate']}" -eq 0 ]] || [[ "${dict['dev']}" -eq 1 ]]
    then
        unalias -a
    fi
    if [[ "${dict['checks']}" -eq 1 ]]
    then
        # Compare with current values defined in '~/.bashrc'.
        # Check all values with 'set +o'.
        # Note that '+o' here means disable, '-o' means enable.
        set +o allexport  # -a
        set -o braceexpand  # -B
        set -o errexit  # -e
        set -o errtrace  # -E
        set -o functrace  # -T
        set -o hashall  # -h
        set -o histexpand  # -H
        set -o history
        set +o ignoreeof
        set -o interactive-comments
        set +o keyword  # -k
        set -o monitor  # -m
        set +o noclobber  # -C
        set +o noexec  # -n
        set +o noglob  # -f
        set +o notify  # -b
        set -o nounset  # -u
        set +o onecmd  # -t
        set -o pipefail
        set +o posix
        set +o physical  # -P
        set +o verbose  # -v
        set +o xtrace  # -x
        # Check all values with 'shopt'.
        shopt -s autocd
        shopt -u cdable_vars
        shopt -s cdspell
        shopt -u checkhash
        shopt -u checkjobs
        shopt -s checkwinsize
        shopt -s cmdhist
        shopt -u direxpand
        shopt -u dirspell
        shopt -u dotglob
        shopt -u execfail
        shopt -u expand_aliases
        shopt -u extdebug
        shopt -s extglob
        shopt -s extquote
        shopt -u failglob
        shopt -s force_fignore
        shopt -s globstar
        shopt -s gnu_errfmt
        shopt -s histappend
        shopt -s histreedit
        shopt -u histverify
        shopt -s hostcomplete
        shopt -u huponexit
        shopt -s interactive_comments
        shopt -u lastpipe
        shopt -u lithist
        shopt -u mailwarn
        shopt -s no_empty_cmd_completion
        shopt -s nocaseglob
        shopt -u nocasematch
        shopt -u nullglob
        shopt -s progcomp
        shopt -s promptvars
        shopt -s shift_verbose
        shopt -s sourcepath
        shopt -u xpg_echo
        case "${BASH_VERSION:-}" in
            '1.'* | '2.'* | '3.'* | '4.'*)
                ;;
            *)
                # Bash 5+ supported options.
                shopt -u assoc_expand_once
                shopt -s complete_fullquote
                shopt -s globasciiranges
                shopt -s inherit_errexit
                shopt -u localvar_inherit
                shopt -u localvar_unset
                shopt -u progcomp_alias
                ;;
        esac
    fi
    if [[ "${dict['verbose']}" -eq 1 ]]
    then
        set -o verbose # -v
        set -o xtrace # -x
    fi
    if [[ -z "${KOOPA_PREFIX:-}" ]]
    then
        dict['header_path']="${BASH_SOURCE[0]}"
        if [[ -L "${dict['header_path']}" ]]
        then
            dict['header_path']="$(__koopa_realpath "${dict['header_path']}")"
        fi
        KOOPA_PREFIX="$( \
            cd "$(dirname "${dict['header_path']}")/../../../.." \
            &>/dev/null \
            && pwd -P \
        )"
        export KOOPA_PREFIX
    fi
    # shellcheck source=/dev/null
    source "${KOOPA_PREFIX:?}/lang/shell/posix/include/header.sh"
    if [[ "${dict['test']}" -eq 1 ]]
    then
        koopa_duration_start || return 1
    fi
    if [[ "${dict['activate']}" -eq 1 ]]
    then
        __koopa_source_functions 'activate'
        if [[ "${dict['minimal']}" -eq 0 ]]
        then
            koopa_activate_bash_extras
        fi
    fi
    if [[ "${dict['activate']}" -eq 0 ]] || [[ "${dict['dev']}" -eq 1 ]]
    then
        __koopa_source_functions 'common'
        dict['os_id']="$(koopa_os_id)"
        if koopa_is_linux
        then
            dict['linux_prefix']='os/linux'
            __koopa_source_functions "${dict['linux_prefix']}/common"
            if koopa_is_debian_like
            then
                __koopa_source_functions "${dict['linux_prefix']}/debian"
                # > koopa_is_ubuntu_like && \
                # >     __koopa_source_functions \
                # >         "${dict['linux_prefix']}/ubuntu"
            elif koopa_is_fedora_like
            then
                __koopa_source_functions "${dict['linux_prefix']}/fedora"
                koopa_is_rhel_like && \
                    __koopa_source_functions "${dict['linux_prefix']}/rhel"
            fi
            __koopa_source_functions "${dict['linux_prefix']}/${dict['os_id']}"
        else
            __koopa_source_functions "os/${dict['os_id']}"
        fi
        # Check if user is requesting help documentation.
        case "${1:-}" in
            '--help' | \
            '-h')
                koopa_help_2
                ;;
        esac
        if [[ -z "${KOOPA_ADMIN:-}" ]]
        then
            if koopa_is_shared_install && koopa_is_admin
            then
                export KOOPA_ADMIN=1
            else
                export KOOPA_ADMIN=0
            fi
        fi
        # Require admin account to run 'sbin/' scripts.
        if koopa_str_detect_fixed --string="$0" --pattern='/sbin'
        then
            koopa_assert_is_admin
        fi
        # Disable user-defined aliases.
        unalias -a
    fi
    if [[ "${dict['dev']}" -eq 1 ]]
    then
        export PS1='[koopa] $ '
    fi
    if [[ "${dict['verbose']}" -eq 1 ]]
    then
        koopa_alert_info 'Shell options'
        set +o
        shopt
        koopa_alert_info 'Shell variables'
        koopa_dl \
            '$' "${$}" \
            '-' "${-}" \
            'KOOPA_SHELL' "${KOOPA_SHELL:-}" \
            'SHELL' "${SHELL:-}"
        if koopa_is_installed 'locale'
        then
            koopa_alert_info 'Locale'
            locale
        fi
    fi
    if [[ "${dict['test']}" -eq 1 ]]
    then
        koopa_duration_stop 'bash' || return 1
    fi
    return 0
}

__koopa_bash_header "$@"
