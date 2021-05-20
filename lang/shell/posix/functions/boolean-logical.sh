#!/bin/sh
# koopa nolint=coreutils

__koopa_git_has_unstaged_changes() { # {{{1
    # """
    # Are there unstaged changes in current git repo?
    # @note Updated 2020-10-06.
    #
    # Don't use '--quiet' flag here, as it can cause shell to exit if 'set -e'
    # mode is enabled.
    #
    # @seealso
    # - https://stackoverflow.com/questions/3878624/
    # - https://stackoverflow.com/questions/28296130/
    # """
    local x
    git update-index --refresh >/dev/null 2>&1
    x="$(git diff-index HEAD -- 2>/dev/null)"
    [ -n "$x" ]
}

__koopa_git_needs_pull_or_push() { # {{{1
    # """
    # Does the current git repo need a pull or push?
    # @note Updated 2020-10-06.
    #
    # This will return an expected fatal warning when no upstream exists.
    # We're handling this case by piping errors to '/dev/null'.
    # """
    local rev_1 rev_2
    rev_1="$(git rev-parse HEAD 2>/dev/null)"
    rev_2="$(git rev-parse '@{u}' 2>/dev/null)"
    [ "$rev_1" != "$rev_2" ]
}

_koopa_expr() { # {{{1
    # """
    # Quiet regular expression matching that is POSIX compliant.
    # @note Updated 2020-06-30.
    #
    # Avoid using '[[ =~ ]]' in sh config files.
    # 'expr' is faster than using 'case'.
    #
    # See also:
    # - https://stackoverflow.com/questions/21115121
    # """
    expr "${1:?}" : "${2:?}" 1>/dev/null
}

_koopa_has_gnu() { # {{{1
    # """
    # Is a GNU program installed?
    # @note Updated 2020-07-20.
    # """
    local cmd str
    cmd="${1:?}"
    _koopa_is_installed "$cmd" || return 1
    str="$("$cmd" --version 2>&1 || true)"
    _koopa_str_match_posix "$str" 'GNU'
}

_koopa_has_gnu_binutils() { # {{{1
    # """
    # Is GNU binutils installed?
    # @note Updated 2020-04-27.
    # """
    _koopa_has_gnu ld
}

_koopa_has_gnu_coreutils() { # {{{1
    # """
    # Is GNU coreutils installed?
    # @note Updated 2020-04-27.
    # """
    _koopa_has_gnu env
}

_koopa_has_gnu_findutils() { # {{{1
    # """
    # Is GNU findutils installed?
    # @note Updated 2020-04-27.
    # """
    _koopa_has_gnu find
}

_koopa_is_alias() { # {{{1
    # """
    # Is the specified argument an alias?
    # @note Updated 2020-07-17.
    #
    # Intended primarily to determine if we need to unalias.
    # Tracked aliases (e.g. 'dash' to '/bin/dash') don't need to be unaliased.
    #
    # @example
    # koopa::is_alias R
    # """
    local cmd str
    for cmd in "$@"
    do
        _koopa_is_installed "$cmd" || return 1
        str="$(type "$cmd")"
        _koopa_str_match "$str" ' tracked alias ' && return 1
        _koopa_str_match_regex "$str" '\balias(ed)?\b' || return 1
    done
    return 0
}

_koopa_is_alpine() { # {{{1
    # """
    # Is the operating system Alpine Linux?
    # @note Updated 2020-08-06.
    # """
    _koopa_is_os 'alpine'
}

_koopa_is_amzn() { # {{{1
    # """
    # Is the operating system Amazon Linux?
    # @note Updated 2020-08-06.
    # """
    _koopa_is_os 'amzn'
}

_koopa_is_arch() { # {{{1
    # """
    # Is the operating system Arch Linux?
    # @note Updated 2020-08-06.
    # """
    _koopa_is_os 'arch'
}

_koopa_is_aws() { # {{{1
    # """
    # Is the current session running on AWS?
    # @note Updated 2020-08-06.
    # """
    _koopa_is_host 'aws'
}

_koopa_is_azure() { # {{{1
    # """
    # Is the current session running on Microsoft Azure?
    # @note Updated 2020-08-06.
    # """
    _koopa_is_host 'azure'
}

_koopa_is_centos() { # {{{1
    # """
    # Is the operating system CentOS?
    # @note Updated 2020-08-06.
    # """
    _koopa_is_os 'centos'
}

_koopa_is_centos_like() { # {{{1
    # """
    # Is the operating system CentOS-like?
    # @note Updated 2020-08-06.
    # """
    _koopa_is_os_like 'centos'
}

_koopa_is_conda_active() { # {{{1
    # """
    # Is there a Conda environment active?
    # @note Updated 2019-10-20.
    # """
    [ -n "${CONDA_DEFAULT_ENV:-}" ]
}

_koopa_is_debian() { # {{{1
    # """
    # Is the operating system Debian?
    # @note Updated 2020-08-06.
    # """
    _koopa_is_os 'debian'
}

_koopa_is_debian_like() { # {{{1
    # """
    # Is the operating system Debian-like?
    # @note Updated 2020-08-06.
    # """
    _koopa_is_os_like 'debian'
}

_koopa_is_fedora() { # {{{1
    # """
    # Is the operating system Fedora?
    # @note Updated 2020-08-06.
    # """
    _koopa_is_os 'fedora'
}

_koopa_is_fedora_like() { # {{{1
    # """
    # Is the operating system Fedora-like?
    # @note Updated 2020-08-06.
    # """
    _koopa_is_os_like 'fedora'
}

_koopa_is_git() { # {{{1i
    # """
    # Is the working directory a git repository?
    # @note Updated 2020-07-04.
    # @seealso
    # - https://stackoverflow.com/questions/2180270
    # """
    _koopa_is_git_toplevel '.' && return 0
    _koopa_is_installed git || return 1
    git rev-parse --git-dir >/dev/null 2>&1 || return 1
    return 0
}

_koopa_is_git_clean() { # {{{1
    # """
    # Is the working directory git repo clean, or does it have unstaged changes?
    # @note Updated 2020-10-06.
    #
    # This is used in prompt, so be careful with assert checks.
    #
    # @seealso
    # - https://stackoverflow.com/questions/3878624
    # - https://stackoverflow.com/questions/3258243
    # """
    _koopa_is_git || return 1
    _koopa_is_installed git || return 1
    __koopa_git_has_unstaged_changes && return 1
    __koopa_git_needs_pull_or_push && return 1
    return 0
}

_koopa_is_git_toplevel() { # {{{1
    # """
    # Is the working directory the top level of a git repository?
    # @note Updated 2020-07-04.
    # """
    local dir
    dir="${1:-.}"
    [ -e "${dir}/.git" ]
}

_koopa_is_host() { # {{{1
    # """
    # Does the current host match?
    # @note Updated 2020-08-06.
    # """
    [ "$(_koopa_host_id)" = "${1:?}" ]
}

_koopa_is_installed() { # {{{1
    # """
    # Is the requested program name installed?
    # @note Updated 2020-07-05.
    # """
    local cmd
    for cmd in "$@"
    do
        command -v "$cmd" >/dev/null || return 1
    done
    return 0
}

_koopa_is_interactive() { # {{{1
    # """
    # Is the current shell interactive?
    # @note Updated 2021-05-07.
    # Consider checking for tmux or subshell here.
    # """
    [ "${KOOPA_INTERACTIVE:-0}" -eq 1 ] && return 0
    _koopa_str_match_posix "$-" 'i' && return 0
    _koopa_is_tty && return 0
    return 1
}

_koopa_is_linux() { # {{{1
    # """
    # Is the current operating system Linux?
    # @note Updated 2020-02-05.
    # """
    [ "$(uname -s)" = 'Linux' ]
}

_koopa_is_local_install() { # {{{1
    # """
    # Is koopa installed only for the current user?
    # @note Updated 2020-04-29.
    # """
    _koopa_str_match_regex "$(_koopa_prefix)" "^${HOME}"
}

_koopa_is_macos() { # {{{1
    # """
    # Is the operating system macOS (Darwin)?
    # @note Updated 2020-01-13.
    # """
    [ "$(uname -s)" = 'Darwin' ]
}

_koopa_is_opensuse() { # {{{1
    # """
    # Is the operating system openSUSE?
    # @note Updated 2020-08-06.
    # """
    _koopa_is_os 'opensuse'
}

_koopa_is_os() { # {{{1
    # """
    # Is a specific OS ID?
    # @note Updated 2020-08-06.
    #
    # This will match Debian but not Ubuntu for a Debian check.
    # """
    [ "$(_koopa_os_id)" = "${1:?}" ]
}

_koopa_is_os_like() { # {{{1
    # """
    # Is a specific OS ID-like?
    # @note Updated 2020-08-06.
    #
    # This will match Debian and Ubuntu for a Debian check.
    # """
    local file id
    id="${1:?}"
    _koopa_is_os "$id" && return 0
    file='/etc/os-release'
    [ -f "$file" ] || return 1
    grep 'ID=' "$file" | grep -q "$id" && return 0
    grep 'ID_LIKE=' "$file" | grep -q "$id" && return 0
    return 1
}

_koopa_is_os_version() { # {{{1
    # """
    # Is a specific OS version?
    # @note Updated 2020-08-06.
    # """
    local file version
    version="${1:?}"
    file='/etc/os-release'
    [ -f "$file" ] || return 1
    grep -q "VERSION_ID=\"${version}" "$file"
}

_koopa_is_qemu() { # {{{1
    # """
    # Is the current shell running inside of QEMU emulation?
    # @note Updated 2021-05-20.
    #
    # This can be the case for ARM Docker images running on an x86 Intel
    # machine, and vice versa.
    # """
    local cmd real_cmd
    cmd="/proc/${$}/exe"
    [ -L "$cmd" ] || return 1
    _koopa_is_installed readlink || return 1
    real_cmd="$(readlink "$cmd")"
    case "$(basename "$real_cmd")" in
        qemu-*)
            return 0
            ;;
    esac
    return 1
}

_koopa_is_raspbian() { # {{{1
    # """
    # Is the operating system Raspbian?
    # @note Updated 2020-08-06.
    # """
    _koopa_is_os 'raspbian'
}

_koopa_is_remote() { # {{{1
    # """
    # Is the current shell session a remote connection over SSH?
    # @note Updated 2019-06-25.
    # """
    [ -n "${SSH_CONNECTION:-}" ]
}

_koopa_is_rhel() { # {{{1
    # """
    # Is the operating system RHEL?
    # @note Updated 2020-08-06.
    # """
    _koopa_is_os 'rhel'
}

_koopa_is_rhel_like() { # {{{1
    # """
    # Is the operating system RHEL-like?
    # @note Updated 2020-08-06.
    # """
    _koopa_is_os_like 'rhel'
}

_koopa_is_rhel_ubi() { # {{{
    # """
    # Is the operating system a RHEL universal base image (UBI)?
    # @note Updated 2020-08-06.
    # """
    [ -f '/etc/yum.repos.d/ubi.repo' ]
}

_koopa_is_rhel_7_like() { # {{{1
    # """
    # Is the operating system RHEL 7-like?
    # @note Updated 2021-03-25.
    # """
    _koopa_is_rhel_like && _koopa_is_os_version 7
}

_koopa_is_rhel_8_like() { # {{{1
    # """
    # Is the operating system RHEL 8-like?
    # @note Updated 2020-08-06.
    # """
    _koopa_is_rhel_like && _koopa_is_os_version 8
}

_koopa_is_root() { # {{{1
    # """
    # Is the current user root?
    # @note Updated 2020-04-16.
    # """
    [ "$(_koopa_user_id)" -eq 0 ]
}

_koopa_is_rstudio() { # {{{1
    # """
    # Is the terminal running inside RStudio?
    # @note Updated 2020-06-19.
    # """
    [ -n "${RSTUDIO:-}" ]
}

_koopa_is_set_nounset() { # {{{1
    # """
    # Is shell running in 'nounset' variable mode?
    # @note Updated 2020-04-29.
    #
    # Many activation scripts, including Perlbrew and others have unset
    # variables that can cause the shell session to exit.
    #
    # How to enable:
    # > set -o nounset
    # > set -u
    #
    # Bash:
    # shopt -o (arg?)
    # Enabled: 'nounset [...] on'.
    #
    # shopt -op (arg?)
    # Enabled: 'set -o nounset'.
    #
    # Zsh:
    # setopt
    # Enabled: 'nounset'.
    # """
    _koopa_str_match_posix "$(set +o)" 'set -o nounset'
}

_koopa_is_shared_install() { # {{{1
    # """
    # Is koopa installed for all users (shared)?
    # @note Updated 2019-06-25.
    # """
    ! _koopa_is_local_install
}

_koopa_is_subshell() { # {{{1
    # """
    # Is koopa running inside a subshell?
    # @note Updated 2021-05-06.
    # """
    [ "${KOOPA_SUBSHELL:-0}" -gt 0 ]
}

_koopa_is_tmux() { # {{{1
    # """
    # Is current session running inside tmux?
    # @note Updated 2020-02-26.
    # """
    [ -n "${TMUX:-}" ]
}

_koopa_is_tty() { # {{{1
    # """
    # Is current shell a teletypewriter?
    # @note Updated 2020-07-03.
    # """
    _koopa_is_installed tty || return 1
    tty >/dev/null 2>&1 || false
}

_koopa_is_ubuntu() { # {{{1
    # """
    # Is the operating system Ubuntu?
    # @note Updated 2020-04-29.
    # """
    _koopa_is_os 'ubuntu'
}

_koopa_is_ubuntu_like() { # {{{1
    # """
    # Is the operating system Ubuntu-like?
    # @note Updated 2020-08-06.
    # """
    _koopa_is_os_like 'ubuntu'
}

_koopa_is_venv_active() { # {{{1
    # """
    # Is there a Python virtual environment active?
    # @note Updated 2019-10-20.
    # """
    [ -n "${VIRTUAL_ENV:-}" ]
}

_koopa_macos_is_dark_mode() { # {{{1
    # """
    # Is the current macOS terminal running in dark mode?
    # @note Updated 2021-05-05.
    # """
    local x
    x=$(defaults read -g 'AppleInterfaceStyle' 2>/dev/null)
    [ "$x" = 'Dark' ]
}

_koopa_macos_is_light_mode() { # {{{1
    # """
    # Is the current terminal running in light mode?
    # @note Updated 2021-05-05.
    # """
    ! _koopa_macos_is_dark_mode
}
