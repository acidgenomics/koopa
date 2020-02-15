#!/bin/sh
# shellcheck disable=SC2039

_koopa_admin_group() {  # {{{1
    # """
    # Return the administrator group.
    # @note Updated 2020-02-13.
    # """
    local group
    local groups
    groups="$(groups)"
    if echo "$groups" | grep -Eq "\b(admin)\b"
    then
        group="admin"
    elif echo "$groups" | grep -Eq "\b(sudo)\b"
    then
        group="sudo"
    elif echo "$groups" | grep -Eq "\b(wheel)\b"
    then
        group="wheel"
    else
        group="$(whoami)"
    fi
    echo "$group"
    return 0
}

_koopa_array_to_r_vector() {  # {{{1
    # """
    # Convert a bash array to an R vector string.
    # @note Updated 2019-09-25.
    #
    # Example: ("aaa" "bbb") array to 'c("aaa", "bbb")'.
    # """
    local x
    x="$(printf '"%s", ' "$@")"
    x="$(_koopa_strip_right "$x" ", ")"
    printf "c(%s)\n" "$x"
}

_koopa_cd_tmp_dir() {  # {{{1
    # """
    # Prepare and navigate (cd) to temporary directory.
    # @note Updated 2020-02-11.
    #
    # Used primarily for cellar build scripts.
    # """
    local dir
    dir="${1:-$(_koopa_tmp_dir)}"
    rm -fr "$dir"
    mkdir -p "$dir"
    # Note that we don't want to run this inside a subshell here.
    cd "$dir" || exit 1
    return 0
}

_koopa_chmod() {  # {{{1
    # """
    # chmod with dynamic sudo handling.
    # @note Updated 2020-01-24.
    # """
    if _koopa_is_shared_install
    then
        _koopa_assert_has_sudo
        sudo chmod "$@"
    else
        chmod "$@"
    fi
    return 0
}

_koopa_chown() {  # {{{1
    # """
    # chown with dynamic sudo handling.
    # @note Updated 2020-01-24.
    # """
    if _koopa_is_shared_install
    then
        _koopa_assert_has_sudo
        sudo chown "$@"
    else
        chown "$@"
    fi
    return 0
}

_koopa_chgrp() {  # {{{1
    # """
    # chgrp with dynamic sudo handling.
    # @note Updated 2020-01-24.
    # """
    if _koopa_is_shared_install
    then
        _koopa_assert_has_sudo
        sudo chgrp "$@"
    else
        chgrp "$@"
    fi
    return 0
}

_koopa_cpu_count() {  # {{{1
    # """
    # Get the number of cores (CPUs) available.
    # @note Updated 2020-01-31.
    # """
    local n
    if _koopa_is_macos
    then
        n="$(sysctl -n hw.ncpu)"
    elif _koopa_is_linux
    then
        n="$(getconf _NPROCESSORS_ONLN)"
    else
        # Otherwise assume single threaded.
        n=1
    fi
    # Set to n-2 cores, if applicable.
    if [ "$n" -gt 2 ]
    then
        n=$((n - 2))
    fi
    echo "$n"
}

_koopa_disk_check() {  # {{{1
    # """
    # Check that disk has enough free space.
    # @note Updated 2019-10-27.
    # """
    local used
    local limit
    used="$(_koopa_disk_pct_used "$@")"
    limit="90"
    if [ "$used" -gt "$limit" ]
    then
        _koopa_warning "Disk usage is ${used}%."
    fi
    return 0
}

_koopa_disk_pct_used() {  # {{{1
    # """
    # Check disk usage on main drive.
    # @note Updated 2020-02-13.
    # """
    local disk
    disk="${1:-"/"}"
    local x
    x="$( \
        df "$disk" \
            | head -n 2 \
            | sed -n '2p' \
            | grep -Eo "([.0-9]+%)" \
            | head -n 1 \
            | sed 's/%$//' \
    )"
    echo "$x"
    return 0
}

_koopa_dotfiles_config_link() {  # {{{1
    # """
    # Dotfiles directory.
    # @note Updated 2019-11-04.
    #
    # Note that we're not checking for existence here, which is handled inside
    # 'link-dotfile' script automatically instead.
    # """
    echo "$(_koopa_config_prefix)/dotfiles"
    return 0
}

_koopa_dotfiles_private_config_link() {  # {{{1
    # """
    # Private dotfiles directory.
    # @note Updated 2019-11-04.
    # """
    echo "$(_koopa_dotfiles_config_link)-private"
    return 0
}

_koopa_dotfiles_source_repo() {  # {{{1
    # """
    # Dotfiles source repository.
    # @note Updated 2019-11-04.
    # """
    if [ -d "${DOTFILES:-}" ]
    then
        echo "$DOTFILES"
        return 0
    fi
    local dotfiles
    dotfiles="$(_koopa_prefix)/dotfiles"
    if [ ! -d "$dotfiles" ]
    then
        _koopa_stop "Dotfiles are not installed at '${dotfiles}'."
    fi
    echo "$dotfiles"
    return 0
}

_koopa_git_branch() {  # {{{1
    # """
    # Current git branch name.
    # @note Updated 2019-10-13.
    #
    # Handles detached HEAD state.
    #
    # Alternatives:
    # > git name-rev --name-only HEAD
    # > git rev-parse --abbrev-ref HEAD
    #
    # See also:
    # - _koopa_assert_is_git
    # - https://git.kernel.org/pub/scm/git/git.git/tree/contrib/completion/
    #       git-completion.bash?id=HEAD
    # """
    _koopa_is_git || return 1
    local branch
    branch="$(git symbolic-ref --short -q HEAD)"
    echo "$branch"
    return 0
}

_koopa_git_clone() {  # {{{1
    # """
    # Quietly clone a git repository.
    # @note Updated 2020-02-15.
    # """
    local repo
    repo="${1:?}"
    local target
    target="${2:?}"
    if [ -d "$target" ]
    then
        _koopa_note "Cloned: '${target}'."
        return 0
    fi
    git clone --quiet --recursive "$repo" "$target"
    return 0
}

_koopa_git_update() {  # {{{1
    # """
    # Update a git repository.
    # @note Updated 2020-02-15.
    #
    # @seealso _koopa_git_pull
    # """
    local repo
    repo="${1:?}"
    [ -d "${repo}" ] || return 0
    [ -x "${repo}/.git" ] || return 0
    _koopa_h2 "Updating '${repo}'."
    (
        cd "$repo" || exit 1
        # Run updater script, if defined.
        # Otherwise pull the git repo.
        if [[ -x "UPDATE.sh" ]]
        then
            ./UPDATE.sh
        else
            git fetch --all --quiet
            git pull --quiet
        fi
    )
    return 0
}

_koopa_group() {  # {{{1
    # """
    # Return the appropriate group to use with koopa installation.
    # @note Updated 2020-02-13.
    #
    # Returns current user for local install.
    # Dynamically returns the admin group for shared install.
    #
    # Admin group priority: admin (macOS), sudo (Debian), wheel (Fedora).
    # """
    local group
    if _koopa_is_shared_install
    then
        group="$(_koopa_admin_group)"
    else
        group="$(whoami)"
    fi
    echo "$group"
    return 0
}

_koopa_gnu_mirror() {  # {{{1
    # """
    # Get GNU FTP mirror URL.
    # @note Updated 2020-02-11.
    # """
    _koopa_variable "gnu-mirror"
    return 0
}

_koopa_header() {  # {{{1
    # """
    # Source script header.
    # @note Updated 2020-01-16.
    #
    # Useful for private scripts using koopa code outside of package.
    # """
    local header_type
    header_type="${1:?}"
    local koopa_prefix
    koopa_prefix="$(_koopa_prefix)"
    local file
    case "$header_type" in
        # shell ----------------------------------------------------------------
        bash)
            file="${koopa_prefix}/shell/bash/include/header.sh"
            ;;
        zsh)
            file="${koopa_prefix}/shell/zsh/include/header.sh"
            ;;
        # os -------------------------------------------------------------------
        amzn)
            file="${koopa_prefix}/os/amzn/include/header.sh"
            ;;
        centos)
            file="${koopa_prefix}/os/centos/include/header.sh"
            ;;
        darwin)
            file="${koopa_prefix}/os/darwin/include/header.sh"
            ;;
        debian)
            file="${koopa_prefix}/os/debian/include/header.sh"
            ;;
        fedora)
            file="${koopa_prefix}/os/fedora/include/header.sh"
            ;;
        linux)
            file="${koopa_prefix}/os/linux/include/header.sh"
            ;;
        macos)
            file="${koopa_prefix}/os/macos/include/header.sh"
            ;;
        rhel)
            file="${koopa_prefix}/os/rhel/include/header.sh"
            ;;
        ubuntu)
            file="${koopa_prefix}/os/ubuntu/include/header.sh"
            ;;
        # host -----------------------------------------------------------------
        aws)
            file="${koopa_prefix}/host/aws/include/header.sh"
            ;;
        azure)
            file="${koopa_prefix}/host/azure/include/header.sh"
            ;;
        *)
            _koopa_invalid_arg "$1"
            ;;
    esac
    echo "$file"
    return 0
}

_koopa_help() {  # {{{1
    # """
    # Show usage via '--help' flag.
    # @note Updated 2020-01-21.
    #
    # Note that using 'path' as a local variable here will mess up Zsh.
    #
    # Now always calls 'man' to display nicely formatted manual page.
    #
    # Bash alternate approach:
    # > file="${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}"
    #
    # Zsh parameter notes:
    # - '$0': The name used to invoke the current shell, or as set by the -c
    #   command line option upon invocation. If the FUNCTION_ARGZERO option is
    #   set, $0 is set upon entry to a shell function to the name of the
    #   function, and upon entry to a sourced script to the name of the script,
    #   and reset to its previous value when the function or script returns.
    # - 'FUNCTION_ARGZERO': When executing a shell function or sourcing a
    #   script, set $0 temporarily to the name of the function/script. Note that
    #   toggling FUNCTION_ARGZERO from on to off (or off to on) does not change
    #   the current value of $0. Only the state upon entry to the function or
    #   script has an effect. Compare POSIX_ARGZERO.
    # - 'POSIX_ARGZERO': This option may be used to temporarily disable
    #   FUNCTION_ARGZERO and thereby restore the value of $0 to the name used to
    #   invoke the shell (or as set by the -c command line option). For
    #   compatibility with previous versions of the shell, emulations use
    #   NO_FUNCTION_ARGZERO instead of POSIX_ARGZERO, which may result in
    #   unexpected scoping of $0 if the emulation mode is changed inside a
    #   function or script. To avoid this, explicitly enable POSIX_ARGZERO in
    #   the emulate command:
    #
    #   emulate sh -o POSIX_ARGZERO
    #
    #   Note that NO_POSIX_ARGZERO has no effect unless FUNCTION_ARGZERO was
    #   already enabled upon entry to the function or script. 
    #
    # See also:
    # - https://stackoverflow.com/questions/192319
    # - http://zsh.sourceforge.net/Doc/Release/Parameters.html
    # - https://stackoverflow.com/questions/35677745
    # """
    case "${1:-}" in
        --help|-h)
            _koopa_assert_is_installed man
            local file name shell
            shell="$(_koopa_shell)"
            case "$shell" in
                bash)
                    file="$0"
                    ;;
                zsh)
                    # This approach is supported in zsh 5.7.1, but will error
                    # in older zsh versions, such as on Travis CI. This is the
                    # same as the value of $0 when the POSIX_ARGZERO option is
                    # set, but is always available. 
                    # > file="${ZSH_ARGZERO:?}"
                    emulate sh -o POSIX_ARGZERO
                    file="$0"
                    ;;
                *)
                    _koopa_stop "Unsupported shell: '${shell}'."
                    exit 1
                    ;;
            esac
            name="${file##*/}"
            man "$name"
            exit 0
            ;;
    esac
    return 0
}

_koopa_host_id() {  # {{{1
    # """
    # Simple host ID string to load up host-specific scripts.
    # @note Updated 2019-12-06.
    #
    # Currently intended to support AWS, Azure, and Harvard clusters.
    #
    # Returns useful host type matching either:
    # - VMs: "aws", "azure".
    # - HPCs: "harvard-o2", "harvard-odyssey".
    #
    # Returns empty for local machines and/or unsupported types.
    #
    # Alternatively, can use 'hostname -d' for reverse lookups.
    # """
    local id
    if [ -r /etc/hostname ]
    then
        id="$(cat /etc/hostname)"
    else
        _koopa_assert_is_installed hostname
        id="$(hostname -f)"
    fi
    case "$id" in
        # VMs
        *.ec2.internal)
            id="aws"
            ;;
        awslab*)
            id="aws"
            ;;
        azlab*)
            id="azure"
            ;;
        # HPCs
        *.o2.rc.hms.harvard.edu)
            id="harvard-o2"
            ;;
        *.rc.fas.harvard.edu)
            id="harvard-odyssey"
            ;;
    esac
    echo "$id"
    return 0
}

_koopa_info_box() {  # {{{1
    # """
    # Info box.
    # @note Updated 2019-10-14.
    #
    # Using unicode box drawings here.
    # Note that we're truncating lines inside the box to 68 characters.
    # """
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

_koopa_link_cellar() {  # {{{1
    # """
    # Symlink cellar into build directory.
    # @note Updated 2020-02-07.
    #
    # If you run into permissions issues during link, check the build prefix
    # permissions. Ensure group is not 'root', and that group has write access.
    #
    # This can be reset easily with '_koopa_set_permissions'.
    #
    # Note that Debian symlinks 'man' to 'share/man', which is non-standard.
    # This is currently corrected in 'install-debian-base', but top-level
    # symlink checks may need to be added here in a future update.
    #
    # @section cp flags:
    # * -f, --force
    # * -R, -r, --recursive
    # * -s, --symbolic-link
    #
    # @examples
    # _koopa_link_cellar emacs 26.3
    # """
    local name
    name="${1:?}"
    local version
    version="${2:-}"
    local make_prefix
    make_prefix="$(_koopa_make_prefix)"
    _koopa_assert_is_dir "$make_prefix"
    local cellar_prefix
    cellar_prefix="$(_koopa_cellar_prefix)/${name}"
    _koopa_assert_is_dir "$cellar_prefix"
    if [ -n "$version" ]
    then
        cellar_prefix="${cellar_prefix}/${version}"
    else
        cellar_prefix="$( \
            find "$cellar_prefix" \
                -mindepth 1 \
                -maxdepth 1 \
                -type d \
            | sort \
            | tail -n 1 \
        )"
    fi
    _koopa_assert_is_dir "$cellar_prefix"
    _koopa_h2 "Linking '${cellar_prefix}' in '${make_prefix}'."
    _koopa_set_permissions "$cellar_prefix"
    if _koopa_is_shared_install
    then
        _koopa_assert_has_sudo
        sudo cp -frs "$cellar_prefix/"* "$make_prefix/".
        _koopa_update_ldconfig
    else
        cp -frs "$cellar_prefix/"* "$make_prefix/".
    fi
    return 0
}

_koopa_make_build_string() {  # {{{1
    # """
    # OS build string for 'make' configuration.
    # @note Updated 2020-01-13.
    #
    # Use this for 'configure --build' flag.
    #
    # This function will distinguish between RedHat, Amazon, and other distros
    # instead of just returning "linux". Note that we're substituting "redhat"
    # instead of "rhel" here, when applicable.
    #
    # - AWS:    x86_64-amzn-linux-gnu
    # - macOS: x86_64-darwin15.6.0
    # - RedHat: x86_64-redhat-linux-gnu
    # """
    local mach
    mach="$(uname -m)"
    local os_type
    os_type="${OSTYPE:?}"
    local os_id
    local string
    if _koopa_is_macos
    then
        string="${mach}-${os_type}"
    else
        os_id="$(_koopa_os_id)"
        if echo "$os_id" | grep -q "rhel"
        then
            os_id="redhat"
        fi
        string="${mach}-${os_id}-${os_type}"
    fi
    echo "$string"
}

_koopa_mkdir() {  # {{{1
    # """
    # mkdir with dynamic sudo handling.
    # @note Updated 2020-02-06.
    # """
    if _koopa_is_shared_install
    then
        _koopa_assert_has_sudo
        sudo mkdir -p "$@"
    else
        mkdir -p "$@"
    fi
    return 0
}

_koopa_mktemp() {  # {{{1
    # """
    # Wrapper function for system 'mktemp'.
    # @note Updated 2020-02-13.
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
    _koopa_assert_is_installed mktemp
    local template
    template="koopa-$(id -u)-$(date "+%Y%m%d%H%M%S")-XXXXXXXXXX"
    mktemp "$@" -t "$template"
    return 0
}

_koopa_os_codename() {  # {{{1
    # """
    # Operating system code name.
    # @note Updated 2020-02-13.
    #
    # Alternate approach:
    # > awk -F= '$1=="VERSION_CODENAME" { print $2 ;}' /etc/os-release \
    # >     | tr -d '"'
    # """
    _koopa_assert_is_debian
    _koopa_assert_is_installed lsb_release
    local os_codename
    os_codename="$(lsb_release -cs)"
    echo "$os_codename"
    return 0
}

_koopa_os_id() {  # {{{1
    # """
    # Operating system ID.
    # @note Updated 2020-02-13.
    #
    # Just return the OS platform ID (e.g. "debian").
    # """
    local os_id
    os_id="$(_koopa_os_string | cut -d '-' -f 1)"
    echo "$os_id"
    return 0
}

_koopa_os_string() {  # {{{1
    # """
    # Operating system string.
    # @note Updated 2020-01-13.
    #
    # Returns 'ID' and major 'VERSION_ID' separated by a '-'.
    #
    # Always returns lowercase, with unique names for Linux distros
    # (e.g. "rhel-8").
    #
    # Alternatively, use hostnamectl.
    # https://linuxize.com/post/how-to-check-linux-version/
    local id
    local version
    local string
    if _koopa_is_macos
    then
        # > id="$(uname -s | tr '[:upper:]' '[:lower:]')"
        id="macos"
        version="$(_koopa_get_version "$id")"
        version="$(_koopa_minor_version "$version")"
    elif _koopa_is_linux
    then
        if [ -r /etc/os-release ]
        then
            id="$( \
                awk -F= '$1=="ID" { print $2 ;}' /etc/os-release \
                | tr -d '"' \
            )"
            # Include the major release version.
            version="$( \
                awk -F= '$1=="VERSION_ID" { print $2 ;}' /etc/os-release \
                | tr -d '"'
            )"
            if [ -n "$version" ]
            then
                version="$(_koopa_major_version "$version")"
            else
                # This is the case for Arch Linux.
                version="rolling"
            fi
        else
            id="linux"
        fi
    fi
    if [ -z "$id" ]
    then
        _koopa_stop "Failed to detect OS ID."
    fi
    string="$id"
    if [ -n "${version:-}" ]
    then
        string="${string}-${version}"
    fi
    echo "$string"
    return 0
}

_koopa_prefix_chgrp() {  # {{{1
    # """
    # Set group for target prefix(es).
    # @note Updated 2020-01-24.
    # """
    _koopa_chgrp -R "$(_koopa_group)" "$@"
    return 0
}

_koopa_prefix_chmod() {  # {{{1
    # """
    # Set file permissions for target prefix(es).
    # @note Updated 2020-01-24.
    #
    # This sets group write access by default for shared install, which is
    # useful so we don't have to constantly switch to root for admin.
    # """
    if _koopa_is_shared_install
    then
        _koopa_assert_has_sudo
        sudo chmod -R u+rw,g+rw "$@"
    else
        chmod -R u+rw,g+r,g-w "$@"
    fi
    return 0
}

_koopa_prefix_chown() {  # {{{1
    # """
    # Set ownership (user and group) for target prefix(es).
    # @note Updated 2020-01-24.
    # """
    local group
    group="$(_koopa_group)"
    if _koopa_is_shared_install
    then
        _koopa_assert_has_sudo
        sudo chown -Rh "root:${group}" "$@"
    else
        chown -Rh "${USER:?}:${group}" "$@"
    fi
    return 0
}

_koopa_prefix_chown_user() {  # {{{1
    # """
    # Set ownership to current user for target prefix(es).
    # @note Updated 2020-01-17.
    # """
    local user
    user="${USER:?}"
    local group
    group="$(_koopa_group)"
    if _koopa_is_shared_install
    then
        _koopa_assert_has_sudo
        sudo chown -Rh "${user}:${group}" "$@"
    else
        chown -Rh "${user}:${group}" "$@"
    fi
    return 0
}

_koopa_prefix_mkdir() {  # {{{1
    # """
    # Make directory at target prefix, only if it doesn't exist.
    # @note Updated 2020-01-24.
    #
    # Note that the main difference with '_koopa_mkdir' is the extra assert
    # check to look if directory already exists here.
    # """
    local prefix
    prefix="${1:?}"
    _koopa_assert_is_not_dir "$prefix"
    _koopa_mkdir "$prefix"
    _koopa_set_permissions "$prefix"
    return 0
}

_koopa_quiet_cd() {  # {{{1
    # """
    # Change directory quietly
    # @note Updated 2019-10-29.
    # """
    cd "$@" > /dev/null || return 1
    return 0
}

_koopa_quiet_expr() {  # {{{1
    # """
    # Quiet regular expression matching that is POSIX compliant.
    # @note Updated 2020-01-12.
    #
    # Avoid using '[[ =~ ]]' in sh config files.
    # 'expr' is faster than using 'case'.
    #
    # See also:
    # - https://stackoverflow.com/questions/21115121
    # """
    expr "${1:?}" : "${2:?}" 1>/dev/null
}

_koopa_quiet_rm() {  # {{{1
    # """
    # Remove quietly.
    # @note Updated 2019-10-29.
    # """
    rm -fr "$@" > /dev/null 2>&1
    return 0
}

_koopa_relink() {  # {{{1
    # """
    # Re-create a symbolic link dynamically, if broken.
    # @note Updated 2020-02-15.
    # """
    local source_file
    source_file="${1:?}"
    local dest_file
    dest_file="${2:?}"
    [ -L "$dest_file" ] && return 0
    # Relaxing this check here, in case dotfiles aren't cloned.
    [ -e "$source_file" ] || return 0
    # > rm -f "$dest_file"
    ln -fns "$source_file" "$dest_file"
    return 0
}

_koopa_rm() {  # {{{1
    # """
    # Remove files/directories without dealing with permissions.
    # @note Updated 2020-02-06.
    # """
    if _koopa_is_shared_install
    then
        _koopa_assert_has_sudo
        sudo rm -fr "$@"
    else
        rm -fr "$@"
    fi
    return 0
}

_koopa_set_permissions() {  # {{{1
    # """
    # Set permissions on target prefix(es).
    # @note Updated 2020-01-24.
    # """
    _koopa_prefix_chown "$@"
    _koopa_prefix_chmod "$@"
    return 0
}

_koopa_set_permissions_user() {  # {{{1
    # """
    # Set permissions on target prefix(es) to current user.
    # @note Updated 2020-01-24.
    # """
    _koopa_prefix_chown_user "$@"
    _koopa_prefix_chmod "$@"
    return 0
}

_koopa_set_sticky_group() {  # {{{1
    # """
    # Set sticky group bit for target prefix(es).
    # @note Updated 2020-01-24.
    # """
    _koopa_chmod g+s "$@"
    return 0
}

_koopa_shell() {  # {{{1
    # """
    # Note that this isn't necessarily the default shell ('$SHELL').
    # @note Updated 2019-06-27.
    # """
    local shell
    if [ -n "${BASH_VERSION:-}" ]
    then
        shell="bash"
    elif [ -n "${KSH_VERSION:-}" ]
    then
        shell="ksh"
    elif [ -n "${ZSH_VERSION:-}" ]
    then
        shell="zsh"
    else
        >&2 cat << EOF
Error: Failed to detect supported shell.
Supported: bash, ksh, zsh.

  SHELL: ${SHELL}
      0: ${0}
      -: ${-}
EOF
        return 1
    fi
    echo "$shell"
    return 0
}

_koopa_tmp_dir() {  # {{{1
    # """
    # Create temporary directory.
    # @note Updated 2020-02-06.
    # """
    _koopa_mktemp -d
    return 0
}

_koopa_tmp_file() {  # {{{1
    # """
    # Create temporary file.
    # @note Updated 2020-02-06.
    # """
    _koopa_mktemp
    return 0
}

_koopa_tmp_log_file() {  # {{{1
    # """
    # Create temporary log file.
    # @note Updated 2020-02-13.
    #
    # Note that old version on macOS doesn't support '--suffix' flag.
    #
    # Used primarily for debugging cellar make install scripts.
    # """
    if _koopa_is_macos
    then
        _koopa_mktemp
    else
        _koopa_mktemp --suffix=".log"
    fi
    return 0
}

_koopa_today_bucket() {  # {{{1
    # """
    # Create a dated file today bucket.
    # @note Updated 2019-11-10.
    #
    # Also adds a '~/today' symlink for quick access.
    #
    # How to check if a symlink target matches a specific path:
    # https://stackoverflow.com/questions/19860345
    #
    # Useful link flags:
    # -f, --force
    #        remove existing destination files
    # -n, --no-dereference
    #        treat LINK_NAME as a normal file if it is a symbolic link to a
    #        directory
    # -s, --symbolic
    #        make symbolic links instead of hard links
    # """
    local bucket_dir
    bucket_dir="${HOME:?}/bucket"
    # Early return if there's no bucket directory on the system.
    if [[ ! -d "$bucket_dir" ]]
    then
        return 0
    fi
    local today
    today="$(date +%Y-%m-%d)"
    local today_dir
    today_dir="${HOME}/today"
    # Early return if we've already updated the symlink.
    if readlink "$today_dir" | grep -q "$today"
    then
        return 0
    fi
    local bucket_today
    bucket_today="$(date +%Y)/$(date +%m)/$(date +%Y-%m-%d)"
    mkdir -p "${bucket_dir}/${bucket_today}"
    ln -fns "${bucket_dir}/${bucket_today}" "$today_dir"
    return 0
}

_koopa_variable() {  # {{{1
    # """
    # Get version stored internally in versions.txt file.
    # @note Updated 2020-02-13.
    # """
    local file
    file="$(_koopa_prefix)/system/include/variables.txt"
    local key
    key="${1:?}"
    local value
    # Note that this approach handles inline comments.
    value="$( \
        grep -Eo "^${key}=\"[^\"]+\"" "$file" \
        || _koopa_stop "'${key}' not defined in '${file}'." \
    )"
    value="$( \
        echo "$value" \
            | head -n 1 \
            | cut -d "\"" -f 2
    )"
    echo "$value"
    return 0
}

_koopa_view_latest_tmp_log_file() {  # {{{1
    # """
    # View the latest temporary log file.
    # @note Updated 2020-02-13.
    # """
    local dir
    dir="${TMPDIR:-/tmp}"
    local log_file
    log_file="$( \
        find "$dir" \
            -mindepth 1 \
            -maxdepth 1 \
            -type f \
            -name "koopa-$(id -u)-*" \
            | sort \
            | tail -n 1 \
    )"
    [ -f "$log_file" ] || return 1
    _koopa_h1 "Viewing '${log_file}'."
    # Note that this will skip to the end automatically.
    less +G "$log_file"
    return 0
}
