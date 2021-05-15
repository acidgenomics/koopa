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

koopa::date() { # {{{1
    # """
    # Koopa date.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    koopa::variable 'koopa-date'
    return 0
}

koopa::datetime() { # {{{
    # """
    # Datetime string.
    # @note Updated 2020-07-04.
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed date
    local x
    x="$(date '+%Y%m%d-%H%M%S')"
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

koopa::github_url() { # {{{1
    # """
    # Koopa GitHub URL.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    koopa::variable 'koopa-github-url'
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

koopa::local_ip_address() { # {{{1
    # """
    # Local IP address.
    # @note Updated 2020-07-05.
    #
    # Some systems (e.g. macOS) will return multiple IP address matches for
    # Ethernet and WiFi. Here we're simplying returning the first match, which
    # corresponds to the default on macOS.
    # """
    koopa::assert_has_no_args "$#"
    local x
    if koopa::is_macos
    then
        x="$( \
            ifconfig \
            | grep 'inet ' \
            | grep 'broadcast' \
            | awk '{print $2}' \
            | tail -n 1
        )"
    else
        x="$( \
            hostname -I \
            | awk '{print $1}' \
            | head -n 1
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
    # @note Updated 2021-01-01.
    # """
    local x
    x="$(uname -s | tr '[:upper:]' '[:lower:]')"
    koopa::print "$x"
    return 0
}

koopa::public_ip_address() { # {{{1
    # """
    # Public (remote) IP address.
    # @note Updated 2020-07-05.
    #
    # @seealso
    # https://www.cyberciti.biz/faq/
    #     how-to-find-my-public-ip-address-from-command-line-on-a-linux/
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed curl dig
    local x
    x="$(dig +short myip.opendns.com @resolver1.opendns.com)"
    # Fallback in case dig approach doesn't work.
    if [[ -z "$x" ]]
    then
        koopa::assert_is_installed curl
        x="$(curl -s ipecho.net/plain)"
    fi
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::script_name() { # {{{1
    # """
    # Get the calling script name.
    # @note Updated 2020-06-29.
    #
    # Note that we're using 'caller' approach, which is Bash-specific.
    # """
    koopa::assert_has_no_args "$#"
    local file x
    file="$( \
        caller \
        | head -n 1 \
        | cut -d ' ' -f 2 \
    )"
    x="$(koopa::basename "$file")"
    [[ -n "$x" ]] || return 0
    koopa::print "$x"
    return 0
}
