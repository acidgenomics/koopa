#!/usr/bin/env bash

# FIXME Need to rethink this for Debian 11, not working correctly.
# FIXME Appears that '/etc/locale.gen' isn't getting modified correctly.
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
    local charset charset2 country lang lang_string file string
    koopa::assert_is_admin
    koopa::assert_is_installed \
        'grep' \
        'locale' \
        '/usr/sbin/locale-gen' \
        '/usr/sbin/update-locale'
    # Consider allowing the user to change these in a future release.
    lang='en'
    country='US'
    charset='UTF-8'
    # Inform the user about the locale that will be set.
    # e.g. 'en_US.UTF-8'.
    lang_string="${lang}_${country}.${charset}"
    koopa::alert "Setting locale to '${lang_string}'."
    # e.g. 'en_US.UTF-8 UTF-8'.
    string="${lang_string} ${charset}"
    file='/etc/locale.gen'
    koopa::assert_is_file "$file"
    koopa::sudo_append_string "$string" "$file"
    # e.g. convert 'UTF-8' to 'utf8'.
    charset2="$(koopa::lowercase "$charset")"
    charset2="$(koopa::gsub '-' '' "$charset2")"
    # e.g. 'en_US.utf8'.
    string="${lang}_${country}.${charset2}"
    sudo /usr/sbin/locale-gen "$string"
    # e.g. 'en_US.UTF-8'.
    string="${lang}_${country}.${charset}"
    sudo /usr/sbin/update-locale LANG="$string"
    locale
    koopa::alert_success "Locale is defined as '${lang_string}'."
    return 0
}
