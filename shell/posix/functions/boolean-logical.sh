#!/bin/sh
# shellcheck disable=SC2039

__koopa_has_gnu() { # {{{1
    # """
    # Is a GNU program installed?
    # @note Updated 2020-06-30.
    # """
    _koopa_assert_has_args "$#"
    local cmd str
    cmd="${1:?}"
    _koopa_is_installed "$cmd" || return 1
    str="$("$cmd" --version 2>&1 || true)"
    _koopa_str_match "$str" "GNU"
}

__koopa_is_os_release() { # {{{1
    # """
    # Is a specific OS release?
    # @note Updated 2020-06-30.
    # """
    _koopa_assert_has_args "$#"
    local file id version
    id="${1:?}"
    version="${2:-}"
    file="/etc/os-release"
    [ -f "$file" ] || return 1
    # Check identifier.
    grep "ID=" "$file" | grep -q "$id" && return 0
    grep "ID_LIKE=" "$file" | grep -q "$id" && return 0
    # Check version.
    if [ -n "$version" ]
    then
        grep -q "VERSION_ID=\"${version}" "$file" && return 0
    fi
    return 1
}

_koopa_has_file_ext() { # {{{1
    # """
    # Does the input contain a file extension?
    # @note Updated 2020-06-30.
    #
    # Simply looks for a "." and returns true/false.
    #
    # @examples
    # _koopa_has_file_ext "hello.txt"
    # """
    _koopa_assert_has_args "$#"
    local file
    file="${1:?}"
    _koopa_str_match "$(_koopa_print "$file")" "."
}

_koopa_has_gnu_binutils() { # {{{1
    # """
    # Is GNU binutils installed?
    # @note Updated 2020-04-27.
    # """
    _koopa_assert_has_no_args "$#"
    __koopa_has_gnu ld
}

_koopa_has_gnu_coreutils() { # {{{1
    # """
    # Is GNU coreutils installed?
    # @note Updated 2020-04-27.
    # """
    _koopa_assert_has_no_args "$#"
    __koopa_has_gnu env
}

_koopa_has_gnu_findutils() { # {{{1
    # """
    # Is GNU findutils installed?
    # @note Updated 2020-04-27.
    # """
    _koopa_assert_has_no_args "$#"
    __koopa_has_gnu find
}

_koopa_has_gnu_sed() { # {{{1
    # """
    # Is GNU tar installed?
    # @note Updated 2020-04-27.
    # """
    _koopa_assert_has_no_args "$#"
    __koopa_has_gnu sed
}

_koopa_has_gnu_tar() { # {{{1
    # """
    # Is GNU tar installed?
    # @note Updated 2020-04-27.
    # """
    _koopa_assert_has_no_args "$#"
    __koopa_has_gnu tar
}

_koopa_has_monorepo() { # {{{1
    # """
    # Does the current user have a monorepo?
    # @note Updated 2020-07-03.
    # """
    [ -d "$(_koopa_monorepo_prefix)" ]
}

_koopa_has_no_environments() { # {{{1
    # """
    # Detect activation of virtual environments.
    # @note Updated 2020-06-30.
    # """
    _koopa_assert_has_no_args "$#"
    _koopa_is_conda_active && return 1
    _koopa_is_venv_active && return 1
    return 0
}

_koopa_has_passwordless_sudo() { # {{{1
    # """
    # Check if sudo is active or doesn't require a password.
    # @note Updated 2020-06-30.
    #
    # See also:
    # https://askubuntu.com/questions/357220
    # """
    _koopa_assert_has_no_args "$#"
    _koopa_is_installed sudo || return 1
    sudo -n true 2>/dev/null && return 0
    return 1
}

_koopa_has_sudo() { # {{{1
    # """
    # Check that current user has administrator (sudo) permission.
    # @note Updated 2020-06-30.
    #
    # This check is hanging on an CPI AWS Ubuntu EC2 instance, I think due to
    # 'groups' can lag on systems for domain user accounts.
    # Currently seeing on CPI AWS Ubuntu config.
    #
    # Avoid prompting with '-n, --non-interactive', but note that this isn't
    # supported on all systems.
    #
    # Note that use of 'sudo -v' does not work consistently across platforms.
    #
    # Alternate approach:
    # > sudo -l
    #
    # List all users with sudo access:
    # > getent group sudo
    #
    # - macOS: admin
    # - Debian: sudo
    # - Fedora: wheel
    #
    # See also:
    # - https://serverfault.com/questions/364334
    # - https://linuxhandbook.com/check-if-user-has-sudo-rights/
    # """
    _koopa_assert_has_no_args "$#"
    # Always return true for root user.
    [ "$(_koopa_current_user_id)" -eq 0 ] && return 0
    # Return false if 'sudo' program is not installed.
    _koopa_is_installed sudo || return 1
    # Early return true if user has passwordless sudo enabled.
    _koopa_has_passwordless_sudo && return 0
    # Check if user is any accepted admin group.
    # Note that this step is very slow for Active Directory domain accounts.
    _koopa_str_match_regex "$(groups)" '\b(admin|root|sudo|wheel)\b'
}

_koopa_is_alias() { # {{{1
    # """
    # Is the specified argument an alias?
    # @note Updated 2020-06-30.
    #
    # Intended primarily to determine if we need to unalias.
    # Tracked aliases (e.g. 'dash' to '/bin/dash') don't need to be unaliased.
    #
    # @example
    # _koopa_is_alias R
    # """
    _koopa_assert_has_args "$#"
    local cmd str
    cmd="${1:?}"
    _koopa_is_installed "$cmd" || return 1
    str="$(type "$cmd")"
    _koopa_str_match "$str" ' tracked alias ' && return 1
    _koopa_str_match_regex "$str" '\balias(ed)?\b'
}

_koopa_is_alpine() { # {{{1
    # """
    # Is the operating system Alpine Linux?
    # @note Updated 2020-02-27.
    # """
    _koopa_assert_has_no_args "$#"
    [ "$(_koopa_os_id)" = 'alpine' ]
}

_koopa_is_amzn() { # {{{1
    # """
    # Is the operating system Amazon Linux?
    # @note Updated 2020-01-21.
    # """
    _koopa_assert_has_no_args "$#"
    [ "$(_koopa_os_id)" = 'amzn' ]
}

_koopa_is_arch() { # {{{1
    # """
    # Is the operating system Arch Linux?
    # @note Updated 2020-02-27.
    # """
    _koopa_assert_has_no_args "$#"
    [ "$(_koopa_os_id)" = 'arch' ]
}

_koopa_is_aws() { # {{{1
    # """
    # Is the current session running on AWS?
    # @note Updated 2019-11-25.
    # """
    _koopa_assert_has_no_args "$#"
    [ "$(_koopa_host_id)" = 'aws' ]
}

_koopa_is_azure() { # {{{1
    # """
    # Is the current session running on Microsoft Azure?
    # @note Updated 2019-11-25.
    # """
    _koopa_assert_has_no_args "$#"
    [ "$(_koopa_host_id)" = 'azure' ]
}

_koopa_is_bash_ok() { # {{{1
    # """
    # Is the current version of Bash OK (or super old)?
    # @note Updated 2020-07-02.
    # 
    # Older versions (< 4; e.g. shipping version on macOS) have issues with
    # 'read' that we have to handle with special care here.
    # """
    _koopa_is_installed bash || return 1
    local major_version version
    version="$(_koopa_get_version "bash")"
    major_version="$(_koopa_major_version "$version")"
    [ "$major_version" -ge 4 ]
}

_koopa_is_cellar() { # {{{1
    # """
    # Is a specific command or file cellarized?
    # @note Updated 2020-06-30.
    #
    # Currently only supported for Linux.
    # """
    _koopa_assert_has_args "$#"
    local cellar_prefix str
    str="${1:?}"
    if _koopa_is_installed "$str"
    then
        # Assume default usage is a command (e.g. R).
        str="$(_koopa_which_realpath "$str")"
    elif [ -e "$str" ]
    then
        # Otherwise assume it's a file path on disk.
        str="$(realpath "$str")"
    else
        return 1
    fi
    # Check koopa cellar.
    cellar_prefix="$(_koopa_cellar_prefix)"
    if [ -d "$cellar_prefix" ]
    then
        if _koopa_str_match_regex "$str" "^${cellar_prefix}"
        then
            return 0
        fi
    fi
    return 1
}

_koopa_is_centos() { # {{{1
    # """
    # Is the operating system CentOS?
    # @note Updated 2020-03-07.
    # """
    _koopa_assert_has_no_args "$#"
    [ "$(_koopa_os_id)" = 'centos' ]
}

_koopa_is_conda_active() { # {{{1
    # """
    # Is there a Conda environment active?
    # @note Updated 2019-10-20.
    # """
    _koopa_assert_has_no_args "$#"
    [ -n "${CONDA_DEFAULT_ENV:-}" ]
}

_koopa_is_current_version() { # {{{1
    # """
    # Is the program version current?
    # @note Updated 2020-06-30.
    # """
    _koopa_assert_has_args "$#"
    local app
    app="${1:?}"
    local expected_version
    expected_version="$(_koopa_variable "$app")"
    local actual_version
    actual_version="$(_koopa_get_version "$app")"
    [ "$actual_version" = "$expected_version" ]
}

_koopa_is_debian() { # {{{1
    # """
    # Is the operating system Debian?
    # @note Updated 2020-06-30.
    # """
    _koopa_assert_has_no_args "$#"
    __koopa_is_os_release debian
}

_koopa_is_defined_in_user_profile() { # {{{1
    # """
    # Is koopa defined in current user's shell profile configuration file?
    # @note Updated 2020-06-30.
    # """
    _koopa_assert_has_no_args "$#"
    local file
    file="$(_koopa_find_user_profile)"
    _koopa_file_match "$file" "koopa"
}

_koopa_is_docker() { # {{{1
    # """
    # Is the current shell running inside Docker?
    # @note Updated 2020-04-29.
    #
    # https://stackoverflow.com/questions/23513045
    # """
    _koopa_assert_has_no_args "$#"
    _koopa_file_match "/proc/1/cgroup" ":/docker/"
}

_koopa_is_export() { # {{{1
    # """
    # Is a variable exported in the current shell session?
    # @note Updated 2020-06-30.
    #
    # Use 'export -p' (POSIX) instead of 'declare -x' (Bashism).
    #
    # See also:
    # - https://unix.stackexchange.com/questions/390831
    #
    # @examples
    # _koopa_is_export "KOOPA_SHELL"
    # """
    _koopa_assert_has_args "$#"
    local arg exports
    exports="$(export -p)"
    for arg in "$@"
    do
        _koopa_str_match_regex "$exports" "\b${arg}\b=" || return 1
    done
    return 0
}

_koopa_is_fedora() { # {{{1
    # """
    # Is the operating system Fedora?
    # @note Updated 2020-06-30.
    # """
    _koopa_assert_has_no_args "$#"
    __koopa_is_os_release fedora
}

_koopa_is_file_system_case_sensitive() { # {{{1
    # """
    # Is the file system case sensitive?
    # @note Updated 2020-06-30.
    #
    # Linux is case sensitive by default, whereas macOS and Windows are not.
    # """
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_installed find
    touch '.tmp.checkcase' '.tmp.checkCase'
    count="$(find . -maxdepth 1 -iname '.tmp.checkcase' | wc -l)"
    _koopa_quiet_rm '.tmp.check'*
    [ "$count" -eq 2 ] && return 0
    return 1
}

_koopa_is_function() { # {{{1
    # """
    # Check if variable is a function.
    # @note Updated 2020-06-30.
    #
    # Note that 'declare' and 'typeset' are bashisms, and not POSIX.
    # Checking against 'type' works consistently across POSIX shells.
    #
    # Works in bash, ksh, zsh:
    # > typeset -f "$fun"
    #
    # Works in bash, zsh:
    # > declare -f "$fun"
    #
    # Works in bash (note use of '-t' flag):
    # > [ "$(type -t "$fun")" == "function" ]
    #
    # @seealso
    # - https://stackoverflow.com/questions/11478673/
    # - https://stackoverflow.com/questions/85880/
    # """
    _koopa_assert_has_args "$#"
    local fun str
    fun="${1:?}"
    str="$(type "$fun" 2>/dev/null)"
    # Harden against empty string return.
    [ -z "$str" ] && str="no"
    _koopa_str_match "$str" "function"
}

_koopa_is_git() { # {{{1i
    # """
    # Is the working directory a git repository?
    # @note Updated 2020-04-29.
    # @seealso
    # - https://stackoverflow.com/questions/2180270
    # """
    _koopa_assert_has_no_args "$#"
    _koopa_is_git_toplevel "." && return 0
    _koopa_is_installed git || return 1
    git rev-parse --git-dir >/dev/null 2>&1 && return 0
    return 1
}

_koopa_is_git_clean() { # {{{1
    # """
    # Is the working directory git repo clean, or does it have unstaged changes?
    # @note Updated 2020-07-03.
    # @seealso
    # - https://stackoverflow.com/questions/3878624
    # - https://stackoverflow.com/questions/3258243
    # """
    _koopa_assert_has_no_args "$#"
    _koopa_is_git || return 1
    local rev_1 rev_2
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
    # Is directory a git repository?
    # @note Updated 2020-02-11.
    #
    # Fast check that we can use for command prompt.
    #
    # Be aware that '.git' is not always a directory.
    #
    # @seealso
    # git rev-parse --show-toplevel
    # """
    local dir
    dir="${1:-.}"
    [ -e "${dir}/.git" ]
}

_koopa_is_github_ssh_enabled() { # {{{1
    # """
    # Is SSH key enabled for GitHub access?
    # @note Updated 2020-06-30.
    # """
    _koopa_assert_has_no_args "$#"
    _koopa_is_ssh_enabled 'git@github.com' 'successfully authenticated'
}

_koopa_is_gitlab_ssh_enabled() { # {{{1
    # """
    # Is SSH key enabled for GitLab access?
    # @note Updated 2020-06-30.
    # """
    _koopa_assert_has_no_args "$#"
    _koopa_is_ssh_enabled 'git@gitlab.com' 'Welcome to GitLab'
}

_koopa_is_installed() { # {{{1
    # """
    # Is the requested program name installed?
    # @note Updated 2020-07-03.
    # """
    _koopa_assert_has_args "$#"
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
    _koopa_assert_has_no_args "$#"
    _koopa_str_match "$-" "i" && return 0
    _koopa_is_tty && return 0
    return 1
}

_koopa_is_kali() { # {{{1
    # """
    # Is the current platform Kali Linux?
    # @note Updated 2020-06-30.
    # """
    _koopa_assert_has_no_args "$#"
    _koopa_str_match "$(_koopa_os_string)" "kali"
}

_koopa_is_linux() { # {{{1
    # """
    # Is the current operating system Linux?
    # @note Updated 2020-02-05.
    # """
    _koopa_assert_has_no_args "$#"
    [ "$(uname -s)" = 'Linux' ]
}

_koopa_is_local_install() { # {{{1
    # """
    # Is koopa installed only for the current user?
    # @note Updated 2020-04-29.
    # """
    _koopa_assert_has_no_args "$#"
    _koopa_str_match_regex "$(_koopa_prefix)" "^${HOME}"
}

_koopa_is_macos() { # {{{1
    # """
    # Is the operating system macOS (Darwin)?
    # @note Updated 2020-01-13.
    # """
    _koopa_assert_has_no_args "$#"
    [ "$(uname -s)" = 'Darwin' ]
}

_koopa_is_opensuse() { # {{{1
    # """
    # Is the operating system openSUSE?
    # @note Updated 2020-02-27.
    # """
    _koopa_assert_has_no_args "$#"
    [ "$(_koopa_os_id)" = 'opensuse' ]
}

_koopa_is_powerful() { # {{{1
    # """
    # Is the current machine powerful?
    # @note Updated 2020-03-07.
    # """
    _koopa_assert_has_no_args "$#"
    local cores
    cores="$(_koopa_cpu_count)"
    [ "$cores" -ge 7 ] && return 0
    return 1
}

_koopa_is_python_package_installed() { # {{{1
    # """
    # Check if Python package is installed.
    # @note Updated 2020-04-25.
    #
    # Fast mode: checking the 'site-packages' directory.
    #
    # Alternate, slow mode:
    # > local freeze
    # > freeze="$("$python" -m pip freeze)"
    # > _koopa_str_match_regex "$freeze" "^${pkg}=="
    #
    # See also:
    # - https://stackoverflow.com/questions/1051254
    # - https://askubuntu.com/questions/588390
    # """
    _koopa_assert_has_args "$#"
    local pkg
    pkg="${1:?}"
    local python_exe
    python_exe="${2:-python3}"
    _koopa_is_installed "$python_exe" || return 1
    local prefix
    prefix="$(_koopa_python_site_packages_prefix "$python_exe")"
    [ -d "${prefix}/${pkg}" ]
}

_koopa_is_r_package_installed() { # {{{1
    # """
    # Is the requested R package installed?
    # @note Updated 2020-04-25.
    #
    # This will only return true for user-installed packages.
    #
    # Fast mode: checking the 'site-library' directory.
    #
    # Alternate, slow mode:
    # > Rscript -e "\"$1\" %in% rownames(utils::installed.packages())" \
    # >     | grep -q "TRUE"
    # """
    _koopa_assert_has_args "$#"
    local pkg prefix rscript_exe
    pkg="${1:?}"
    rscript_exe="${2:-Rscript}"
    _koopa_is_installed "$rscript_exe" || return 1
    prefix="$(_koopa_r_library_prefix "$rscript_exe")"
    [ -d "${prefix}/${pkg}" ]
}

_koopa_is_raspbian() { # {{{1
    # """
    # Is the operating system Raspbian?
    # @note Updated 2020-05-12.
    # """
    _koopa_assert_has_no_args "$#"
    __koopa_is_os_release raspbian
}

_koopa_is_recent() {
    # """
    # If the file exists and is more recent than 2 weeks old.
    #
    # @note Updated 2020-06-03.
    #
    # Current approach uses GNU find to filter based on modification date.
    #
    # Alternatively, can we use 'stat' to compare the modification time to Unix
    # epoch in seconds or with GNU date.
    #
    # @seealso
    # - https://stackoverflow.com/a/32019461
    #
    # @examples
    # _koopa_is_recent ~/hello-world.txt
    # """
    _koopa_assert_has_args "$#"
    _koopa_assert_is_installed find
    local days exists file
    days=14
    for file in "$@"
    do
        [ -e "$file" ] || return 1
        exists="$( \
            find "$file" \
                -mindepth 0 \
                -maxdepth 0 \
                -mtime "-${days}" \
            2>/dev/null \
        )"
        [ -n "$exists" ] || return 1
    done
    return 0
}

_koopa_is_rhel() { # {{{1
    # """
    # Is the operating system RHEL?
    # @note Updated 2020-04-29.
    # """
    _koopa_assert_has_no_args "$#"
    __koopa_is_os_release rhel
}

_koopa_is_rhel_7() { # {{{1
    # """
    # Is the operating system RHEL 7?
    # @note Updated 2020-04-29.
    # """
    _koopa_assert_has_no_args "$#"
    _koopa_is_amzn && return 0
    __koopa_is_os_release rhel 7
}

_koopa_is_rhel_8() { # {{{1
    # """
    # Is the operating system RHEL 8?
    # @note Updated 2020-04-29.
    # """
    _koopa_assert_has_no_args "$#"
    __koopa_is_os_release rhel 8
}

_koopa_is_remote() { # {{{1
    # """
    # Is the current shell session a remote connection over SSH?
    # @note Updated 2019-06-25.
    # """
    _koopa_assert_has_no_args "$#"
    [ -n "${SSH_CONNECTION:-}" ]
}

_koopa_is_root() { # {{{1
    # """
    # Is the current user root?
    # @note Updated 2020-04-16.
    # """
    _koopa_assert_has_no_args "$#"
    [ "$(_koopa_current_user_id)" -eq 0 ]
}

_koopa_is_rstudio() { # {{{1
    # """
    # Is the terminal running inside RStudio?
    # @note Updated 2020-06-19.
    # """
    _koopa_assert_has_no_args "$#"
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
    _koopa_assert_has_no_args "$#"
    _koopa_str_match "$(set +o)" "set -o nounset"
}

_koopa_is_shared_install() { # {{{1
    # """
    # Is koopa installed for all users (shared)?
    # @note Updated 2019-06-25.
    # """
    _koopa_assert_has_no_args "$#"
    ! _koopa_is_local_install
}

_koopa_is_ssh_enabled() { # {{{1
    # """
    # Is SSH key enabled (e.g. for git)?
    # @note Updated 2020-07-03.
    #
    # @seealso
    # - https://help.github.com/en/github/authenticating-to-github/
    #       testing-your-ssh-connection
    # """
    _koopa_assert_has_args "$#"
    local pattern url x
    url="${1:?}"
    pattern="${2:?}"
    _koopa_is_installed ssh || return 1
    x="$( \
        ssh -T \
            -o StrictHostKeyChecking=no \
            "$url" 2>&1 \
    )"
    [ -n "$x" ] || return 1
    _koopa_str_match "$x" "$pattern"
}

_koopa_is_subshell() { # {{{1
    # """
    # Is koopa running inside a subshell?
    # @note Updated 2020-02-26.
    # """
    _koopa_assert_has_no_args "$#"
    [ "${KOOPA_SUBSHELL:-0}" -gt 0 ]
}

_koopa_is_tmux() { # {{{1
    # """
    # Is current session running inside tmux?
    # @note Updated 2020-02-26.
    # """
    _koopa_assert_has_no_args "$#"
    [ -n "${TMUX:-}" ]
}

_koopa_is_tty() { # {{{1
    # """
    # Is current shell a teletypewriter?
    # @note Updated 2020-02-15.
    # """
    _koopa_assert_has_no_args "$#"
    _koopa_is_installed tty || return 1
    tty >/dev/null 2>&1 || false
}

_koopa_is_ubuntu() { # {{{1
    # """
    # Is the operating system Ubuntu?
    # @note Updated 2020-04-29.
    # """
    _koopa_assert_has_no_args "$#"
    __koopa_is_os_release ubuntu
}

_koopa_is_ubuntu_18() { # {{{1
    # """
    # Is the operating system Ubuntu 18 LTS?
    # @note Updated 2020-04-29.
    # """
    _koopa_assert_has_no_args "$#"
    __koopa_is_os_release ubuntu 18.04
}

_koopa_is_ubuntu_20() { # {{{1
    # """
    # Is the operating system Ubuntu 20 LTS?
    # @note Updated 2020-04-29.
    # """
    _koopa_assert_has_no_args "$#"
    __koopa_is_os_release ubuntu 20.04
}

_koopa_is_venv_active() { # {{{1
    # """
    # Is there a Python virtual environment active?
    # @note Updated 2019-10-20.
    # """
    _koopa_assert_has_no_args "$#"
    [ -n "${VIRTUAL_ENV:-}" ]
}
