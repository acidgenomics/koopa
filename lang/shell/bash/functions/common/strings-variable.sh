#!/usr/bin/env bash

koopa::admin_group() { # {{{1
    # """
    # Return the administrator group.
    # @note Updated 2021-03-18.
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
    elif koopa::is_alpine
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
        koopa::stop 'Failed to detect admin group.'
    fi
    koopa::print "$group"
    return 0
}

koopa::compress_ext_pattern() { # {{{1
    # """
    # Compressed file extension pattern.
    # @note Updated 2022-01-11.
    # """
    koopa::print '\.(bz2|gz|xz|zip)$'
    return 0
}

koopa::datetime() { # {{{
    # """
    # Datetime string.
    # @note Updated 2021-05-21.
    local date x
    koopa::assert_has_no_args "$#"
    date="$(koopa::locate_date)"
    x="$("$date" '+%Y%m%d-%H%M%S')"
    [[ -n "$x" ]] || return 1
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
    # @note Updated 2020-07-14.
    # """
    type='public'
    while (("$#"))
    do
        case "$1" in
            '--local')
                type='local'
                shift 1
                ;;
            '--public')
                type='public'
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    case "$type" in
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

# FIXME Need to locate ifconfig and hostname here.
koopa::local_ip_address() { # {{{1
    # """
    # Local IP address.
    # @note Updated 2021-10-27.
    #
    # Some systems (e.g. macOS) will return multiple IP address matches for
    # Ethernet and WiFi. Here we're simplying returning the first match, which
    # corresponds to the default on macOS.
    # """
    local app x
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [awk]="$(koopa::locate_awk)"
        [head]="$(koopa::locate_head)"
        [tail]="$(koopa::locate_tail)"
    )
    if koopa::is_macos
    then
        koopa::assert_is_installed 'ifconfig'
        # shellcheck disable=SC2016
        x="$( \
            ifconfig \
            | koopa::grep 'inet ' \
            | koopa::grep 'broadcast' \
            | "${app[awk]}" '{print $2}' \
            | "${app[tail]}" -n 1
        )"
    else
        koopa::assert_is_installed 'hostname'
        # shellcheck disable=SC2016
        x="$( \
            hostname -I \
            | "${app[awk]}" '{print $1}' \
            | "${app[head]}" -n 1
        )"
    fi
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::make_build_string() { # {{{1
    # """
    # OS build string for 'make' configuration.
    # @note Updated 2021-01-01.
    #
    # Use this for 'configure --build' flag.
    #
    # - macOS: x86_64-darwin15.6.0
    # - Linux: x86_64-linux-gnu
    # """
    koopa::assert_has_no_args "$#"
    local arch os_type string
    arch="$(koopa::arch)"
    if koopa::is_linux
    then
        os_type='linux-gnu'
    else
        os_type="$(koopa::os_type)"
    fi
    string="${arch}-${os_type}"
    koopa::print "$string"
    return 0
}

koopa::os_type() { # {{{1
    # """
    # Operating system type.
    # @note Updated 2021-10-27.
    # """
    local app x
    declare -A app=(
        [tr]="$(koopa::locate_tr)"
        [uname]="$(koopa::locate_uname)"
    )
    x="$( \
        "${app[uname]}" -s \
        | "${app[tr]}" '[:upper:]' '[:lower:]' \
    )"
    koopa::print "$x"
    return 0
}

koopa::public_ip_address() { # {{{1
    # """
    # Public (remote) IP address.
    # @note Updated 2021-10-25.
    #
    # @seealso
    # - https://www.cyberciti.biz/faq/
    #     how-to-find-my-public-ip-address-from-command-line-on-a-linux/
    # """
    local dig x
    koopa::assert_has_no_args "$#"
    x=''
    # Attempt to use BIND's Domain Information Groper (dig) tool.
    dig="$(koopa::locate_dig 2>/dev/null || true)"
    if koopa::is_installed "$dig"
    then
        x="$("$dig" +short 'myip.opendns.com' '@resolver1.opendns.com')"
    fi
    # Otherwise fall back to parsing URL via cURL.
    if [[ -z "$x" ]]
    then
        x="$(koopa::parse_url 'https://ipecho.net/plain')"
    fi
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::script_name() { # {{{1
    # """
    # Get the calling script name.
    # @note Updated 2021-10-27.
    #
    # Note that we're using 'caller' approach, which is Bash-specific.
    # """
    local app file x
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [cut]="$(koopa::locate_cut)"
        [head]="$(koopa::locate_head)"
    )
    file="$( \
        caller \
        | "${app[head]}" -n 1 \
        | "${app[cut]}" -d ' ' -f 2 \
    )"
    x="$(koopa::basename "$file")"
    [[ -n "$x" ]] || return 0
    koopa::print "$x"
    return 0
}

koopa::variable() { # {{{1
    # """
    # Return a variable stored 'variables.txt' include file.
    # @note Updated 2021-10-27.
    #
    # This approach handles inline comments.
    # """
    local app file include_prefix key value
    declare -A app=(
        [cut]="$(koopa::locate_cut)"
        [head]="$(koopa::locate_head)"
    )
    key="${1:?}"
    include_prefix="$(koopa::include_prefix)"
    file="${include_prefix}/variables.txt"
    koopa::assert_is_file "$file"
    value="$( \
        koopa::grep \
            --extended-regexp \
            --only-matching \
            "^${key}=\"[^\"]+\"" \
            "$file" \
        || koopa::stop "'${key}' not defined in '${file}'." \
    )"
    value="$( \
        koopa::print "$value" \
            | "${app[head]}" -n 1 \
            | "${app[cut]}" -d '"' -f 2 \
    )"
    [[ -n "$value" ]] || return 1
    koopa::print "$value"
    return 0
}
