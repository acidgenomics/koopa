#!/usr/bin/env bash

main() {
    # """
    # Install bcbio-nextgen.
    # @note Updated 2022-10-05.
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
    koopa_activate_app --build-only 'bzip2'
    declare -A app
    app['python']="$(koopa_locate_python311 --realpath)"
    [[ -x "${app['python']}" ]] || return 1
    declare -A dict=(
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['install_dir']="${dict['prefix']}/libexec"
    dict['tools_dir']="${dict['prefix']}"
    dict['file']='bcbio_nextgen_install.py'
    dict['url']="https://raw.github.com/bcbio/bcbio-nextgen/master/\
scripts/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_mkdir "${dict['prefix']}"
    install_args=(
        "${dict['install_dir']}"
        '--datatarget' 'rnaseq'
        '--isolate'
        '--mamba'
        '--nodata'
        '--tooldir' "${dict['tools_dir']}"
        '--upgrade' 'stable'
    )
    koopa_activate_ca_certificates
    koopa_print_env
    koopa_dl 'Install args' "${install_args[*]}"
    "${app['python']}" "${dict['file']}" "${install_args[@]}"
    # Version-specific hotfixes.
    # > case "${dict['version']}" in
    # >     '1.2.9')
    # >         koopa_alert_info 'Fixing bcftools and samtools.'
    # >         app['mamba']="${dict['install_dir']}/anaconda/bin/mamba"
    # >         "${app['mamba']}" install --yes \
    # >             --name 'base' \
    # >             'bcftools==1.15' \
    # >             'samtools==1.15'
    # >         # bcftools / samtools (htslib) are also currently messed up
    # >         # in these other conda environments:
    # >         # > "${app['mamba']}" install --yes \
    # >         # >     --name 'bwakit' \
    # >         # >     'samtools==1.15'
    # >         # > "${app['mamba']}" install --yes \
    # >         # >     --name 'htslib1.12_py3.9' \
    # >         # >     'samtools==1.15'
    # >         # > "${app['mamba']}" install --yes \
    # >         # >     --name 'python2' \
    # >         # >     'bcftools==1.15' 'samtools==1.15'
    # >         # > "${app['mamba']}" install --yes \
    # >         # >     --name 'python3.6' \
    # >         # >     'samtools==1.15'
    # >         ;;
    # > esac
    app['conda']="${dict['install_dir']}/anaconda/bin/conda"
    koopa_assert_is_installed "${app['conda']}"
    "${app['conda']}" clean --yes --tarballs
    return 0
}
