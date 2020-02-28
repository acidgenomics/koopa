#!/bin/sh
# shellcheck disable=SC2039

_koopa_admin_group() {  # {{{1
    # """
    # Return the administrator group.
    # @note Updated 2020-02-19.
    #
    # Usage of 'groups' here is terribly slow for domain users.
    # Currently seeing this with CPI AWS Ubuntu config.
    # Instead of grep matching against 'groups' return, just set the
    # expected default per Linux distro. In the event that we're unsure,
    # the function will intentionally error.
    # """
    local group
    if _koopa_is_root
    then
        group="root"
    elif _koopa_is_debian
    then
        group="sudo"
    elif _koopa_is_fedora
    then
        group="wheel"
    elif _koopa_is_macos
    then
        group="admin"
    else
        _koopa_stop "Failed to detect admin group."
    fi
    echo "$group"
    return 0
}

_koopa_cd() {  # {{{1
    # """
    # Change directory quietly.
    # @note Updated 2019-10-29.
    # """
    cd "$@" > /dev/null || return 1
    return 0
}

_koopa_cd_tmp_dir() {  # {{{1
    # """
    # Prepare and navigate (cd) to temporary directory.
    # @note Updated 2020-02-16.
    #
    # Used primarily for cellar build scripts.
    # """
    local dir
    dir="${1:-$(_koopa_tmp_dir)}"
    rm -fr "$dir"
    mkdir -p "$dir"
    _koopa_cd "$dir"
    return 0
}

_koopa_chgrp() {  # {{{1
    # """
    # chgrp with dynamic sudo handling.
    # @note Updated 2020-02-16.
    # """
    if _koopa_is_shared_install
    then
        sudo chgrp "$@"
    else
        chgrp "$@"
    fi
    return 0
}

_koopa_chmod() {  # {{{1
    # """
    # chmod with dynamic sudo handling.
    # @note Updated 2020-02-16.
    # """
    if _koopa_is_shared_install
    then
        sudo chmod "$@"
    else
        chmod "$@"
    fi
    return 0
}

_koopa_chmod_flags() {
    # """
    # Default recommended flags for chmod.
    # @note Updated 2020-02-16.
    # """
    local flags
    if _koopa_is_shared_install
    then
        flags="u+rw,g+rw"
    else
        flags="u+rw,g+r,g-w"
    fi
    echo "$flags"
    return 0
}

_koopa_chown() {  # {{{1
    # """
    # chown with dynamic sudo handling.
    # @note Updated 2020-02-16.
    # """
    if _koopa_is_shared_install
    then
        sudo chown "$@"
    else
        chown "$@"
    fi
    return 0
}

_koopa_commit() {  # {{{1
    # """
    # Koopa commit ID.
    # @note Updated 2020-02-26.
    # """
    local x
    x="$( \
        _koopa_cd "$koopa_prefix"; \
        _koopa_git_last_commit_local \
    )"
    echo "$x"
    return 0
}

_koopa_cp() {  # {{{1
    # """
    # Koopa copy.
    # @note Updated 2020-02-28.
    # """
    if _koopa_is_shared_install
    then
        sudo cp -an "$@"
    else
        cp -an "$@"
    fi
    return 0
}

_koopa_cpu_count() {  # {{{1
    # """
    # Return a usable number of CPU cores.
    # @note Updated 2020-02-20.
    #
    # Dynamically assigns 'n-1' or 'n-2' depending on the machine power.
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
    # Subtract some cores for login use on powerful machines.
    if [ "$n" -ge 17 ]
    then
        # For 17+ cores, use 'n-2'.
        n=$((n - 2))
    elif [ "$n" -ge 5 ] && [ "$n" -le 16 ]
    then
        # For 5-16 cores, use 'n-1'.
        n=$((n - 1))
    fi
    echo "$n"
    return 0
}

_koopa_date() {  # {{{1
    # """
    # Koopa date.
    # @note Updated 2020-02-26.
    # """
    _koopa_variable "koopa-date"
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

_koopa_download() {  # {{{1
    # """
    # Download a file.
    # @note Updated 2020-02-16.
    #
    # Potentially useful curl flags:
    # * --connect-timeout <seconds>
    # * --silent
    # * --stderr
    # * --verbose
    #
    # Note that '--fail-early' flag is useful, but not supported on old versions
    # of curl (e.g. 7.29.0; RHEL 7).
    #
    # Alternatively, can use wget instead of curl:
    # > wget -O file url
    # > wget -q -O - url (piped to stdout)
    # > wget -qO-
    # """
    _koopa_assert_is_installed curl
    local url
    url="${1:?}"
    local file
    file="${2:-}"
    if [ -z "$file" ]
    then
        local wd
        wd="$(pwd)"
        local bn
        bn="$(basename "$url")"
        file="${wd}/${bn}"
    fi
    _koopa_info "Downloading '${url}' to '${file}'."
    curl \
        --create-dirs \
        --fail \
        --location \
        --output "$file" \
        --progress-bar \
        --retry 1 \
        --show-error \
        "$url"
    return 0
}

_koopa_expr() {  # {{{1
    # """
    # Quiet regular expression matching that is POSIX compliant.
    # @note Updated 2020-02-16.
    #
    # Avoid using '[[ =~ ]]' in sh config files.
    # 'expr' is faster than using 'case'.
    #
    # See also:
    # - https://stackoverflow.com/questions/21115121
    # """
    expr "${1:?}" : "${2:?}" 1>/dev/null
}

_koopa_extract() {  # {{{1
    # """
    # Extract compressed files automatically.
    # @note Updated 2020-02-13.
    #
    # As suggested by Mendel Cooper in "Advanced Bash Scripting Guide".
    #
    # See also:
    # - https://github.com/stephenturner/oneliners
    # """
    local file
    file="${1:?}"
    if [ ! -f "$file" ]
    then
        _koopa_stop "Invalid file: '${file}'."
    fi
    _koopa_h2 "Extracting '${file}'."
    case "$file" in
        *.tar.bz2)
            tar -xj -f "$file"
            ;;
        *.tar.gz)
            tar -xz -f "$file"
            ;;
        *.tar.xz)
            tar -xJ -f "$file"
            ;;
        *.bz2)
            _koopa_assert_is_installed bunzip2
            bunzip2 "$file"
            ;;
        *.gz)
            gunzip "$file"
            ;;
        *.rar)
            _koopa_assert_is_installed unrar
            unrar -x "$file"
            ;;
        *.tar)
            tar -x -f "$file"
            ;;
        *.tbz2)
            tar -xj -f "$file"
            ;;
        *.tgz)
            tar -xz -f "$file"
            ;;
        *.xz)
            _koopa_assert_is_installed xz
            xz --decompress "$file"
            ;;
        *.zip)
            _koopa_assert_is_installed unzip
            unzip "$file"
            ;;
        *.Z)
            uncompress "$file"
            ;;
        *.7z)
            _koopa_assert_is_installed 7z
            7z -x "$file"
            ;;
        *)
            _koopa_stop "Unsupported extension: '${file}'."
            ;;
   esac
   return 0
}


_koopa_github_url() {  # {{{1
    # """
    # Koopa GitHub URL.
    # @note Updated 2020-02-26.
    # """
    _koopa_variable "koopa-github-url"
    return 0
}

_koopa_group() {  # {{{1
    # """
    # Return the appropriate group to use with koopa installation.
    # @note Updated 2020-02-16.
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
        group="$(id -gn)"
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
    # @note Updated 2020-02-19.
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

    # Detect the version automatically, if not specified.
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
    _koopa_set_permissions --recursive "$cellar_prefix"
    _koopa_remove_broken_symlinks "$cellar_prefix"

    # Early return cellar-only if Homebrew is installed.
    if _koopa_is_installed brew
    then
        _koopa_note "Homebrew installation detected."
        _koopa_note "Skipping linkage into '${make_prefix}'."
        return 0
    fi

    _koopa_remove_broken_symlinks "$make_prefix"

    if _koopa_is_shared_install
    then
        sudo cp -frs "$cellar_prefix/"* "$make_prefix/".
        _koopa_update_ldconfig
    else
        cp -frs "$cellar_prefix/"* "$make_prefix/".
    fi

    return 0
}

_koopa_list_internal_functions() {  # {{{1
    # """
    # List all functions defined by koopa.
    # @note Updated 2020-02-19.
    # """
    local x
    case "$(_koopa_shell)" in
        bash)
            x="$( \
                declare -F \
                | sed "s/^declare -f //g" \
            )"
            ;;
        zsh)
            # shellcheck disable=SC2086,SC2154
            x="$(print -l ${(ok)functions})"
            ;;
        *)
            return 1
            ;;
    esac
    x="$(echo "$x" | grep -E "^_koopa_")"
    echo "$x"
    return 0
}

_koopa_ln() {  # {{{1
    # """
    # Create symlink quietly.
    # @note Updated 2020-02-16.
    # """
    if _koopa_is_shared_install
    then
        sudo ln -fns "$@"
    else
        ln -fns "$@"
    fi
    return 0
}

_koopa_local_ip_address() {  # {{{1
    # """
    # Local IP address.
    # @note Updated 2020-02-23.
    #
    # Some systems (e.g. macOS) will return multiple IP address matches for
    # Ethernet and WiFi. Here we're simplying returning the first match, which
    # corresponds to the default on macOS.
    # """
    local x
    if _koopa_is_macos
    then
        x="$( \
            ifconfig \
            | grep "inet " \
            | grep "broadcast" \
            | awk '{print $2}' \
        )"
    else
        x="$( \
            hostname -I \
            | awk '{print $1}' \
        )"
    fi
    echo "$x" | head -n 1
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
    # @note Updated 2020-02-16.
    # """
    if _koopa_is_shared_install
    then
        sudo mkdir -p "$@"
    else
        mkdir -p "$@"
    fi
    _koopa_chmod "$(_koopa_chmod_flags)" "$@"
    _koopa_chgrp "$(_koopa_group)" "$@"
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

_koopa_mv() {  # {{{1
    # """
    # Koopa move.
    # @note Updated 2020-02-28.
    # """
    if _koopa_is_shared_install
    then
        sudo mv -Tf --strip-trailing-slashes "$@"
    else
        mv -Tf --strip-trailing-slashes "$@"
    fi
    return 0
}

_koopa_os_codename() {  # {{{1
    # """
    # Operating system code name.
    # @note Updated 2020-02-27.
    #
    # Alternate approach:
    # > awk -F= '$1=="VERSION_CODENAME" { print $2 ;}' /etc/os-release \
    # >     | tr -d '"'
    # """
    _koopa_assert_is_debian
    _koopa_assert_is_installed lsb_release
    local os_codename
    if _koopa_is_kali
    then
        os_codename="buster"
    else
        os_codename="$(lsb_release -cs)"
    fi
    echo "$os_codename"
    return 0
}

_koopa_os_id() {  # {{{1
    # """
    # Operating system ID.
    # @note Updated 2020-02-27.
    #
    # Just return the OS platform ID (e.g. "debian").
    # """
    local os_id
    if _koopa_is_kali
    then
        os_id="debian"
    else
        os_id="$(_koopa_os_string | cut -d '-' -f 1)"
    fi
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

_koopa_public_ip_address() {  # {{{1
    # """
    # Public (remote) IP address.
    # @note Updated 2020-02-23.
    #
    # @seealso
    # https://www.cyberciti.biz/faq/
    #     how-to-find-my-public-ip-address-from-command-line-on-a-linux/
    # """
    _koopa_is_installed dig || return 1
    local x
    x="$(dig +short myip.opendns.com @resolver1.opendns.com)"
    echo "$x"
    return 0
}

_koopa_python_remove_pycache() {  # {{{1
    # """
    # Remove Python '__pycache__/' from site packages.
    # @note Updated 2020-02-19.
    #
    # These directories can create permission issues when attempting to rsync
    # installation across multiple VMs.
    # """
    local prefix
    prefix="${1:-}"
    if [ -z "$prefix" ]
    then
        # e.g. /usr/local/cellar/python/3.8.1
        local python
        python="$(_koopa_which_realpath "python3")"
        prefix="$(realpath "$(dirname "$python")/..")"
    fi
    _koopa_h2 "Removing pycache in '${prefix}'."
    # > find "$prefix" \
    # >     -type d \
    # >     -name "__pycache__" \
    # >     -print0 \
    # >     -exec rm -frv "{}" \;
    find "$prefix" \
        -type d \
        -name "__pycache__" \
        -print0 \
        | xargs -0 -I {} rm -frv "{}"
    return 0
}

_koopa_relink() {  # {{{1
    # """
    # Re-create a symbolic link dynamically, if broken.
    # @note Updated 2020-02-16.
    # """
    local source_file
    source_file="${1:?}"
    local dest_file
    dest_file="${2:?}"
    # Relaxing this check, in case dotfiles haven't been cloned.
    [ -e "$source_file" ] || return 0
    [ -L "$dest_file" ] && return 0
    _koopa_rm "$dest_file"
    ln -fns "$source_file" "$dest_file"
    return 0
}

_koopa_rm() {  # {{{1
    # """
    # Remove files/directories without dealing with permissions.
    # @note Updated 2020-02-16.
    # """
    if _koopa_is_shared_install
    then
        sudo rm -fr "$@" > /dev/null 2>&1
    else
        rm -fr "$@" > /dev/null 2>&1
    fi
    return 0
}

_koopa_rsync_flags() {  # {{{1
    # """
    # rsync flags.
    # @note Updated 2019-10-28.
    #
    #     --delete-before         receiver deletes before xfer, not during
    #     --iconv=CONVERT_SPEC    request charset conversion of filenames
    #     --numeric-ids           don't map uid/gid values by user/group name
    #     --partial               keep partially transferred files
    #     --progress              show progress during transfer
    # -A, --acls                  preserve ACLs (implies -p)
    # -H, --hard-links            preserve hard links
    # -L, --copy-links            transform symlink into referent file/dir
    # -O, --omit-dir-times        omit directories from --times
    # -P                          same as --partial --progress
    # -S, --sparse                handle sparse files efficiently
    # -X, --xattrs                preserve extended attributes
    # -a, --archive               archive mode; equals -rlptgoD (no -H,-A,-X)
    # -g, --group                 preserve group
    # -h, --human-readable        output numbers in a human-readable format
    # -n, --dry-run               perform a trial run with no changes made
    # -o, --owner                 preserve owner (super-user only)
    # -r, --recursive             recurse into directories
    # -x, --one-file-system       don't cross filesystem boundaries    
    # -z, --compress              compress file data during the transfer
    #
    # Use '--rsync-path="sudo rsync"' to sync across machines with sudo.
    #
    # See also:
    # - https://unix.stackexchange.com/questions/165423
    # """
    echo "--archive --delete-before --human-readable --progress"
    return 0
}

_koopa_set_sticky_group() {  # {{{1
    # """
    # Set sticky group bit for target prefix(es).
    # @note Updated 2020-01-24.
    #
    # This never works recursively.
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

_koopa_test_true_color() {  # {{{1
    # """
    # Test 24-bit true color support.
    # @note Updated 2020-02-15.
    #
    # @seealso
    # https://jdhao.github.io/2018/10/19/tmux_nvim_true_color/
    # """
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
    # @note Updated 2020-02-27.
    #
    # Used primarily for debugging cellar make install scripts.
    #
    # Note that mktemp on macOS and BusyBox doesn't support '--suffix' flag.
    # Otherwise, we can use:
    # > _koopa_mktemp --suffix=".log"
    # """
    _koopa_tmp_file
    return 0
}

# > _koopa_unset_internal_functions() {  # {{{1
# >     # """
# >     # Unset all of koopa's internal functions.
# >     # @note Updated 2020-02-19.
# >     #
# >     # Potentially useful as a final clean-up step for activation.
# >     # Note that this will nuke functions currently required for interactive
# >     # prompt, so don't do this yet.
# >     # """
# >     local funs
# >     # Convert the '\n' delimited list into an array.
# >     case "$(_koopa_shell)" in
# >         bash)
# >             mapfile -t funs < <(_koopa_list_internal_functions)
# >             ;;
# >         zsh)
# >             funs=("${(@f)$(_koopa_list_internal_functions)}")
# >             ;;
# >         *)
# >             return 1
# >             ;;
# >     esac
# >     unset -f "${funs[@]}"
# >     return 0
# > }

_koopa_url() {  # {{{1
    # """
    # Koopa URL.
    # @note Updated 2020-02-26.
    # """
    _koopa_variable "koopa-url"
    return 0
}

_koopa_user() {  # {{{1
    # """
    # Set the default user.
    # @note Updated 2020-02-16.
    # """
    local user
    if _koopa_is_shared_install
    then
        user="root"
    else
        user="${USER:?}"
    fi
    echo "$user"
    return 0
}

_koopa_variable() {  # {{{1
    # """
    # Get version stored internally in versions.txt file.
    # @note Updated 2020-02-27.
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
