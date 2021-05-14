#!/usr/bin/env bash

koopa::fedora_set_locale() { # {{{1
    # """
    # Set locale to English US UTF-8.
    # @note Updated 2021-03-25.
    # """
    local charset country lang lang_string
    koopa::assert_is_admin
    koopa::assert_is_installed locale localedef
    lang='en'
    country='US'
    charset='UTF-8'
    lang_string="${lang}_${country}.${charset}"
    koopa::alert "Setting locale to '${lang_string}'."
    sudo localedef \
        -i "${lang}_${country}" \
        -f "$charset" \
        "$lang_string"
    locale
    koopa::alert_success "Locale is defined as '${lang_string}'."
    return 0
}
