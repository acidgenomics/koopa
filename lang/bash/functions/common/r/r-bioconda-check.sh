#!/usr/bin/env bash

# FIXME Need to create bioconda recipe in temporary location.
# FIXME Consider installing devtools into recipe first.
# FIXME Need to locate Rscript there.

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
    local -A app
    koopa_assert_has_args "$#"
    app['cat']="$(koopa_locate_cat --allow-system)"
    app['conda']="$(koopa_locate_conda)"
    koopa_assert_is_executable "${app[@]}"
    for pkg in "$@"
    do
        local -A dict
        dict['pkg']="$pkg"
        dict['pkg2']="r-$(koopa_lowercase "${dict['pkg']}")"
        dict['tmp_dir']="$(koopa_tmp_dir)"
        dict['tarball']="https://github.com/acidgenomics/\
r-${dict['pkg2']}/archive/refs/heads/develop.tar.gz"
        dict['conda_name']="${dict['pkg2']}"
        dict['conda_prefix']="$(koopa_init_dir "${dict['tmp_dir']}/conda")"
        "${app['conda']}" create \
            --prefix="${dict['conda_prefix']}" \
            'r-biocmanager' \
            'r-desc' \
            'r-goalie' \
            'r-knitr' \
            'r-rcmdcheck' \
            'r-rmarkdown' \
            'r-testthat' \
            'r-urlchecker' \
            "${dict['conda_name']}"
        app['r']="${dict['conda_prefix']}/bin/R"
        app['rscript']="${dict['conda_prefix']}/bin/Rscript"
        koopa_assert_is_executable "${app[@]}"
        dict['rscript']='check.R'
        dict['tarball']="https://github.com/acidgenomics/${dict['pkg2']}/\
archive/refs/heads/develop.tar.gz"
        koopa_alert "Checking '${dict['pkg']}' package in '${dict['tmp_dir']}'."
        (
            koopa_cd "${dict['tmp_dir']}"
            koopa_download "${dict['tarball']}"
            koopa_extract "$(koopa_basename "${dict['tarball']}")" 'src'
            # FIXME Use our string writer instead.
            "${app['cat']}" << END > "${dict['rscript']}"
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
            "${app['rscript']}" "${dict['rscript']}"
        )
        koopa_rm "${dict['tmp_dir']}"
    done
    return 0
}
