#!/usr/bin/env bash

main() {
    # """
    # Install bcbio-nextgen-vm.
    # @note Updated 2022-07-14.
    #
    # Install pinned bcbio-nextgen v1.2.4:
    # > data_dir="${prefix}/v1.2.4"
    # > image='quay.io/bcbio/bcbio-vc:1.2.4-517bb34'
    #
    # Install latest version of bcbio-nextgen:
    # > data_dir="${prefix}/latest"
    # > image='quay.io/bcbio/bcbio-vc:latest'
    # > "${bin_dir}/bcbio_vm.py" --datadir="$data_dir" saveconfig
    # > "${bin_dir}/bcbio_vm.py" install --tools --image "$image"
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [bash]="$(koopa_locate_bash)"
    )
    [[ -x "${app[bash]}" ]] || return 1
    declare -A dict=(
        [arch]="$(koopa_arch)"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    # ARM is not yet supported. Check for Intel x86.
    case "${dict[arch]}" in
        'x86_64')
            ;;
        *)
            koopa_stop "Architecture not supported: '${dict[arch]}'."
            ;;
    esac
    # Install is failing latest version of Miniconda installer, so pin
    # specifically to this legacy version instead.
    dict[script]='Miniconda3-py37_4.9.2-Linux-x86_64.sh'
    dict[url]="https://repo.anaconda.com/miniconda/${dict[script]}"
    koopa_download "${dict[url]}" "${dict[script]}"
    "${app[bash]}" "$script" -b -p "${dict[prefix]}/anaconda"
    app[conda]="${dict[prefix]}/anaconda/bin/conda"
    koopa_assert_is_executable "${app[conda]}"
    "${app[conda]}" install --yes \
        --channel='bioconda' \
        --channel='conda-forge' \
        --override-channels \
        "bcbio-nextgen-vm=${dict[version]}"
    return 0
}
