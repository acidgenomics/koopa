#!/usr/bin/env bash

main() {
    # """
    # Install Oxford Nanopore guppy caller.
    # @note Updated 2023-06-12.
    # """
    local -A app dict
    if koopa_is_macos
    then
        koopa_assert_is_not_arm64
    fi
    app['aws']="$(koopa_locate_aws --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['arch']="$(koopa_arch2)" # e.g. 'amd64'.
    dict['core_type']='cpu' # or 'gpu'.
    dict['installers_base']="$(koopa_private_installers_s3_uri)"
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
    dict['url']="${dict['installers_base']}/ont-guppy/${dict['platform']}/\
${dict['arch']}/${dict['version']}-${dict['core_type']}.${dict['ext']}"
    "${app['aws']}" --profile='acidgenomics' \
        s3 cp \
            "${dict['url']}" \
            "$(koopa_basename "${dict['url']}")"
    koopa_extract \
        "$(koopa_basename "${dict['url']}")" \
        "${dict['prefix']}"
    return 0
}
