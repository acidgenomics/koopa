#!/usr/bin/env bash

koopa_fedora_set_locale() {
    # """
    # Set locale to English US UTF-8.
    # @note Updated 2023-05-01.
    # """
    local -A app dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    app['locale']="$(koopa_locate_locale)"
    app['localedef']="$(koopa_locate_localedef)"
    koopa_assert_is_executable "${app[@]}"
    dict['lang']='en'
    dict['country']='US'
    dict['charset']='UTF-8'
    dict['lang_string']="${dict['lang']}_${dict['country']}.${dict['charset']}"
    koopa_alert "Setting locale to '${dict['lang_string']}'."
    koopa_sudo \
        "${app['localedef']}" \
            -i "${dict['lang']}_${dict['country']}" \
            -f "${dict['charset']}" \
            "${dict['lang_string']}"
    "${app['locale']}"
    koopa_alert_success "Locale is defined as '${dict['lang_string']}'."
    return 0
}
