#!/usr/bin/env bash

# FIXME Now seeing this error:
# ModuleNotFoundError: No module named 'imp'

# Traceback (most recent call last):
#   File "/opt/koopa/app/google-cloud-sdk/446.0.0/libexec/lib/gcloud.py", line 132, in <module>
#     main()
#   File "/opt/koopa/app/google-cloud-sdk/446.0.0/libexec/lib/gcloud.py", line 90, in main
#     from googlecloudsdk.core.util import encoding
#   File "/opt/koopa/app/google-cloud-sdk/446.0.0/libexec/lib/googlecloudsdk/__init__.py", line 23, in <module>
#     from googlecloudsdk.core.util import importing
#   File "/opt/koopa/app/google-cloud-sdk/446.0.0/libexec/lib/googlecloudsdk/core/util/importing.py", line 23, in <module>
#     import imp
# ModuleNotFoundError: No module named 'imp'

main() {
    # """
    # Install Google Cloud SDK.
    # @note Updated 2023-10-02.
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
    koopa_activate_app --build-only 'python3.11'
    app['python']="$(koopa_locate_python311)"
    koopa_assert_is_executable "${app[@]}"
    dict['arch']="$(koopa_arch)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['libexec']="$(koopa_init_dir "${dict['prefix']}/libexec")"
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
    koopa_extract "$(koopa_basename "${dict['url']}")" "${dict['libexec']}"
    (
        koopa_cd "${dict['libexec']}"
        ./install.sh \
            --bash-completion false \
            --install-python false \
            --path-update false \
            --rc-path false \
            --usage-reporting false
    )
    app['gcloud']="${dict['libexec']}/bin/gcloud"
    koopa_assert_is_executable "${app['gcloud']}"
    conf_args=(
        "export CLOUDSDK_PYTHON=${app['python']}"
        'export CLOUDSDK_PYTHON_SITEPACKAGES=0'
        "export PYTHONPATH=${dict['libexec']}/lib"
    )
    dict['conf_string']="$(koopa_print "${conf_args[@]}")"
    koopa_insert_at_line_number \
        --file="${app['gcloud']}" \
        --line-number=2 \
        --string="${dict['conf_string']}"
    (
        koopa_cd "${dict['prefix']}"
        koopa_ln 'libexec/bin' 'bin'
    )
    "${app['gcloud']}" --version
    return 0
}
