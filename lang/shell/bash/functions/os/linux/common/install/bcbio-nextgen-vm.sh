#!/usr/bin/env bash

# FIXME This is failing due to incompatible Python...conda?

koopa::linux_install_bcbio_nextgen_vm() { # {{{1
    koopa::install_app \
        --name='bcbio-nextgen-vm' \
        --no-link \
        --platform='linux' \
        "$@"
}

# NOTE ARM is not yet supported.
koopa:::linux_install_bcbio_nextgen_vm() { # {{{1
    # """
    # Install bcbio-nextgen-vm.
    # @note Updated 2021-06-11.
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
    local arch conda file prefix url
    koopa::assert_has_no_envs
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    arch="$(koopa::arch)"
    case "$arch" in
        x86_64)
            ;;
        *)
            koopa::stop "Architecture not supported: '${arch}'."
            ;;
    esac
    file='Miniconda3-py37_4.9.2-Linux-x86_64.sh'
    url="https://repo.anaconda.com/miniconda/${file}"
    koopa::download "$url"
    bash "$file" -b -p "${prefix}/anaconda"
    conda="${prefix}/anaconda/bin/conda"
    koopa::assert_is_executable "$conda"
    "$conda" install --yes \
        --channel='bioconda' \
        --channel='conda-forge' \
        --override-channels \
        "bcbio-nextgen-vm=${version}"
    if ! koopa::str_match "$(groups)" 'docker'
    then
        sudo groupadd 'docker'
        sudo service docker restart
        sudo gpasswd -a "$(whoami)" 'docker'
        newgrp 'docker'
    fi
    return 0
}

koopa::linux_uninstall_bcbio_nextgen_vm() { # {{{1
    # """
    # Uninstall bcbio-nextgen-vm.
    # @note Updated 2021-06-11.
    # """
    koopa::uninstall_app \
        --name='bcbio-nextgen-vm' \
        --no-link \
        "$@"
}
