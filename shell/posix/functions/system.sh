#!/bin/sh
# shellcheck disable=SC2039

_koopa_add_config_link() {                                                # {{{1
    # """
    # Add a symlink into the koopa configuration directory.
    # Updated 2019-09-23.
    #
    # Examples:
    # _koopa_add_config_link vimrc
    # _koopa_add_config_link vim
    # """
    local config_dir
    config_dir="$(_koopa_config_prefix)"
    local source_file
    source_file="$1"
    _koopa_assert_is_existing "$source_file"
    source_file="$(realpath "$source_file")"
    local dest_name
    dest_name="$2"
    local dest_file
    dest_file="${config_dir}/${dest_name}"
    rm -fv "$dest_file"
    ln -fnsv "$source_file" "$dest_file"
}

_koopa_cd_tmp_dir() {                                                     # {{{1
    # """
    # Prepare and navigate (cd) to temporary directory.
    # Updated 2019-11-21.
    #
    # Used primarily for cellar build scripts.
    # """
    rm -fr "$1"
    mkdir -p "$1"
    cd "$1" || exit 1
}

_koopa_cellar_script() {                                                  # {{{1
    # """
    # Return source path for a koopa cellar build script.
    # Updated 2019-11-25.
    # """
    local name
    name="$1"
    file="$(_koopa_prefix)/system/include/cellar/${name}.sh"
    _koopa_assert_is_file "$file"
    _koopa_assert_has_no_envs
    # shellcheck source=/dev/null
    . "$file"
    _koopa_success "'${name}' installed successfully."
    return 0
}

_koopa_current_version() {                                                # {{{1
    # """
    # Get the current version of a supported program.
    # Updated 2019-11-16.
    # """
    local name
    name="$1"
    local script
    script="$(_koopa_prefix)/system/include/version/${name}.sh"
    if [ ! -x "$script" ]
    then
        _koopa_stop "'${name}' is not supported."
    fi
    "$script"
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
    disk="${1:-/}"
    df "$disk" \
        | head -n 2 \
        | sed -n '2p' \
        | grep -Eo "([.0-9]+%)" \
        | head -n 1 \
        | sed 's/%$//'
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
    # Updated 2019-11-25.
    #
    # Useful for private scripts using koopa code outside of package.
    # """
    local path
    if [ -z "${1:-}" ]
    then
        >&2 cat << EOF
error: TYPE argument missing.
usage: _koopa_header TYPE

shell:
    - bash
    - zsh

os:
    - amzn
    - centos
    - darwin
    - debian
    - fedora
    - linux
    - rhel
    - ubuntu

host:
    - aws
    - azure
EOF
        return 1
    fi
    case "$1" in
        # shell ----------------------------------------------------------------
        bash)
            path="${KOOPA_PREFIX}/shell/bash/include/header.sh"
            ;;
        zsh)
            path="${KOOPA_PREFIX}/shell/zsh/include/header.sh"
            ;;
        # os -------------------------------------------------------------------
        amzn)
            path="${KOOPA_PREFIX}/os/amzn/include/header.sh"
            ;;
        centos)
            path="${KOOPA_PREFIX}/os/centos/include/header.sh"
            ;;
        darwin)
            path="${KOOPA_PREFIX}/os/darwin/include/header.sh"
            ;;
        debian)
            path="${KOOPA_PREFIX}/os/debian/include/header.sh"
            ;;
        fedora)
            path="${KOOPA_PREFIX}/os/fedora/include/header.sh"
            ;;
        linux)
            path="${KOOPA_PREFIX}/os/linux/include/header.sh"
            ;;
        rhel)
            path="${KOOPA_PREFIX}/os/rhel/include/header.sh"
            ;;
        ubuntu)
            path="${KOOPA_PREFIX}/os/ubuntu/include/header.sh"
            ;;
        # host -----------------------------------------------------------------
        aws)
            path="${KOOPA_PREFIX}/host/aws/include/header.sh"
            ;;
        azure)
            path="${KOOPA_PREFIX}/host/azure/include/header.sh"
            ;;
        *)
            _koopa_stop "'${1}' is not supported."
            ;;
    esac
    echo "$path"
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
    # """
    _koopa_is_installed "hostname" || return 1
    local id
    case "$(hostname -f)" in
        # VMs
        *.ec2.internal)
            id="aws"
            ;;
        azlabapp*)
            id="azure"
            ;;
        # HPCs
        *.o2.rc.hms.harvard.edu)
            id="harvard-o2"
            ;;
        *.rc.fas.harvard.edu)
            id="harvard-odyssey"
            ;;
        *)
            id=
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
}

_koopa_install_mike() {                                                   # {{{1
    # """
    # Install additional Mike-specific config files.
    # Updated 2019-11-04.
    # """
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
    # Use SSH instead of HTTPS.
    (
        cd "$KOOPA_PREFIX" || exit 1
        git remote set-url origin "git@github.com:acidgenomics/koopa.git"
    )
}

_koopa_link_cellar() {                                                    # {{{1
    # """
    # Symlink cellar into build directory.
    # Updated 2019-11-27.
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
    # Example: _koopa_link_cellar emacs 26.3
    # """
    local name
    local version
    local make_prefix
    local cellar_prefix
    name="$1"
    version="${2:-}"
    make_prefix="$(_koopa_make_prefix)"
    _koopa_assert_is_dir "$make_prefix"
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
    _koopa_message "Linking '${cellar_prefix}' in '${make_prefix}'."
    _koopa_set_permissions "$cellar_prefix"
    if _koopa_is_shared_install
    then
        _koopa_assert_has_sudo
        sudo cp -frsv "$cellar_prefix/"* "$make_prefix/".
        _koopa_update_ldconfig
    else
        cp -frsv "$cellar_prefix/"* "$make_prefix/".
    fi
}

_koopa_macos_app_version() {                                              # {{{1
    # """
    # Extract the version of a macOS application.
    # Updated 2019-09-28.
    # """
    _koopa_assert_is_darwin
    plutil -p "/Applications/${1}.app/Contents/Info.plist" \
        | grep CFBundleShortVersionString \
        | awk -F ' => ' '{print $2}' \
        | tr -d '"'
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
    # Updated 2019-12-06.
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
    if _koopa_is_darwin
    then
        # > id="$(uname -s | tr '[:upper:]' '[:lower:]')"
        id="darwin"
        version="$(uname -r)"
    elif _koopa_is_linux
    then
        if [ -r /etc/os/release ]
        then
            id="$( \
                awk -F= '$1=="ID" { print $2 ;}' /etc/os-release \
                | tr -d '"' \
            )"
            # Include the major release version.
            version="$( \
                awk -F= '$1=="VERSION_ID" { print $2 ;}' /etc/os-release \
                | tr -d '"' \
                | cut -d '.' -f 1 \
            )"
        else
            # This provides fallback support for Arch Linux.
            id="linux"
            version="$(uname -r | cut -d '-' -f 1)"
        fi
    fi
    echo "${id}-${version}"
}

_koopa_os_version() {                                                     # {{{1
    # """
    # Operating system version.
    # Updated 2019-06-22.
    #
    # Note that this returns Darwin version information for macOS.
    # """
    uname -r
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
    bucket_dir="${HOME}/bucket"
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

_koopa_tmp_dir() {                                                        # {{{1
    # """
    # Create temporary directory.
    # Updated 2019-10-17.
    #
    # See also:
    # - https://stackoverflow.com/questions/4632028
    # - https://gist.github.com/earthgecko/3089509
    #
    # Note: macOS requires 'env LC_CTYPE=C'.
    # Otherwise, you'll see this error: 'tr: Illegal byte sequence'.
    # This doesn't seem to work reliably, so using timestamp instead.
    #
    # Alternate approach:
    # > local unique
    # > local dir
    # > unique="$(date "+%Y%m%d-%H%M%S")"
    # > dir="/tmp/koopa-$(id -u)-${unique}"
    # > echo "$dir"
    # """
    mktemp -d
}

_koopa_variable() {                                                       # {{{1
    # """
    # Get version stored internally in versions.txt file.
    # Updated 2019-10-27.
    # """
    local what
    local file
    local match
    what="$1"
    file="${KOOPA_PREFIX}/system/include/variables.txt"
    match="$(grep -E "^${what}=" "$file" || echo "")"
    if [ -n "$match" ]
    then
        echo "$match" | cut -d "\"" -f 2
    else
        _koopa_stop "'${what}' not defined in '${file}'."
    fi
}
