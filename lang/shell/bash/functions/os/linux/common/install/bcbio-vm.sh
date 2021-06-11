#!/usr/bin/env bash

# NOTE ARM is not yet support for this.
koopa::linux_install_bcbio_vm() { # {{{1
    # """
    # Install bcbio-vm.
    # @note Updated 2021-05-20.
    # """
    local bin_dir conda file make_bin_dir make_prefix name name_fancy prefix url
    koopa::assert_has_no_envs
    koopa::assert_is_installed 'conda' 'docker'
    name='bcbio-vm'
    name_fancy='bcbio-nextgen-vm'
    version="$(koopa::conda_env_latest_version "$name")"
    prefix="$(koopa::app_prefix)/${version}/${name}"
    if [[ -d "$prefix" ]]
    then
        koopa::alert_note "'${name_fancy}' already installed at '${prefix}'."
        return 0
    fi
    koopa::install_start "$name_fancy" "$prefix"
    # Configure Docker, if necessary.
    if ! koopa::str_match "$(groups)" 'docker'
    then
        sudo groupadd 'docker'
        sudo service docker restart
        sudo gpasswd -a "$(whoami)" 'docker'
        newgrp 'docker'
    fi
    # Download and install Conda.
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        file='Miniconda3-latest-Linux-x86_64.sh'
        url="https://repo.continuum.io/miniconda/${file}"
        koopa::download "$url"
        bash "$file" -b -p "${prefix}/anaconda"
    )
    koopa::rm "$tmp_dir"
    # Ready to install bcbio-vm.
    bin_dir="${prefix}/anaconda/bin"
    conda="${bin_dir}/conda"
    "$conda" install --yes \
        --channel='conda-forge' \
        --channel='bioconda' \
        'bcbio-nextgen' \
        'bcbio-nextgen-vm'
    # Symlink into '/usr/local'.
    make_prefix="$(koopa::make_prefix)"
    make_bin_dir="${make_prefix}/bin"
    koopa::ln -S "${bin_dir}/bcbio_vm.py" "${make_bin_dir}/bcbio_vm.py"
    koopa::chgrp -S docker "${make_bin_dir}/bcbio_vm.py"
    koopa::chmod -S g+s "${make_bin_dir}/bcbio_vm.py"
    # Install pinned bcbio-nextgen v1.2.4:
    # > data_dir="${prefix}/v1.2.4"
    # > image='quay.io/bcbio/bcbio-vc:1.2.4-517bb34'
    # Install latest version of bcbio-nextgen:
    # > data_dir="${prefix}/latest"
    # > image='quay.io/bcbio/bcbio-vc:latest'
    # > "${bin_dir}/bcbio_vm.py" --datadir="$data_dir" saveconfig
    # > "${bin_dir}/bcbio_vm.py" install --tools --image "$image"
    koopa::link_into_opt "$prefix" "$name"
    koopa::install_success "$name_fancy"
    return 0
}

koopa::linux_install_bcbio_vm() { # {{{1
    # """
    # Uninstall bcbio-vm.
    # @note Updated 2021-06-11.
    # """
    koopa::stop 'FIXME'
}
