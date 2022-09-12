#!/usr/bin/env bash

main() {
    # """
    # Install aspell.
    # @note Updated 2022-07-15.
    #
    # @seealso
    # - http://aspell.net/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/aspell.rb
    # - https://tylercipriani.com/blog/2017/08/14/offline-spelling-with-aspell/
    # """
    local dict key lang
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['lang_base_url']='https://ftp.gnu.org/gnu/aspell/dict'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    )
    koopa_install_app_subshell \
        --installer='gnu-app' \
        --name='aspell'
    app['aspell']="${dict['prefix']}/bin/aspell"
    app['prezip']="${dict['prefix']}/bin/prezip"
    koopa_assert_is_installed "${app['aspell']}" "${app['prezip']}"
    koopa_add_to_path_start "${dict['prefix']}/bin"
    declare -A lang=(
        ['de']='aspell6-de-20161207-7-0'
        ['en']='aspell6-en-2020.12.07-0'
        ['es']='aspell6-es-1.11-2'
        ['fr']='aspell-fr-0.50-3'
    )
    koopa_print_env
    for key in "${!lang[@]}"
    do
        local conf_args dict2
        declare -A dict2
        dict2['bn']="${lang[$key]}"
        dict2['file']="${dict2['bn']}.tar.bz2"
        dict2['url']="${dict['lang_base_url']}/${key}/${dict2['file']}"
        koopa_download "${dict2['url']}" "${dict2['file']}"
        koopa_extract "${dict2['file']}"
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
