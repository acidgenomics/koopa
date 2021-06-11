#!/usr/bin/env bash

koopa::linux_install_bcbio() { # {{{1
    koopa::install_app \
        --name='bcbio' \
        --name-fancy='bcbio-nextgen' \
        --no-link \
        --platform='linux' \
        --version="$(koopa::current_bcbio_version)" \
        "$@"
}

koopa:::linux_install_bcbio() { # {{{1
    # """
    # Install bcbio-nextgen.
    # @note Updated 2021-05-23.
    #
    # Consider just installing RNA-seq and not variant calling by default,
    # to speed up the installation.
    # """
    local conda file install_dir prefix python tools_dir upgrade url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    python="$(koopa::locate_python)"
    koopa::assert_is_installed "$python"
    koopa::alert_coffee_time
    install_dir="${prefix}/install"
    tools_dir="${prefix}/tools"
    case "$version" in
        development)
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
        koopa::assert_is_file "$conda"
        "$conda" clean --yes --tarballs
    fi
    return 0
}

koopa::linux_uninstall_bcbio() { # {{{1
    # """
    # Uninstall bcbio-nextgen.
    # @note Updated 2021-06-11.
    # """
    koopa::stop 'FIXME'
    # Need to prompt the user about this.
}

koopa::linux_update_bcbio() { # {{{1
    # """
    # Update bcbio-nextgen.
    # @note Updated 2021-06-11.
    # """
    local bcbio cores name_fancy tee
    koopa::assert_has_no_args "$#"
    koopa::assert_has_no_envs
    bcbio='bcbio_nextgen.py'
    koopa::assert_is_installed "$bcbio"
    bcbio="$(koopa::which_realpath "$bcbio")"
    name_fancy='bcbio-nextgen'
    koopa::update_start "$name_fancy"
    koopa::dl 'bcbio' "$bcbio"
    cores="$(koopa::cpu_count)"
    tee="$(koopa::locate_tee)"
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        "$bcbio" upgrade \
            --cores="$cores" \
            --data \
            --tools \
            --upgrade='stable'
    ) 2>&1 | "$tee" "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    koopa::update_success "$name_fancy"
    return 0
}
