#!/usr/bin/env bash

# FIXME s3://private.koopa.acidgenomics.com/installers/ont-guppy/linux/amd64/6.4.2-cpu.tar.gz
# FIXME s3://private.koopa.acidgenomics.com/installers/ont-guppy/macos/amd64/6.4.2-cpu.zip

main() {
    # """
    # Install Oxford Nanopore guppy caller.
    # @note Updated 2023-03-14.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_assert_has_private_access
    declare -A app
    app['aws']="$(koopa_locate_aws)"
    [[ -x "${app['aws']}" ]] || return 1
    declare -A dict=(
        ['arch']="$(koopa_arch2)" # e.g. 'amd64'.
        ['core_type']='cpu' # or 'gpu'.
        ['installers_base']="$(koopa_private_installers_s3_uri)"
        ['name']='ont-guppy'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
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
