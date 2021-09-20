#!/usr/bin/env bash

koopa::linux_install_bcbio_nextgen() { # {{{1
    koopa:::install_app \
        --name='bcbio-nextgen' \
        --no-link \
        --platform='linux' \
        --version="$(koopa::current_bcbio_nextgen_version)" \
        "$@"
}

koopa:::linux_install_bcbio_nextgen() { # {{{1
    # """
    # Install bcbio-nextgen.
    # @note Updated 2021-06-11.
    #
    # Consider just installing RNA-seq and not variant calling by default,
    # to speed up the installation.
    # """
    local conda file install_dir prefix python
    local tools_dir upgrade url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    python="$(koopa::locate_python)"
    koopa::alert_coffee_time
    install_dir="${prefix}/install"
    tools_dir="${prefix}/tools"
    case "$version" in
        'development')
            upgrade='development'
            ;;
        *)
            upgrade='stable'
            ;;
    esac
    file='bcbio_nextgen_install.py'
    url="https://raw.github.com/bcbio/bcbio-nextgen/master/scripts/${file}"
    koopa::download "$url"
    koopa::mkdir "$prefix"
    "$python" \
        "$file" \
        "$install_dir" \
        --datatarget='rnaseq' \
        --datatarget='variation' \
        --isolate \
        --nodata \
        --tooldir="$tools_dir" \
        --upgrade="$upgrade"
    # Clean up conda packages inside Docker image.
    if koopa::is_docker
    then
        # > conda="${install_dir}/anaconda/bin/conda"
        conda="${tools_dir}/bin/bcbio_conda"
        koopa::assert_is_executable "$conda"
        "$conda" clean --yes --tarballs
    fi
    return 0
}

koopa::linux_uninstall_bcbio() { # {{{1
    # """
    # Uninstall bcbio-nextgen.
    # @note Updated 2021-06-11.
    # """
    koopa:::install_app \
        --name='bcbio-nextgen' \
        --no-link \
        "$@"
}
