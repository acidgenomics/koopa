#!/usr/bin/env bash

koopa_macos_os_codename() {
    # """
    # macOS OS codename (marketing name).
    # @note Updated 2024-11-04.
    #
    # @seealso
    # - https://apple.stackexchange.com/questions/333452/
    # - https://unix.stackexchange.com/questions/234104/
    # """
    local -A dict
    dict['version']="$(koopa_macos_os_version)"
    case "${dict['version']}" in
        '15.'*)
            dict['string']='Sequoia'
            ;;
        '14.'*)
            dict['string']='Sonoma'
            ;;
        '13.'*)
            dict['string']='Ventura'
            ;;
        '12.'*)
            dict['string']='Monterey'
            ;;
        '11.'*)
            dict['string']='Big Sur'
            ;;
        '10.15.'*)
            dict['string']='Catalina'
            ;;
        '10.14.'*)
            dict['string']='Mojave'
            ;;
        '10.13.'*)
            dict['string']='High Sierra'
            ;;
        '10.12.'*)
            dict['string']='Sierra'
            ;;
        '10.11.'*)
            dict['string']='El Capitan'
            ;;
        '10.10.'*)
            dict['string']='Yosmite'
            ;;
        '10.9.'*)
            dict['string']='Mavericks'
            ;;
        '10.8.'*)
            dict['string']='Mountain Lion'
            ;;
        '10.7.'*)
            dict['string']='Lion'
            ;;
        '10.6.'*)
            dict['string']='Snow Leopard'
            ;;
        '10.5.'*)
            dict['string']='Leopard'
            ;;
        '10.4.'*)
            dict['string']='Tiger'
            ;;
        '10.3.'*)
            dict['string']='Panther'
            ;;
        '10.2.'*)
            dict['string']='Jaguar'
            ;;
        '10.1.'*)
            dict['string']='Puma'
            ;;
        '10.0.'*)
            dict['string']='Cheetah'
            ;;
        *)
            return 1
            ;;
    esac
    [[ -n "${dict['string']}" ]] || return 1
    koopa_print "${dict['string']}"
    return 0
}
