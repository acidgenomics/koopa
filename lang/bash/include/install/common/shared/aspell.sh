#!/usr/bin/env bash

main() {
    # """
    # Install aspell.
    # @note Updated 2023-08-29.
    #
    # @seealso
    # - http://aspell.net/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/aspell.rb
    # - https://tylercipriani.com/blog/2017/08/14/offline-spelling-with-aspell/
    # """
    local -A app dict lang
    local key
    koopa_activate_app --build-only 'make'
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['lang_base_url']='https://ftp.gnu.org/gnu/aspell/dict'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    koopa_install_gnu_app
    app['aspell']="${dict['prefix']}/bin/aspell"
    app['prezip']="${dict['prefix']}/bin/prezip"
    koopa_assert_is_executable "${app['aspell']}" "${app['prezip']}"
    koopa_add_to_path_start "${dict['prefix']}/bin"
    lang['de']='aspell6-de-20161207-7-0'
    lang['en']='aspell6-en-2020.12.07-0'
    lang['es']='aspell6-es-1.11-2'
    lang['fr']='aspell-fr-0.50-3'
    koopa_print_env
    for key in "${!lang[@]}"
    do
        local -A dict2
        local -a conf_args
        dict2['bn']="${lang[$key]}"
        dict2['url']="${dict['lang_base_url']}/${key}/${dict2['bn']}.tar.bz2"
        koopa_download "${dict2['url']}"
        koopa_extract "$(koopa_basename "${dict2['url']}")" "${dict2['bn']}"
        koopa_cd "${dict2['bn']}"
        # Useful vars: ASPELL ASPELL_PARMS PREZIP DESTDIR.
        conf_args=(
            '--vars'
            "ASPELL=${app['aspell']}"
            "PREZIP=${app['prezip']}"
        )
        koopa_dl 'configure args' "${conf_args[*]}"
        ./configure --help
        ./configure "${conf_args[@]}"
        "${app['make']}" VERBOSE=1 install
    done
    "${app['aspell']}" dump dicts
    return 0
}
