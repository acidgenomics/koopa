#!/usr/bin/env bash

koopa::install_aspera_connect() {
    # """
    # Install Aspera Connect.
    # @note Updated 2020-07-04.
    #
    # Aspera Connect:
    # https://downloads.asperasoft.com/en/downloads/8?list
    # - Linux
    #   https://download.asperasoft.com/download/sw/connect/3.9.9/
    #       ibm-aspera-connect-3.9.9.177872-linux-g2.12-64.tar.gz
    # - macOS
    #   https://download.asperasoft.com/download/sw/connect/3.9.9/
    #       IBMAsperaConnectInstaller-3.9.9.177872.dmg
    #
    # Aspera CLI:
    # https://downloads.asperasoft.com/en/downloads/62
    # - macOS
    #   https://download.asperasoft.com/download/sw/cli/3.9.6/
    #       ibm-aspera-cli-3.9.6.1467.159c5b1-mac-10.11-64-release.sh
    # - Linux
    #   https://download.asperasoft.com/download/sw/cli/3.9.6/
    #       ibm-aspera-cli-3.9.6.1467.159c5b1-linux-64-release.sh
    # """
    local aspera_dir aspera_user file name name_fancy prefix script \
        script_target tmp_dir url version version_full
    koopa::assert_has_no_args "$#"
    koopa::assert_has_no_envs
    name='aspera-connect'
    version_full="$(koopa::variable "$name")"
    # Standardize version as MAJOR.MINOR.PATCH only.
    version="$(koopa::major_minor_patch_version "$version_full")"
    aspera_dir="$(koopa::aspera_prefix)"
    prefix="${aspera_dir}/${version}"
    koopa::exit_if_dir "$prefix"
    name_fancy='Aspera Connect'
    koopa::install_start "$name_fancy" "$version" "$prefix"
    koopa::mkdir "$aspera_dir"
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        file="ibm-${name}-${version_full}-linux-g2.12-64.tar.gz"
        # Note that this step can fail on servers requiring TLS 1.2+, as the
        # IBM Aspera server is currently using TLS 1.1.
        url="http://download.asperasoft.com/download/sw/connect/\
${version}/${file}"
        koopa::download "$url"
        koopa::extract "$file"
        script="${file//.tar.gz/.sh}"
        "./${script}"
        # Target is currently hard-coded in IBM Aspera install script.
        aspera_user="${HOME}/.aspera"
        script_target="${aspera_user}/connect"
        koopa::assert_is_dir "$script_target"
        # Fix annoying sticky bit on log directory.
        # > chmod 2775 "${script_target}/var/log"
        # Move and enable for all users on Linux.
        if [[ "$prefix" != "$script_target" ]]
        then
            koopa::cp "$script_target" "$prefix"
            koopa::rm "$script_target" "$aspera_user"
        fi
        koopa::assert_is_file "${prefix}/bin/ascp"
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    (
        koopa::cd "$aspera_dir"
        koopa::sys_ln "$version" "latest"
    )
    koopa::sys_set_permissions -r "$aspera_dir"
    koopa::install_success "$name_fancy"
    return 0
}

