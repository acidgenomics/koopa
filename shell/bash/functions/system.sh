#!/usr/bin/env bash

koopa::add_local_bins_to_path() { # {{{1
    # """
    # Add local build bins to PATH (e.g. '/usr/local').
    # @note Updated 2020-07-06.
    #
    # This will recurse through the local library and find 'bin/' subdirs.
    # Note: read '-a' flag doesn't work on macOS.
    # """
    local dir dirs
    koopa::assert_has_no_args "$#"
    koopa::add_to_path_start "$(koopa::make_prefix)/bin"
    readarray -t dirs <<< "$(koopa::find_local_bin_dirs)"
    for dir in "${dirs[@]}"
    do
        koopa::add_to_path_start "$dir"
    done
    return 0
}

koopa::admin_group() { # {{{1
    # """
    # Return the administrator group.
    # @note Updated 2020-06-30.
    #
    # Usage of 'groups' here is terribly slow for domain users.
    # Currently seeing this with CPI AWS Ubuntu config.
    # Instead of grep matching against 'groups' return, just set the
    # expected default per Linux distro. In the event that we're unsure,
    # the function will intentionally error.
    # """
    local group
    koopa::assert_has_no_args "$#"
    if koopa::is_root
    then
        group='root'
    elif koopa::is_debian
    then
        group='sudo'
    elif koopa::is_fedora
    then
        group='wheel'
    elif koopa::is_macos
    then
        group='admin'
    else
        koopa::stop 'Failed to detect admin group.'
    fi
    koopa::print "$group"
    return 0
}

koopa::check_exports() { # {{{1
    # """
    # Check exported environment variables.
    # @note Updated 2020-07-05.
    #
    # Warn the user if they are setting unrecommended values.
    # """
    koopa::assert_has_no_args "$#"
    koopa::is_rstudio && return 0
    local vars
    vars=(
        'JAVA_HOME'
        'LD_LIBRARY_PATH'
        'PYTHONHOME'
        'R_HOME'
    )
    koopa::warn_if_export "${vars[@]}"
    return 0
}

koopa::check_system() { # {{{1
    # """
    # Check system.
    # @note Updated 2020-07-05.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed Rscript
    local koopa_prefix
    koopa_prefix="$(koopa::prefix)"
    export KOOPA_FORCE=1
    set +u
    # shellcheck disable=SC1090
    source "${koopa_prefix}/activate"
    set -u
    Rscript --vanilla "$(koopa::include_prefix)/check-system.R"
    koopa::check_exports
    koopa::check_disk
    koopa::check_data_disk
    return 0
}

koopa::date() { # {{{1
    # """
    # Koopa date.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    koopa::variable "koopa-date"
    return 0
}

koopa::datetime() { # {{{
    # """
    # Datetime string.
    # @note Updated 2020-07-04.
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed date
    local x
    x="$(date "+%Y%m%d-%H%M%S")"
    koopa::print "$x"
    return 0
}

koopa::dotfiles_config_link() { # {{{1
    # """
    # Dotfiles directory.
    # @note Updated 2019-11-04.
    #
    # Note that we're not checking for existence here, which is handled inside
    # 'link-dotfile' script automatically instead.
    # """
    koopa::assert_has_no_args "$#"
    koopa::print "$(koopa::config_prefix)/dotfiles"
    return 0
}

koopa::dotfiles_private_config_link() { # {{{1
    # """
    # Private dotfiles directory.
    # @note Updated 2019-11-04.
    # """
    koopa::assert_has_no_args "$#"
    koopa::print "$(koopa::dotfiles_config_link)-private"
    return 0
}

koopa::find_local_bin_dirs() { # {{{1
    # """
    # Find local bin directories.
    # @note Updated 2020-07-05.
    #
    # Should we exclude koopa from this search?
    #
    # See also:
    # - https://stackoverflow.com/questions/23356779
    # - https://stackoverflow.com/questions/7442417
    # """
    koopa::assert_has_no_args "$#"
    local prefix x
    prefix="$(koopa::make_prefix)"
    x="$( \
        find "$prefix" \
            -mindepth 2 \
            -maxdepth 3 \
            -type d \
            -name 'bin' \
            -not -path '*/Caskroom/*' \
            -not -path '*/Cellar/*' \
            -not -path '*/Homebrew/*' \
            -not -path '*/anaconda3/*' \
            -not -path '*/bcbio/*' \
            -not -path '*/conda/*' \
            -not -path '*/lib/*' \
            -not -path '*/miniconda3/*' \
            -not -path '*/opt/*' \
            -print | sort \
    )"
    koopa::print "$x"
    return 0
}

koopa::fix_sudo_setrlimit_error() { # {{{1
    # """
    # Fix bug in recent version of sudo.
    # @note Updated 2020-07-05.
    #
    # This is popping up on Docker builds:
    # sudo: setrlimit(RLIMIT_CORE): Operation not permitted
    #
    # @seealso
    # - https://ask.fedoraproject.org/t/
    #       sudo-setrlimit-rlimit-core-operation-not-permitted/4223
    # - https://bugzilla.redhat.com/show_bug.cgi?id=1773148
    # """
    koopa::assert_has_no_args "$#"
    local source_file target_file
    target_file='/etc/sudo.conf'
    # Ensure we always overwrite for Docker images.
    # Note that Fedora base image contains this file by default.
    if ! koopa::is_docker
    then
        [[ -e "$target_file" ]] && return 0
    fi
    source_file="$(koopa::prefix)/os/linux/etc/sudo.conf"
    sudo cp -v "$source_file" "$target_file"
    return 0
}

koopa::github_url() { # {{{1
    # """
    # Koopa GitHub URL.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    koopa::variable "koopa-github-url"
    return 0
}

koopa::gnu_mirror() { # {{{1
    # """
    # Get GNU FTP mirror URL.
    # @note Updated 2020-04-16.
    # """
    koopa::assert_has_no_args "$#"
    koopa::variable "gnu-mirror"
    return 0
}

koopa::info_box() { # {{{1
    # """
    # Info box.
    # @note Updated 2020-07-04.
    #
    # Using unicode box drawings here.
    # Note that we're truncating lines inside the box to 68 characters.
    # """
    koopa::assert_has_args "$#"
    local array
    array=("$@")
    local barpad
    barpad="$(printf "━%.0s" {1..70})"
    printf "  %s%s%s  \n" "┏" "$barpad" "┓"
    for i in "${array[@]}"
    do
        printf "  ┃ %-68s ┃  \n" "${i::68}"
    done
    printf "  %s%s%s  \n\n" "┗" "$barpad" "┛"
    return 0
}

koopa::list() { # {{{1
    # """
    # List exported koopa scripts.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed Rscript
    Rscript --vanilla "$(koopa::include_prefix)/list.R"
    return 0
}

koopa::local_ip_address() { # {{{1
    # """
    # Local IP address.
    # @note Updated 2020-07-05.
    #
    # Some systems (e.g. macOS) will return multiple IP address matches for
    # Ethernet and WiFi. Here we're simplying returning the first match, which
    # corresponds to the default on macOS.
    # """
    koopa::assert_has_no_args "$#"
    local x
    if koopa::is_macos
    then
        x="$( \
            ifconfig \
            | grep 'inet ' \
            | grep 'broadcast' \
            | awk '{print $2}' \
            | tail -n 1
        )"
    else
        x="$( \
            hostname -I \
            | awk '{print $1}' \
            | head -n 1
        )"
    fi
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::make_build_string() { # {{{1
    # """
    # OS build string for 'make' configuration.
    # @note Updated 2020-07-05.
    #
    # Use this for 'configure --build' flag.
    #
    # - macOS: x86_64-darwin15.6.0
    # - Linux: x86_64-linux-gnu
    # """
    koopa::assert_has_no_args "$#"
    local mach os_type string
    if koopa::is_macos
    then
        mach="$(uname -m)"
        os_type="${OSTYPE:?}"
        string="${mach}-${os_type}"
    else
        string='x86_64-linux-gnu'
    fi
    koopa::print "$string"
    return 0
}

koopa::mktemp() { # {{{1
    # """
    # Wrapper function for system 'mktemp'.
    # @note Updated 2020-07-04.
    #
    # Traditionally, many shell scripts take the name of the program with the
    # pid as a suffix and use that as a temporary file name. This kind of
    # naming scheme is predictable and the race condition it creates is easy for
    # an attacker to win. A safer, though still inferior, approach is to make a
    # temporary directory using the same naming scheme. While this does allow
    # one to guarantee that a temporary file will not be subverted, it still
    # allows a simple denial of service attack. For these reasons it is
    # suggested that mktemp be used instead.
    #
    # Note that old version of mktemp (e.g. macOS) only supports '-t' instead of
    # '--tmpdir' flag for prefix.
    #
    # See also:
    # - https://stackoverflow.com/questions/4632028
    # - https://stackoverflow.com/a/10983009/3911732
    # - https://gist.github.com/earthgecko/3089509
    # """
    koopa::assert_is_installed mktemp
    local date_id template user_id
    user_id="$(koopa::user_id)"
    date_id="$(koopa::datetime)"
    template="koopa-${user_id}-${date_id}-XXXXXXXXXX"
    mktemp "$@" -t "$template"
    return 0
}

koopa::pager() {
    # """
    # Run less with support for colors (escape characters).
    # @note Updated 2020-07-03.
    #
    # Detail on handling escape sequences:
    # https://major.io/2013/05/21/
    #     handling-terminal-color-escape-sequences-in-less/
    # """
    local pager
    pager="${PAGER:-less}"
    koopa::assert_is_installed "$pager"
    "$pager" -R "$@"
    return 0
}

koopa::public_ip_address() { # {{{1
    # """
    # Public (remote) IP address.
    # @note Updated 2020-07-05.
    #
    # @seealso
    # https://www.cyberciti.biz/faq/
    #     how-to-find-my-public-ip-address-from-command-line-on-a-linux/
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed curl dig
    local x
    x="$(dig +short myip.opendns.com @resolver1.opendns.com)"
    # Fallback in case dig approach doesn't work.
    if [[ -z "$x" ]]
    then
        koopa::assert_is_installed curl
        x="$(curl -s ipecho.net/plain)"
    fi
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::run_if_installed() { # {{{1
    # """
    # Run program(s) if installed.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_args "$#"
    for arg in "$@"
    do
        if ! koopa::is_installed "$arg"
        then
            koopa::note "Skipping '${arg}'."
            continue
        fi
        local exe
        exe="$(koopa::which_realpath "$arg")"
        "$exe"
    done
    return 0
}

koopa::script_name() { # {{{1
    # """
    # Get the calling script name.
    # @note Updated 2020-06-29.
    #
    # Note that we're using 'caller' approach, which is Bash-specific.
    # """
    koopa::assert_has_no_args "$#"
    local file x
    file="$( \
        caller \
        | head -n 1 \
        | cut -d ' ' -f 2 \
    )"
    x="$(koopa::basename "$file")"
    [[ -n "$x" ]] || return 0
    koopa::print "$x"
    return 0
}

koopa::sudo_write_string() { # {{{1
    # """
    # Write a string to disk using root user.
    # @note Updated 2020-07-01.
    #
    # Alternatively, 'tee -a' can be used to append file.
    # """
    koopa::assert_has_args_eq "$#" 2
    local file string
    string="${1:?}"
    file="${2:?}"
    koopa::print "$string" | sudo tee "$file" >/dev/null
    return 0
}

koopa::sys_git_pull() { # {{{1
    # """
    # Pull koopa git repo.
    # @note Updated 2020-07-04.
    #
    # Intended for use with 'koopa pull'.
    #
    # This handles updates to Zsh functions that are changed to group
    # non-writable permissions, so Zsh passes 'compaudit' checks.
    # """
    koopa::assert_has_no_args "$#"
    local branch prefix
    (
        prefix="$(koopa::prefix)"
        cd "$prefix" || exit 1
        koopa::sys_set_permissions \
            --recursive "${prefix}/shell/zsh" \
            >/dev/null 2>&1
        branch="$(koopa::git_branch)"
        koopa::git_pull
        # Ensure other branches, such as develop, are rebased.
        if [[ "$branch" != "master" ]]
        then
            koopa::git_pull origin master
        fi
        koopa::fix_zsh_permissions &>/dev/null
    )
    return 0
}

koopa::sys_info() { # {{{
    # """
    # System information.
    # @note Updated 2020-07-05.
    # """
    koopa::assert_has_no_args "$#"
    local array koopa_prefix nf origin shell shell_name shell_version
    koopa_prefix="$(koopa::prefix)"
    array=(
        "koopa $(koopa::version) ($(koopa::date))"
        "URL: $(koopa::url)"
        "GitHub URL: $(koopa::github_url)"
    )
    if koopa::is_git_toplevel "$koopa_prefix"
    then
        origin="$( \
            cd "$koopa_prefix" || exit 1; \
            koopa::git_remote_url
        )"
        commit="$( \
            cd "$koopa_prefix" || exit 1; \
            koopa::git_last_commit_local
        )"
        array+=(
            "Git Remote: ${origin}"
            "Commit: ${commit}"
        )
    fi
    array+=(
        ''
        'Configuration'
        '-------------'
        "Koopa Prefix: ${koopa_prefix}"
        "Config Prefix: $(koopa::config_prefix)"
        "App Prefix: $(koopa::app_prefix)"
        "Make Prefix: $(koopa::make_prefix)"
    )
    if koopa::is_linux
    then
        array+=("Cellar Prefix: $(koopa::cellar_prefix)")
    fi
    array+=("")
    # Show neofetch info, if installed.
    if koopa::is_installed neofetch
    then
        readarray -t nf <<< "$(neofetch --stdout)"
        array+=(
            'System information (neofetch)'
            '-----------------------------'
            "${nf[@]:2}"
        )
    else
        local os
        if koopa::is_macos
        then
            os="$( \
                printf '%s %s (%s)\n' \
                    "$(sw_vers -productName)" \
                    "$(sw_vers -productVersion)" \
                    "$(sw_vers -buildVersion)" \
            )"
        else
            if koopa::is_installed python
            then
                os="$(python -mplatform)"
            else
                os="$(uname --all)"
            fi
        fi
        shell_name="$KOOPA_SHELL"
        shell_version="$(koopa::get_version "${shell_name}")"
        shell="${shell_name} ${shell_version}"
        array+=(
            'System information'
            '------------------'
            "OS: ${os}"
            "Shell: ${shell}"
            ""
        )
    fi
    array+=('Run "koopa check" to verify installation.')
    cat "$(koopa::include_prefix)/ascii-turtle.txt"
    koopa::info_box "${array[@]}"
    return 0
}

koopa::sys_set_permissions() { # {{{1
    # """
    # Set permissions on target prefix(es).
    # @note Updated 2020-07-06.
    # @param -r
    #   Change permissions recursively.
    # """
    koopa::assert_has_args "$#"
    local OPTIND arg chmod chown recursive
    recursive=0
    OPTIND=1
    while getopts 'r' opt
    do
        case "$opt" in
            r)
                recursive=1
                ;;
            \?)
                koopa::stop "Invalid option: -${OPTARG}"
            ;;
        esac
    done
    shift "$((OPTIND-1))"
    koopa::assert_has_args "$#"
    chmod=('koopa::sys_chmod')
    chown=('koopa::sys_chown' '-h')
    if [[ "$recursive" -eq 1 ]]
    then
        chmod_flags+=('-R')
        chown_flags+=('-R')
    fi
    for arg in "$@"
    do
        # Ensure we resolve symlinks here.
        arg="$(realpath "$arg")"
        "${chmod[@]}" "$arg"
        "${chown[@]}" "$arg"
    done
    return 0
}

koopa::sys_chgrp() { # {{{1
    # """
    # chgrp with dynamic sudo handling.
    # @note Updated 2020-07-06.
    # """
    local chgrp group
    koopa::assert_has_args "$#"
    group="$(koopa::sys_group)"
    if koopa::is_shared_install
    then
        chgrp=('sudo' 'chgrp')
    else
        chgrp=('chgrp')
    fi
    "${chgrp[@]}" "$group" "$@"
    return 0
}

koopa::sys_chmod() { # {{{1
    # """
    # chmod with dynamic sudo handling.
    # @note Updated 2020-07-06.
    # """
    local chmod chmod_flags
    koopa::assert_has_args "$#"
    flags=("$(koopa::sys_chmod_flags)")
    if koopa::is_shared_install
    then
        chmod=('sudo' 'chmod')
    else
        chmod=('chmod')
    fi
    "${chmod[@]}" "${chmod_flags[@]}" "$@"
    return 0
}

koopa::sys_chmod_flags() {
    # """
    # Default recommended flags for chmod.
    # @note Updated 2020-04-16.
    # """
    local flags
    koopa::assert_has_no_args "$#"
    if koopa::is_shared_install
    then
        flags='u+rw,g+rw'
    else
        flags='u+rw,g+r,g-w'
    fi
    koopa::print "$flags"
    return 0
}

koopa::sys_chown() { # {{{1
    # """
    # chown with dynamic sudo handling.
    # @note Updated 2020-07-06.
    # """
    local chown group user
    koopa::assert_has_args "$#"
    user="$(koopa::sys_user)"
    group="$(koopa::sys_group)"
    if koopa::is_shared_install
    then
        chown=('sudo' 'chown')
    else
        chown=('chown')
    fi
    "${chown[@]}" "${user}:${group}" "$@"
    return 0
}

koopa::sys_cp() { # {{{1
    # """
    # Koopa copy.
    # @note Updated 2020-06-30.
    # """
    local cp
    koopa::assert_has_args "$#"
    cp=('koopa::cp')
    koopa::is_shared_install && cp+=('-S')
    "${cp[@]}" "$@"
    return 0
}

koopa::sys_group() { # {{{1
    # """
    # Return the appropriate group to use with koopa installation.
    # @note Updated 2020-07-04.
    #
    # Returns current user for local install.
    # Dynamically returns the admin group for shared install.
    #
    # Admin group priority: admin (macOS), sudo (Debian), wheel (Fedora).
    # """
    local group
    koopa::assert_has_no_args "$#"
    if koopa::is_shared_install
    then
        group="$(koopa::admin_group)"
    else
        group="$(koopa::group)"
    fi
    koopa::print "$group"
    return 0
}

koopa::sys_ln() { # {{{1
    # """
    # Create a symlink quietly.
    # @note Updated 2020-07-06.
    # """
    local ln
    koopa::assert_has_args "$#"
    ln=('koopa::ln')
    koopa::is_shared_install && ln+=('-S')
    "${ln[@]}" "$@"
    return 0
}

koopa::sys_mkdir() { # {{{1
    # """
    # mkdir with dynamic sudo handling.
    # @note Updated 2020-07-06.
    # """
    local mkdir
    koopa::assert_has_args "$#"
    mkdir=('koopa::mkdir')
    koopa::is_shared_install && mkdir+=('-S')
    "${mkdir[@]}" "$@"
    koopa::sys_set_permissions "$@"
    return 0
}

koopa::sys_mv() { # {{{1
    # """
    # Move a file or directory.
    # @note Updated 2020-07-06.
    # """
    local mv
    koopa::assert_has_args "$#"
    mv=('koopa::mv')
    koopa::is_shared_install && mv+=('-S')
    "${mv[@]}" "$@"
    return 0
}

koopa::sys_rm() { # {{{1
    # """
    # Remove files/directories quietly.
    # @note Updated 2020-06-30.
    # """
    local rm
    koopa::assert_has_args "$#"
    rm=('koopa::rm')
    koopa::is_shared_install && rm+=('-S')
    "${rm[@]}" "$@"
    return 0
}

koopa::sys_user() { # {{{1
    # """
    # Set the koopa installation system user.
    # @note Updated 2020-07-06.
    # """
    local user
    koopa::assert_has_no_args "$#"
    if koopa::is_shared_install
    then
        user='root'
    else
        user="$(koopa::user)"
    fi
    koopa::print "$user"
    return 0
}

koopa::test() { # {{{1
    # """
    # Run koopa unit tests.
    # @note Updated 2020-06-26.
    # """
    "$(koopa::tests_prefix)/tests" "$@"
    return 0
}

koopa::test_find_files() { # {{{1
    # """
    # Find relevant files for unit tests.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    local prefix x
    prefix="$(koopa::prefix)"
    x="$( \
        find "$prefix" \
            -mindepth 1 \
            -type f \
            -not -name "$(basename "$0")" \
            -not -name '*.md' \
            -not -name '.pylintrc' \
            -not -path "${prefix}/.git/*" \
            -not -path "${prefix}/cellar/*" \
            -not -path "${prefix}/coverage/*" \
            -not -path "${prefix}/dotfiles/*" \
            -not -path "${prefix}/opt/*" \
            -not -path "${prefix}/tests/*" \
            -not -path '*/etc/R/*' \
            -print | sort \
    )"
    koopa::print "$x"
}

koopa::test_true_color() { # {{{1
    # """
    # Test 24-bit true color support.
    # @note Updated 2020-02-15.
    #
    # @seealso
    # https://jdhao.github.io/2018/10/19/tmux_nvim_true_color/
    # """
    koopa::assert_has_no_args "$#"
    awk 'BEGIN{
        s="/\\/\\/\\/\\/\\"; s=s s s s s s s s;
        for (colnum = 0; colnum<77; colnum++) {
            r = 255-(colnum*255/76);
            g = (colnum*510/76);
            b = (colnum*255/76);
            if (g>255) g = 510-g;
            printf "\033[48;2;%d;%d;%dm", r,g,b;
            printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
            printf "%s\033[0m", substr(s,colnum+1,1);
        }
        printf "\n";
    }'
    return 0
}

koopa::tmp_dir() { # {{{1
    # """
    # Create temporary directory.
    # @note Updated 2020-02-06.
    # """
    koopa::assert_has_no_args "$#"
    koopa::mktemp -d
    return 0
}

koopa::tmp_file() { # {{{1
    # """
    # Create temporary file.
    # @note Updated 2020-02-06.
    # """
    koopa::assert_has_no_args "$#"
    koopa::mktemp
    return 0
}

koopa::tmp_log_file() { # {{{1
    # """
    # Create temporary log file.
    # @note Updated 2020-02-27.
    #
    # Used primarily for debugging cellar make install scripts.
    #
    # Note that mktemp on macOS and BusyBox doesn't support '--suffix' flag.
    # Otherwise, we can use:
    # > koopa::mktemp --suffix=".log"
    # """
    koopa::assert_has_no_args "$#"
    koopa::tmp_file
    return 0
}

koopa::uninstall() { # {{{1
    # """
    # Uninstall koopa.
    # @note Updated 2020-06-24.
    # """
    "$(koopa::prefix)/uninstall" "$@"
    return 0
}

koopa::url() { # {{{1
    # """
    # Koopa URL.
    # @note Updated 2020-04-16.
    # """
    koopa::assert_has_no_args "$#"
    koopa::variable 'koopa-url'
    return 0
}

koopa::variables() { # {{{1
    # """
    # Edit koopa variables.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed vim
    vim "$(koopa::include_prefix)/variables.txt"
    return 0
}

koopa::view_latest_tmp_log_file() { # {{{1
    # """
    # View the latest temporary log file.
    # @note Updated 2020-07-05.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed find
    local dir log_file
    dir="${TMPDIR:-/tmp}"
    log_file="$( \
        find "$dir" \
            -mindepth 1 \
            -maxdepth 1 \
            -type f \
            -name "koopa-$(koopa::user_id)-*" \
            | sort \
            | tail -n 1 \
    )"
    [[ -f "$log_file" ]] || return 1
    koopa::info "Viewing '${log_file}'."
    # Note that this will skip to the end automatically.
    koopa::pager +G "$log_file"
    return 0
}

koopa::warn_if_export() { # {{{1
    # """
    # Warn if variable is exported in current shell session.
    # @note Updated 2020-02-20.
    #
    # Useful for checking against unwanted compiler settings.
    # In particular, useful to check for 'LD_LIBRARY_PATH'.
    # """
    koopa::assert_has_args "$#"
    for arg in "$@"
    do
        if koopa::is_export "$arg"
        then
            koopa::warning "'${arg}' is exported."
        fi
    done
    return 0
}
