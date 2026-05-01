#!/usr/bin/env bash

_koopa_fedora_set_locale() {
    # """
    # Set locale to English US UTF-8.
    # @note Updated 2023-05-01.
    # """
    local -A app dict
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_admin
    app['locale']="$(_koopa_locate_locale)"
    app['localedef']="$(_koopa_locate_localedef)"
    _koopa_assert_is_executable "${app[@]}"
    dict['lang']='en'
    dict['country']='US'
    dict['charset']='UTF-8'
    dict['lang_string']="${dict['lang']}_${dict['country']}.${dict['charset']}"
    _koopa_alert "Setting locale to '${dict['lang_string']}'."
    _koopa_sudo \
        "${app['localedef']}" \
            -i "${dict['lang']}_${dict['country']}" \
            -f "${dict['charset']}" \
            "${dict['lang_string']}"
    "${app['locale']}"
    _koopa_alert_success "Locale is defined as '${dict['lang_string']}'."
    return 0
}
