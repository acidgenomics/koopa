#!/usr/bin/env bash

koopa::admin_group() { # {{{1
    # """
    # Return the administrator group.
    # @note Updated 2022-02-11.
    #
    # Usage of 'groups' can be terribly slow for domain users. Instead of grep
    # matching against 'groups' return, just set the expected default per Linux
    # distro. In the event that we're unsure, the function will intentionally
    # error.
    # """
    local group
    koopa::assert_has_no_args "$#"
    if koopa::is_alpine
    then
        group='wheel'
    elif koopa::is_arch
    then
        group='wheel'
    elif koopa::is_debian_like
    then
        group='sudo'
    elif koopa::is_fedora_like
    then
        group='wheel'
    elif koopa::is_macos
    then
        group='admin'
    elif koopa::is_opensuse
    then
        group='wheel'
    else
        koopa::stop 'Failed to determine admin group.'
    fi
    koopa::print "$group"
    return 0
}

koopa::arch2() { # {{{1
    # """
    # Alternative platform architecture.
    # @note Updated 2022-02-09.
    #
    # e.g. Intel: amd64; ARM: arm64.
    #
    # @seealso
    # - https://wiki.debian.org/ArchitectureSpecificsMemo
    # """
    local str
    koopa::assert_has_no_args "$#"
    case "$(koopa::arch)" in
        'aarch64')
            str='arm64'
            ;;
        'x86_64')
            str='amd64'
            ;;
        *)
            return 1
            ;;
    esac
    [[ -n "$str" ]] || return 1
    koopa::print "$str"
    return 0
}

koopa::compress_ext_pattern() { # {{{1
    # """
    # Compressed file extension pattern.
    # @note Updated 2022-01-11.
    # """
    koopa::assert_has_no_args "$#"
    koopa::print '\.(bz2|gz|xz|zip)$'
    return 0
}

koopa::cpu_count() { # {{{1
    # """
    # Return a usable number of CPU cores.
    # @note Updated 2022-02-09.
    # """
    local app num
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [nproc]="$(koopa::locate_nproc 2>/dev/null || true)"
    )
    if koopa::is_installed "${app[nproc]}"
    then
        num="$("${app[nproc]}")"
    elif koopa::is_macos
    then
        app[sysctl]="$(koopa::macos_locate_sysctl)"
        num="$("${app[sysctl]}" -n 'hw.ncpu')"
    elif koopa::is_linux
    then
        app[getconf]="$(koopa::linux_locate_getconf)"
        num="$("${app[getconf]}" '_NPROCESSORS_ONLN')"
    else
        num=1
    fi
    koopa::print "$num"
    return 0
}

koopa::datetime() { # {{{
    # """
    # Datetime string.
    # @note Updated 2022-01-20.
    # """
    local app str
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [date]="$(koopa::locate_date)"
    )
    str="$("${app[date]}" '+%Y%m%d-%H%M%S')"
    [[ -n "$str" ]] || return 1
    koopa::print "$str"
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

koopa::gcrypt_url() { # {{{1
    # """
    # Get GnuPG FTP URL.
    # @note Updated 2021-04-27.
    # """
    koopa::assert_has_no_args "$#"
    koopa::variable 'gcrypt-url'
    return 0
}

koopa::gnu_mirror_url() { # {{{1
    # """
    # Get GNU FTP mirror URL.
    # @note Updated 2020-04-16.
    # """
    koopa::assert_has_no_args "$#"
    koopa::variable 'gnu-mirror-url'
    return 0
}

koopa::ip_address() { # {{{1
    # """
    # IP address.
    # @note Updated 2022-02-09.
    # """
    local dict
    declare -A dict=(
        [type]='public'
    )
    while (("$#"))
    do
        case "$1" in
            '--local')
                dict[type]='local'
                shift 1
                ;;
            '--public')
                dict[type]='public'
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    case "${dict[type]}" in
        'local')
            koopa::local_ip_address
            ;;
        'public')
            koopa::public_ip_address
            ;;
    esac
    return 0
}

koopa::koopa_date() { # {{{1
    # """
    # Koopa date.
    # @note Updated 2021-06-07.
    # """
    koopa::assert_has_no_args "$#"
    koopa::variable 'koopa-date'
    return 0
}

koopa::koopa_github_url() { # {{{1
    # """
    # Koopa GitHub URL.
    # @note Updated 2021-06-07.
    # """
    koopa::assert_has_no_args "$#"
    koopa::variable 'koopa-github-url'
    return 0
}

koopa::koopa_installers_url() { # {{{1
    # """
    # Koopa installers URL.
    # @note Updated 2022-01-06.
    # """
    koopa::assert_has_no_args "$#"
    koopa::print "$(koopa::koopa_url)/installers"
}

koopa::koopa_url() { # {{{1
    # """
    # Koopa URL.
    # @note Updated 2021-06-07.
    # """
    koopa::assert_has_no_args "$#"
    koopa::variable 'koopa-url'
    return 0
}

koopa::local_ip_address() { # {{{1
    # """
    # Local IP address.
    # @note Updated 2022-02-09.
    #
    # Some systems (e.g. macOS) will return multiple IP address matches for
    # Ethernet and WiFi. Here we're simplying returning the first match, which
    # corresponds to the default on macOS.
    # """
    local app str
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [awk]="$(koopa::locate_awk)"
        [head]="$(koopa::locate_head)"
        [tail]="$(koopa::locate_tail)"
    )
    if koopa::is_macos
    then
        app[ifconfig]="$(koopa::macos_locate_ifconfig)"
        # shellcheck disable=SC2016
        str="$( \
            "${app[ifconfig]}" \
            | koopa::grep --pattern='inet ' \
            | koopa::grep --pattern='broadcast' \
            | "${app[awk]}" '{print $2}' \
            | "${app[tail]}" --lines=1 \
        )"
    else
        app[hostname]="$(koopa::locate_hostname)"
        # shellcheck disable=SC2016
        str="$( \
            "${app[hostname]}" -I \
            | "${app[awk]}" '{print $1}' \
            | "${app[head]}" --lines=1 \
        )"
    fi
    [[ -n "$str" ]] || return 1
    koopa::print "$str"
    return 0
}

koopa::make_build_string() { # {{{1
    # """
    # OS build string for 'make' configuration.
    # @note Updated 2022-02-09.
    #
    # Use this for 'configure --build' flag.
    #
    # - macOS: x86_64-darwin15.6.0
    # - Linux: x86_64-linux-gnu
    # """
    local dict
    koopa::assert_has_no_args "$#"
    declare -A dict=(
        [arch]="$(koopa::arch)"
    )
    if koopa::is_linux
    then
        dict[os_type]='linux-gnu'
    else
        dict[os_type]="$(koopa::os_type)"
    fi
    koopa::print "${dict[arch]}-${dict[os_type]}"
    return 0
}

koopa::mem_gb() { # {{{1
    # """
    # Get total system memory in GB.
    # @note Updated 2022-02-09.
    #
    # - 1 GB / 1024 MB
    # - 1 MB / 1024 KB
    # - 1 KB / 1024 bytes
    #
    # Usage of 'int()' in awk rounds down.
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [awk]='awk'
    )
    declare -A dict
    if koopa::is_macos
    then
        app[sysctl]="$(koopa::macos_locate_sysctl)"
        dict[mem]="$("${app[sysctl]}" -n 'hw.memsize')"
        dict[denom]=1073741824  # 1024^3; bytes
    elif koopa::is_linux
    then
        dict[meminfo]='/proc/meminfo'
        koopa::assert_is_file "${dict[meminfo]}"
        # shellcheck disable=SC2016
        dict[mem]="$("${app[awk]}" '/MemTotal/ {print $2}' "${dict[meminfo]}")"
        dict[denom]=1048576  # 1024^2; KB
    else
        koopa::stop 'Unsupported system.'
    fi
    dict[str]="$( \
        "${app[awk]}" \
            -v denom="${dict[denom]}" \
            -v mem="${dict[mem]}" \
            'BEGIN{ printf "%.0f\n", mem / denom }' \
    )"
    [[ -n "${dict[str]}" ]] || return 1
    koopa::print "${dict[str]}"
    return 0
}

koopa::os_type() { # {{{1
    # """
    # Operating system type.
    # @note Updated 2022-02-09.
    # """
    local app str
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [tr]="$(koopa::locate_tr)"
        [uname]="$(koopa::locate_uname)"
    )
    str="$( \
        "${app[uname]}" -s \
        | "${app[tr]}" '[:upper:]' '[:lower:]' \
    )"
    [[ -n "$str" ]] || return 1
    koopa::print "$str"
    return 0
}

koopa::public_ip_address() { # {{{1
    # """
    # Public (remote) IP address.
    # @note Updated 2022-02-11.
    #
    # @section BIND's Domain Information Groper (dig) tool:
    #
    # - IPv4 address:
    #   > dig +short 'myip.opendns.com' '@resolver1.opendns.com' -4
    # - IPv6 address:
    #   > dig +short 'AAAA' 'myip.opendns.com' '@resolver1.opendns.com'
    #
    # @seealso
    # - https://www.cyberciti.biz/faq/
    #     how-to-find-my-public-ip-address-from-command-line-on-a-linux/
    # - https://dev.to/adityathebe/a-handy-way-to-know-your-public-ip-address-
    #     with-dns-servers-4nmn
    # """
    local app str
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [dig]="$(koopa::locate_dig 2>/dev/null || true)"
    )
    if koopa::is_installed "${app[dig]}"
    then
        str="$( \
            "${app[dig]}" +short \
                'myip.opendns.com' \
                '@resolver1.opendns.com' \
                -4 \
        )"
    else
        # Otherwise fall back to parsing URL via cURL.
        str="$(koopa::parse_url 'https://ipecho.net/plain')"
    fi
    [[ -n "$str" ]] || return 1
    koopa::print "$str"
    return 0
}

koopa::script_name() { # {{{1
    # """
    # Get the calling script name.
    # @note Updated 2022-02-09.
    #
    # Note that we're using 'caller' approach, which is Bash-specific.
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [cut]="$(koopa::locate_cut)"
        [head]="$(koopa::locate_head)"
    )
    declare -A dict
    dict[file]="$( \
        caller \
        | "${app[head]}" --lines=1 \
        | "${app[cut]}" --delimiter=' ' --fields='2' \
    )"
    dict[bn]="$(koopa::basename "${dict[file]}")"
    [[ -n "${dict[bn]}" ]] || return 0
    koopa::print "${dict[bn]}"
    return 0
}

koopa::variable() { # {{{1
    # """
    # Return a variable stored 'variables.txt' include file.
    # @note Updated 2022-02-09.
    #
    # This approach handles inline comments.
    # """
    local app dict
    koopa::assert_has_args_eq "$#" 1
    declare -A app=(
        [cut]="$(koopa::locate_cut)"
        [head]="$(koopa::locate_head)"
    )
    declare -A dict=(
        [key]="${1:?}"
        [include_prefix]="$(koopa::include_prefix)"
    )
    dict[file]="${dict[include_prefix]}/variables.txt"
    koopa::assert_is_file "${dict[file]}"
    dict[str]="$( \
        koopa::grep \
            --extended-regexp \
            --file="${dict[file]}" \
            --only-matching \
            --pattern="^${dict[key]}=\"[^\"]+\"" \
        || koopa::stop "'${dict[key]}' not defined in '${dict[file]}'." \
    )"
    dict[str]="$( \
        koopa::print "${dict[str]}" \
            | "${app[head]}" --lines=1 \
            | "${app[cut]}" --delimiter='"' --fields='2' \
    )"
    [[ -n "${dict[str]}" ]] || return 1
    koopa::print "${dict[str]}"
    return 0
}
