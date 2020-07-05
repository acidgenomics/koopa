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

koopa::expr() { # {{{1
    # """
    # Quiet regular expression matching that is POSIX compliant.
    # @note Updated 2020-06-30.
    #
    # Avoid using '[[ =~ ]]' in sh config files.
    # 'expr' is faster than using 'case'.
    #
    # See also:
    # - https://stackoverflow.com/questions/21115121
    # """
    koopa::assert_has_args_eq "$#" 2
    expr "${1:?}" : "${2:?}" 1>/dev/null
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

# FIXME SAVE TO MOVE? USED IN TODAY ACTIVATE SCRIPT?
koopa::ln() { # {{{1
    # """
    # Create a symlink quietly.
    # @note Updated 2020-07-04.
    # """
    koopa::assert_has_args_eq "$#" 2
    koopa::assert_is_installed ln
    local source_file target_file
    source_file="${1:?}"
    target_file="${2:?}"
    koopa::rm "$target_file"
    ln -fns "$source_file" "$target_file"
    return 0
}

koopa::mkdir() { # {{{1
    # """
    # Create directories with parents automatically.
    # @note Updated 2020-07-04.
    koopa::assert_has_args "$#"
    mkdir -pv "$@"
    return 0
}

koopa::mv() { # {{{1
    # """
    # Move a file or directory.
    # @note Updated 2020-07-04.
    #
    # This function works on 1 file or directory at a time.
    # It ensures that the target parent directory exists automatically.
    #
    # Useful GNU cp flags, for reference (non-POSIX):
    # - -T: no-target-directory
    # - --strip-trailing-slashes
    # """
    koopa::assert_has_args_eq "$#" 2
    local source_file target_file
    source_file="$(koopa::strip_trailing_slash "${1:?}")"
    koopa::assert_is_existing "$source_file"
    target_file="$(koopa::strip_trailing_slash "${2:?}")"
    [ -e "$target_file" ] && koopa::rm "$target_file"
    koopa::mkdir "$(dirname "$target_file")"
    mv -f "$source_file" "$target_file"
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

koopa::public_ip_address() { # {{{1
    # """
    # Public (remote) IP address.
    # @note Updated 2020-06-18.
    #
    # @seealso
    # https://www.cyberciti.biz/faq/
    #     how-to-find-my-public-ip-address-from-command-line-on-a-linux/
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed dig
    local x
    x="$(dig +short myip.opendns.com @resolver1.opendns.com)"
    # Fallback in case dig approach doesn't work.
    if [ -z "$x" ]
    then
        koopa::assert_is_installed curl
        x="$(curl -s ipecho.net/plain)"
    fi
    [ -n "$x" ] || return 1
    koopa::print "$x"
    return 0
}

koopa::python_remove_pycache() { # {{{1
    # """
    # Remove Python '__pycache__/' from site packages.
    # @note Updated 2020-06-30.
    #
    # These directories can create permission issues when attempting to rsync
    # installation across multiple VMs.
    # """
    koopa::assert_has_args_le "$#" 1
    koopa::assert_is_installed find
    local prefix python
    prefix="${1:-}"
    if [ -z "$prefix" ]
    then
        # e.g. /usr/local/cellar/python/3.8.1
        python="$(koopa::which_realpath "python3")"
        prefix="$(realpath "$(dirname "$python")/..")"
    fi
    koopa::info "Removing pycache in '${prefix}'."
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

koopa::relink() { # {{{1
    # """
    # Re-create a symbolic link dynamically, if broken.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_args_eq "$#" 2
    local dest_file source_file
    source_file="${1:?}"
    dest_file="${2:?}"
    # Keep this check relaxed, in case dotfiles haven't been cloned.
    [ -e "$source_file" ] || return 0
    [ -L "$dest_file" ] && return 0
    koopa::rm "$dest_file"
    ln -fns "$source_file" "$dest_file"
    return 0
}

koopa::rm() { # {{{1
    # """
    # Remove files/directories quietly.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_args "$#"
    rm -fr "$@" >/dev/null 2>&1
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
            -not -name "*.md" \
            -not -name ".pylintrc" \
            -not -path "${prefix}/.git/*" \
            -not -path "${prefix}/cellar/*" \
            -not -path "${prefix}/coverage/*" \
            -not -path "${prefix}/dotfiles/*" \
            -not -path "${prefix}/opt/*" \
            -not -path "${prefix}/tests/*" \
            -not -path "*/etc/R/*" \
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

koopa::umask() { # {{{1
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
    # - 0022: u=rwx,g=rx,o=rx
    #         User can write, others can read. Usually default.
    # - 0002: u=rwx,g=rwx,o=rx
    #         User and group can write, others can read.
    #         Recommended setting in a shared coding environment.
    # - 0077: u=rwx,g=,o=
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
    koopa::assert_has_no_args "$#"
    umask 0002
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
    koopa::variable "koopa-url"
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

