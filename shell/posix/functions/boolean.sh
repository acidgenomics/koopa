#!/bin/sh
# shellcheck disable=SC2039

_koopa_has_file_ext() {  # {{{1
    # """
    # Does the input contain a file extension?
    # @note Updated 2020-01-12.
    #
    # Simply looks for a "." and returns true/false.
    # """
    local file
    file="${1:?}"
    echo "$file" | grep -q "\."
}

_koopa_has_no_environments() {  # {{{1
    # """
    # Detect activation of virtual environments.
    # @note Updated 2019-10-20.
    # """
    _koopa_is_conda_active && return 1
    _koopa_is_venv_active && return 1
    return 0
}

_koopa_has_passwordless_sudo() {  # {{{1
    # """
    # Check if sudo is active or doesn't require a password.
    # @note Updated 2020-02-05.
    #
    # See also:
    # https://askubuntu.com/questions/357220
    # """
    _koopa_is_installed sudo || return 1
    sudo -n true 2>/dev/null && return 0
    return 1
}

_koopa_has_sudo() {  # {{{1
    # """
    # Check that current user has administrator (sudo) permission.
    # @note Updated 2020-02-05.
    #
    # This check is hanging on an CPI AWS Ubuntu EC2 instance, I think due to
    # 'groups' taking a long time to return for domain users.
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
    # Always return true for root user.
    [ "$(id -u)" -eq 0 ] && return 0
    # Return false if 'sudo' program is not installed.
    _koopa_is_installed sudo || return 1
    # Early return true if user has passwordless sudo enabled.
    _koopa_has_passwordless_sudo && return 0
    # This step is slow for Active Directory domain user accounts on Ubuntu.
    _koopa_assert_is_installed grep groups
    groups | grep -Eq "\b(admin|root|sudo|wheel)\b"
}

_koopa_is_alias() {  # {{{1
    # """
    # Is the specified argument an alias?
    # @note Updated 2020-02-06.
    #
    # @example
    # _koopa_is_alias R
    # """
    local cmd
    cmd="${1:?}"
    _koopa_is_installed "$cmd" || return 1
    local str
    str="$(type "$cmd")"
    local shell
    shell="$(_koopa_shell)"
    case "$shell" in
        bash)
            pattern="is aliased to"
            ;;
        zsh)
            pattern="is an alias for"
            ;;
    esac
    _koopa_is_matching_fixed "$str" "$pattern"
}

_koopa_is_aws() {  # {{{1
    # """
    # Is the current session running on AWS?
    # @note Updated 2019-11-25.
    # """
    [ "$(_koopa_host_id)" = "aws" ]
}

_koopa_is_amzn() {  # {{{1
    # """
    # Is the operating system Amazon Linux?
    # @note Updated 2020-01-21.
    # """
    [ "$(_koopa_os_id)" = "amzn" ]
}

_koopa_is_azure() {  # {{{1
    # """
    # Is the current session running on Microsoft Azure?
    # @note Updated 2019-11-25.
    # """
    [ "$(_koopa_host_id)" = "azure" ]
}

_koopa_is_cellar() {  # {{{1
    # """
    # Is a specific command cellarized?
    # @note Updated 2020-02-10.
    # """
    local cmd
    cmd="${1:?}"
    _koopa_is_installed "$cmd" || return 1
    cmd="$(_koopa_which_realpath "$cmd")"
    local cellar_prefix
    cellar_prefix="$(_koopa_cellar_prefix)"
    _koopa_is_matching_regex "$cmd" "^${cellar_prefix}"
}

_koopa_is_conda_active() {  # {{{1
    # """
    # Is there a Conda environment active?
    # @note Updated 2019-10-20.
    # """
    [ -n "${CONDA_DEFAULT_ENV:-}" ]
}

_koopa_is_current_version() {  # {{{1
    # """
    # Is the installed program current?
    # @note Updated 2020-02-07.
    # """
    local app
    app="${1:?}"
    local expected
    expected="$(_koopa_variable "$app")"
    echo "$expected"
    local actual
    actual="$(_koopa_get_version "$app")"
    echo "$actual"
    [ "$actual" == "$expected" ]
}

_koopa_is_debian() {  # {{{1
    # """
    # Is the operating system Debian?
    # @note Updated 2019-10-25.
    # """
    [ -f /etc/os-release ] || return 1
    grep "ID=" /etc/os-release | grep -q "debian" ||
        grep "ID_LIKE=" /etc/os-release | grep -q "debian"
}

_koopa_is_defined_in_shell_profile() {  # {{{1
    # """
    # Is koopa defined in current user's shell profile configuration file?
    # @note Updated 2020-02-15
    # """
    local file
    file="$(_koopa_find_shell_profile)"
    [ -r "$file" ] || return 1
    grep -q "koopa" "$file"
}

_koopa_is_docker() {  # {{{1
    # """
    # Is the current shell running inside Docker?
    # @note Updated 2020-01-22.
    #
    # https://stackoverflow.com/questions/23513045
    # """
    local file
    file="/proc/1/cgroup"
    [ -f "$file" ] || return 1
    grep -q ':/docker/' "$file"
}

_koopa_is_fedora() {  # {{{1
    # """
    # Is the operating system Fedora?
    # @note Updated 2019-10-25.
    # """
    [ -f /etc/os-release ] || return 1
    grep "ID=" /etc/os-release | grep -q "fedora" ||
        grep "ID_LIKE=" /etc/os-release | grep -q "fedora"
}

_koopa_is_file_system_case_sensitive() {  # {{{1
    # """
    # Is the file system case sensitive?
    # @note Updated 2019-10-21.
    #
    # Linux is case sensitive by default, whereas macOS and Windows are not.
    # """
    touch ".tmp.checkcase" ".tmp.checkCase"
    count="$(find . -maxdepth 1 -iname ".tmp.checkcase" | wc -l)"
    _koopa_quiet_rm .tmp.check* 
    if [ "$count" -eq 2 ]
    then
        return 0
    else
        return 1
    fi
}

_koopa_is_function() {  # {{{1
    # """
    # Check if variable is a function.
    # @note Updated 2020-02-07.
    #
    # @seealso
    # https://stackoverflow.com/questions/85880
    # """
    local fun
    fun="${1:?}"
    case "$(_koopa_shell)" in
        bash)
            [ "$(type -t "$fun")" == "function" ]
            ;;
        zsh)
            _koopa_is_matching_fixed "$(type "$fun")" "is a shell function"
            ;;
    esac
}

_koopa_is_git() {  # {{{1
    # """
    # Is directory a git repository?
    # @note Updated 2020-02-11.
    #
    # Fast check that we can use for command prompt.
    #
    # Be aware that '.git' is not always a directory.
    # """
    local dir
    dir="${1:-.}"
    [ -e "${dir}/.git" ]
}

_koopa_is_git2() {  # {{{1
    # """
    # Is the working directory a git repository?
    # @note Updated 2020-02-10.
    #
    # Slower and more thorough check.
    #
    # See also:
    # - https://stackoverflow.com/questions/2180270
    # """
    _koopa_assert_is_installed git
    if git rev-parse --git-dir > /dev/null 2>&1
    then
        return 0
    else
        return 1
    fi
}

_koopa_is_git_clean() {  # {{{1
    # """
    # Is the working directory git repo clean, or does it have unstaged changes?
    # @note Updated 2020-02-11.
    #
    # See also:
    # - https://stackoverflow.com/questions/3878624
    # - https://stackoverflow.com/questions/3258243
    # """
    _koopa_is_git "." || return 1
    _koopa_assert_is_installed git
    # Are there unstaged changes?
    if ! git diff-index --quiet HEAD --
    then
        return 1
    fi
    # In need of a pull or push?
    if [ "$(git rev-parse HEAD)" != "$(git rev-parse '@{u}')" ]
    then
        return 1
    fi
    return 0
}

_koopa_is_github_ssh_enabled() {  # {{{1
    # """
    # Is SSH key enabled for GitHub access?
    # @note Updated 2020-02-11.
    # """
    _koopa_is_ssh_enabled "git@github.com" "successfully authenticated"
}

_koopa_is_gitlab_ssh_enabled() {  # {{{1
    # """
    # Is SSH key enabled for GitLab access?
    # @note Updated 2020-02-11.
    # """
    _koopa_is_ssh_enabled "git@gitlab.com" "Welcome to GitLab"
}

_koopa_is_installed() {  # {{{1
    # """
    # Is the requested program name installed?
    # @note Updated 2019-10-02.
    # """
    command -v "$1" >/dev/null
}

_koopa_is_interactive() {  # {{{1
    # """
    # Is the current shell interactive?
    # @note Updated 2019-06-21.
    # """
    echo "$-" | grep -q "i"
}

_koopa_is_linux() {  # {{{1
    # """
    # Is the current operating system Linux?
    # @note Updated 2020-02-05.
    # """
    [ "$(uname -s)" = "Linux" ]
}

_koopa_is_local_install() {  # {{{1
    # """
    # Is koopa installed only for the current user?
    # @note Updated 2020-02-13.
    # """
    local prefix
    prefix="$(_koopa_prefix)"
    echo "$prefix" | grep -Eq "^${HOME}"
}

_koopa_is_login() {  # {{{1
    # """
    # Is the current shell a login shell?
    # @note Updated 2019-08-14.
    # """
    echo "$0" | grep -Eq "^-"
}

_koopa_is_login_bash() {  # {{{1
    # """
    # Is the current shell a login bash shell?
    # @note Updated 2019-06-21.
    # """
    [ "$0" = "-bash" ]
}

_koopa_is_login_zsh() {  # {{{1
    # """
    # Is the current shell a login zsh shell?
    # @note Updated 2019-06-21.
    # """
    [ "$0" = "-zsh" ]
}

_koopa_is_macos() {  # {{{1
    # """
    # Is the operating system macOS (Darwin)?
    # @note Updated 2020-01-13.
    # """
    [ "$(uname -s)" = "Darwin" ]
}

_koopa_is_matching_fixed() {  # {{{1
    # """
    # Does the input match a fixed string?
    # @note Updated 2020-01-12.
    # """
    local string
    string="${1:?}"
    local pattern
    pattern="${2:?}"
    echo "$string" | grep -Fq "$pattern"
}

_koopa_is_matching_regex() {  # {{{1
    # """
    # Does the input match a regular expression?
    # @note Updated 2020-01-12.
    # """
    local string
    string="${1:?}"
    local pattern
    pattern="${2:?}"
    echo "$string" | grep -Eq "$pattern"
}

_koopa_is_powerful() {  # {{{1
    # """
    # Is the current machine powerful?
    # @note Updated 2019-11-22.
    # """
    local cores
    cores="$(_koopa_cpu_count)"
    if [ "$cores" -ge 7 ]
    then
        return 0
    else
        return 1
    fi
}

_koopa_is_python_package_installed() {  # {{{1
    # """
    # Check if Python package is installed.
    # @note Updated 2020-02-10.
    #
    # Fast mode: checking the 'site-packages' directory.
    #
    # Alternate, slow mode:
    # > local freeze
    # > freeze="$("$python" -m pip freeze)"
    # > _koopa_is_matching_regex "$freeze" "^${pkg}=="
    #
    # See also:
    # - https://stackoverflow.com/questions/1051254
    # - https://askubuntu.com/questions/588390
    # """
    local pkg
    pkg="${1:?}"
    local python
    python="${2:-python3}"
    _koopa_is_installed "$python" || return 1
    local prefix
    prefix="$(_koopa_python_site_packages_prefix "$python")"
    [ -d "${prefix}/${pkg}" ]
}

_koopa_is_r_package_installed() {  # {{{1
    # """
    # Is the requested R package installed?
    # @note Updated 2020-02-10.
    #
    # Fast mode: checking the 'site-library' directory.
    #
    # Alternate, slow mode:
    # > Rscript -e "\"$1\" %in% rownames(utils::installed.packages())" \
    # >     | grep -q "TRUE"
    # """
    local pkg
    pkg="${1:?}"
    _koopa_is_installed R || return 1
    local prefix
    prefix="$(_koopa_r_library_prefix)"
    [ -d "${prefix}/${pkg}" ]
}

_koopa_is_rhel() {  # {{{1
    # """
    # Is the operating system RHEL?
    # @note Updated 2019-12-09.
    # """
    _koopa_is_fedora || return 1
    [ -f /etc/os-release ] || return 1
    grep "ID=" /etc/os-release | grep -q "rhel" && return 0
    grep "ID_LIKE=" /etc/os-release | grep -q "rhel" && return 0
    return 1
}

_koopa_is_rhel_7() {  # {{{1
    # """
    # Is the operating system RHEL 7?
    # @note Updated 2019-11-25.
    # """
    [ -f /etc/os-release ] || return 1
    grep -q 'ID="rhel"' /etc/os-release || return 1
    grep -q 'VERSION_ID="7' /etc/os-release || return 1
    return 0
}

_koopa_is_rhel_8() {  # {{{1
    # """
    # Is the operating system RHEL 8?
    # @note Updated 2019-11-25.
    # """
    [ -f /etc/os-release ] || return 1
    grep -q 'ID="rhel"' /etc/os-release || return 1
    grep -q 'VERSION_ID="8' /etc/os-release || return 1
    return 0
}

_koopa_is_remote() {  # {{{1
    # """
    # Is the current shell session a remote connection over SSH?
    # @note Updated 2019-06-25.
    # """
    [ -n "${SSH_CONNECTION:-}" ]
}

_koopa_is_root() {  # {{{1
    # """
    # Is the current user root?
    # @note Updated 2019-12-17
    # """
    [ "$(id -u)" -eq 0 ]
}

_koopa_is_shared_install() {  # {{{1
    # """
    # Is koopa installed for all users (shared)?
    # @note Updated 2019-06-25.
    # """
    ! _koopa_is_local_install
}

_koopa_is_set() {  # {{{1
    # """
    # Is the variable set and non-empty?
    # @note Updated 2020-02-07.
    #
    # Passthrough of empty strings is bad practice in shell scripting.
    #
    # @seealso
    # https://stackoverflow.com/questions/3601515
    # """
    [ -n "${1:-}" ]
}

_koopa_is_setopt_nounset() {  # {{{1
    # """
    # Is shell running in 'nounset' variable mode?
    # @note Updated 2020-01-24.
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
    local shell
    shell="$(_koopa_shell)"
    case "$shell" in
        bash)
            # > shopt -op nounset | grep -q 'set -o nounset'
            shopt -oq nounset
            ;;
        zsh)
            setopt | grep -q 'nounset'
            ;;
        *)
            _koopa_stop "Unknown error."
            ;;
    esac
}

_koopa_is_ssh_enabled() {  # {{{1
    # """
    # Is SSH key enabled (e.g. for git)?
    # @note Updated 2020-02-11.
    #
    # @seealso
    # - https://help.github.com/en/github/authenticating-to-github/
    #       testing-your-ssh-connection
    # """
    local url
    url="${1:?}"
    local pattern
    pattern="${2:?}"
    _koopa_is_installed ssh || return 1
    local x
    x="$( \
        ssh -T \
            -o StrictHostKeyChecking=no \
            "$url" 2>&1 \
    )"
    [ -n "$x" ] || return 1
    _koopa_is_matching_fixed "$x" "$pattern"
}

_koopa_is_ubuntu() {  # {{{1
    # """
    # Is the operating system Ubuntu?
    # @note Updated 2020-01-14.
    # """
    [ -f /etc/os-release ] || return 1
    grep "ID=" /etc/os-release | grep -q "ubuntu" ||
        grep "ID_LIKE=" /etc/os-release | grep -q "ubuntu"
}

_koopa_is_venv_active() {  # {{{1
    # """
    # Is there a Python virtual environment active?
    # @note Updated 2019-10-20.
    # """
    [ -n "${VIRTUAL_ENV:-}" ]
}
