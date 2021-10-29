#!/usr/bin/env bash

# FIXME Need to locate sudo and other Debian tools here.

koopa::debian_set_locale() { # {{{1
    # """
    # Set locale to English US UTF-8.
    # @note Updated 2021-09-21.
    #
    # Refer to '/usr/share/i18n/SUPPORTED' for supported locales.
    #
    # NOTE Don't set 'LC_ALL' here, it overrides everything, and is explicitly
    # discouraged in the official Debian documentation.
    #
    # @seealso
    # - https://wiki.debian.org/Locale
    # """
    local charset country lang lang_string file
    koopa::add_to_path_start '/usr/sbin'
    koopa::assert_is_installed \
        'dpkg-reconfigure' \
        'locale' \
        'locale-gen' \
        'update-locale' 
    lang='en'
    country='US'
    charset='UTF-8'
    lang_string="${lang}_${country}.${charset}"
    koopa::alert "Setting locale to '${lang_string}'."
    file='/etc/locale.gen'
    koopa::sudo_write_string "${lang_string} ${charset}" "$file"
    sudo locale-gen --purge
    sudo dpkg-reconfigure --frontend='noninteractive' locales
    sudo update-locale LANG="$lang_string"
    locale -a
    koopa::alert_success "Locale is defined as '${lang_string}'."
    return 0
}
