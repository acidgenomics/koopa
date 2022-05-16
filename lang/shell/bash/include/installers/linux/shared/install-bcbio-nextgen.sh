#!/usr/bin/env bash

main() {
    # """
    # Install bcbio-nextgen.
    # @note Updated 2022-03-23.
    #
    # Consider just installing RNA-seq and not variant calling by default,
    # to speed up the installation.
    #
    # STAR isn't working reliably in 1.2.9 due to stdin handoff to samtools
    # sort. HISAT2 does not have this problem.
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
    dict[file]='bcbio_nextgen_install.py'
    dict[url]="https://raw.github.com/bcbio/bcbio-nextgen/master/\
scripts/${dict[file]}"
    koopa_alert_coffee_time
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_mkdir "${dict[prefix]}"
    install_args=(
        "${dict[install_dir]}"
        '--datatarget' 'rnaseq'
        '--isolate'
        '--mamba'
        '--nodata'
        '--tooldir' "${dict[tools_dir]}"
        '--upgrade' 'stable'
    )
    koopa_dl 'Install args' "${install_args[*]}"
    "${app[python]}" "${dict[file]}" "${install_args[@]}"
    # Version-specific hotfixes.
    case "${dict[version]}" in
        '1.2.9')
            koopa_alert_info 'Fixing bcftools and samtools.'
            app[mamba]="${dict[install_dir]}/anaconda/bin/mamba"
            "${app[mamba]}" install --yes \
                --name 'base' \
                'bcftools==1.15' \
                'samtools==1.15'
            # bcftools / samtools (htslib) are also currently messed up
            # in these other conda environments:
            # > "${app[mamba]}" install --yes \
            # >     --name 'bwakit' \
            # >     'samtools==1.15'
            # > "${app[mamba]}" install --yes \
            # >     --name 'htslib1.12_py3.9' \
            # >     'samtools==1.15'
            # > "${app[mamba]}" install --yes \
            # >     --name 'python2' \
            # >     'bcftools==1.15' 'samtools==1.15'
            # > "${app[mamba]}" install --yes \
            # >     --name 'python3.6' \
            # >     'samtools==1.15'
            ;;
    esac
    if koopa_is_docker
    then
        app[conda]="${dict[install_dir]}/anaconda/bin/conda"
        koopa_assert_is_installed "${app[conda]}"
        "${app[conda]}" clean --yes --tarballs
    fi
    return 0
}
