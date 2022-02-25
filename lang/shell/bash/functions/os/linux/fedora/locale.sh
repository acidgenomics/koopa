#!/usr/bin/env bash

koopa_fedora_set_locale() { # {{{1
    # """
    # Set locale to English US UTF-8.
    # @note Updated 2022-01-28.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [locale]="$(koopa_locate_locale)"
        [localedef]="$(koopa_locate_localedef)"
        [sudo]="$(koopa_locate_sudo)"
    )
    declare -A dict=(
        [lang]='en'
        [country]='US'
        [charset]='UTF-8'
    )
    dict[lang_string]="${dict[lang]}_${dict[country]}.${dict[charset]}"
    koopa_alert "Setting locale to '${dict[lang_string]}'."
    "${app[sudo]}" "${app[localedef]}" \
        -i "${dict[lang]}_${dict[country]}" \
        -f "${dict[charset]}" \
        "${dict[lang_string]}"
    "${app[locale]}"
    koopa_alert_success "Locale is defined as '${dict[lang_string]}'."
    return 0
}
