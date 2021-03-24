#!/usr/bin/env bash

koopa::debian_set_locale() { # {{{1
    # """
    # Set locale to English US UTF-8.
    # @note Updated 2021-03-24.
    #
    # Refer to '/usr/share/i18n/SUPPORTED' for supported locales.
    # """
    local charset charset2 country lang file string
    koopa::assert_is_installed grep locale-gen update-locale
    # Consider allowing the user to change these in a future release.
    lang='en'
    country='US'
    charset='UTF-8'
    # e.g. 'en_US.UTF-8 UTF-8'.
    string="${lang}_${country}.${charset} ${charset}"
    file='/etc/locale.gen'
    koopa::assert_is_file "$file"
    if ! grep -q "$string" "$file"
    then
        koopa::alert "Adding '${string}' to '${file}'."
        koopa::sudo_append_string "$string" "$file"
    fi
    # e.g. convert 'UTF-8' to 'utf8'.
    charset2="$(koopa::lowercase "$charset")"
    charset2="$(koopa::gsub '-' '' "$charset2")"
    # e.g. 'en_US.utf8'.
    string="${lang}_${country}.${charset2}".
    locale-gen "$string"
    # e.g. 'en_US.UTF-8'.
    string="${lang}_${country}.${charset}"
    update-locale LANG="$string"
    return 0
}
