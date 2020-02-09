#!/bin/sh
# shellcheck disable=SC2039

_koopa_add_config_link() {                                                # {{{1
    # """
    # Add a symlink into the koopa configuration directory.
    # Updated 2020-01-12.
    # """
    local config_dir
    config_dir="$(_koopa_config_prefix)"
    local source_file
    source_file="${1:?}"
    _koopa_assert_is_existing "$source_file"
    source_file="$(realpath "$source_file")"
    local dest_name
    dest_name="${2:?}"
    local dest_file
    dest_file="${config_dir}/${dest_name}"
    rm -f "$dest_file"
    ln -fnsv "$source_file" "$dest_file"
    return 0
}

_koopa_apt_disable_deb_src() {                                            # {{{1
    # """
    # Enable 'deb-src' source packages.
    # Updated 2020-02-05.
    # """
    _koopa_assert_is_debian
    _koopa_assert_has_sudo
    local file
    file="${1:-/etc/apt/sources.list}"
    file="$(realpath "$file")"
    _koopa_h2 "Disabling Debian sources in '${file}'."
    if ! grep -Eq '^deb-src ' "$file"
    then
        _koopa_note "No 'deb-src' lines to comment in '${file}'."
        return 0
    fi
    sed -Ei 's/^deb-src /# deb-src /' "$file"
    sudo apt-get update
    return 0
}

_koopa_apt_enable_deb_src() {                                             # {{{1
    # """
    # Enable 'deb-src' source packages.
    # Updated 2020-02-05.
    # """
    _koopa_assert_is_debian
    _koopa_assert_has_sudo
    local file
    file="${1:-/etc/apt/sources.list}"
    file="$(realpath "$file")"
    _koopa_h2 "Enabling Debian sources in '${file}'."
    if ! grep -Eq '^# deb-src ' "$file"
    then
        _koopa_note "No '# deb-src' lines to uncomment in '${file}'."
        return 0
    fi
    sudo sed -Ei 's/^# deb-src /deb-src /' "$file"
    sudo apt-get update
    return 0
}

_koopa_apt_enabled_repos() {                                              # {{{1
    # """
    # Get a list of enabled default apt repos.
    # Updated 2020-02-07.
    # """
    grep -E '^deb ' /etc/apt/sources.list \
        | cut -d ' ' -f 4 \
        | awk '!a[$0]++' \
        | sort
}

_koopa_apt_link_sources() {                                               # {{{1
    # """
    # Symlink 'sources.list' files in '/etc/apt'.
    # Updated 2020-02-05.
    # """
    _koopa_assert_is_debian
    _koopa_assert_has_sudo
    local prefix
    prefix="$(_koopa_prefix)"
    local os_id
    os_id="$(_koopa_os_id)"
    local source_dir
    source_dir="${prefix}/os/${os_id}/etc/apt"
    _koopa_assert_is_dir "$source_dir"
    local target_dir
    target_dir="/etc/apt"
    _koopa_assert_is_dir "$target_dir"
    _koopa_h2 "Linking Debian sources in '${target_dir}'."
    sudo ln -fnsv \
        "${source_dir}/sources.list" \
        "${target_dir}/sources.list"
    sudo rm -fv "${target_dir}/sources.list~"
    sudo rm -frv "${target_dir}/sources.list.d"
    sudo ln -fnsv \
        "${source_dir}/sources.list.d" \
        "${target_dir}/sources.list.d"
    sudo apt-get update
    return 0
}

_koopa_apt_import_keys() {                                                # {{{1
    # """
    # Import GPG keys used to sign apt repositories.
    # Updated 2020-02-05.
    #
    # Refer to 'Secure apt' section for details.
    #
    # Get list of enabled apt repositories:
    # https://stackoverflow.com/questions/8647454
    #
    # Can use 'wget -O' instead of curl call below.
    #
    # Variables that may be useful:
    # > local distro
    # > distro="$(lsb_release -is)"
    # > local version
    # > version="$(lsb_release -sr)"
    # > local dist_version
    # > dist_version="${distro}_${version}"
    #
    # See also:
    # - install-docker
    # - install-llvm
    # - install-r
    # """
    _koopa_assert_is_debian
    _koopa_assert_has_sudo
    _koopa_assert_is_installed curl

    _koopa_h1 "Importing signatures for GPG-signed apt repositories."

    local apt_repos
    apt_repos="$( \
        grep -h '^deb' \
            /etc/apt/sources.list \
            /etc/apt/sources.list.d/* \
    )"

    # Expecting "debian" or "ubuntu" here.
    local os_id
    os_id="$(_koopa_os_id)"

    # Docker
    if _koopa_is_matching_fixed "$apt_repos" "download.docker.com"
    then
        _koopa_h2 "Adding official Docker release GPG key."
        _koopa_assert_is_file "/etc/apt/sources.list.d/docker.list"
        curl -fsSL "https://download.docker.com/linux/${os_id}/gpg" \
            | sudo apt-key add - \
            > /dev/null 2>&1
    fi

    # LLVM
    if _koopa_is_matching_fixed "$apt_repos" "apt.llvm.org"
    then
        _koopa_h2 "Adding official LLVM release GPG key."
        curl -fsSL "https://apt.llvm.org/llvm-snapshot.gpg.key" \
            | sudo apt-key add - \
            > /dev/null 2>&1
    fi

    # R
    if _koopa_is_matching_fixed "$apt_repos" "cloud.r-project.org"
    then
        _koopa_h2 "Adding official R release GPG key."
        _koopa_assert_is_file "/etc/apt/sources.list.d/r.list"
        if _koopa_is_ubuntu
        then
            # Release is signed by Michael Rutter <marutter@gmail.com>.
            sudo apt-key adv \
                --keyserver keyserver.ubuntu.com \
                --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 \
                > /dev/null 2>&1
        else
            # Release is signed by Johannes Ranke <jranke@uni-bremen.de>.
            sudo apt-key adv \
                --keyserver keys.gnupg.net \
                --recv-key E19F5F87128899B192B1A2C2AD5F960A256A04AF \
                > /dev/null 2>&1
        fi
    fi

    return 0
}

_koopa_apt_space_used_by() {                                              # {{{1
    # """
    # Check installed apt package size, with dependencies.
    # Updated 2020-01-31.
    #
    # Alternate approach that doesn't attempt to grep match.
    _koopa_assert_is_debian
    _koopa_assert_has_sudo
    sudo apt-get --assume-no autoremove "$@"
}

_koopa_apt_space_used_by_grep() {                                         # {{{1
    # """
    # Check installed apt package size, with dependencies.
    # Updated 2020-01-31.
    #
    # See also:
    # https://askubuntu.com/questions/490945
    # """
    _koopa_assert_is_debian
    _koopa_assert_has_sudo
    sudo apt-get --assume-no autoremove "$@" \
        | grep freed \
        | cut -d ' ' -f 4-5
}

_koopa_apt_space_used_by_no_deps() {                                      # {{{1
    # """
    # Check install apt package size, without dependencies.
    # Updated 2020-01-31.
    # """
    sudo apt show "$@" | grep 'Size'
}

_koopa_cd_tmp_dir() {                                                     # {{{1
    # """
    # Prepare and navigate (cd) to temporary directory.
    # Updated 2020-01-12.
    #
    # Used primarily for cellar build scripts.
    # """
    local dir
    dir="${1:?}"
    rm -fr "$dir"
    mkdir -p "$dir"
    # Note that we don't want to run this inside a subshell here.
    cd "$dir" || exit 1
    return 0
}

_koopa_disk_check() {                                                     # {{{1
    # """
    # Check that disk has enough free space.
    # Updated 2019-10-27.
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

_koopa_disk_pct_used() {                                                  # {{{1
    # """
    # Check disk usage on main drive.
    # Updated 2019-08-17.
    # """
    local disk
    disk="${1:-"/"}"
    df "$disk" \
        | head -n 2 \
        | sed -n '2p' \
        | grep -Eo "([.0-9]+%)" \
        | head -n 1 \
        | sed 's/%$//'
}

_koopa_dotfiles_config_link() {                                           # {{{1
    # """
    # Dotfiles directory.
    # Updated 2019-11-04.
    #
    # Note that we're not checking for existence here, which is handled inside
    # 'link-dotfile' script automatically instead.
    # """
    echo "$(_koopa_config_prefix)/dotfiles"
}

_koopa_dotfiles_private_config_link() {                                   # {{{1
    # """
    # Private dotfiles directory.
    # Updated 2019-11-04.
    # """
    echo "$(_koopa_dotfiles_config_link)-private"
}

_koopa_dotfiles_source_repo() {                                           # {{{1
    # """
    # Dotfiles source repository.
    # Updated 2019-11-04.
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
}

_koopa_git_branch() {                                                     # {{{1
    # """
    # Current git branch name.
    # Updated 2019-10-13.
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
    git symbolic-ref --short -q HEAD
}

# Also defined in koopa installer.
_koopa_group() {                                                          # {{{1
    # """
    # Return the approach group to use with koopa installation.
    # Updated 2019-10-22.
    #
    # Returns current user for local install.
    # Dynamically returns the admin group for shared install.
    #
    # Admin group priority: admin (macOS), sudo (Debian), wheel (Fedora).
    # """
    local group
    if _koopa_is_shared_install && _koopa_has_sudo
    then
        if groups | grep -Eq "\b(admin)\b"
        then
            group="admin"
        elif groups | grep -Eq "\b(sudo)\b"
        then
            group="sudo"
        elif groups | grep -Eq "\b(wheel)\b"
        then
            group="wheel"
        else
            group="$(whoami)"
        fi
    else
        group="$(whoami)"
    fi
    echo "$group"
}

_koopa_header() {                                                         # {{{1
    # """
    # Source script header.
    # Updated 2020-01-16.
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
}

_koopa_help() {                                                           # {{{1
    # """
    # Show usage via '--help' flag.
    # Updated 2020-01-21.
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

_koopa_host_id() {                                                        # {{{1
    # """
    # Simple host ID string to load up host-specific scripts.
    # Updated 2019-12-06.
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
}

_koopa_info_box() {                                                       # {{{1
    # """
    # Info box.
    # Updated 2019-10-14.
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

_koopa_install_mike() {                                                   # {{{1
    # """
    # Install additional Mike-specific config files.
    # Updated 2020-01-14.
    # """
    # > _koopa_h2 "Setting koopa remote to Git (SSH) instead of HTTPS."
    # > (
    # >     cd "${KOOPA_PREFIX:?}" || exit 1
    # >     git remote set-url origin "git@github.com:acidgenomics/koopa.git"
    # > )
    install-dotfiles --mike
    # docker
    source_repo="git@github.com:acidgenomics/docker.git"
    target_dir="$(_koopa_config_prefix)/docker"
    if [[ ! -d "$target_dir" ]]
    then
        git clone --recursive "$source_repo" "$target_dir"
    fi
    # scripts-private
    source_repo="git@github.com:mjsteinbaugh/scripts-private.git"
    target_dir="$(_koopa_config_prefix)/scripts-private"
    if [[ ! -d "$target_dir" ]]
    then
        git clone --recursive "$source_repo"  "$target_dir"
    fi
    return 0
}

_koopa_install_pip() {                                                    # {{{1
    # """
    # Install pip for Python.
    # Updated 2020-01-03.
    # """
    local python
    python="${1:-python3}"
    _koopa_h2 "Installing pip for Python '${python}'."
    local file
    file="get-pip.py"
    _koopa_download "https://bootstrap.pypa.io/${file}"
    "$python" "$file" --no-warn-script-location
    rm "$file"
    return 0
}

_koopa_install_pipx() {
    # """
    # Install pipx for Python.
    # Updated 2020-01-11.
    #
    # Local user installation:
    # Use the '--user' flag with 'pip install' call.
    #
    # This recommended step will modify shell RC file, which we don't want.
    # > "$python" -m pipx ensurepath
    # """
    local python
    python="${1:-python3}"
    _koopa_h2 "Installing pipx for Python '${python}'."
    "$python" -m pip install --no-warn-script-location pipx
    local prefix
    prefix="$(_koopa_app_prefix)/python/pipx"
    _koopa_prefix_mkdir "$prefix"
    _koopa_h2 "pipx installed successfully."
    _koopa_note "Restart the shell to activate pipx."
    return 0
}

_koopa_link_cellar() {                                                    # {{{1
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

_koopa_mktemp() {                                                         # {{{1
    # """
    # Wrapper function for system 'mktemp'.
    # Updated 2020-02-06.
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
    # See also:
    # - https://stackoverflow.com/questions/4632028
    # - https://stackoverflow.com/a/10983009/3911732
    # - https://gist.github.com/earthgecko/3089509
    # """
    _koopa_assert_is_installed mktemp
    local template
    template="koopa-$(id -u)-$(date "+%Y%m%d%H%M%S")-XXXXXXXXXX"
    mktemp "$@" --tmpdir "$template"
}

_koopa_os_codename() {                                                    # {{{1
    # """
    # Operating system code name.
    # Updated 2019-12-09.
    #
    # Alternate approach:
    # > awk -F= '$1=="VERSION_CODENAME" { print $2 ;}' /etc/os-release \
    # >     | tr -d '"'
    # """
    _koopa_assert_is_debian
    _koopa_assert_is_installed lsb_release
    lsb_release -cs
}

_koopa_os_id() {                                                          # {{{1
    # """
    # Operating system ID.
    # Updated 2019-11-25.
    #
    # Just return the OS platform ID (e.g. "debian").
    # """
    _koopa_os_string | cut -d '-' -f 1
}

_koopa_os_string() {                                                      # {{{1
    # """
    # Operating system string.
    # Updated 2020-01-13.
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
}

_koopa_relink() {                                                         # {{{1
    # """
    # Re-create a symbolic link dynamically, if broken.
    # Updated 2020-01-12.
    # """
    local source_file
    source_file="${1:?}"
    local dest_file
    dest_file="${2:?}"
    if [ ! -e "$dest_file" ]
    then
        if [ ! -e "$source_file" ]
        then
            _koopa_warning "Source file missing: '${source_file}'."
            return 1
        fi
        # > _koopa_h2 "Updating XDG config in '${config_dir}'."
        rm -f "$dest_file"
        ln -fns "$source_file" "$dest_file"
    fi
    return 0
}

_koopa_shell() {                                                          # {{{1
    # """
    # Note that this isn't necessarily the default shell ('$SHELL').
    # Updated 2019-06-27.
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
}

_koopa_tmp_dir() {                                                        # {{{1
    # """
    # Create temporary directory.
    # Updated 2020-02-06.
    # """
    _koopa_mktemp -d
}

_koopa_tmp_file() {                                                       # {{{1
    # """
    # Create temporary file.
    # Updated 2020-02-06.
    # """
    _koopa_mktemp
}

_koopa_tmp_log_file() {                                                   # {{{1
    # """
    # Create temporary log file.
    # Updated 2020-02-06.
    #
    # Used primarily for debugging cellar make install scripts.
    # """
    _koopa_mktemp --suffix=".log"
}

_koopa_today_bucket() {                                                   # {{{1
    # """
    # Create a dated file today bucket.
    # Updated 2019-11-10.
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
}

_koopa_variable() {                                                       # {{{1
    # """
    # Get version stored internally in versions.txt file.
    # Updated 2020-01-12.
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
    echo "$value" \
        | head -n 1 \
        | cut -d "\"" -f 2
}

_koopa_view_latest_tmp_log_file() {                                       # {{{1
    # """
    # View the latest temporary log file.
    # Updated 2020-02-06.
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
    less "$log_file"
    return 0
}
