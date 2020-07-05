#!/bin/sh
# shellcheck disable=SC2039

koopa::_id() { # {{{1
    # """
    # Return ID string.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_args "$#"
    local x
    x="$(id "$@")"
    koopa::print "$x"
    return 0
}

koopa::cpu_count() { # {{{1
    # """
    # Return a usable number of CPU cores.
    # @note Updated 2020-07-05.
    #
    # Dynamically assigns 'n-1' or 'n-2' depending on the machine power.
    # """
    koopa::assert_has_no_args "$#"
    local n
    if koopa::is_installed nproc
    then
        n="$(nproc)"
    elif koopa::is_macos
    then
        n="$(sysctl -n hw.ncpu)"
    elif koopa::is_linux
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
    koopa::print "$n"
    return 0
}

koopa::group() { # {{{1
    # """
    # Current user's default group.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    koopa::_id -gn
    return 0
}

koopa::group_id() { # {{{1
    # """
    # Current user's default group ID.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    koopa::_id -g
    return 0
}

koopa::hostname() { # {{{1
    # """
    # Host name.
    # @note Updated 2020-07-04.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed uname
    local x
    x="$(uname -n)"
    x="${x//.*/}"
    koopa::print "$x"
    return 0
}

koopa::host_id() { # {{{1
    # """
    # Simple host ID string to load up host-specific scripts.
    # @note Updated 2020-06-30.
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
        koopa::assert_is_installed hostname
        id="$(hostname -f)"
    fi
    case "$id" in
        # VMs {{{2
        # ----------------------------------------------------------------------
        *.ec2.internal)
            id="aws"
            ;;
        awslab*)
            id="aws"
            ;;
        azlab*)
            id="azure"
            ;;
        # HPCs {{{2
        # ----------------------------------------------------------------------
        *.o2.rc.hms.harvard.edu)
            id="harvard-o2"
            ;;
        *.rc.fas.harvard.edu)
            id="harvard-odyssey"
            ;;
    esac
    koopa::print "$id"
    return 0
}

koopa::os_codename() { # {{{1
    # """
    # Operating system code name.
    # @note Updated 2020-06-30.
    #
    # Alternate approach:
    # > awk -F= '$1=="VERSION_CODENAME" { print $2 ;}' /etc/os-release \
    # >     | tr -d '"'
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_debian
    koopa::assert_is_installed lsb_release
    local os_codename
    if koopa::is_kali
    then
        os_codename='buster'
    else
        os_codename="$(lsb_release -cs)"
    fi
    koopa::print "$os_codename"
    return 0
}

koopa::os_id() { # {{{1
    # """
    # Operating system ID.
    # @note Updated 2020-06-30.
    #
    # Just return the OS platform ID (e.g. "debian").
    # """
    koopa::assert_has_no_args "$#"
    local os_id
    if koopa::is_kali
    then
        os_id='debian'
    else
        os_id="$(koopa::os_string | cut -d '-' -f 1)"
    fi
    koopa::print "$os_id"
    return 0
}

koopa::os_string() { # {{{1
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
    koopa::assert_has_no_args "$#"
    local id string version
    if koopa::is_macos
    then
        # > id="$(uname -s | tr '[:upper:]' '[:lower:]')"
        id='macos'
        version="$(koopa::get_version "$id")"
        version="$(koopa::major_minor_version "$version")"
    elif koopa::is_linux
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
                version="$(koopa::major_version "$version")"
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
        koopa::stop 'Failed to detect OS ID.'
    fi
    string="$id"
    if [ -n "${version:-}" ]
    then
        string="${string}-${version}"
    fi
    koopa::print "$string"
    return 0
}

koopa::shell() { # {{{1
    # """
    # Current shell.
    # @note Updated 2020-07-05.
    #
    # @seealso
    # - https://stackoverflow.com/questions/3327013
    # """
    koopa::assert_has_no_args "$#"
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
        shell="$(basename "$(readlink /proc/$$/exe)")"
    else
        # This approach works on macOS.
        # The sed step converts '-zsh' to 'zsh', for example.
        # The basename step handles the case when ps returns full path.
        # This can happen inside of editors, such as vim.
        shell="$(basename "$(ps -p "$$" -o 'comm=' | sed 's/^-//g')")"
    fi
    koopa::print "$shell"
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

koopa::user() { # {{{1
    # """
    # Current user name.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    koopa::_id -un
    return 0
}

koopa::user_id() { # {{{1
    # """
    # Current user ID.
    # @note Updated 2020-04-16.
    # """
    koopa::assert_has_no_args "$#"
    koopa::_id -u
    return 0
}

koopa::variable() { # {{{1
    # """
    # Get version stored internally in versions.txt file.
    # @note Updated 2020-06-30.
    #
    # This approach handles inline comments.
    # """
    koopa::assert_has_args_eq "$#" 1
    local file key value
    key="${1:?}"
    file="$(koopa::include_prefix)/variables.txt"
    koopa::assert_is_file "$file"
    value="$( \
        grep -Eo "^${key}=\"[^\"]+\"" "$file" \
        || koopa::stop "'${key}' not defined in '${file}'." \
    )"
    value="$( \
        koopa::print "$value" \
            | head -n 1 \
            | cut -d "\"" -f 2 \
    )"
    [ -n "$value" ] || return 1
    koopa::print "$value"
    return 0
}

