#!/usr/bin/env bash

install_from_conda() {
    koopa_install_conda_package
    return 0
}

install_from_source() {
    # """
    # Install Google Cloud SDK.
    # @note Updated 2025-11-20.
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
    koopa_activate_app --build-only 'python3.13'
    app['python']="$(koopa_locate_python313)"
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
    dict['libexec']="$(koopa_init_dir "${dict['prefix']}/libexec")"
    dict['gcloud_libexec']="$(koopa_init_dir "${dict['libexec']}/gcloud")"
    dict['python_libexec']="$(koopa_init_dir "${dict['libexec']}/python")"
    koopa_python_create_venv \
        --prefix="${dict['python_libexec']}" \
        --python="${app['python']}"
    app['venv_python']="${dict['python_libexec']}/bin/\
$(koopa_basename "${app['python']}")"
    koopa_assert_is_executable "${app['venv_python']}"
    "${app['venv_python']}" -m pip install crcmod
    dict['url']="https://dl.google.com/dl/cloudsdk/channels/rapid/\
downloads/google-cloud-cli-${dict['version']}-${dict['os']}-\
${dict['arch2']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract \
        "$(koopa_basename "${dict['url']}")" "${dict['gcloud_libexec']}"
    (
        koopa_cd "${dict['gcloud_libexec']}"
        ./install.sh \
            --bash-completion false \
            --install-python false \
            --path-update false \
            --rc-path false \
            --usage-reporting false
    )
    app['gcloud']="${dict['gcloud_libexec']}/bin/gcloud"
    app['gsutil']="${dict['gcloud_libexec']}/bin/gsutil"
    koopa_assert_is_executable \
        "${app['gcloud']}" \
        "${app['gsutil']}"
    conf_args=(
        # > "export CLOUDSDK_GSUTIL_PYTHON=${app['venv_python']}"
        "export CLOUDSDK_PYTHON=${app['venv_python']}"
        'export CLOUDSDK_PYTHON_SITEPACKAGES=1'
        "export PYTHONPATH=${dict['libexec']}/lib"
        'unset -v PYTHONSAFEPATH'
    )
    dict['conf_string']="$(koopa_print "${conf_args[@]}")"
    koopa_insert_at_line_number \
        --file="${app['gcloud']}" \
        --line-number=2 \
        --string="${dict['conf_string']}"
    koopa_insert_at_line_number \
        --file="${app['gsutil']}" \
        --line-number=2 \
        --string="${dict['conf_string']}"
    (
        koopa_cd "${dict['prefix']}"
        koopa_ln 'libexec/gcloud/bin' 'bin'
    )
    "${app['gcloud']}" --version
    "${app['gsutil']}" version -l
    return 0
}

main() {
    install_from_source
    return 0
}
