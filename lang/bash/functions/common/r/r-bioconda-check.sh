#!/usr/bin/env bash

koopa_r_bioconda_check() {
    # """
    # Acid Genomics Bioconda recipe 'R CMD check' workflow.
    # @note Updated 2023-09-15.
    #
    # To test against stable code, use 'archive/HEAD.tar.gz'.
    #
    # @examples
    # koopa_r_bioconda_check 'AcidGenomes' 'pipette'
    # """
    local -A dict
    koopa_assert_has_args "$#"
    dict['tmp_dir']="$(koopa_tmp_dir)"
    dict['conda_cache_prefix']="$(koopa_init_dir "${dict['tmp_dir']}/conda")"
    export CONDA_PKGS_DIRS="${dict['conda_cache_prefix']}"
    for pkg in "$@"
    do
        local -A dict2
        dict2['pkg']="$pkg"
        dict2['pkg2']="r-$(koopa_lowercase "${dict2['pkg']}")"
        dict2['tmp_dir']="$( \
            koopa_init_dir "${dict['tmp_dir']}/${dict2['pkg2']}" \
        )"
        dict2['tarball']="https://github.com/acidgenomics/\
r-${dict2['pkg2']}/archive/refs/heads/develop.tar.gz"
        dict2['conda_prefix']="${dict2['tmp_dir']}/conda"
        dict2['tarball']="https://github.com/acidgenomics/${dict2['pkg2']}/\
archive/refs/heads/develop.tar.gz"
        dict2['rscript']="${dict2['tmp_dir']}/check.R"
        read -r -d '' "dict2[rscript_string]" << END || true
pkgbuild::check_build_tools(debug = TRUE)
install.packages(
    pkgs = c("AcidDevTools", "AcidTest"),
    repos = c(
        "https://r.acidgenomics.com",
        BiocManager::repositories()
    ),
    dependencies = FALSE
)
AcidDevTools::check("src")
END
        koopa_write_string \
            --file="${dict2['rscript']}" \
            --string="${dict2['rscript_string']}"
        koopa_alert "Checking '${dict2['pkg']}' in '${dict2['tmp_dir']}'."
        (
            local -A app2
            local -a conda_deps
            koopa_cd "${dict2['tmp_dir']}"
            conda_deps=(
                'r-biocmanager'
                'r-desc'
                'r-goalie'
                'r-knitr'
                'r-rcmdcheck'
                'r-rmarkdown'
                'r-testthat'
                'r-urlchecker'
                "${dict2['pkg2']}"
            )
            koopa_conda_create_env \
                --prefix="${dict2['conda_prefix']}" \
                "${conda_deps[@]}"
            app2['rscript']="${dict2['conda_prefix']}/bin/Rscript"
            koopa_assert_is_executable "${app2[@]}"
            koopa_download "${dict2['tarball']}"
            koopa_extract "$(koopa_basename "${dict2['tarball']}")" 'src'
            koopa_conda_activate_env "${dict2['conda_prefix']}"
            "${app2['rscript']}" "${dict2['rscript']}"
            koopa_conda_deactivate
        )
        koopa_rm "${dict2['tmp_dir']}"
    done
    koopa_rm "${dict['tmp_dir']}"
    return 0
}
