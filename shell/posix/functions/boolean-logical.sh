#!/bin/sh

__koopa_has_gnu() { # {{{1
    # """
    # Is a GNU program installed?
    # @note Updated 2020-07-04.
    # """
    # shellcheck disable=SC2039
    local cmd str
    cmd="${1:?}"
    _koopa_is_installed "$cmd" || return 1
    str="$("$cmd" --version 2>&1 || true)"
    _koopa_str_match_posix "$str" 'GNU'
}

__koopa_is_os_release() { # {{{1
    # """
    # Is a specific OS release?
    # @note Updated 2020-07-04.
    # """
    # shellcheck disable=SC2039
    local file id version
    id="${1:?}"
    version="${2:-}"
    file='/etc/os-release'
    [ -f "$file" ] || return 1
    # Check identifier.
    grep 'ID=' "$file" | grep -q "$id" && return 0
    grep 'ID_LIKE=' "$file" | grep -q "$id" && return 0
    # Check version.
    if [ -n "$version" ]
    then
        grep -q "VERSION_ID=\"${version}" "$file" && return 0
    fi
    return 1
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

_koopa_has_gnu_binutils() { # {{{1
    # """
    # Is GNU binutils installed?
    # @note Updated 2020-04-27.
    # """
    __koopa_has_gnu ld
}

_koopa_has_gnu_coreutils() { # {{{1
    # """
    # Is GNU coreutils installed?
    # @note Updated 2020-04-27.
    # """
    __koopa_has_gnu env
}

_koopa_has_gnu_findutils() { # {{{1
    # """
    # Is GNU findutils installed?
    # @note Updated 2020-04-27.
    # """
    __koopa_has_gnu find
}

_koopa_has_gnu_sed() { # {{{1
    # """
    # Is GNU tar installed?
    # @note Updated 2020-04-27.
    # """
    __koopa_has_gnu sed
}

_koopa_has_gnu_tar() { # {{{1
    # """
    # Is GNU tar installed?
    # @note Updated 2020-04-27.
    # """
    __koopa_has_gnu tar
}

_koopa_is_alpine() { # {{{1
    # """
    # Is the operating system Alpine Linux?
    # @note Updated 2020-02-27.
    # """
    [ "$(_koopa_os_id)" = 'alpine' ]
}

_koopa_is_amzn() { # {{{1
    # """
    # Is the operating system Amazon Linux?
    # @note Updated 2020-01-21.
    # """
    [ "$(_koopa_os_id)" = 'amzn' ]
}

_koopa_is_arch() { # {{{1
    # """
    # Is the operating system Arch Linux?
    # @note Updated 2020-02-27.
    # """
    [ "$(_koopa_os_id)" = 'arch' ]
}

_koopa_is_aws() { # {{{1
    # """
    # Is the current session running on AWS?
    # @note Updated 2019-11-25.
    # """
    [ "$(_koopa_host_id)" = 'aws' ]
}

_koopa_is_azure() { # {{{1
    # """
    # Is the current session running on Microsoft Azure?
    # @note Updated 2019-11-25.
    # """
    [ "$(_koopa_host_id)" = 'azure' ]
}

_koopa_is_centos() { # {{{1
    # """
    # Is the operating system CentOS?
    # @note Updated 2020-03-07.
    # """
    [ "$(_koopa_os_id)" = 'centos' ]
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
    # @note Updated 2020-06-30.
    # """
    __koopa_is_os_release debian
}

_koopa_is_fedora() { # {{{1
    # """
    # Is the operating system Fedora?
    # @note Updated 2020-06-30.
    # """
    __koopa_is_os_release fedora
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
    # @note Updated 2020-07-04.
    #
    # This is used in prompt, so be careful with assert checks.
    #
    # @seealso
    # - https://stackoverflow.com/questions/3878624
    # - https://stackoverflow.com/questions/3258243
    # """
    # shellcheck disable=SC2039
    local rev_1 rev_2
    _koopa_is_git || return 1
    _koopa_is_installed git || return 1
    # Are there unstaged changes?
    git diff-index --quiet HEAD -- 2>/dev/null || return 1
    # In need of a pull or push?
    rev_1="$(git rev-parse HEAD 2>/dev/null)"
    # Note that this step will return fatal warning on no upstream.
    rev_2="$(git rev-parse '@{u}' 2>/dev/null)"
    [ "$rev_1" != "$rev_2" ] && return 1
    return 0
}

_koopa_is_git_toplevel() { # {{{1
    # """
    # Is the working directory the top level of a git repository?
    # @note Updated 2020-07-04.
    # """
    # shellcheck disable=SC2039
    local dir
    dir="${1:-.}"
    [ -e "${dir}/.git" ]
}

_koopa_is_installed() { # {{{1
    # """
    # Is the requested program name installed?
    # @note Updated 2020-07-05.
    # """
    # shellcheck disable=SC2039
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
    # @note Updated 2020-07-03.
    # Consider checking for tmux or subshell here.
    # """
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
    # @note Updated 2020-02-27.
    # """
    [ "$(_koopa_os_id)" = 'opensuse' ]
}

_koopa_is_raspbian() { # {{{1
    # """
    # Is the operating system Raspbian?
    # @note Updated 2020-05-12.
    # """
    __koopa_is_os_release raspbian
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
    # @note Updated 2020-04-29.
    # """
    __koopa_is_os_release rhel
}

_koopa_is_rhel_7() { # {{{1
    # """
    # Is the operating system RHEL 7?
    # @note Updated 2020-04-29.
    # """
    _koopa_is_amzn && return 0
    __koopa_is_os_release rhel 7
}

_koopa_is_rhel_8() { # {{{1
    # """
    # Is the operating system RHEL 8?
    # @note Updated 2020-04-29.
    # """
    __koopa_is_os_release rhel 8
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
    _koopa_str_match "$(set +o)" 'set -o nounset'
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
    # @note Updated 2020-02-26.
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
    __koopa_is_os_release ubuntu
}

_koopa_is_ubuntu_18() { # {{{1
    # """
    # Is the operating system Ubuntu 18 LTS?
    # @note Updated 2020-04-29.
    # """
    __koopa_is_os_release ubuntu 18.04
}

_koopa_is_ubuntu_20() { # {{{1
    # """
    # Is the operating system Ubuntu 20 LTS?
    # @note Updated 2020-04-29.
    # """
    __koopa_is_os_release ubuntu 20.04
}

_koopa_is_venv_active() { # {{{1
    # """
    # Is there a Python virtual environment active?
    # @note Updated 2019-10-20.
    # """
    [ -n "${VIRTUAL_ENV:-}" ]
}
