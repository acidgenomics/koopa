#!/bin/sh

__koopa_id() { # {{{1
    # """
    # Return ID string.
    # @note Updated 2020-06-30.
    # """
    _koopa_print "$(id "$@")"
    return 0
}

_koopa_cpu_count() { # {{{1
    # """
    # Return a usable number of CPU cores.
    # @note Updated 2020-07-05.
    #
    # Dynamically assigns 'n-1' or 'n-2' depending on the machine power.
    # """
    # shellcheck disable=2039
    local n
    if _koopa_is_installed nproc
    then
        n="$(nproc)"
    elif _koopa_is_macos
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
    _koopa_print "$n"
    return 0
}

_koopa_group() { # {{{1
    # """
    # Current user's default group.
    # @note Updated 2020-06-30.
    # """
    __koopa_id -gn
    return 0
}

_koopa_group_id() { # {{{1
    # """
    # Current user's default group ID.
    # @note Updated 2020-06-30.
    # """
    __koopa_id -g
    return 0
}

_koopa_hostname() { # {{{1
    # """
    # Host name.
    # @note Updated 2020-07-05.
    # """
    koopa::print "$(uname -n)"
    return 0
}

_koopa_host_id() { # {{{1
    # """
    # Simple host ID string to load up host-specific scripts.
    # @note Updated 2020-07-05.
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
    # shellcheck disable=SC2039
    local id
    if [ -r '/etc/hostname' ]
    then
        id="$(cat '/etc/hostname')"
    else
        _koopa_is_installed hostname || return 1
        id="$(hostname -f)"
    fi
    case "$id" in
        # VMs {{{2
        # ----------------------------------------------------------------------
        *.ec2.internal)
            id='aws'
            ;;
        awslab*)
            id='aws'
            ;;
        azlab*)
            id='azure'
            ;;
        # HPCs {{{2
        # ----------------------------------------------------------------------
        *.o2.rc.hms.harvard.edu)
            id='harvard-o2'
            ;;
        *.rc.fas.harvard.edu)
            id='harvard-odyssey'
            ;;
    esac
    _koopa_print "$id"
    return 0
}

_koopa_os_codename() { # {{{1
    # """
    # Operating system code name.
    # @note Updated 2020-06-30.
    #
    # Alternate approach:
    # > awk -F= '$1=="VERSION_CODENAME" { print $2 ;}' /etc/os-release \
    # >     | tr -d '"'
    # """
    _koopa_is_debian || return 1
    _koopa_is_installed lsb_release || return 1
    # shellcheck disable=SC2039
    local os_codename
    if _koopa_is_kali
    then
        os_codename='buster'
    else
        os_codename="$(lsb_release -cs)"
    fi
    _koopa_print "$os_codename"
    return 0
}

_koopa_os_id() { # {{{1
    # """
    # Operating system ID.
    # @note Updated 2020-06-30.
    #
    # Just return the OS platform ID (e.g. "debian").
    # """
    # shellcheck disable=SC2039
    local os_id
    if _koopa_is_kali
    then
        os_id='debian'
    else
        os_id="$(_koopa_os_string | cut -d '-' -f 1)"
    fi
    _koopa_print "$os_id"
    return 0
}

_koopa_os_string() { # {{{1
    # """
    # Operating system string.
    # @note Updated 2020-06-30.
    #
    # Returns 'ID' and major 'VERSION_ID' separated by a '-'.
    #
    # Always returns lowercase, with unique names for Linux distros
    # (e.g. "rhel-8").
    #
    # Alternatively, use hostnamectl.
    # https://linuxize.com/post/how-to-check-linux-version/
    # """
    # shellcheck disable=SC2039
    local id release_file string version
    _koopa_is_installed awk || return 1
    if _koopa_is_macos
    then
        # > id="$(uname -s | tr '[:upper:]' '[:lower:]')"
        id='macos'
        version="$(_koopa_get_version "$id")"
        version="$(_koopa_major_minor_version "$version")"
    elif _koopa_is_linux
    then
        release_file='/etc/os-release'
        if [ -r "$release_file" ]
        then
            id="$( \
                awk -F= '$1=="ID" { print $2 ;}' "$release_file" \
                | tr -d '"' \
            )"
            # Include the major release version.
            version="$( \
                awk -F= '$1=="VERSION_ID" { print $2 ;}' "$release_file" \
                | tr -d '"'
            )"
            if [ -n "$version" ]
            then
                version="$(_koopa_major_version "$version")"
            else
                # This is the case for Arch Linux.
                version='rolling'
            fi
        else
            id='linux'
        fi
    fi
    if [ -z "$id" ]
    then
        _koopa_stop 'Failed to detect OS ID.'
    fi
    string="$id"
    if [ -n "${version:-}" ]
    then
        string="${string}-${version}"
    fi
    _koopa_print "$string"
    return 0
}

_koopa_shell() { # {{{1
    # """
    # Current shell.
    # @note Updated 2020-07-05.
    #
    # @seealso
    # - https://stackoverflow.com/questions/3327013
    # """
    # shellcheck disable=SC2039
    local shell
    if [ -n "${BASH_VERSION:-}" ]
    then
        shell='bash'
    elif [ -n "${ZSH_VERSION:-}" ]
    then
        shell='zsh'
    elif [ -d '/proc' ]
    then
        # Standard approach on Linux.
        _koopa_is_installed basename readlink || return 1
        shell="$(basename "$(readlink /proc/$$/exe)")"
    else
        # This approach works on macOS.
        # The sed step converts '-zsh' to 'zsh', for example.
        # The basename step handles the case when ps returns full path.
        # This can happen inside of editors, such as vim.
        _koopa_is_installed basename ps sed || return 1
        shell="$(basename "$(ps -p "$$" -o 'comm=' | sed 's/^-//g')")"
    fi
    _koopa_print "$shell"
    return 0
}

_koopa_user() { # {{{1
    # """
    # Current user name.
    # @note Updated 2020-06-30.
    # """
    __koopa_id -un
    return 0
}

_koopa_user_id() { # {{{1
    # """
    # Current user ID.
    # @note Updated 2020-04-16.
    # """
    __koopa_id -u
    return 0
}

