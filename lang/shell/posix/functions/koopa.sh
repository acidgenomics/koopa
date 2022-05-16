#!/bin/sh

koopa_docker_prefix() {
    # """
    # Docker prefix.
    # @note Updated 2020-02-15.
    # """
    koopa_print "$(koopa_config_prefix)/docker"
    return 0
}

koopa_docker_private_prefix() {
    # """
    # Private Docker prefix.
    # @note Updated 2020-03-05.
    # """
    koopa_print "$(koopa_config_prefix)/docker-private"
    return 0
}

koopa_doom_emacs_prefix() {
    # """
    # Doom Emacs prefix.
    # @note Updated 2021-06-07.
    # """
    koopa_print "$(koopa_xdg_data_home)/doom"
    return 0
}

koopa_dotfiles_prefix() {
    # """
    # Dotfiles prefix.
    # @note Updated 2020-05-05.
    # """
    koopa_print "$(koopa_opt_prefix)/dotfiles"
    return 0
}

koopa_dotfiles_private_prefix() {
    # """
    # Private dotfiles prefix.
    # @note Updated 2021-11-24.
    # """
    koopa_print "$(koopa_config_prefix)/dotfiles-private"
    return 0
}

koopa_duration_start() {
    # """
    # Start activation duration timer.
    # @note Updated 2022-04-10.
    # """
    local bin_prefix
    bin_prefix="$(koopa_bin_prefix)"
    [ -x "${bin_prefix}/date" ] || return 0
    KOOPA_DURATION_START="$(date -u '+%s%3N')"
    export KOOPA_DURATION_START
    return 0
}

koopa_duration_stop() {
    # """
    # Stop activation duration timer.
    # @note Updated 2022-04-10.
    # """
    local bin_prefix
    bin_prefix="$(koopa_bin_prefix)"
    if [ ! -x "${bin_prefix}/bc" ] || \
        [ ! -x "${bin_prefix}/date" ]
    then
        return 0
    fi
    local duration key start stop
    key="${1:-}"
    if [ -z "$key" ]
    then
        key='duration'
    else
        key="[${key}] duration"
    fi
    start="${KOOPA_DURATION_START:?}"
    stop="$(date -u '+%s%3N')"
    duration="$(koopa_print "${stop}-${start}" | bc)"
    [ -n "$duration" ] || return 1
    koopa_dl "$key" "${duration} ms"
    unset -v KOOPA_DURATION_START
    return 0
}

koopa_emacs_prefix() {
    # """
    # Default Emacs prefix.
    # @note Updated 2020-06-29.
    # """
    koopa_print "${HOME:?}/.emacs.d"
    return 0
}

koopa_ensembl_perl_api_prefix() {
    # """
    # Ensembl Perl API prefix.
    # @note Updated 2021-05-04.
    # """
    koopa_print "$(koopa_opt_prefix)/ensembl-perl-api"
    return 0
}

koopa_export_editor() {
    # """
    # Export 'EDITOR' variable.
    # @note Updated 2022-05-12.
    # """
    if [ -z "${EDITOR:-}" ]
    then
        EDITOR="$(koopa_bin_prefix)/vim"
    fi
    VISUAL="$EDITOR"
    export EDITOR VISUAL
    return 0
}

koopa_export_git() {
    # """
    # Export git configuration.
    # @note Updated 2021-05-14.
    #
    # @seealso
    # https://git-scm.com/docs/merge-options
    # """
    if [ -z "${GIT_MERGE_AUTOEDIT:-}" ]
    then
        GIT_MERGE_AUTOEDIT='no'
    fi
    export GIT_MERGE_AUTOEDIT
    return 0
}

koopa_export_gnupg() {
    # """
    # Export GnuPG settings.
    # @note Updated 2022-04-08.
    #
    # Enable passphrase prompting in terminal.
    # Useful for getting Docker credential store to work.
    # https://github.com/docker/docker-credential-helpers/issues/118
    # """
    [ -z "${GPG_TTY:-}" ] || return 0
    koopa_is_tty || return 0
    GPG_TTY="$(tty || true)"
    [ -n "$GPG_TTY" ] || return 0
    export GPG_TTY
    return 0
}

koopa_export_history() {
    # """
    # Export history.
    # @note Updated 2021-01-31.
    #
    # See bash(1) for more options.
    # For setting history length, see HISTSIZE and HISTFILESIZE.
    # """
    local shell
    shell="$(koopa_shell_name)"
    # Standardize the history file name across shells.
    # Note that snake case is commonly used here across platforms.
    if [ -z "${HISTFILE:-}" ]
    then
        HISTFILE="${HOME:?}/.${shell}_history"
    fi
    export HISTFILE
    # Create the history file, if necessary.
    # Note that the HOME check here hardens against symlinked data disk failure.
    if [ ! -f "$HISTFILE" ] \
        && [ -e "${HOME:-}" ] \
        && koopa_is_installed 'touch'
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

koopa_export_koopa_shell() {
    # """
    # Export 'KOOPA_SHELL' variable.
    # @note Updated 2022-02-02.
    # """
    unset -v KOOPA_SHELL
    KOOPA_SHELL="$(koopa_locate_shell)"
    export KOOPA_SHELL
    return 0
}

koopa_export_pager() {
    # """
    # Export 'PAGER' variable.
    # @note Updated 2022-05-12.
    #
    # @seealso
    # - 'tldr --pager' (Rust tealdeer) requires the '-R' flag to be set here,
    #   otherwise will return without proper escape code handling.
    # """
    local less
    [ -n "${PAGER:-}" ] && return 0
    less="$(koopa_bin_prefix)/less"
    [ -x "$less" ] || return 0
    export PAGER="${less} -R"
    return 0
}

koopa_expr() {
    # """
    # Quiet regular expression matching that is POSIX compliant.
    # @note Updated 2020-06-30.
    # """
    expr "${1:?}" : "${2:?}" 1>/dev/null
}

koopa_fzf_prefix() {
    # """
    # fzf prefix.
    # @note Updated 2020-11-19.
    # """
    koopa_print "$(koopa_opt_prefix)/fzf"
    return 0
}

koopa_git_branch() {
    # """
    # Current git branch name.
    # @note Updated 2022-02-23.
    #
    # Currently used in prompt, so be careful with assert checks.
    #
    # Correctly handles detached HEAD state.
    #
    # Approaches:
    # > git branch --show-current
    # > git name-rev --name-only 'HEAD'
    # > git rev-parse --abbrev-ref 'HEAD'
    # > git symbolic-ref --short -q 'HEAD'
    #
    # @seealso
    # - https://stackoverflow.com/questions/6245570/
    # - https://git.kernel.org/pub/scm/git/git.git/tree/contrib/completion/
    #       git-completion.bash?id=HEAD
    # """
    local branch
    koopa_is_git_repo || return 0
    branch="$(git branch --show-current 2>/dev/null)"
    # Keep track of detached HEAD state, similar to starship.
    if [ -z "$branch" ]
    then
        branch="$( \
            git branch 2>/dev/null \
            | head -n 1 \
            | cut -c '3-' \
        )"
    fi
    [ -n "$branch" ] || return 0
    koopa_print "$branch"
    return 0
}

koopa_git_repo_has_unstaged_changes() {
    # """
    # Are there unstaged changes in current git repo?
    # @note Updated 2021-08-19.
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
    x="$(git diff-index 'HEAD' -- 2>/dev/null)"
    [ -n "$x" ]
}

koopa_git_repo_needs_pull_or_push() {
    # """
    # Does the current git repo need a pull or push?
    # @note Updated 2021-08-19.
    #
    # This will return an expected fatal warning when no upstream exists.
    # We're handling this case by piping errors to '/dev/null'.
    # """
    local rev_1 rev_2
    rev_1="$(git rev-parse 'HEAD' 2>/dev/null)"
    rev_2="$(git rev-parse '@{u}' 2>/dev/null)"
    [ "$rev_1" != "$rev_2" ]
}

koopa_go_packages_prefix() {
    # """
    # Go packages 'GOPATH', for building from source.
    # @note Updated 2021-06-11.
    #
    # This must be different from 'go root' value.
    #
    # @usage koopa_go_packages_prefix [VERSION]
    #
    # @seealso
    # - go help gopath
    # - go env GOPATH
    # - go env GOROOT
    # - https://golang.org/wiki/SettingGOPATH to set a custom GOPATH
    # """
    __koopa_packages_prefix 'go' "$@"
}

koopa_go_prefix() {
    # """
    # Go prefix.
    # @note Updated 2020-11-19.
    # """
    koopa_print "$(koopa_opt_prefix)/go"
    return 0
}

koopa_group() {
    # """
    # Current user's default group.
    # @note Updated 2020-06-30.
    # """
    __koopa_id -gn
    return 0
}

koopa_group_id() {
    # """
    # Current user's default group ID.
    # @note Updated 2020-06-30.
    # """
    __koopa_id -g
    return 0
}

koopa_homebrew_cellar_prefix() {
    # """
    # Homebrew cellar prefix.
    # @note Updated 2020-07-01.
    # """
    koopa_print "$(koopa_homebrew_prefix)/Cellar"
    return 0
}

koopa_homebrew_cask_prefix() {
    # """
    # Homebrew cask prefix.
    # @note Updated 2022-04-04.
    # """
    koopa_print "$(koopa_homebrew_prefix)/Caskroom"
    return 0
}

koopa_homebrew_prefix() {
    # """
    # Homebrew prefix.
    # @note Updated 2022-04-07.
    #
    # @seealso https://brew.sh/
    # """
    local arch x
    x="${HOMEBREW_PREFIX:-}"
    if [ -z "$x" ]
    then
        if koopa_is_installed 'brew'
        then
            x="$(brew --prefix)"
        elif koopa_is_macos
        then
            arch="$(koopa_arch)"
            case "$arch" in
                'arm'*)
                    x='/opt/homebrew'
                    ;;
                'x86'*)
                    x='/usr/local'
                    ;;
            esac
        elif koopa_is_linux
        then
            x='/home/linuxbrew/.linuxbrew'
        fi
    fi
    [ -d "$x" ] || return 1
    koopa_print "$x"
    return 0
}

koopa_homebrew_opt_prefix() {
    # """
    # Homebrew opt prefix.
    # @note Updated 2022-04-04.
    # """
    koopa_print "$(koopa_homebrew_prefix)/opt"
    return 0
}

koopa_hostname() {
    # """
    # Host name.
    # @note Updated 2022-01-21.
    # """
    local x
    x="$(uname -n)"
    [ -n "$x" ] || return 1
    koopa_print "$x"
    return 0
}

koopa_host_id() {
    # """
    # Simple host ID string to load up host-specific scripts.
    # @note Updated 2022-01-20.
    #
    # Currently intended to support AWS, Azure, and Harvard clusters.
    #
    # Returns useful host type matching either:
    # - VMs: aws, azure.
    # - HPCs: harvard-o2, harvard-odyssey.
    #
    # Returns empty for local machines and/or unsupported types.
    #
    # Alternatively, can use 'hostname -d' for reverse lookups.
    # """
    local id
    if [ -r '/etc/hostname' ]
    then
        id="$(cat '/etc/hostname')"
    elif koopa_is_installed 'hostname'
    then
        id="$(hostname -f)"
    else
        return 0
    fi
    case "$id" in
        # VMs {{{2
        # ----------------------------------------------------------------------
        *'.ec2.internal')
            id='aws'
            ;;
        # HPCs {{{2
        # ----------------------------------------------------------------------
        *'.o2.rc.hms.harvard.edu')
            id='harvard-o2'
            ;;
        *'.rc.fas.harvard.edu')
            id='harvard-odyssey'
            ;;
    esac
    [ -n "$id" ] || return 1
    koopa_print "$id"
    return 0
}

koopa_include_prefix() {
    # """
    # Koopa system includes prefix.
    # @note Updated 2020-07-30.
    # """
    koopa_print "$(koopa_koopa_prefix)/include"
    return 0
}

koopa_is_aarch64() {
    # """
    # Is the architecture ARM 64-bit?
    # @note Updated 2021-11-02.
    #
    # a.k.a. "arm64" (arch2 return).
    # """
    [ "$(koopa_arch)" = 'aarch64' ]
}

koopa_is_alacritty() {
    # """
    # Is Alacritty the current terminal client?
    # @note Updated 2022-05-06.
    # """
    [ -n "${ALACRITTY_SOCKET:-}" ]
}

koopa_is_alias() {
    # """
    # Is the specified argument an alias?
    # @note Updated 2022-01-10.
    #
    # Intended primarily to determine if we need to unalias.
    # Tracked aliases (e.g. 'dash' to '/bin/dash') don't need to be unaliased.
    #
    # @example
    # > koopa_is_alias 'R'
    # """
    local cmd str
    for cmd in "$@"
    do
        koopa_is_installed "$cmd" || return 1
        str="$(type "$cmd")"
        # Bash convention.
        koopa_str_detect_posix "$str" ' is aliased to ' && continue
        # Zsh convention.
        koopa_str_detect_posix "$str" ' is an alias for ' && continue
        return 1
    done
    return 0
}

koopa_is_alpine() {
    # """
    # Is the operating system Alpine Linux?
    # @note Updated 2020-08-06.
    # """
    koopa_is_os 'alpine'
}

koopa_is_amzn() {
    # """
    # Is the operating system Amazon Linux?
    # @note Updated 2020-08-06.
    # """
    koopa_is_os 'amzn'
}

koopa_is_arch() {
    # """
    # Is the operating system Arch Linux?
    # @note Updated 2020-08-06.
    # """
    koopa_is_os 'arch'
}

koopa_is_aws() {
    # """
    # Is the current session running on AWS?
    # @note Updated 2020-08-06.
    # """
    koopa_is_host 'aws'
}

koopa_is_azure() {
    # """
    # Is the current session running on Microsoft Azure?
    # @note Updated 2020-08-06.
    # """
    koopa_is_host 'azure'
}

koopa_is_centos() {
    # """
    # Is the operating system CentOS?
    # @note Updated 2020-08-06.
    # """
    koopa_is_os 'centos'
}

koopa_is_centos_like() {
    # """
    # Is the operating system CentOS-like?
    # @note Updated 2020-08-06.
    # """
    koopa_is_os_like 'centos'
}

koopa_is_conda_active() {
    # """
    # Is there a Conda environment active?
    # @note Updated 2019-10-20.
    # """
    [ -n "${CONDA_DEFAULT_ENV:-}" ]
}

koopa_is_conda_env_active() {
    # """
    # Is a Conda environment (other than base) active?
    # @note Updated 2021-08-17.
    # """
    [ "${CONDA_SHLVL:-1}" -gt 1 ] && return 0
    [ "${CONDA_DEFAULT_ENV:-base}" != 'base' ] && return 0
    return 1
}

koopa_is_debian() {
    # """
    # Is the operating system Debian?
    # @note Updated 2020-08-06.
    # """
    koopa_is_os 'debian'
}

koopa_is_debian_like() {
    # """
    # Is the operating system Debian-like?
    # @note Updated 2020-08-06.
    # """
    koopa_is_os_like 'debian'
}

koopa_is_docker() {
    # """
    # Is the current session running inside Docker?
    # @note Updated 2022-01-21.
    #
    # @seealso
    # - https://stackoverflow.com/questions/23513045/
    # - https://stackoverflow.com/questions/20010199/
    # """
    [ -f '/.dockerenv' ]
}

koopa_is_fedora() {
    # """
    # Is the operating system Fedora?
    # @note Updated 2020-08-06.
    # """
    koopa_is_os 'fedora'
}

koopa_is_fedora_like() {
    # """
    # Is the operating system Fedora-like?
    # @note Updated 2020-08-06.
    # """
    koopa_is_os_like 'fedora'
}

koopa_is_git_repo() { # {{{1i
    # """
    # Is the working directory a git repository?
    # @note Updated 2022-02-23.
    # @seealso
    # - https://stackoverflow.com/questions/2180270
    # """
    koopa_is_git_repo_top_level '.' && return 0
    git rev-parse --git-dir >/dev/null 2>&1 || return 1
    return 0
}

koopa_is_git_repo_clean() {
    # """
    # Is the working directory git repo clean, or does it have unstaged changes?
    # @note Updated 2022-01-20.
    #
    # This is used in prompt, so be careful with assert checks.
    #
    # @seealso
    # - https://stackoverflow.com/questions/3878624
    # - https://stackoverflow.com/questions/3258243
    # """
    koopa_is_git_repo || return 1
    koopa_git_repo_has_unstaged_changes && return 1
    koopa_git_repo_needs_pull_or_push && return 1
    return 0
}

koopa_is_git_repo_top_level() {
    # """
    # Is the working directory the top level of a git repository?
    # @note Updated 2021-08-19.
    # """
    local dir
    dir="${1:-.}"
    [ -e "${dir}/.git" ]
}

koopa_is_host() {
    # """
    # Does the current host match?
    # @note Updated 2020-08-06.
    # """
    [ "$(koopa_host_id)" = "${1:?}" ]
}

koopa_is_installed() {
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

koopa_is_interactive() {
    # """
    # Is the current shell interactive?
    # @note Updated 2021-05-27.
    # Consider checking for tmux or subshell here.
    # """
    [ "${KOOPA_INTERACTIVE:-0}" -eq 1 ] && return 0
    [ "${KOOPA_FORCE:-0}" -eq 1 ] && return 0
    koopa_str_detect_posix "$-" 'i' && return 0
    koopa_is_tty && return 0
    return 1
}

koopa_is_kitty() {
    # """
    # Is Kitty the active terminal?
    # @note Updated 2022-05-06.
    # """
    [ -n "${KITTY_PID:-}" ]
}

koopa_is_linux() {
    # """
    # Is the current operating system Linux?
    # @note Updated 2020-02-05.
    # """
    [ "$(uname -s)" = 'Linux' ]
}

koopa_is_local_install() {
    # """
    # Is koopa installed only for the current user?
    # @note Updated 2022-02-15.
    # """
    koopa_str_detect_posix "$(koopa_koopa_prefix)" "${HOME:?}"
}

koopa_is_macos() {
    # """
    # Is the operating system macOS (Darwin)?
    # @note Updated 2020-01-13.
    # """
    [ "$(uname -s)" = 'Darwin' ]
}

koopa_is_opensuse() {
    # """
    # Is the operating system openSUSE?
    # @note Updated 2020-08-06.
    # """
    koopa_is_os 'opensuse'
}

koopa_is_os() {
    # """
    # Is a specific OS ID?
    # @note Updated 2020-08-06.
    #
    # This will match Debian but not Ubuntu for a Debian check.
    # """
    [ "$(koopa_os_id)" = "${1:?}" ]
}

koopa_is_os_like() {
    # """
    # Is a specific OS ID-like?
    # @note Updated 2021-05-26.
    #
    # This will match Debian and Ubuntu for a Debian check.
    # """
    local grep file id
    grep='grep'
    id="${1:?}"
    koopa_is_os "$id" && return 0
    file='/etc/os-release'
    [ -f "$file" ] || return 1
    "$grep" 'ID=' "$file" | "$grep" -q "$id" && return 0
    "$grep" 'ID_LIKE=' "$file" | "$grep" -q "$id" && return 0
    return 1
}

koopa_is_os_version() {
    # """
    # Is a specific OS version?
    # @note Updated 2022-01-21.
    # """
    local file grep version
    file='/etc/os-release'
    grep='grep'
    version="${1:?}"
    [ -f "$file" ] || return 1
    "$grep" -q "VERSION_ID=\"${version}" "$file"
}

koopa_is_python_venv_active() {
    # """
    # Is there a Python virtual environment active?
    # @note Updated 2019-10-20.
    # """
    [ -n "${VIRTUAL_ENV:-}" ]
}

koopa_is_qemu() {
    # """
    # Is the current shell running inside of QEMU emulation?
    # @note Updated 2021-05-26.
    #
    # This can be the case for ARM Docker images running on an x86 Intel
    # machine, and vice versa.
    # """
    local basename cmd real_cmd
    basename='basename'
    cmd="/proc/${$}/exe"
    [ -L "$cmd" ] || return 1
    real_cmd="$(koopa_realpath "$cmd")"
    case "$("$basename" "$real_cmd")" in
        'qemu-'*)
            return 0
            ;;
    esac
    return 1
}

koopa_is_raspbian() {
    # """
    # Is the operating system Raspbian?
    # @note Updated 2020-08-06.
    # """
    koopa_is_os 'raspbian'
}

koopa_is_remote() {
    # """
    # Is the current shell session a remote connection over SSH?
    # @note Updated 2019-06-25.
    # """
    [ -n "${SSH_CONNECTION:-}" ]
}

koopa_is_rhel() {
    # """
    # Is the operating system RHEL?
    # @note Updated 2020-08-06.
    # """
    koopa_is_os 'rhel'
}

koopa_is_rhel_like() {
    # """
    # Is the operating system RHEL-like?
    # @note Updated 2020-08-06.
    # """
    koopa_is_os_like 'rhel'
}

koopa_is_rhel_ubi() { # {{{
    # """
    # Is the operating system a RHEL universal base image (UBI)?
    # @note Updated 2020-08-06.
    # """
    [ -f '/etc/yum.repos.d/ubi.repo' ]
}

koopa_is_rhel_7_like() {
    # """
    # Is the operating system RHEL 7-like?
    # @note Updated 2021-03-25.
    # """
    koopa_is_rhel_like && koopa_is_os_version 7
}

koopa_is_rhel_8_like() {
    # """
    # Is the operating system RHEL 8-like?
    # @note Updated 2020-08-06.
    # """
    koopa_is_rhel_like && koopa_is_os_version 8
}

koopa_is_rocky() {
    # """
    # Is the current operating system Rocky Linux?
    # @note Updated 2021-06-21.
    # """
    koopa_is_os 'rocky'
}

koopa_is_root() {
    # """
    # Is the current user root?
    # @note Updated 2020-04-16.
    # """
    [ "$(koopa_user_id)" -eq 0 ]
}

koopa_is_rstudio() {
    # """
    # Is the terminal running inside RStudio?
    # @note Updated 2020-06-19.
    # """
    [ -n "${RSTUDIO:-}" ]
}

koopa_is_set_nounset() {
    # """
    # Is shell running in 'nounset' variable mode?
    # @note Updated 2020-04-29.
    #
    # Many activation scripts, including Perlbrew and others have unset
    # variables that can cause the shell session to exit.
    #
    # How to enable:
    # > set -o nounset  # -u
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
    koopa_str_detect_posix "$(set +o)" 'set -o nounset'
}

koopa_is_shared_install() {
    # """
    # Is koopa installed for all users (shared)?
    # @note Updated 2019-06-25.
    # """
    ! koopa_is_local_install
}

koopa_is_subshell() {
    # """
    # Is koopa running inside a subshell?
    # @note Updated 2021-05-06.
    # """
    [ "${KOOPA_SUBSHELL:-0}" -gt 0 ]
}

koopa_is_tmux() {
    # """
    # Is current session running inside tmux?
    # @note Updated 2020-02-26.
    # """
    [ -n "${TMUX:-}" ]
}

koopa_is_tty() {
    # """
    # Is current shell a teletypewriter?
    # @note Updated 2020-07-03.
    # """
    koopa_is_installed 'tty' || return 1
    tty >/dev/null 2>&1 || false
}

koopa_is_ubuntu() {
    # """
    # Is the operating system Ubuntu?
    # @note Updated 2020-04-29.
    # """
    koopa_is_os 'ubuntu'
}

koopa_is_ubuntu_like() {
    # """
    # Is the operating system Ubuntu-like?
    # @note Updated 2020-08-06.
    # """
    koopa_is_os_like 'ubuntu'
}

koopa_is_x86_64() {
    # """
    # Is the architecture Intel x86 64-bit?
    # @note Updated 2021-11-02.
    #
    # a.k.a. "amd64" (arch2 return).
    # """
    [ "$(koopa_arch)" = 'x86_64' ]
}

koopa_java_prefix() {
    # """
    # Java prefix.
    # @note Updated 2022-04-08.
    #
    # See also:
    # - https://www.mkyong.com/java/
    #       how-to-set-java_home-environment-variable-on-mac-os-x/
    # - https://stackoverflow.com/questions/22290554
    # """
    local prefix
    if [ -n "${JAVA_HOME:-}" ]
    then
        koopa_print "$JAVA_HOME"
        return 0
    fi
    if [ -d "$(koopa_openjdk_prefix)" ]
    then
        koopa_print "$(koopa_openjdk_prefix)"
        return 0
    fi
    if [ -x '/usr/libexec/java_home' ]
    then
        prefix="$('/usr/libexec/java_home' || true)"
        [ -n "$prefix" ] || return 1
        koopa_print "$prefix"
        return 0
    fi
    if [ -d "$(koopa_homebrew_opt_prefix)/openjdk" ]
    then
        koopa_print "$(koopa_homebrew_opt_prefix)/openjdk"
        return 0
    fi
    return 1
}

koopa_julia_packages_prefix() {
    # """
    # Julia packages (depot) library prefix.
    # @note Updated 2021-06-14.
    #
    # @usage koopa_julia_packages_prefix [VERSION]
    #
    # In the shell environment, check 'JULIA_DEPOT_PATH'.
    # Inside Julia, check 'DEPOT_PATH'.
    # """
    __koopa_packages_prefix 'julia' "$@"
}

koopa_koopa_prefix() {
    # """
    # Koopa prefix (home).
    # @note Updated 2020-01-12.
    # """
    koopa_print "${KOOPA_PREFIX:?}"
    return 0
}

koopa_lmod_prefix() {
    # """
    # Lmod prefix.
    # @note Updated 2021-01-20.
    # """
    koopa_print "$(koopa_opt_prefix)/lmod"
    return 0
}

koopa_local_data_prefix() {
    # """
    # Local user application data prefix.
    # @note Updated 2021-05-25.
    #
    # This is the default app path when koopa is installed per user.
    # """
    koopa_print "$(koopa_xdg_data_home)"
    return 0
}

koopa_locate_shell() {
    # """
    # Locate the current shell executable.
    # @note Updated 2022-02-02.
    #
    # Detection issues with qemu ARM emulation on x86:
    # - The 'ps' approach will return correct shell for ARM running via
    #   emulation on x86 (e.g. Docker).
    # - ARM running via emulation on x86 (e.g. Docker) will return
    #   '/usr/bin/qemu-aarch64' here, rather than the shell we want.
    #
    # @seealso
    # - https://stackoverflow.com/questions/3327013
    # - http://opensourceforgeeks.blogspot.com/2013/05/
    #     how-to-find-current-shell-in-linux.html
    # - https://superuser.com/questions/103309/
    # - https://unix.stackexchange.com/questions/87061/
    # - https://unix.stackexchange.com/questions/182590/
    # """
    local proc_file pid shell
    shell="${KOOPA_SHELL:-}"
    if [ -n "$shell" ]
    then
        koopa_print "$shell"
        return 0
    fi
    pid="${$}"
    if koopa_is_linux
    then
        proc_file="/proc/${pid}/exe"
        if [ -x "$proc_file" ] && ! koopa_is_qemu
        then
            shell="$(koopa_realpath "$proc_file")"
        elif koopa_is_installed 'ps'
        then
            shell="$( \
                ps -p "$pid" -o 'comm=' \
                | sed 's/^-//' \
            )"
        fi
    elif koopa_is_macos
    then
        shell="$( \
            lsof \
                -a \
                -F 'n' \
                -d 'txt' \
                -p "$pid" \
                2>/dev/null \
            | sed -n '3p' \
            | sed 's/^n//' \
        )"
    fi
    # Fallback support for detection failure inside of some subprocesses.
    if [ -z "$shell" ]
    then
        if [ -n "${BASH_VERSION:-}" ]
        then
            shell='bash'
        elif [ -n "${ZSH_VERSION:-}" ]
        then
            shell='zsh'
        fi
    fi
    [ -n "$shell" ] || return 1
    koopa_print "$shell"
    return 0
}

koopa_macos_activate_cli_colors() {
    # """
    # Activate macOS-specific terminal color settings.
    # @note Updated 2020-07-05.
    #
    # Refer to 'man ls' for 'LSCOLORS' section on color designators. Note that
    # this doesn't get inherited by GNU coreutils, which uses 'LS_COLORS'.
    # """
    [ -z "${CLICOLOR:-}" ] && export CLICOLOR=1
    [ -z "${LSCOLORS:-}" ] && export LSCOLORS='Gxfxcxdxbxegedabagacad'
    return 0
}

koopa_macos_activate_google_cloud_sdk() {
    # """
    # Activate macOS Google Cloud SDK Homebrew cask.
    # @note Updated 2022-04-04.
    #
    # Alternate (slower) approach that enables autocompletion.
    # > local prefix shell
    # > prefix="$(koopa_homebrew_cask_prefix)/google-cloud-sdk/\
    # > latest/google-cloud-sdk"
    # > [ -d "$prefix" ] || return 0
    # > shell="$(koopa_shell_name)"
    # > # shellcheck source=/dev/null
    # > [ -f "${prefix}/path.${shell}.inc" ] && \
    # >     . "${prefix}/path.${shell}.inc"
    # > # shellcheck source=/dev/null
    # > [ -f "${prefix}/completion.${shell}.inc" ] && \
    # >     . "${prefix}/completion.${shell}.inc"
    #
    # @seealso
    # - https://cloud.google.com/sdk/docs/install#mac
    # """
    CLOUDSDK_PYTHON="$(koopa_homebrew_opt_prefix)/python@3.9/bin/python3.9"
    export CLOUDSDK_PYTHON
    return 0
}

koopa_macos_gfortran_prefix() {
    # """
    # macOS gfortran prefix.
    # @note Updated 2022-04-08.
    # """
    koopa_print '/usr/local/gfortran'
    return 0
}

koopa_macos_is_dark_mode() {
    # """
    # Is the current macOS terminal running in dark mode?
    # @note Updated 2021-05-05.
    # """
    local x
    x=$(defaults read -g 'AppleInterfaceStyle' 2>/dev/null)
    [ "$x" = 'Dark' ]
}

koopa_macos_is_light_mode() {
    # """
    # Is the current terminal running in light mode?
    # @note Updated 2021-05-05.
    # """
    ! koopa_macos_is_dark_mode
}

koopa_macos_julia_prefix() {
    # """
    # macOS Julia prefix.
    # @note Updated 2021-12-01.
    # """
    local x
    x="$( \
        find '/Applications' \
            -mindepth 1 \
            -maxdepth 1 \
            -name 'Julia-*.app' \
            -type 'd' \
            -print \
        | sort \
        | tail -n 1 \
    )"
    [ -d "$x" ] || return 1
    prefix="${x}/Contents/Resources/julia"
    [ -d "$x" ] || return 1
    koopa_print "$prefix"
}

koopa_macos_os_codename() {
    # """
    # macOS OS codename (marketing name).
    # @note Updated 2021-12-07.
    #
    # @seealso
    # - https://apple.stackexchange.com/questions/333452/
    # - https://unix.stackexchange.com/questions/234104/
    # """
    local version x
    version="$(koopa_macos_os_version)"
    case "$version" in
        '12.'*)
            x='Monterey'
            ;;
        '11.'*)
            x='Big Sur'
            ;;
        '10.15.'*)
            x='Catalina'
            ;;
        '10.14.'*)
            x='Mojave'
            ;;
        '10.13.'*)
            x='High Sierra'
            ;;
        '10.12.'*)
            x='Sierra'
            ;;
        '10.11.'*)
            x='El Capitan'
            ;;
        '10.10.'*)
            x='Yosmite'
            ;;
        '10.9.'*)
            x='Mavericks'
            ;;
        '10.8.'*)
            x='Mountain Lion'
            ;;
        '10.7.'*)
            x='Lion'
            ;;
        '10.6.'*)
            x='Snow Leopard'
            ;;
        '10.5.'*)
            x='Leopard'
            ;;
        '10.4.'*)
            x='Tiger'
            ;;
        '10.3.'*)
            x='Panther'
            ;;
        '10.2.'*)
            x='Jaguar'
            ;;
        '10.1.'*)
            x='Puma'
            ;;
        '10.0.'*)
            x='Cheetah'
            ;;
        *)
            return 1
            ;;
    esac
    [ -n "$x" ] || return 1
    koopa_print "$x"
    return 0
}

koopa_macos_os_version() {
    # """
    # macOS version.
    # @note Updated 2022-04-08.
    # """
    local x
    x="$(sw_vers -productVersion)"
    [ -n "$x" ] || return 1
    koopa_print "$x"
    return 0
}

koopa_macos_python_prefix() {
    # """
    # macOS Python installation prefix.
    # @note Updated 2022-04-08.
    # """
    koopa_print '/Library/Frameworks/Python.framework/Versions/Current'
}

koopa_macos_r_prefix() {
    # """
    # macOS R installation prefix.
    # @note Updated 2022-04-08.
    # """
    koopa_print '/Library/Frameworks/R.framework/Versions/Current/Resources'
}

koopa_major_version() {
    # """
    # Program 'MAJOR' version.
    # @note Updated 2022-02-23.
    #
    # This function captures 'MAJOR' only, removing 'MINOR.PATCH', etc.
    # """
    local version x
    for version in "$@"
    do
        x="$( \
            koopa_print "$version" \
            | cut -d '.' -f '1' \
        )"
        [ -n "$x" ] || return 1
        koopa_print "$x"
    done
    return 0
}

koopa_major_minor_version() {
    # """
    # Program 'MAJOR.MINOR' version.
    # @note Updated 2021-05-26.
    # """
    local version x
    for version in "$@"
    do
        x="$( \
            koopa_print "$version" \
            | cut -d '.' -f '1-2' \
        )"
        [ -n "$x" ] || return 1
        koopa_print "$x"
    done
    return 0
}

koopa_major_minor_patch_version() {
    # """
    # Program 'MAJOR.MINOR.PATCH' version.
    # @note Updated 2021-05-26.
    # """
    local version x
    for version in "$@"
    do
        x="$( \
            koopa_print "$version" \
            | cut -d '.' -f '1-3' \
        )"
        [ -n "$x" ] || return 1
        koopa_print "$x"
    done
    return 0
}

koopa_make_prefix() {
    # """
    # Return the installation prefix to use.
    # @note Updated 2022-04-08.
    # """
    local prefix
    if [ -n "${KOOPA_MAKE_PREFIX:-}" ]
    then
        prefix="$KOOPA_MAKE_PREFIX"
    elif koopa_is_local_install
    then
        prefix="$(koopa_xdg_local_home)"
    else
        prefix='/usr/local'
    fi
    koopa_print "$prefix"
    return 0
}

koopa_msigdb_prefix() {
    # """
    # MSigDB prefix.
    # @note Updated 2020-05-05.
    # """
    koopa_print "$(koopa_refdata_prefix)/msigdb"
    return 0
}

koopa_monorepo_prefix() {
    # """
    # Git monorepo prefix.
    # @note Updated 2020-07-03.
    # """
    koopa_print "${HOME:?}/monorepo"
    return 0
}

koopa_nim_packages_prefix() {
    # """
    # Nim (Nimble) packages prefix.
    # @note Updated 2021-09-29.
    #
    # @usage koopa_nim_packages_prefix [VERSION]
    # """
    __koopa_packages_prefix 'nim' "$@"
}

koopa_node_packages_prefix() {
    # """
    # Node.js (NPM) packages prefix.
    # @note Updated 2021-05-25.
    #
    # @usage koopa_node_packages_prefix [VERSION]
    # """
    __koopa_packages_prefix 'node' "$@"
}

koopa_openjdk_prefix() {
    # """
    # OpenJDK prefix.
    # @note Updated 2020-11-19.
    # """
    koopa_print "$(koopa_opt_prefix)/openjdk"
    return 0
}

koopa_opt_prefix() {
    # """
    # Custom application install prefix.
    # @note Updated 2021-05-17.
    # """
    koopa_print "$(koopa_koopa_prefix)/opt"
    return 0
}

koopa_os_codename() {
    # """
    # Operating system codename.
    # @note Updated 2021-06-02.
    # """
    if koopa_is_debian_like
    then
        koopa_debian_os_codename
    elif koopa_is_macos
    then
        koopa_macos_os_codename
    else
        return 1
    fi
    return 0
}

koopa_os_id() {
    # """
    # Operating system ID.
    # @note Updated 2021-05-21.
    #
    # Just return the OS platform ID (e.g. debian).
    # """
    local x
    x="$( \
        koopa_os_string \
        | cut -d '-' -f '1' \
    )"
    [ -n "$x" ] || return 1
    koopa_print "$x"
    return 0
}

koopa_os_string() {
    # """
    # Operating system string.
    # @note Updated 2022-02-23.
    #
    # Alternatively, use 'hostnamectl'.
    # https://linuxize.com/post/how-to-check-linux-version/
    #
    # If we ever add Windows support, look for: cygwin, mingw32*, msys*.
    # """
    local id release_file string version
    if koopa_is_macos
    then
        id='macos'
        version="$(koopa_macos_os_version)"
        version="$(koopa_major_minor_version "$version")"
    elif koopa_is_linux
    then
        release_file='/etc/os-release'
        if [ -r "$release_file" ]
        then
            # shellcheck disable=SC2016
            id="$( \
                awk -F= '$1=="ID" { print $2 ;}' "$release_file" \
                | tr -d '"' \
            )"
            # Include the major release version.
            # shellcheck disable=SC2016
            version="$( \
                awk -F= '$1=="VERSION_ID" { print $2 ;}' "$release_file" \
                | tr -d '"'
            )"
            if [ -n "$version" ]
            then
                version="$(koopa_major_version "$version")"
            else
                # This is the case for Arch Linux.
                version='rolling'
            fi
        else
            id='linux'
        fi
    fi
    [ -z "$id" ] && return 1
    string="$id"
    if [ -n "${version:-}" ]
    then
        string="${string}-${version}"
    fi
    koopa_print "$string"
    return 0
}

koopa_perl_packages_prefix() {
    # """
    # Perl site library prefix.
    # @note Updated 2021-06-11.
    #
    # @usage koopa_perl_packages_prefix [VERSION]
    #
    # @seealso
    # > perl -V
    # # Inspect the '@INC' variable.
    # """
    __koopa_packages_prefix 'perl' "$@"
}

koopa_perlbrew_prefix() {
    # """
    # Perlbrew prefix.
    # @note Updated 2021-05-25.
    # """
    koopa_print "$(koopa_opt_prefix)/perlbrew"
    return 0
}

koopa_pipx_prefix() {
    # """
    # pipx prefix.
    # @note Updated 2021-05-25.
    # """
    koopa_print "$(koopa_opt_prefix)/pipx"
    return 0
}

koopa_prelude_emacs_prefix() {
    # """
    # Prelude Emacs prefix.
    # @note Updated 2021-06-07.
    # """
    koopa_print "$(koopa_xdg_data_home)/prelude"
    return 0
}

koopa_print() {
    # """
    # Print a string.
    # @note Updated 2020-07-05.
    #
    # printf vs. echo
    # - http://www.etalabs.net/sh_tricks.html
    # - https://unix.stackexchange.com/questions/65803
    # - https://www.freecodecamp.org/news/
    #       how-print-newlines-command-line-output/
    # """
    local string
    if [ "$#" -eq 0 ]
    then
        printf '\n'
        return 0
    fi
    for string in "$@"
    do
        printf '%b\n' "$string"
    done
    return 0
}

koopa_prompt_conda() {
    # """
    # Get conda environment name for prompt string.
    # @note Updated 2021-08-17.
    # """
    local env
    env="$(koopa_conda_env_name)"
    [ -n "$env" ] || return 0
    koopa_print " conda:${env}"
    return 0
}

koopa_prompt_git() {
    # """
    # Return the current git branch, if applicable.
    # @note Updated 2021-08-19.
    #
    # Also indicate status with '*' if dirty (i.e. has unstaged changes).
    # """
    local git_branch git_status
    koopa_is_git_repo || return 0
    git_branch="$(koopa_git_branch)"
    if koopa_is_git_repo_clean
    then
        git_status=''
    else
        git_status='*'
    fi
    koopa_print " ${git_branch}${git_status}"
    return 0
}

koopa_prompt_python_venv() {
    # """
    # Get Python virtual environment name for prompt string.
    # @note Updated 2021-06-14.
    #
    # See also: https://stackoverflow.com/questions/10406926
    # """
    local env
    env="$(koopa_python_venv_name)"
    [ -n "$env" ] || return 0
    koopa_print " venv:${env}"
    return 0
}

koopa_pyenv_prefix() {
    # """
    # Python pyenv prefix.
    # @note Updated 2021-05-25.
    #
    # See also approach used for rbenv.
    # """
    koopa_print "$(koopa_opt_prefix)/pyenv"
    return 0
}

# > koopa_python_packages_prefix() {
# >     # """
# >     # Python site packages library prefix.
# >     # @note Updated 2021-06-11.
# >     #
# >     # @usage koopa_python_packages_prefix [VERSION]
# >     #
# >     # @seealso
# >     # > "$python" -m site
# >     # """
# >     __koopa_packages_prefix 'python' "$@"
# > }

koopa_python_venv_name() {
    # """
    # Python virtual environment name.
    # @note Updated 2021-08-17.
    # """
    local x
    x="${VIRTUAL_ENV:-}"
    [ -n "$x" ] || return 1
    # Strip out the path and just leave the env name.
    x="${x##*/}"
    [ -n "$x" ] || return 1
    koopa_print "$x"
    return 0
}

koopa_python_virtualenvs_prefix() {
    # """
    # Python virtual environment prefix.
    # @note Updated 2022-03-30.
    # """
    koopa_print "$(koopa_opt_prefix)/python-virtualenvs"
    return 0
}

koopa_r_packages_prefix() {
    # """
    # R site library prefix.
    # @note Updated 2021-06-11.
    #
    # @usage koopa_r_packages_prefix [VERSION]
    # """
    __koopa_packages_prefix 'r' "$@"
}

koopa_rbenv_prefix() {
    # """
    # Ruby rbenv prefix.
    # @note Updated 2021-05-25.
    # ""
    koopa_print "$(koopa_opt_prefix)/rbenv"
    return 0
}

# FIXME Consider using GNU 'realpath' as top priority, if installed.

koopa_realpath() {
    # """
    # Real path to file/directory on disk.
    # @note Updated 2022-04-08.
    #
    # Note that 'readlink -f' only works with GNU coreutils but not BSD
    # (i.e. macOS) variant.
    #
    # Python option:
    # > x="(python -c "import os; print(os.path.realpath('$1'))")"
    #
    # Perl option:
    # > x="$(perl -MCwd -e 'print Cwd::abs_path shift' "$1")"
    #
    # @seealso
    # - https://stackoverflow.com/questions/3572030/
    # - https://github.com/bcbio/bcbio-nextgen/blob/master/tests/run_tests.sh
    # """
    local readlink x
    readlink='readlink'
    if ! koopa_is_installed "$readlink"
    then
        local brew_readlink koopa_readlink
        koopa_readlink="$(koopa_opt_prefix)/coreutils/bin/readlink"
        brew_readlink="$(koopa_homebrew_opt_prefix)/coreutils/libexec/\
gnubin/readlink"
        if [ -x "$koopa_readlink" ]
        then
            readlink="$koopa_readlink"
        elif [ -x "$brew_readlink" ]
        then
            readlink="$brew_readlink"
        else
            return 1
        fi
    fi
    x="$("$readlink" -f "$@")"
    [ -n "$x" ] || return 1
    koopa_print "$x"
    return 0
}

koopa_refdata_prefix() {
    # """
    # Reference data prefix.
    # @note Updated 2021-12-09.
    # """
    koopa_print "$(koopa_opt_prefix)/refdata"
    return 0
}

koopa_ruby_packages_prefix() {
    # """
    # Ruby packags (gems) prefix.
    # @note Updated 2021-05-25.
    #
    # @usage koopa_ruby_packages_prefix [VERSION]
    # """
    __koopa_packages_prefix 'ruby' "$@"
}

koopa_rust_prefix() {
    # """
    # Rust (rustup) install prefix.
    # @note Updated 2021-05-25.
    # """
    koopa_print "$(koopa_opt_prefix)/rust"
    return 0
}

koopa_rust_packages_prefix() {
    # """
    # Rust packags prefix.
    # @note Updated 2022-04-09.
    #
    # @usage koopa_rust_packages_prefix [VERSION]
    # """
    __koopa_packages_prefix 'rust' "$@"
}

koopa_sbin_prefix() {
    # """
    # Koopa super user binary prefix.
    # @note Updated 2022-04-05.
    # """
    koopa_print "$(koopa_koopa_prefix)/sbin"
    return 0
}

koopa_scripts_private_prefix() {
    # """
    # Private scripts prefix.
    # @note Updated 2020-02-15.
    # """
    koopa_print "$(koopa_config_prefix)/scripts-private"
    return 0
}

koopa_shell_name() {
    # """
    # Current shell name.
    # @note Updated 2021-05-25.
    # """
    local shell str
    shell="$(koopa_locate_shell)"
    str="$(basename "$shell")"
    [ -n "$str" ] || return 1
    koopa_print "$str"
    return 0
}

koopa_spacemacs_prefix() {
    # """
    # Spacemacs prefix.
    # @note Updated 2021-06-07.
    # """
    koopa_print "$(koopa_xdg_data_home)/spacemacs"
    return 0
}

koopa_spacevim_prefix() {
    # """
    # SpaceVim prefix.
    # @note Updated 2021-06-07.
    # """
    koopa_print "$(koopa_xdg_data_home)/spacevim"
    return 0
}

koopa_str_detect_posix() {
    # """
    # Evaluate whether a string contains a desired value.
    # @note Updated 2022-02-15.
    #
    # We're unsetting 'test' here to ensure no variables/functions mask the
    # shell built-in.
    # """
    unset test
    test "${1#*"$2"}" != "$1"
}

koopa_today() {
    # """
    # Today string.
    # @note Updated 2021-05-26.
    # """
    local str
    str="$(date '+%Y-%m-%d')"
    [ -n "$str" ] || return 1
    koopa_print "$str"
    return 0
}

koopa_umask() {
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

koopa_user() {
    # """
    # Current user name.
    # @note Updated 2020-06-30.
    #
    # Alternatively, can use 'whoami' here.
    # """
    __koopa_id -un
    return 0
}

koopa_user_id() {
    # """
    # Current user ID.
    # @note Updated 2020-04-16.
    # """
    __koopa_id -u
    return 0
}

koopa_xdg_cache_home() {
    # """
    # XDG cache home.
    # @note Updated 2021-05-20.
    # """
    local x
    x="${XDG_CACHE_HOME:-}"
    if [ -z "$x" ]
    then
        x="${HOME:?}/.cache"
    fi
    koopa_print "$x"
    return 0
}

koopa_xdg_config_dirs() {
    # """
    # XDG config dirs.
    # @note Updated 2021-05-20.
    # """
    local x
    x="${XDG_CONFIG_DIRS:-}"
    if [ -z "$x" ] 
    then
        x='/etc/xdg'
    fi
    koopa_print "$x"
    return 0
}

koopa_xdg_config_home() {
    # """
    # XDG config home.
    # @note Updated 2021-05-20.
    # """
    local x
    x="${XDG_CONFIG_HOME:-}"
    if [ -z "$x" ]
    then
        x="${HOME:?}/.config"
    fi
    koopa_print "$x"
    return 0
}

koopa_xdg_data_dirs() {
    # """
    # XDG data dirs.
    # @note Updated 2022-04-08.
    # """
    local x
    x="${XDG_DATA_DIRS:-}"
    if [ -z "$x" ]
    then
        x='/usr/local/share:/usr/share'
    fi
    koopa_print "$x"
    return 0
}

koopa_xdg_data_home() {
    # """
    # XDG data home.
    # @note Updated 2021-05-20.
    # """
    local x
    x="${XDG_DATA_HOME:-}"
    if [ -z "$x" ]
    then
        x="${HOME:?}/.local/share"
    fi
    koopa_print "$x"
    return 0
}
