#!/usr/bin/env bash

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
