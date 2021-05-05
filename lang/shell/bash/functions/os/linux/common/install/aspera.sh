#!/usr/bin/env bash

# FIXME This needs to call 'install_linux_app'.
# FIXME NEED TO IMPROVE THE VERSION HANDLING.

# Current Linux version:
# https://d3gcli72yxqn2z.cloudfront.net/connect_latest/v4/bin/ibm-aspera-connect-3.11.2.63-linux-g2.12-64.tar.gz

# NOTE Not yet supported for ARM correct?
koopa::linux_install_aspera_connect() { # {{{1
    # """
    # Install Aspera Connect.
    # @note Updated 2020-11-12.
    #
    # Use Homebrew Cask to install on macOS instead.
    #
    # @seealso
    # - https://www.ibm.com/aspera/connect/
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
    [[ -d "$prefix" ]] && return 0
    name_fancy='Aspera Connect'
    koopa::install_start "$name_fancy" "$version" "$prefix"
    koopa::mkdir "$aspera_dir"
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        file="ibm-aspera-connect-${version_full}-linux-g2.12-64.tar.gz"
        url="https://ak-delivery04-mul.dhe.ibm.com/sar/CMA/OSA/097io/0/${file}"
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
        koopa::sys_ln "$version" 'latest'
    )
    koopa::sys_set_permissions -r "$aspera_dir"
    koopa::install_success "$name_fancy"
    return 0
}

