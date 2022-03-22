#!/usr/bin/env bash

linux_install_bcbio_nextgen() { # {{{1
    # """
    # Install bcbio-nextgen.
    # @note Updated 2022-03-22.
    #
    # Consider just installing RNA-seq and not variant calling by default,
    # to speed up the installation.
    #
    # Consider using '--revision REVISION' for a pinned version install.
    #
    # @seealso
    # - bcbio_nextgen.py upgrade --help
    # - https://bcbio-nextgen.readthedocs.io/en/latest/contents/
    #     installation.html
    # - samtools install issue (libcrypto.so.1.0.0):
    #   - https://github.com/bcbio/bcbio-nextgen/issues/3632
    #   - https://github.com/bcbio/bcbio-nextgen/issues/3557
    #   - https://github.com/bcbio/bcbio-nextgen/issues/3318
    #   - https://github.com/PacificBiosciences/pbbioconda/issues/85
    #   - https://github.com/bioconda/bioconda-recipes/issues/13958
    # """
    local app dict install_args
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [python]="$(koopa_locate_python)"
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
    koopa_alert_coffee_time
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_mkdir "${dict[prefix]}"
    install_args=(
        "${dict[install_dir]}"
        # > '--datatarget' 'variation'
        '--datatarget' 'rnaseq'
        '--isolate'
        '--mamba'
        '--nodata'
        '--tooldir' "${dict[tools_dir]}"
        '--upgrade' "${dict[upgrade]}"
    )
    koopa_dl 'Install args' "${install_args[*]}"
    "${app[python]}" "${dict[file]}" "${install_args[@]}"
    # Clean up conda packages inside Docker image.
    if koopa_is_docker
    then
        app[conda]="${dict[install_dir]}/anaconda/bin/conda"
        koopa_assert_is_installed "${app[conda]}"
        "${app[conda]}" clean --yes --tarballs
    fi
    return 0
}
