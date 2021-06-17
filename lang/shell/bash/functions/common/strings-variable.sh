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

koopa::dotfiles_private_config_link() { # {{{1
    # """
    # Private dotfiles directory.
    # @note Updated 2019-11-04.
    # """
    koopa::assert_has_no_args "$#"
    koopa::print "$(koopa::dotfiles_config_link)-private"
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
            --local)
                type='local'
                shift 1
                ;;
            --public)
                type='public'
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    case "$type" in
        local)
            koopa::local_ip_address
            ;;
        public)
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
    # @note Updated 2021-05-21.
    #
    # Some systems (e.g. macOS) will return multiple IP address matches for
    # Ethernet and WiFi. Here we're simplying returning the first match, which
    # corresponds to the default on macOS.
    # """
    local awk grep head tail x
    koopa::assert_has_no_args "$#"
    awk="$(koopa::locate_awk)"
    grep="$(koopa::locate_grep)"
    head="$(koopa::locate_head)"
    tail="$(koopa::locate_tail)"
    if koopa::is_macos
    then
        koopa::assert_is_installed 'ifconfig'
        # shellcheck disable=SC2016
        x="$( \
            ifconfig \
            | "$grep" 'inet ' \
            | "$grep" 'broadcast' \
            | "$awk" '{print $2}' \
            | "$tail" -n 1
        )"
    else
        koopa::assert_is_installed 'hostname'
        # shellcheck disable=SC2016
        x="$( \
            hostname -I \
            | "$awk" '{print $1}' \
            | "$head" -n 1
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
    # @note Updated 2021-05-21.
    # """
    local tr uname x
    tr="$(koopa::locate_tr)"
    uname="$(koopa::locate_uname)"
    x="$( \
        "$uname" -s \
        | "$tr" '[:upper:]' '[:lower:]' \
    )"
    koopa::print "$x"
    return 0
}

koopa::public_ip_address() { # {{{1
    # """
    # Public (remote) IP address.
    # @note Updated 2021-05-21.
    #
    # @seealso
    # - https://www.cyberciti.biz/faq/
    #     how-to-find-my-public-ip-address-from-command-line-on-a-linux/
    # """
    local curl x
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed 'dig'
    x="$(dig +short 'myip.opendns.com' '@resolver1.opendns.com')"
    # Fallback in case dig approach doesn't work.
    if [[ -z "$x" ]]
    then
        curl="$(koopa::locate_curl)"
        x="$("$curl" -s 'ipecho.net/plain')"
    fi
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::script_name() { # {{{1
    # """
    # Get the calling script name.
    # @note Updated 2021-05-21.
    #
    # Note that we're using 'caller' approach, which is Bash-specific.
    # """
    local cut file head x
    koopa::assert_has_no_args "$#"
    cut="$(koopa::locate_cut)"
    head="$(koopa::locate_head)"
    file="$( \
        caller \
        | "$head" -n 1 \
        | "$cut" -d ' ' -f 2 \
    )"
    x="$(koopa::basename "$file")"
    [[ -n "$x" ]] || return 0
    koopa::print "$x"
    return 0
}

koopa::variable() { # {{{1
    # """
    # Return a variable stored 'variables.txt' include file.
    # @note Updated 2021-05-25.
    #
    # This approach handles inline comments.
    # """
    local cut file grep head include_prefix key value
    cut="$(koopa::locate_cut)"
    grep="$(koopa::locate_grep)"
    head="$(koopa::locate_head)"
    key="${1:?}"
    include_prefix="$(koopa::include_prefix)"
    file="${include_prefix}/variables.txt"
    koopa::assert_is_file "$file"
    value="$( \
        "$grep" -Eo "^${key}=\"[^\"]+\"" "$file" \
        || koopa::stop "'${key}' not defined in '${file}'." \
    )"
    value="$( \
        koopa::print "$value" \
            | "$head" -n 1 \
            | "$cut" -d '"' -f 2 \
    )"
    [[ -n "$value" ]] || return 1
    koopa::print "$value"
    return 0
}
