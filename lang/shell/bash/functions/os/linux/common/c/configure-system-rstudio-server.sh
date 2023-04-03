#!/usr/bin/env bash

koopa_linux_configure_system_rstudio_server() {
    # """
    # Configure RStudio Server.
    # @note Updated 2023-04-03.
    #
    # @seealso
    # - https://support.posit.co/hc/en-us/articles/
    #     200552316-Configuring-RStudio-Workbench-RStudio-Server
    # """
    local app conf_lines dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A app dict
    app['r']="$(koopa_locate_system_r --realpath)"
    app['rscript']="$(koopa_locate_system_rscript)"
    app['rstudio_server']="$(koopa_linux_locate_rstudio_server)"
    [[ -x "${app['r']}" ]] || return 1
    [[ -x "${app['rscript']}" ]] || return 1
    [[ -x "${app['rstudio_server']}" ]] || return 1
    dict['name']='rstudio-server'
    koopa_alert_configure_start "${dict['name']}" "${app['rstudio_server']}"
    dict['ld_library_path']="$( \
        "${app['rscript']}" -e \
            'cat(Sys.getenv("LD_LIBRARY_PATH"), sep = "\n")' \
    )"
    [[ -n "${dict['ld_library_path']}" ]] || return 1
    conf_lines=()
    if koopa_is_root
    then
        conf_lines+=(
            'auth-minimum-user-id=0'
            'auth-none=1'
        )
    fi
    conf_lines+=(
        "rsession-ld-library-path=${dict['ld_library_path']}"
        "rsession-which-r=${app['r']}"
    )
    dict['conf_string']="$(koopa_print "${conf_lines[@]}")"
    dict['conf_file']='/etc/rstudio/rserver.conf'
    koopa_alert_info "Modifying '${dict['conf_file']}'."
    koopa_sudo_write_string \
        --file="${dict['conf_file']}" \
        --string="${dict['conf_string']}"
    koopa_alert_configure_success "${dict['name']}" "${app['rstudio_server']}"
    return 0
}
