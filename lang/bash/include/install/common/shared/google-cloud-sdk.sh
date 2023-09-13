#!/usr/bin/env bash

main() {
    # """
    # Install Google Cloud SDK.
    # @note Updated 2023-09-13.
    #
    # @seealso
    # - https://cloud.google.com/sdk/docs/install
    # - https://cloud.google.com/sdk/docs/downloads-interactive
    # - https://formulae.brew.sh/cask/google-cloud-sdk
    # - https://saturncloud.io/blog/how-to-resolve-modulenotfounderror-no-
    #     module-named-googlecloud-error/
    # """
    local -A app dict
    local -a conf_args
    app['python']="$(koopa_locate_python311)"
    koopa_assert_is_executable "${app[@]}"
    dict['arch']="$(koopa_arch)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    if koopa_is_linux
    then
        dict['os']='linux'
    elif koopa_is_macos
    then
        dict['os']='darwin'
    fi
    case "${dict['arch']}" in
        'aarch64' | 'arm64')
            dict['arch2']='arm'
            ;;
        *)
            dict['arch2']="${dict['arch']}"
            ;;
    esac
    dict['url']="https://dl.google.com/dl/cloudsdk/channels/rapid/\
downloads/google-cloud-cli-${dict['version']}-${dict['os']}-\
${dict['arch2']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract \
        "$(koopa_basename "${dict['url']}")" \
        "${dict['prefix']}"
    app['gcloud']="${dict['prefix']}/bin/gcloud"
    koopa_assert_is_executable "${app['gcloud']}"
    conf_args=(
        "export CLOUDSDK_PYTHON=${app['python']}"
        'export CLOUDSDK_PYTHON_SITEPACKAGES=0'
        "export PYTHONPATH=${dict['prefix']}/lib"
    )
    dict['conf_string']="$(koopa_print "${conf_args[@]}")"
    koopa_insert_at_line_number \
        --file="${app['gcloud']}" \
        --line-number=2 \
        --string="${dict['conf_string']}"
    "${app['gcloud']}" --version
    return 0
}
