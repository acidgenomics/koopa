#!/usr/bin/env bash

koopa::fedora_set_locale() { # {{{1
    # """
    # Set locale to English US UTF-8.
    # @note Updated 2021-11-16.
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [locale]="$(koopa::locate_locale)"
        [localedef]="$(koopa::locate_localedef)"
        [sudo]="$(koopa::locate_sudo)"
    )
    declare -A dict=(
        [lang]='en'
        [country]='US'
        [charset]='UTF-8'
        [lang_string]="${dict[lang]}_${dict[country]}.${dict[charset]}"
    )
    koopa::alert "Setting locale to '${dict[lang_string]}'."
    "${app[sudo]}" "${app[localedef]}" \
        -i "${dict[lang]}_${dict[country]}" \
        -f "${dict[charset]}" \
        "${dict[lang_string]}"
    "${app[locale]}"
    koopa::alert_success "Locale is defined as '${dict[lang_string]}'."
    return 0
}
