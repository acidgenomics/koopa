#!/usr/bin/env bash

main() {
    # """
    # Install Oxford Nanopore guppy caller.
    # @note Updated 2023-04-06.
    # """
    local -A app dict
    koopa_assert_has_no_args "$#"
    if koopa_is_macos
    then
        koopa_assert_is_not_aarch64
    fi
    app['aws']="$(koopa_locate_aws --allow-system)"
    [[ -x "${app['aws']}" ]] || exit 1
    dict['arch']="$(koopa_arch2)" # e.g. 'amd64'.
    dict['core_type']='cpu' # or 'gpu'.
    dict['installers_base']="$(koopa_private_installers_s3_uri)"
    dict['name']='ont-guppy'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['libexec']="$(koopa_init_dir "${dict['prefix']}/libexec")"
    if koopa_is_macos
    then
        dict['platform']='macos'
        dict['ext']='zip'
    else
        dict['platform']='linux'
        dict['ext']='tar.gz'
    fi
    dict['file']="${dict['version']}-${dict['core_type']}.${dict['ext']}"
    dict['url']="${dict['installers_base']}/${dict['name']}/\
${dict['platform']}/${dict['arch']}/${dict['file']}"
    "${app['aws']}" --profile='acidgenomics' \
        s3 cp "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['core_type']}"
    koopa_cp ./* --target-directory="${dict['prefix']}"
    return 0
}
