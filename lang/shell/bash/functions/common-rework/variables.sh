#!/usr/bin/env bash

koopa_admin_group() {
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
    koopa_assert_has_no_args "$#"
    if koopa_is_alpine
    then
        group='wheel'
    elif koopa_is_arch
    then
        group='wheel'
    elif koopa_is_debian_like
    then
        group='sudo'
    elif koopa_is_fedora_like
    then
        group='wheel'
    elif koopa_is_macos
    then
        group='admin'
    elif koopa_is_opensuse
    then
        group='wheel'
    else
        koopa_stop 'Failed to determine admin group.'
    fi
    koopa_print "$group"
    return 0
}

koopa_arch2() {
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
    koopa_assert_has_no_args "$#"
    case "$(koopa_arch)" in
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
    koopa_print "$str"
    return 0
}

koopa_compress_ext_pattern() {
    # """
    # Compressed file extension pattern.
    # @note Updated 2022-01-11.
    # """
    koopa_assert_has_no_args "$#"
    koopa_print '\.(bz2|gz|xz|zip)$'
    return 0
}

koopa_cpu_count() {
    # """
    # Return a usable number of CPU cores.
    # @note Updated 2022-04-06.
    # """
    local app num
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [nproc]="$(koopa_locate_nproc --allow-missing)"
    )
    if koopa_is_installed "${app[nproc]}"
    then
        num="$("${app[nproc]}")"
    elif koopa_is_macos
    then
        app[sysctl]="$(koopa_macos_locate_sysctl)"
        num="$("${app[sysctl]}" -n 'hw.ncpu')"
    elif koopa_is_linux
    then
        app[getconf]="$(koopa_linux_locate_getconf)"
        num="$("${app[getconf]}" '_NPROCESSORS_ONLN')"
    else
        num=1
    fi
    koopa_print "$num"
    return 0
}

koopa_datetime() { # {{{
    # """
    # Datetime string.
    # @note Updated 2022-01-20.
    # """
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [date]="$(koopa_locate_date)"
    )
    str="$("${app[date]}" '+%Y%m%d-%H%M%S')"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_dotfiles_config_link() {
    # """
    # Dotfiles directory.
    # @note Updated 2019-11-04.
    #
    # Note that we're not checking for existence here, which is handled inside
    # 'link-dotfile' script automatically instead.
    # """
    koopa_assert_has_no_args "$#"
    koopa_print "$(koopa_config_prefix)/dotfiles"
    return 0
}

koopa_gcrypt_url() {
    # """
    # Get GnuPG FTP URL.
    # @note Updated 2021-04-27.
    # """
    koopa_assert_has_no_args "$#"
    koopa_variable 'gcrypt-url'
    return 0
}

koopa_gnu_mirror_url() {
    # """
    # Get GNU FTP mirror URL.
    # @note Updated 2020-04-16.
    # """
    koopa_assert_has_no_args "$#"
    koopa_variable 'gnu-mirror-url'
    return 0
}

koopa_ip_address() {
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
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    case "${dict[type]}" in
        'local')
            koopa_local_ip_address
            ;;
        'public')
            koopa_public_ip_address
            ;;
    esac
    return 0
}

koopa_koopa_date() {
    # """
    # Koopa date.
    # @note Updated 2021-06-07.
    # """
    koopa_assert_has_no_args "$#"
    koopa_variable 'koopa-date'
    return 0
}

koopa_koopa_github_url() {
    # """
    # Koopa GitHub URL.
    # @note Updated 2021-06-07.
    # """
    koopa_assert_has_no_args "$#"
    koopa_variable 'koopa-github-url'
    return 0
}

# FIXME Return the platform and architecture here automatically.
# FIXME Also consider adding support for easy return of S3 bucket path.

koopa_koopa_app_binary_url() { # {{{2
    # """
    # Koopa app binary URL.
    # @note Updated 2022-04-08.
    # """
    koopa_assert_has_no_args "$#"
    koopa_print "$(koopa_koopa_url)/app"
}

koopa_koopa_installers_url() {
    # """
    # Koopa installers URL.
    # @note Updated 2022-01-06.
    # """
    koopa_assert_has_no_args "$#"
    koopa_print "$(koopa_koopa_url)/installers"
}

koopa_koopa_url() {
    # """
    # Koopa URL.
    # @note Updated 2021-06-07.
    # """
    koopa_assert_has_no_args "$#"
    koopa_variable 'koopa-url'
    return 0
}

koopa_local_ip_address() {
    # """
    # Local IP address.
    # @note Updated 2022-02-09.
    #
    # Some systems (e.g. macOS) will return multiple IP address matches for
    # Ethernet and WiFi. Here we're simplying returning the first match, which
    # corresponds to the default on macOS.
    # """
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [awk]="$(koopa_locate_awk)"
        [head]="$(koopa_locate_head)"
        [tail]="$(koopa_locate_tail)"
    )
    if koopa_is_macos
    then
        app[ifconfig]="$(koopa_macos_locate_ifconfig)"
        # shellcheck disable=SC2016
        str="$( \
            "${app[ifconfig]}" \
            | koopa_grep --pattern='inet ' \
            | koopa_grep --pattern='broadcast' \
            | "${app[awk]}" '{print $2}' \
            | "${app[tail]}" -n 1 \
        )"
    else
        app[hostname]="$(koopa_locate_hostname)"
        # shellcheck disable=SC2016
        str="$( \
            "${app[hostname]}" -I \
            | "${app[awk]}" '{print $1}' \
            | "${app[head]}" -n 1 \
        )"
    fi
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_make_build_string() {
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
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [arch]="$(koopa_arch)"
    )
    if koopa_is_linux
    then
        dict[os_type]='linux-gnu'
    else
        dict[os_type]="$(koopa_os_type)"
    fi
    koopa_print "${dict[arch]}-${dict[os_type]}"
    return 0
}

koopa_mem_gb() {
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
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [awk]='awk'
    )
    declare -A dict
    if koopa_is_macos
    then
        app[sysctl]="$(koopa_macos_locate_sysctl)"
        dict[mem]="$("${app[sysctl]}" -n 'hw.memsize')"
        dict[denom]=1073741824  # 1024^3; bytes
    elif koopa_is_linux
    then
        dict[meminfo]='/proc/meminfo'
        koopa_assert_is_file "${dict[meminfo]}"
        # shellcheck disable=SC2016
        dict[mem]="$("${app[awk]}" '/MemTotal/ {print $2}' "${dict[meminfo]}")"
        dict[denom]=1048576  # 1024^2; KB
    else
        koopa_stop 'Unsupported system.'
    fi
    dict[str]="$( \
        "${app[awk]}" \
            -v denom="${dict[denom]}" \
            -v mem="${dict[mem]}" \
            'BEGIN{ printf "%.0f\n", mem / denom }' \
    )"
    [[ -n "${dict[str]}" ]] || return 1
    koopa_print "${dict[str]}"
    return 0
}

koopa_os_type() {
    # """
    # Operating system type.
    # @note Updated 2022-02-09.
    # """
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [tr]="$(koopa_locate_tr)"
        [uname]="$(koopa_locate_uname)"
    )
    str="$( \
        "${app[uname]}" -s \
        | "${app[tr]}" '[:upper:]' '[:lower:]' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_public_ip_address() {
    # """
    # Public (remote) IP address.
    # @note Updated 2022-04-06.
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
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [dig]="$(koopa_locate_dig --allow-missing)"
    )
    if koopa_is_installed "${app[dig]}"
    then
        str="$( \
            "${app[dig]}" +short \
                'myip.opendns.com' \
                '@resolver1.opendns.com' \
                -4 \
        )"
    else
        # Otherwise fall back to parsing URL via cURL.
        str="$(koopa_parse_url 'https://ipecho.net/plain')"
    fi
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_script_name() {
    # """
    # Get the calling script name.
    # @note Updated 2022-02-09.
    #
    # Note that we're using 'caller' approach, which is Bash-specific.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [head]="$(koopa_locate_head)"
    )
    declare -A dict
    dict[file]="$( \
        caller \
        | "${app[head]}" -n 1 \
        | "${app[cut]}" -d ' ' -f '2' \
    )"
    dict[bn]="$(koopa_basename "${dict[file]}")"
    [[ -n "${dict[bn]}" ]] || return 0
    koopa_print "${dict[bn]}"
    return 0
}

koopa_variable() {
    # """
    # Return a variable stored 'variables.txt' include file.
    # @note Updated 2022-03-09.
    #
    # This approach handles inline comments.
    # """
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [head]="$(koopa_locate_head)"
    )
    declare -A dict=(
        [key]="${1:?}"
        [include_prefix]="$(koopa_include_prefix)"
    )
    dict[file]="${dict[include_prefix]}/variables.txt"
    koopa_assert_is_file "${dict[file]}"
    dict[str]="$( \
        koopa_grep \
            --file="${dict[file]}" \
            --only-matching \
            --pattern="^${dict[key]}=\"[^\"]+\"" \
            --regex \
    )"
    [[ -n "${dict[str]}" ]] || return 1
    dict[str]="$( \
        koopa_print "${dict[str]}" \
            | "${app[head]}" -n 1 \
            | "${app[cut]}" -d '"' -f '2' \
    )"
    [[ -n "${dict[str]}" ]] || return 1
    koopa_print "${dict[str]}"
    return 0
}
