#!/usr/bin/env bash

_koopa_debian_set_locale() {
    # """
    # Set locale to English US UTF-8.
    # @note Updated 2023-05-01.
    #
    # Refer to '/usr/share/i18n/SUPPORTED' for supported locales.
    #
    # NOTE Don't set 'LC_ALL' here, it overrides everything, and is explicitly
    # discouraged in the official Debian documentation.
    #
    # @seealso
    # - https://wiki.debian.org/Locale
    # """
    local -A app dict
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_admin
    app['dpkg_reconfigure']="$(_koopa_debian_locate_dpkg_reconfigure)"
    app['locale']="$(_koopa_locate_locale)"
    app['locale_gen']="$(_koopa_debian_locate_locale_gen)"
    app['update_locale']="$(_koopa_debian_locate_update_locale)"
    _koopa_assert_is_executable "${app[@]}"
    dict['charset']='UTF-8'
    dict['country']='US'
    dict['lang']='en'
    dict['locale_file']='/etc/locale.gen'
    dict['lang_string']="${dict['lang']}_${dict['country']}.${dict['charset']}"
    _koopa_alert "Setting locale to '${dict['lang_string']}'."
    _koopa_sudo_write_string \
        --file="${dict['locale_file']}" \
        --string="${dict['lang_string']} ${dict['charset']}"
    _koopa_sudo "${app['locale_gen']}" --purge
    _koopa_sudo "${app['dpkg_reconfigure']}" \
        --frontend='noninteractive' \
        'locales'
    _koopa_sudo "${app['update_locale']}" LANG="${dict['lang_string']}"
    "${app['locale']}" -a
    return 0
}
