#!/usr/bin/env bash

koopa:::linux_install_bcbio_nextgen() { # {{{1
    # """
    # Install bcbio-nextgen.
    # @note Updated 2022-01-31.
    #
    # Consider just installing RNA-seq and not variant calling by default,
    # to speed up the installation.
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [python]="$(koopa::locate_python)"
    )
    declare -A dict=(
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[install_dir]="${dict[prefix]}/install"
    dict[tools_dir]="${dict[prefix]}/tools"
    case "${dict[version]}" in
        'development')
            dict[upgrade]='development'
            ;;
        *)
            dict[upgrade]='stable'
            ;;
    esac
    dict[file]='bcbio_nextgen_install.py'
    dict[url]="https://raw.github.com/bcbio/bcbio-nextgen/master/\
scripts/${dict[file]}"
    koopa::alert_coffee_time
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::mkdir "${dict[prefix]}"
    "${app[python]}" \
        "${dict[file]}" \
        "${dict[install_dir]}" \
        --datatarget='rnaseq' \
        --datatarget='variation' \
        --isolate \
        --nodata \
        --tooldir="${dict[tools_dir]}" \
        --upgrade="${dict[upgrade]}"
    # Clean up conda packages inside Docker image.
    if koopa::is_docker
    then
        # > app[conda]="${dict[install_dir]}/anaconda/bin/conda"
        app[conda]="${dict[tools_dir]}/bin/bcbio_conda"
        koopa::assert_is_installed "${app[conda]}"
        "${app[conda]}" clean --yes --tarballs
    fi
    return 0
}
